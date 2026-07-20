import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_pandaa/config/legal_urls.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/utils/auth_messages.dart';
import 'package:shop_pandaa/widgets/brand_logo.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/legal_link.dart';
import 'package:shop_pandaa/widgets/underline_field.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _dukaan = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _emailValid = false;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> _createAccount() async {
    final fullName = _name.text.trim();
    final dukaanName = _dukaan.text.trim();
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (fullName.isEmpty || dukaanName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name, dukaan name, email, and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(fullName);

      if (credential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'fullName': fullName,
          'dukaanName': dukaanName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      // Account created & signed in — clear the auth stack so the root
      // AuthGate (now streaming a signed-in user) shows the Home shell.
      Navigator.of(context).popUntil((route) => route.isFirst);
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
    _name.dispose();
    _dukaan.dispose();
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.text),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: BrandLogo(size: 58, borderRadius: 18)),
              const SizedBox(height: 28),
              Text('Sign up', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Register your dukaan to order wholesale stock',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              UnderlineField(
                label: 'Full name',
                controller: _name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              UnderlineField(
                label: 'Dukaan name (store name)',
                controller: _dukaan,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              UnderlineField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                showValidCheck: _emailValid,
                onChanged: (v) {
                  final valid = _emailRegex.hasMatch(v.trim());
                  if (valid != _emailValid) setState(() => _emailValid = valid);
                },
              ),
              const SizedBox(height: 20),
              UnderlineField(
                label: 'Password',
                controller: _password,
                obscureText: true,
                showToggle: true,
              ),
              const SizedBox(height: 20),
              _TermsText(),
              const SizedBox(height: 20),
              AuthButton(
                label: 'Sign Up',
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : _createAccount,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                      children: [
                        TextSpan(
                          text: 'Sign in',
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

class _TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('By continuing you agree to our ', style: base),
        LegalLinkText(
          label: 'Terms of Service',
          url: LegalUrls.termsOfService,
          style: AppTheme.link.copyWith(fontSize: 12),
        ),
        Text(' and ', style: base),
        LegalLinkText(
          label: 'Privacy Policy',
          url: LegalUrls.privacyPolicy,
          style: AppTheme.link.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
