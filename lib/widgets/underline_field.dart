import 'package:flutter/material.dart';
import 'package:shop_pandaa/theme/app_colors.dart';

/// Minimal underlined text field used on the auth screens: a small label above
/// a single underline (no box), with an optional password eye-toggle and an
/// optional green "valid" check (e.g. a well-formed email).
class UnderlineField extends StatefulWidget {
  const UnderlineField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.showToggle = false,
    this.onChanged,
    this.showValidCheck = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool showToggle;
  final ValueChanged<String>? onChanged;

  /// When true, shows a check icon on the right (used for a valid email).
  final bool showValidCheck;
  final TextCapitalization textCapitalization;

  @override
  State<UnderlineField> createState() => _UnderlineFieldState();
}

class _UnderlineFieldState extends State<UnderlineField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    Widget? suffix;
    if (widget.showToggle) {
      suffix = IconButton(
        splashRadius: 20,
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textLight,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    } else if (widget.showValidCheck) {
      suffix = const Icon(Icons.check_circle, size: 20, color: AppColors.credit);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted, fontSize: 13),
        ),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          onChanged: widget.onChanged,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderInput),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.teal, width: 1.6),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderInput),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pill-shaped primary button for the auth screens (matches the reference's
/// rounded CTA), in ThokBazaar's navy gradient.
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
