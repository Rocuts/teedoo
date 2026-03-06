import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/audit_event.dart';

/// Timeline vertical de eventos de auditoría.
///
/// Ref Pencil: Audit screen — Left column timeline card.
class AuditTimeline extends StatelessWidget {
  final List<AuditEvent> events;

  const AuditTimeline({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: GlassCardHeader(
        title: 'Timeline de eventos',
        trailing: Text(
          'Hoy',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.accentBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          children: [
            for (int i = 0; i < events.length; i++)
              _TimelineEvent(
                event: events[i],
                isLast: i == events.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  final AuditEvent event;
  final bool isLast;

  const _TimelineEvent({
    required this.event,
    required this.isLast,
  });

  Color _dotColor(BuildContext context) => switch (event.type) {
        AuditEventType.create => context.colors.accentBlue,
        AuditEventType.complianceCheck => context.colors.aiPurple,
        AuditEventType.send => context.colors.statusSuccess,
        AuditEventType.update => context.colors.statusWarning,
        AuditEventType.export => context.colors.accentTeal,
        AuditEventType.login => context.colors.statusInfo,
        AuditEventType.delete => context.colors.statusError,
      };

  StatusType? get _badgeType => switch (event.type) {
        AuditEventType.create => StatusType.info,
        AuditEventType.complianceCheck => StatusType.warning,
        AuditEventType.send => StatusType.success,
        _ => null,
      };

  String? get _badgeLabel => switch (event.type) {
        AuditEventType.create => 'Info',
        AuditEventType.complianceCheck => 'Warnings',
        AuditEventType.send => 'Enviado',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column (dot + line)
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _dotColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: context.colors.borderSubtle,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (_badgeType != null && _badgeLabel != null) ...[
                        StatusBadge(
                          label: _badgeLabel!,
                          type: _badgeType!,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          _buildSubtext(),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtext() {
    final parts = <String>[];
    if (event.userName != null) parts.add(event.userName!);
    if (event.description != null) parts.add(event.description!);
    parts.add(_formatTime(event.timestamp));
    return parts.join(' \u00b7 ');
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours}h';
    }

    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
