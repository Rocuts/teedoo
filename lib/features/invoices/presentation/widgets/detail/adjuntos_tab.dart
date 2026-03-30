import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/glass_toast.dart';
import '../documents/document_grid_view.dart';
import '../documents/dropzone_area.dart';

class AdjuntosTab extends StatelessWidget {
  const AdjuntosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final mockDocuments = [
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropzoneArea(
          onUploadTap: () {
            GlassToast.show(
              context,
              message: 'Abriendo explorador de archivos...',
              type: StatusType.info,
            );
          },
        ),
        const SizedBox(height: AppSpacing.s24),
        DocumentGridView(
          documents: mockDocuments,
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
    );
  }
}
