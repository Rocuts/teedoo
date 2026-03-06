import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import 'invoice_model.dart';

/// Helper extensions for [InvoiceStatus] display properties.
extension InvoiceStatusX on InvoiceStatus {
  /// Label en español para mostrar en la UI.
  String get label => switch (this) {
        InvoiceStatus.draft => 'Borrador',
        InvoiceStatus.pendingReview => 'Pendiente revisión',
        InvoiceStatus.readyToSend => 'Lista para envío',
        InvoiceStatus.sent => 'Enviada',
        InvoiceStatus.accepted => 'Aceptada',
        InvoiceStatus.rejected => 'Rechazada',
        InvoiceStatus.cancelled => 'Cancelada',
      };

  /// Color principal del estado.
  Color get color => switch (this) {
        InvoiceStatus.draft => AppColorsTheme.dark.textTertiary,
        InvoiceStatus.pendingReview => AppColorsTheme.dark.statusWarning,
        InvoiceStatus.readyToSend => AppColorsTheme.dark.accentBlue,
        InvoiceStatus.sent => AppColorsTheme.dark.statusSuccess,
        InvoiceStatus.accepted => AppColorsTheme.dark.statusSuccess,
        InvoiceStatus.rejected => AppColorsTheme.dark.statusError,
        InvoiceStatus.cancelled => AppColorsTheme.dark.textTertiary,
      };

  /// Color de fondo del estado.
  Color get bgColor => switch (this) {
        InvoiceStatus.draft => AppColorsTheme.dark.statusInfoBg,
        InvoiceStatus.pendingReview => AppColorsTheme.dark.statusWarningBg,
        InvoiceStatus.readyToSend => AppColorsTheme.dark.accentBlueSubtle,
        InvoiceStatus.sent => AppColorsTheme.dark.statusSuccessBg,
        InvoiceStatus.accepted => AppColorsTheme.dark.statusSuccessBg,
        InvoiceStatus.rejected => AppColorsTheme.dark.statusErrorBg,
        InvoiceStatus.cancelled => AppColorsTheme.dark.statusInfoBg,
      };

  /// Icono lucide asociado al estado.
  IconData get icon => switch (this) {
        InvoiceStatus.draft => LucideIcons.filePlus,
        InvoiceStatus.pendingReview => LucideIcons.clock,
        InvoiceStatus.readyToSend => LucideIcons.send,
        InvoiceStatus.sent => LucideIcons.checkCircle,
        InvoiceStatus.accepted => LucideIcons.checkCircle2,
        InvoiceStatus.rejected => LucideIcons.xCircle,
        InvoiceStatus.cancelled => LucideIcons.ban,
      };

  /// Tipo de badge para el [StatusBadge] widget.
  StatusType get badgeType => switch (this) {
        InvoiceStatus.draft => StatusType.info,
        InvoiceStatus.pendingReview => StatusType.warning,
        InvoiceStatus.readyToSend => StatusType.info,
        InvoiceStatus.sent => StatusType.success,
        InvoiceStatus.accepted => StatusType.success,
        InvoiceStatus.rejected => StatusType.error,
        InvoiceStatus.cancelled => StatusType.info,
      };
}

/// Helper extensions for [ComplianceStatus] display properties.
extension ComplianceStatusX on ComplianceStatus {
  /// Label en español para mostrar en la UI.
  String get label => switch (this) {
        ComplianceStatus.pass => 'Pass',
        ComplianceStatus.warnings => 'Warnings',
        ComplianceStatus.fail => 'Fail',
        ComplianceStatus.pending => 'Pending',
      };

  /// Color principal del compliance status.
  Color get color => switch (this) {
        ComplianceStatus.pass => AppColorsTheme.dark.statusSuccess,
        ComplianceStatus.warnings => AppColorsTheme.dark.statusWarning,
        ComplianceStatus.fail => AppColorsTheme.dark.statusError,
        ComplianceStatus.pending => AppColorsTheme.dark.textTertiary,
      };

  /// Icono lucide asociado al compliance status.
  IconData get icon => switch (this) {
        ComplianceStatus.pass => LucideIcons.shieldCheck,
        ComplianceStatus.warnings => LucideIcons.shield,
        ComplianceStatus.fail => LucideIcons.shieldAlert,
        ComplianceStatus.pending => LucideIcons.shieldQuestion,
      };

  /// Tipo de badge para el [StatusBadge] widget.
  StatusType get badgeType => switch (this) {
        ComplianceStatus.pass => StatusType.success,
        ComplianceStatus.warnings => StatusType.warning,
        ComplianceStatus.fail => StatusType.error,
        ComplianceStatus.pending => StatusType.info,
      };
}
