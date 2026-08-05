import 'package:flutter/material.dart';

/// Static color tokens for Marky's "pitch black luxury knowledge vault" design system.
///
/// All values use full 8-digit hex to satisfy the
/// `use_full_hex_values_for_flutter_colors` lint rule.
abstract final class AppColors {
  // ─── Base & Surfaces ───
  /// True black AMOLED base.
  static const Color base = Color(0xFF000000);

  /// First elevated surface layer.
  static const Color surface1 = Color(0xFF0B0B0D);

  /// Second elevated surface for cards, inputs, overlays.
  static const Color surface2 = Color(0xFF111216);

  /// Third elevated surface for higher emphasis cards/panels.
  static const Color surface3 = Color(0xFF171922);

  // ─── Border & Divider ───
  /// Low-contrast separator stroke.
  static const Color border = Color(0xFF232634);

  // ─── Text ───
  /// Primary text — near-white for maximum legibility.
  static const Color textPrimary = Color(0xFFF5F7FA);

  /// Secondary text — muted but readable.
  static const Color textSecondary = Color(0xFFA7ADBB);

  /// Tertiary text — lowest emphasis, metadata, hints.
  static const Color textTertiary = Color(0xFF73798A);

  // ─── Accents ───
  /// Primary accent — jewel-tone purple.
  static const Color accentPrimary = Color(0xFF7C5CFF);

  /// Secondary accent — cyan highlight.
  static const Color accentSecondary = Color(0xFF35C2FF);

  /// Tertiary accent — warm orange.
  static const Color accentTertiary = Color(0xFFFF8A3D);

  /// Luxe accent — metallic gold for premium moments.
  static const Color accentLuxe = Color(0xFFD6B25E);

  // ─── Functional ───
  /// Success states.
  static const Color success = Color(0xFF35D07F);

  /// Warning states.
  static const Color warning = Color(0xFFFFB84D);

  /// Destructive actions / danger states.
  static const Color danger = Color(0xFFFF5D73);

  // ─── Overlay ───
  /// Semi-black overlay for modals, sheets, and scrims.
  static const Color overlay = Color(0xB3000000);
}
