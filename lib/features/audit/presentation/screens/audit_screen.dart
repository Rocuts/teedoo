import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../data/models/audit_event.dart';
import '../widgets/audit_timeline.dart';
import '../widgets/export_center.dart';
import '../widgets/integrity_card.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Pantalla de Evidencias y Auditoría.
///
/// Ref Pencil: Evidencias / Auditoría (UuHcQ) — 1440x900
/// - Topbar con breadcrumbs
/// - Header: título + exportar
/// - Tabs: Log de eventos | Integridad | Exportaciones
/// - Body: 2 columnas (timeline + side cards)
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  int _activeTab = 0;
  final _scrollController = ScrollController();

  static final _mockEvents = [
    AuditEvent(
      id: 'evt-1',
      type: AuditEventType.create,
      title: 'Factura INV-2026-092 creada',
      userId: 'usr-1',
      userName: 'Admin',
      description: 'Hace 14 min',
      timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      relatedEntityId: 'INV-2026-092',
    ),
    AuditEvent(
      id: 'evt-2',
      type: AuditEventType.complianceCheck,
      title: 'Compliance check ejecutado por IA',
      userId: 'system',
      description: 'Score: 78 · Evaluación',
      timestamp: DateTime.now().subtract(const Duration(minutes: 60)),
      relatedEntityId: 'INV-2026-092',
      metadata: {'score': 78},
    ),
    AuditEvent(
      id: 'evt-3',
      type: AuditEventType.send,
      title: 'Factura INV-2026-091 enviada al SII',
      userId: 'usr-2',
      userName: 'María López',
      timestamp: DateTime(2026, 1, 16, 10, 34),
      relatedEntityId: 'INV-2026-091',
    ),
    AuditEvent(
      id: 'evt-4',
      type: AuditEventType.update,
      title: 'Factura INV-2026-090 actualizada',
      userId: 'usr-1',
      userName: 'Admin',
      description: 'Campos de pago modificados',
      timestamp: DateTime(2026, 1, 16, 9, 15),
      relatedEntityId: 'INV-2026-090',
    ),
    AuditEvent(
      id: 'evt-5',
      type: AuditEventType.create,
      title: 'Factura INV-2026-090 creada',
      userId: 'usr-3',
      userName: 'Carlos Ruiz',
      timestamp: DateTime(2026, 1, 15, 16, 20),
      relatedEntityId: 'INV-2026-090',
    ),
  ];

  static const _tabLabels = ['Log de eventos', 'Integridad', 'Exportaciones'];

  void _onTabChanged(int index) {
    if (index == _activeTab) return;
    setState(() => _activeTab = index);
    // Reset scroll position when switching tabs
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Topbar ──
        AppTopbar(
          breadcrumbs: [
            const BreadcrumbItem(label: 'Evidencias'),
            BreadcrumbItem(label: _tabLabels[_activeTab]),
          ],
        ),

        // ── Content ──
        Expanded(
          child: ClipRect(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.contentPaddingH,
                vertical: context.contentPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.s20),

                  // ── Tabs ──
                  _buildTabs(),
                  const SizedBox(height: AppSpacing.s20),

                  // ── Body ──
                  // ValueKey ensures Flutter rebuilds the widget tree on tab change
                  KeyedSubtree(
                    key: ValueKey<int>(_activeTab),
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    return switch (_activeTab) {
      0 => _buildLogTab(),
      1 => const IntegrityCard(),
      2 => const ExportCenter(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLogTab() {
    final isWide = context.isExpanded;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Timeline
          Expanded(child: AuditTimeline(events: _mockEvents)),
          const SizedBox(width: AppSpacing.s20),
          // Right: Side cards
          const SizedBox(
            width: 340,
            child: Column(
              children: [
                IntegrityCard(),
                SizedBox(height: AppSpacing.s20),
                ExportCenter(),
              ],
            ),
          ),
        ],
      );
    }

    // Compact / Medium: stack vertically
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuditTimeline(events: _mockEvents),
        const SizedBox(height: AppSpacing.s20),
        const IntegrityCard(),
        const SizedBox(height: AppSpacing.s20),
        const ExportCenter(),
      ],
    );
  }

  Widget _buildHeader() {
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidencias y Auditoría',
          style: AppTypography.h2.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Trazabilidad completa de operaciones e integridad',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );

    final exportButton = SecondaryButton(
      label: 'Exportar logs',
      icon: LucideIcons.download,
      onPressed: () {
        GlassToast.show(
          context,
          message: 'Preparando archivo de logs seguros (PDF)...',
          type: StatusType.info,
        );
      },
    );

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleColumn,
          const SizedBox(height: AppSpacing.s16),
          exportButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [titleColumn, exportButton],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        for (int i = 0; i < _tabLabels.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          _buildTab(i),
        ],
      ],
    );
  }

  Widget _buildTab(int index) {
    final isActive = _activeTab == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? context.colors.accentBlueSubtle
                : Colors.transparent,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: isActive
                  ? context.colors.accentBlue
                  : context.colors.borderSubtle,
            ),
          ),
          child: Text(
            _tabLabels[index],
            style: AppTypography.bodySmallMedium.copyWith(
              color: isActive
                  ? context.colors.accentBlue
                  : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
