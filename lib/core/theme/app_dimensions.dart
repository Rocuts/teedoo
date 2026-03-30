/// Dimension constants used across the TeeDoo application.
///
/// Centralizes hardcoded layout values to avoid magic numbers.
abstract final class AppDimensions {
  // ── Sidebar ──
  static const double sidebarExpandedWidth = 260;
  static const double sidebarCollapsedWidth = 72;

  // ── Topbar ──
  static const double topbarHeight = 56;

  // ── Padding ──
  static const double cardPadding = 20;
  static const double cardPaddingLarge = 24;
  static const double sectionPadding = 16;
  static const double sectionPaddingSmall = 12;

  // ── Icon Sizes ──
  static const double iconSize = 20;
  static const double iconSizeSmall = 16;
  static const double iconSizeLarge = 24;

  // ── Button / Touch Targets ──
  static const double buttonHeight = 44;
  static const double touchTargetSize = 40;
  static const double collapsedNavItemSize = 44;
  static const double avatarSize = 32;
  static const double logoSize = 32;

  // ── Table ──
  static const double tableCheckboxColumnWidth = 40;
  static const double tableCellPaddingH = 16;
  static const double tableCellPaddingV = 12;

  // ── AI Voice ──
  static const double aiOrbIdle = 64;
  static const double aiOrbActive = 80;
  static const double aiCardWidth = 320;
  static const double aiOrbVisualizerIdle = 40;
  static const double aiOrbVisualizerActive = 60;

  // ── Auth Screens ──
  static const double authCardPadding = 40;
  static const double authIconSize = 52;
  static const double authButtonHeight = 56;
}
