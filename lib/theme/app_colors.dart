import 'package:flutter/material.dart';

/// TechRestock palette — a modern, sleek tech-hardware B2B aesthetic:
/// Deep Tech Navy, Electric Cyan accents, Slate-Blue surfaces, and crisp 
/// status indicators for wholesale mobile accessories & electronics.
abstract final class AppColors {
  // --- Brand accent (Deep Tech Navy → Electric Cyan) ---
  /// Primary brand ink — buttons, active states, headings.
  static const teal = Color(0xFF0F2537);
  static const tealMid = Color(0xFF1B3B59);

  /// Deepest navy — strong headings / totals on the slate canvas.
  static const tealDark = Color(0xFF0B1B2B);

  /// Header band (top bars, home/profile headers).
  static const header = Color(0xFF0F2537);

  /// Deepest tone kept for shadows.
  static const navy = Color(0xFF081420);

  // --- Tech Accent (Electric Cyan) ---
  /// Signature highlight — wholesale discounts, stock badges, highlights.
  static const accent = Color(0xFF00A8E8);
  static const accentSoft = Color(0x1A00A8E8);

  // --- Ledger semantics ---
  /// Credit / paid (ledger green).
  static const credit = Color(0xFF10B981);

  /// Debit / outstanding balance (ledger red).
  static const debit = Color(0xFFEF4444);

  // --- Canvas (light tech slate) ---
  static const bgTop = Color(0xFFFAFDFE);
  static const bgMid = Color(0xFFF4F7FA);
  static const bgSoft = Color(0xFFEBF1F6);
  static const bgBottom = Color(0xFFE2E9F0);

  // --- Surfaces & text ---
  static const surface = Colors.white;
  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF475569);
  static const textLight = Color(0xFF94A3B8);

  /// Border lines / input borders.
  static const borderInput = Color(0xFFCBD5E1);
  static const primarySoft = Color(0x140F2537);
  static const danger = Color(0xFFEF4444);

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgSoft, bgBottom],
    stops: [0.0, 0.24, 0.62, 1.0],
  );

  /// Deep Tech Navy → Electric Cyan sweep for primary buttons.
  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF0B1B2B),
      Color(0xFF0F2537),
      Color(0xFF1B3B59),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2537), Color(0xFF1B3B59), Color(0xFF00A8E8)],
    stops: [0.0, 0.6, 1.0],
  );

  /// Soft shadow suited to the tech slate canvas.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F2537).withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: const Color(0xFF081420).withValues(alpha: 0.20),
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

