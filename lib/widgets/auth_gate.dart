import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_restock/screens/auth/sign_in_screen.dart';
import 'package:tech_restock/screens/shell/main_shell.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/widgets/brand_logo.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';

/// Restores Firebase session on launch and switches between sign-in and main app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GradientScaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandLogo(size: 52, borderRadius: 14),
                  SizedBox(height: 24),
                  CircularProgressIndicator(color: AppColors.teal),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainShell();
        }

        return const SignInScreen();
      },
    );
  }
}
