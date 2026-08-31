import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/utils/auth_messages.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/app_card.dart';
import 'package:tech_restock/widgets/brand_header.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';
import 'package:tech_restock/widgets/outlined_field.dart';
import 'package:tech_restock/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _email.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the email for your account.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset link has been sent to your email!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyAuthErrorMessage(e))),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyGenericAuthError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.text,
                ),
              ),
              const BrandHeaderCenter(
                subtitle: 'Enter your account email to receive a reset link.',
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Reset password',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We will email you a secure link to choose a new password.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        OutlinedField(
                          label: 'Email',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: _isLoading ? 'Sending...' : 'Send reset link',
                          onPressed: _isLoading ? () {} : _sendResetLink,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                            child: Text(
                              'Back to sign in',
                              style: AppTheme.link.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.teal),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
