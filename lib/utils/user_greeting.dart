import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Resolves a friendly home-header subtitle from Auth + Firestore `users/{uid}`.
class UserGreeting {
  UserGreeting._();

  static Stream<String> homeSubtitle() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value('Discover markets & shops');
      }

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => 'Hello, ${resolveDisplayName(user, doc.data())}!');
    });
  }

  static String resolveDisplayName(User user, Map<String, dynamic>? data) {
    final fromDoc = (data?['fullName'] as String?)?.trim();
    if (fromDoc != null && fromDoc.isNotEmpty) {
      return fromDoc;
    }

    final fromAuth = user.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) {
      return fromAuth;
    }

    final email = user.email;
    if (email != null && email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) {
        return local;
      }
    }

    return 'there';
  }
}
