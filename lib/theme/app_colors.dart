import 'package:flutter/material.dart';

/// ThokBazaar palette — a utilitarian, ledger/"khata-book" identity for a B2B
/// wholesale app: deep navy ink, slate secondaries, a warm cream-gray paper
/// canvas, and a mustard-gold accent reserved for balances and highlights.
///
/// Token names are kept stable across the app (e.g. `teal` is the primary
/// brand accent, historically named) so the whole UI re-themes from this one
/// file. ThokBazaar-specific additions (`accent`, `accentSoft`, `credit`,
/// `debit`) power the khata ledger and bulk-pricing surfaces.
abstract final class AppColors {
  // --- Brand accent (deep navy → slate) ---
  /// Primary brand ink — buttons, active states, headings.
  static const teal = Color(0xFF1B3A57);
  static const tealMid = Color(0xFF2C4E6E);

  /// Deepest navy — strong headings / totals on the paper canvas.
  static const tealDark = Color(0xFF12293D);

  /// Navy header band (top bars, home/profile headers).
  static const header = Color(0xFF1B3A57);

  /// Deepest tone kept for shadows.
  static const navy = Color(0xFF0F2233);

  // --- Ledger accent (mustard gold) ---
  /// Signature highlight — outstanding balances, bulk-tier savings, badges.
  static const accent = Color(0xFFD4A017);
  static const accentSoft = Color(0x1AD4A017);

  // --- Khata semantics ---
  /// Credit / you-are-owed / paid (ledger green).
  static const credit = Color(0xFF2E7D5B);

  /// Debit / outstanding udhaar (ledger red — reuse `danger`).
  static const debit = Color(0xFFC0392B);

  // --- Canvas (warm cream-gray "paper", top → bottom) ---
  static const bgTop = Color(0xFFFBFBF9);
  static const bgMid = Color(0xFFF4F4F2);
  static const bgSoft = Color(0xFFEDEDE9);
  static const bgBottom = Color(0xFFF7F7F5);

  // --- Surfaces & text ---
  static const surface = Colors.white;
  static const text = Color(0xFF1F2933);
  static const textMuted = Color(0xFF52606D);
  static const textLight = Color(0xFF9AA5B1);

  /// Ledger rule-lines / input borders.
  static const borderInput = Color(0xFFDDE1E6);
  static const primarySoft = Color(0x141B3A57);
  static const danger = Color(0xFFC0392B);

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgSoft, bgBottom],
    stops: [0.0, 0.24, 0.62, 1.0],
  );

  /// Restrained navy → slate sweep for primary buttons (business, not flashy).
  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF12293D),
      Color(0xFF1B3A57),
      Color(0xFF2C4E6E),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B3A57), Color(0xFF2C4E6E), Color(0xFF495867)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Soft slate shadow suited to the paper canvas.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1B3A57).withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: const Color(0xFF0F2233).withValues(alpha: 0.20),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
}
