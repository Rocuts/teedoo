import 'package:flutter/animation.dart';

/// Motion tokens — centralized animation constants.
///
/// Principle: motion should communicate state changes, not decorate.
/// Every animation must have a purpose: entrance, feedback, or state transition.
abstract final class AppMotion {
  // ── Durations ──

  /// 100ms — Micro-feedback (button press, toggle)
  static const Duration durationMicro = Duration(milliseconds: 100);

  /// 150ms — Fast transitions (hover states, small reveals)
  static const Duration durationFast = Duration(milliseconds: 150);

  /// 300ms — Standard transitions (panel open, card expand)
  static const Duration durationNormal = Duration(milliseconds: 300);

  /// 500ms — Emphasis transitions (page enter, modal appear)
  static const Duration durationSlow = Duration(milliseconds: 500);

  /// 800ms — Dramatic transitions (onboarding, first-load)
  static const Duration durationDramatic = Duration(milliseconds: 800);

  // ── Curves ──

  /// Standard ease-out for most transitions
  static const Curve curveStandard = Curves.easeOutCubic;

  /// Emphasized spring for attention-grabbing motion
  static const Curve curveEmphasized = Curves.easeOutBack;

  /// Decelerate for entrances
  static const Curve curveDecelerate = Curves.decelerate;

  // ── Scale values ──

  /// Press feedback scale
  static const double scalePressed = 0.97;

  /// Hover subtle scale
  static const double scaleHover = 1.005;

  /// Active highlight scale (voice agent selection)
  static const double scaleActive = 1.02;

  // ── Opacity values ──

  /// Press feedback opacity
  static const double opacityPressed = 0.9;

  // ── Entry animation defaults ──

  /// Standard slide distance for entrance animations
  static const double slideEntryOffset = 0.05;

  /// Stagger delay between sequential items
  static const Duration staggerDelay = Duration(milliseconds: 100);
}
