import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../widgets/documents/document_grid_view.dart';
import '../widgets/documents/dropzone_area.dart';

class InvoiceDocumentsScreen extends StatefulWidget {
  const InvoiceDocumentsScreen({super.key});

  @override
  State<InvoiceDocumentsScreen> createState() => _InvoiceDocumentsScreenState();
}

class _InvoiceDocumentsScreenState extends State<InvoiceDocumentsScreen> {
  final List<InvoiceDocument> _mockDocuments = [
    const InvoiceDocument(
      id: '1',
      name: 'INV-2026-092.xml',
      size: '12.4 KB',
      date: '27 Feb 2026',
      type: 'xml',
      tag: 'FacturaE',
    ),
    const InvoiceDocument(
      id: '2',
      name: 'INV-2026-092_Comprobante.pdf',
      size: '245 KB',
      date: '27 Feb 2026',
      type: 'pdf',
      tag: 'Recibo SEPA',
    ),
    const InvoiceDocument(
      id: '3',
      name: 'Foto_Materiales_Obra.jpg',
      size: '1.2 MB',
      date: '26 Feb 2026',
      type: 'image',
    ),
    const InvoiceDocument(
      id: '4',
      name: 'Contrato_Soporte_IT.pdf',
      size: '3.1 MB',
      date: '15 Ene 2026',
      type: 'pdf',
      tag: 'Contrato',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(
              label: 'Facturas',
              onTap: () => context.go(RoutePaths.invoices),
            ),
            const BreadcrumbItem(label: 'Documentos'),
          ],
        ),
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
                  Text(
                    'Documentos por Facturas',
                    style: AppTypography.h2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Central de archivos, contratos y evidencias asociadas a tus facturas',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  // ── Subida ──
                  DropzoneArea(
                    onUploadTap: () {
                      GlassToast.show(
                        context,
                        message: 'Abriendo explorador de archivos...',
                        type: StatusType.info,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s32),

                  // ── Galería Central ──
                  DocumentGridView(
                    documents: _mockDocuments,
                    onDownloadTap: (doc) {
                      GlassToast.show(
                        context,
                        message: 'Descargando ${doc.name}...',
                        type: StatusType.success,
                      );
                    },
                    onDeleteTap: (doc) {
                      GlassToast.show(
                        context,
                        message: 'Eliminando ${doc.name}...',
                        type: StatusType.error,
                      );
                    },
                    onUploadTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
