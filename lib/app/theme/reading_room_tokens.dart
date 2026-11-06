import 'package:flutter/material.dart';

/// Design tokens for the **Reading Room** theme.
///
/// Reading Room is Marky's visual identity starting with the MVP
/// rewrite: a calm, content-first, library-inspired aesthetic. Warm
/// off-white + deep black, generous whitespace, flat surfaces (no
/// glassmorphism, no elevation shadows), a restrained ink-blue accent.
///
/// Tokens are grouped by semantic role so feature code never hard-codes
/// a hex value. All screens must reference [ReadingRoomColors],
/// [ReadingRoomSpacing], or [ReadingRoomRadii] — never a raw [Color]
/// or magic number.
abstract final class ReadingRoomColors {
  // ─── Light palette ─────────────────────────────────────────────────
  /// Primary page background in light mode — warm off-white, easier on
  /// the eyes than pure `#FFFFFF` during long reading sessions.
  static const Color lightSurface = Color(0xFFFAFAF7);

  /// Cards, sheets, and dialogs sit on this slightly brighter layer to
  /// create hierarchy *without* using an elevation shadow.
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);

  /// Primary text colour — deep black, not pure, preserves the warm
  /// off-white cast.
  static const Color lightInk = Color(0xFF0A0A0A);

  /// Secondary text (metadata, timestamps, hints).
  static const Color lightMuted = Color(0xFF525252);

  /// Border / divider colour. Replaces elevation in this flat theme.
  static const Color lightOutline = Color(0xFFE7E5E0);

  /// Single accent — ink blue, used for interactive primary actions,
  /// focused chips, link text.
  static const Color lightAccent = Color(0xFF1E3A8A);

  /// Destructive action tint (delete, clear).
  static const Color lightDanger = Color(0xFF9F1239);

  // ─── Dark palette ─────────────────────────────────────────────────
  /// Near-black page background — warm black, preserves the library
  /// feel. Pure `#000000` is reserved for OLED mode.
  static const Color darkSurface = Color(0xFF0E0E0C);

  static const Color darkSurfaceRaised = Color(0xFF161614);

  static const Color darkInk = Color(0xFFF5F5F0);

  static const Color darkMuted = Color(0xFFA3A3A0);

  static const Color darkOutline = Color(0xFF2A2A28);

  /// Dark-mode accent — lightened ink blue so it meets contrast on
  /// the warm-black surface.
  static const Color darkAccent = Color(0xFF8AA4DD);

  static const Color darkDanger = Color(0xFFF87171);

  // ─── OLED overrides ─────────────────────────────────────────────────
  /// When OLED-pure-black is enabled, the base surface becomes
  /// `#000000` for the AMOLED save; raised surface and outline shift
  /// accordingly.
  static const Color oledSurface = Color(0xFF000000);
  static const Color oledSurfaceRaised = Color(0xFF0A0A0A);
  static const Color oledOutline = Color(0xFF1A1A1A);
}

/// 8-point spacing grid. Feature code uses named steps, not raw
/// integers, so rhythm stays consistent across every screen.
abstract final class ReadingRoomSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

/// Corner radii, matched to the three surface sizes.
abstract final class ReadingRoomRadii {
  /// Chips, badges, inline pills.
  static const double chip = 4;

  /// Cards, list rows, standard buttons.
  static const double standard = 12;

  /// Bottom sheets, modal cards.
  static const double sheet = 24;
}

/// Animation durations. Reading Room favours restraint — no bouncy
/// springs, no long easings. 200ms is the upper bound.
abstract final class ReadingRoomMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 200);

  static const Curve standardCurve = Curves.easeOut;
}
