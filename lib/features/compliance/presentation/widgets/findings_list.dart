import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../shared/widgets/buttons/ghost_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/finding.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Lista de hallazgos de compliance con filtro por tabs.
///
/// Ref Pencil: Results screen — Findings card.
class FindingsList extends StatefulWidget {
  final List<Finding> findings;

  const FindingsList({
    super.key,
    required this.findings,
  });

  @override
  State<FindingsList> createState() => _FindingsListState();
}

class _FindingsListState extends State<FindingsList> {
  _FindingFilter _activeFilter = _FindingFilter.all;

  List<Finding> get _filteredFindings => switch (_activeFilter) {
        _FindingFilter.all => widget.findings,
        _FindingFilter.high => widget.findings
            .where((f) => f.priority == FindingPriority.high)
            .toList(),
        _FindingFilter.medium => widget.findings
            .where((f) => f.priority == FindingPriority.medium)
            .toList(),
        _FindingFilter.low => widget.findings
            .where((f) => f.priority == FindingPriority.low)
            .toList(),
      };

  int _countByPriority(FindingPriority p) =>
      widget.findings.where((f) => f.priority == p).length;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: GlassCardHeader(
        title: 'Hallazgos (${widget.findings.length})',
        trailing: _buildTabs(context),
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          children: [
            for (int i = 0; i < _filteredFindings.length; i++)
              _FindingItem(
                finding: _filteredFindings[i],
                showBorder: i < _filteredFindings.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTab(context, 'Todos', _FindingFilter.all),
        const SizedBox(width: 4),
        _buildTab(
          context,
          'Alta (${_countByPriority(FindingPriority.high)})',
          _FindingFilter.high,
        ),
        const SizedBox(width: 4),
        _buildTab(
          context,
          'Media (${_countByPriority(FindingPriority.medium)})',
          _FindingFilter.medium,
        ),
        const SizedBox(width: 4),
        _buildTab(
          context,
          'Baja (${_countByPriority(FindingPriority.low)})',
          _FindingFilter.low,
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String label, _FindingFilter filter) {
    final isActive = _activeFilter == filter;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? context.colors.accentBlueSubtle : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? context.colors.accentBlue : context.colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

enum _FindingFilter { all, high, medium, low }

class _FindingItem extends StatelessWidget {
  final Finding finding;
  final bool showBorder;

  const _FindingItem({
    required this.finding,
    required this.showBorder,
  });

  Color _dotColor(BuildContext context) => switch (finding.priority) {
        FindingPriority.high => context.colors.statusError,
        FindingPriority.medium => context.colors.statusWarning,
        FindingPriority.low => context.colors.statusInfo,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(color: context.colors.borderSubtle),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority dot
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _dotColor(context),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finding.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  finding.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                if (finding.fieldPath != null || finding.xPath != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (finding.fieldPath != null)
                        'Campo: ${finding.fieldPath}',
                      if (finding.xPath != null)
                        'XPath: ${finding.xPath}',
                    ].join(' \u00b7 '),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textTertiary,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    GhostButton(
                      label: 'Corregir',
                      foregroundColor: context.colors.accentBlue,
                      onPressed: () {
                        GlassToast.show(context, message: 'Aplicando corrección sugerida por IA...', type: StatusType.info);
                      },
                    ),
                    const SizedBox(width: 4),
                    GhostButton(
                      label: 'Sugerir',
                      foregroundColor: context.colors.aiPurple,
                      onPressed: () {
                        GlassToast.show(context, message: 'Analizando sugerencias...', type: StatusType.info);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
