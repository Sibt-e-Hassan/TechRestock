import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_pandaa/services/cart_service.dart';

class CartScope extends StatefulWidget {
  const CartScope({super.key, required this.child});

  final Widget child;

  static CartService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_InheritedCart>();
    assert(scope != null, 'CartScope not found in widget tree');
    return scope!.cart;
  }

  @override
  State<CartScope> createState() => _CartScopeState();
}

class _CartScopeState extends State<CartScope> {
  late final CartService _cart = CartService();
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _cart.bindUser(FirebaseAuth.instance.currentUser?.uid);
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _cart.bindUser(user?.uid);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedCart(
      cart: _cart,
      child: widget.child,
    );
  }
}

class _InheritedCart extends InheritedNotifier<CartService> {
  const _InheritedCart({required CartService cart, required super.child}) : super(notifier: cart);

  CartService get cart => notifier!;
}
