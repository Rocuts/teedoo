import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../widgets/ai_result_panel.dart';
import '../widgets/context_chat_panel.dart';

/// Pantalla de Compliance IA - Resultados + Chat.
///
/// Ref Pencil: Compliance IA - Results + Chat (cNV6b) — 1440x900
/// - Topbar con breadcrumbs
/// - Body: 2 paneles (resultados + chat IA)
class ResultsScreen extends StatelessWidget {
  final String checkId;

  const ResultsScreen({super.key, required this.checkId});

  @override
  Widget build(BuildContext context) {
    final result = AiResultPanel.mockResult;

    return Column(
      children: [
        // ── Topbar ──
        const AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(label: 'Compliance IA'),
            BreadcrumbItem(label: 'Resultados'),
          ],
        ),

        // ── Body: 2 panels (side-by-side on expanded, stacked otherwise) ──
        Expanded(
          child: ClipRect(
            child: context.isExpanded
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left panel: Results
                      Expanded(child: AiResultPanel(result: result)),
                      // Right panel: AI Chat (fixed 360px)
                      const SizedBox(width: 360, child: ContextChatPanel()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top: Results panel
                      Expanded(child: AiResultPanel(result: result)),
                      // Bottom: AI Chat panel (constrained height)
                      const SizedBox(height: 360, child: ContextChatPanel()),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
