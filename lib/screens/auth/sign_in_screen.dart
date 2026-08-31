import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_restock/app.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/utils/auth_messages.dart';
import 'package:tech_restock/widgets/brand_logo.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';
import 'package:tech_restock/widgets/underline_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyAuthErrorMessage(e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyGenericAuthError(e))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(child: BrandLogo(size: 58, borderRadius: 18)),
              const SizedBox(height: 36),
              Text('Log in', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Enter your email and password',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              UnderlineField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 22),
              UnderlineField(
                label: 'Password',
                controller: _password,
                obscureText: true,
                showToggle: true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    ShoppandaApp.forgotPasswordRoute,
                    arguments: _email.text.trim(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('Forgot password?', style: AppTheme.link),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AuthButton(
                label: 'Log In',
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : _signIn,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(ShoppandaApp.createAccountRoute),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
