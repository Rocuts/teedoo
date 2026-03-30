import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/file_dropzone.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/inputs/search_input.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../data/models/regulation.dart';
import '../widgets/regulation_selector.dart';

/// Pantalla de Compliance IA - Chequeo rápido.
///
/// Ref Pencil: Compliance IA - Quick Check (qJplI) — 1440x900
/// - Topbar con breadcrumbs
/// - Header: sparkles + "Compliance IA" + subtitle
/// - Body: 2 columnas (documento + regulación)
class QuickCheckScreen extends StatefulWidget {
  const QuickCheckScreen({super.key});

  @override
  State<QuickCheckScreen> createState() => _QuickCheckScreenState();
}

class _QuickCheckScreenState extends State<QuickCheckScreen> {
  String _selectedRegulation = 'es-facturae';
  bool _isAnalyzing = false;

  static const _regulations = [
    Regulation(
      id: 'es-facturae',
      country: 'España',
      name: 'Facturae / VeriFActu',
      version: 'SII 2026',
      isActive: true,
    ),
    Regulation(
      id: 'fr-facturx',
      country: 'Francia',
      name: 'Factur-X / Chorus Pro',
      version: 'v2.3',
      isActive: false,
      description: 'Coming soon',
    ),
    Regulation(
      id: 'it-fattpa',
      country: 'Italia',
      name: 'FatturaPA / SDI',
      version: 'v1.2',
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Topbar ──
        const AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(label: 'Compliance IA'),
            BreadcrumbItem(label: 'Chequeo rápido'),
          ],
        ),

        // ── Content ──
        Expanded(
          child: ClipRect(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.contentPaddingH,
                vertical: context.contentPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.s24),

                  // ── Body: 2 columns (side-by-side on expanded, stacked otherwise) ──
                  if (context.isExpanded)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column: Seleccionar documento
                        Expanded(child: _buildDocumentColumn()),
                        const SizedBox(width: AppSpacing.s20),
                        // Right column: Regulación
                        SizedBox(width: 360, child: _buildRegulationColumn()),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Document column (full width)
                        _buildDocumentColumn(),
                        const SizedBox(height: AppSpacing.s20),
                        // Regulation column (full width, stacked below)
                        _buildRegulationColumn(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 24,
              color: context.colors.aiPurple,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Compliance IA',
              style: AppTypography.h2.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Valida documentos contra regulaciones vigentes con asistencia de IA',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentColumn() {
    return GlassCard(
      header: const GlassCardHeader(
        title: 'Seleccionar documento',
        subtitle: 'Arrastra un archivo o selecciona una factura existente',
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.xl,
          AppSpacing.s24,
          AppSpacing.s24,
        ),
        child: Column(
          children: [
            // Dropzone
            const FileDropzone(allowedExtensions: ['pdf', 'xml']),
            const SizedBox(height: AppSpacing.s20),

            // Divider with text
            _buildDivider(),
            const SizedBox(height: AppSpacing.s20),

            // Search input
            const SearchInput(
              placeholder: 'Buscar factura por número o cliente...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colors.borderSubtle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            'o busca una factura existente',
            style: AppTypography.caption.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colors.borderSubtle)),
      ],
    );
  }

  Widget _buildRegulationColumn() {
    return Column(
      children: [
        // Regulation card
        GlassCard(
          header: const GlassCardHeader(
            title: 'Regulación',
            subtitle: 'Selecciona el marco normativo a validar',
          ),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.xl,
              AppSpacing.s24,
              AppSpacing.s24,
            ),
            child: RegulationSelector(
              regulations: _regulations,
              selectedId: _selectedRegulation,
              onSelected: (id) => setState(() => _selectedRegulation = id),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Analyze button
        PrimaryButton(
          label: _isAnalyzing
              ? 'Analizando con IA...'
              : 'Analizar cumplimiento',
          icon: _isAnalyzing ? LucideIcons.loader : LucideIcons.sparkles,
          isExpanded: true,
          onPressed: _isAnalyzing
              ? () {}
              : () async {
                  setState(() => _isAnalyzing = true);
                  await Future<void>.delayed(
                    const Duration(milliseconds: 2500),
                  );
                  if (!mounted) return;
                  context.go(
                    RoutePaths.complianceResults('inv_3'),
                  ); // demo fail check
                },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Disclaimer
        _buildDisclaimer(),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colors.aiPurpleBg,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.aiPurpleBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              LucideIcons.info,
              size: 14,
              color: context.colors.aiPurple,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Los resultados de IA son orientativos y no constituyen '
              'asesoramiento legal. Verifica siempre con un profesional '
              'antes de enviar documentos oficiales.',
              style: AppTypography.caption.copyWith(
                color: context.colors.aiPurple,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
