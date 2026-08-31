import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_restock/data/models.dart';

/// Manages `users/{uid}/cart` and submits inquiries to the `orders` collection.
class CartService extends ChangeNotifier {
  String? _uid;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSub;
  List<CartLineItem> _items = const [];
  bool _isSubmitting = false;

  List<CartLineItem> get items => _items;

  int get itemCount => _items.fold<int>(0, (total, item) => total + item.quantity);

  bool get isEmpty => _items.isEmpty;

  bool get isSubmitting => _isSubmitting;

  void bindUser(String? uid) {
    if (_uid == uid) {
      return;
    }
    _uid = uid;
    _cartSub?.cancel();
    _items = const [];
    notifyListeners();

    if (uid == null) {
      return;
    }

    _cartSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _items = snapshot.docs
                .map((doc) => CartLineItem.fromFirestore(doc.id, doc.data()))
                .toList();
            notifyListeners();
          },
          onError: (Object error, StackTrace stack) {
            debugPrint('Cart stream error: $error');
          },
        );
  }

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('cart');
  }

  /// Adds [quantity] units of [product] to the order sheet. If the product is
  /// already on the sheet, [quantity] is added to the existing amount (bulk
  /// wholesale orders can be large, so we don't cap at 1).
  Future<void> addProduct(ProductItem product, {int quantity = 1}) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('You must be signed in to add items to your order.');
    }
    final addQty = quantity < 1 ? 1 : quantity;

    final ref = _cartRef(uid).doc(product.id);
    final existing = await ref.get();
    final nextQuantity = existing.exists
        ? ((existing.data()?['quantity'] as num?)?.toInt() ?? 0) + addQty
        : addQty;

    await ref.set(
      {
        ...CartLineItem(product: product, quantity: nextQuantity).toFirestorePayload(),
        'quantity': nextQuantity,
        'addedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeItem(String productId) async {
    final uid = _uid;
    if (uid == null) {
      return;
    }
    await _cartRef(uid).doc(productId).delete();
  }

  Future<String> submitInquiry() async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('You must be signed in to send an inquiry.');
    }
    if (_items.isEmpty) {
      throw StateError('Your cart is empty.');
    }
    if (_isSubmitting) {
      throw StateError('Inquiry is already being submitted.');
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      final orderRef = firestore.collection('orders').doc();
      final batch = firestore.batch();

      final orderItems = _items
          .map(
            (line) => {
              ...line.toFirestorePayload(),
              'quantity': line.quantity,
            },
          )
          .toList();

      batch.set(orderRef, {
        'userId': uid,
        'items': orderItems,
        'totalPrice': formatOrderTotal(_items),
        'itemCount': itemCount,
        'status': 'submitted',
        'timestamp': FieldValue.serverTimestamp(),
      });

      for (final line in _items) {
        batch.delete(_cartRef(uid).doc(line.productId));
      }

      await batch.commit();
      return orderRef.id;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  static String formatOrderTotal(List<CartLineItem> items) {
    if (items.isEmpty) {
      return '0 items';
    }

    final count = items.fold<int>(0, (total, line) => total + line.quantity);
    final priceParts = items
        .map(
          (line) => line.quantity > 1
              ? '${line.quantity}× ${line.product.priceLabel}'
              : line.product.priceLabel,
        )
        .toList();

    final summary = priceParts.join(' + ');
    if (summary.length > 120) {
      return '$count items · multiple listings';
    }
    return '$count items · $summary';
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    super.dispose();
  }
}
