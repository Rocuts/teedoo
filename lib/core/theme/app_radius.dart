import 'package:flutter/material.dart';

/// Border radius tokens — enterprise minimal.
///
/// Más afilados que playful, más profesionales.
abstract final class AppRadius {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;

  // ── Specific ──
  static const double button = 8;
  static const double input = 8;
  static const double badge = 5;
  static const double stepperCircle = 14;
  static const double card = 12;

  // ── BorderRadius presets ──
  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius buttonAll = BorderRadius.circular(button);
  static final BorderRadius inputAll = BorderRadius.circular(input);
  static final BorderRadius badgeAll = BorderRadius.circular(badge);
  static final BorderRadius cardAll = BorderRadius.circular(card);
}
