import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';

class InvoiceDocument {
  final String id;
  final String name;
  final String size;
  final String date;
  final String type; // 'pdf', 'image', 'xml', 'csv'
  final String? tag; // e.g. 'Recibo SEPA'

  const InvoiceDocument({
    required this.id,
    required this.name,
    required this.size,
    required this.date,
    required this.type,
    this.tag,
  });
}

class DocumentGridView extends StatefulWidget {
  final List<InvoiceDocument> documents;
  final VoidCallback onUploadTap;
  final void Function(InvoiceDocument) onDownloadTap;
  final void Function(InvoiceDocument) onDeleteTap;

  const DocumentGridView({
    super.key,
    required this.documents,
    required this.onUploadTap,
    required this.onDownloadTap,
    required this.onDeleteTap,
  });

  @override
  State<DocumentGridView> createState() => _DocumentGridViewState();
}

class _DocumentGridViewState extends State<DocumentGridView> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // View Toggle Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.documents.length} Documentos',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.bgInput,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Row(
                children: [
                  _ViewToggleButton(
                    icon: LucideIcons.grid,
                    isSelected: _isGridView,
                    onTap: () => setState(() => _isGridView = true),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: context.colors.borderSubtle,
                  ),
                  _ViewToggleButton(
                    icon: LucideIcons.list,
                    isSelected: !_isGridView,
                    onTap: () => setState(() => _isGridView = false),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: AppSpacing.s16),

        // Content
        if (_isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: widget.documents.length,
            itemBuilder: (context, index) {
              return _DocumentCardItem(
                document: widget.documents[index],
                onDownload: () => widget.onDownloadTap(widget.documents[index]),
                onDelete: () => widget.onDeleteTap(widget.documents[index]),
              );
            },
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.documents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _DocumentListItem(
                document: widget.documents[index],
                onDownload: () => widget.onDownloadTap(widget.documents[index]),
                onDelete: () => widget.onDeleteTap(widget.documents[index]),
              );
            },
          ),
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.accentBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: AppRadius.mdAll,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? context.colors.accentBlue : context.colors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ── GLASSMORPHISM CARD ITEM (GRID VIEW) ──
class _DocumentCardItem extends StatefulWidget {
  final InvoiceDocument document;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _DocumentCardItem({
    required this.document,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  State<_DocumentCardItem> createState() => _DocumentCardItemState();
}

class _DocumentCardItemState extends State<_DocumentCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final IconData iconData;
    final Color iconColor;
    
    switch (widget.document.type) {
      case 'pdf':
        iconData = LucideIcons.fileText;
        iconColor = Colors.redAccent;
        break;
      case 'image':
        iconData = LucideIcons.image;
        iconColor = context.colors.accentBlue;
        break;
      case 'xml':
        iconData = LucideIcons.code;
        iconColor = Colors.orangeAccent;
        break;
      default:
        iconData = LucideIcons.file;
        iconColor = context.colors.textSecondary;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? context.colors.bgSurface : context.colors.bgInput,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: _isHovered ? context.colors.accentBlue.withValues(alpha: 0.3) : context.colors.borderSubtle,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            // Thumbnail Area
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.bgSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        iconData,
                        size: 48,
                        color: iconColor.withValues(alpha: 0.5),
                      ),
                    ),
                    if (widget.document.tag != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.bgSurface.withValues(alpha: 0.8),
                            borderRadius: AppRadius.smAll,
                            border: Border.all(color: context.colors.borderSubtle),
                          ),
                          child: Text(
                            widget.document.tag!,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Hover Actions Overlay
                    if (_isHovered)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colors.bgSurface.withValues(alpha: 0.85),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _HoverActionButton(
                                icon: LucideIcons.download,
                                tooltip: 'Descargar',
                                onTap: widget.onDownload,
                                color: context.colors.textPrimary,
                              ),
                              const SizedBox(width: 12),
                              _HoverActionButton(
                                icon: LucideIcons.trash2,
                                tooltip: 'Eliminar',
                                onTap: widget.onDelete,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Details Area
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.document.name,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.document.size} · ${widget.document.date}',
                      style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
               ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── COMPACT LIST ITEM (LIST VIEW) ──
class _DocumentListItem extends StatefulWidget {
  final InvoiceDocument document;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _DocumentListItem({
    required this.document,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  State<_DocumentListItem> createState() => _DocumentListItemState();
}

class _DocumentListItemState extends State<_DocumentListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final IconData iconData;
    final Color iconColor;
    
    switch (widget.document.type) {
      case 'pdf':
        iconData = LucideIcons.fileText;
        iconColor = Colors.redAccent;
        break;
      case 'image':
        iconData = LucideIcons.image;
        iconColor = context.colors.accentBlue;
        break;
      case 'xml':
        iconData = LucideIcons.code;
        iconColor = Colors.orangeAccent;
        break;
      default:
        iconData = LucideIcons.file;
        iconColor = context.colors.textSecondary;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered ? context.colors.bgSurface : context.colors.bgInput,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
             color: _isHovered ? context.colors.accentBlue.withValues(alpha: 0.3) : context.colors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.bgSurface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: context.colors.borderSubtle.withValues(alpha: 0.5)),
              ),
              child: Icon(iconData, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.document.name,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.document.tag != null) ...[
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: widget.document.tag!,
                          type: StatusType.info, 
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.document.size} · Subido el ${widget.document.date}',
                    style: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isHovered) ...[
              IconButton(
                icon: Icon(LucideIcons.download, size: 18, color: context.colors.textSecondary),
                onPressed: widget.onDownload,
                tooltip: 'Descargar',
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                onPressed: widget.onDelete,
                tooltip: 'Eliminar',
              ),
            ] else
              Icon(LucideIcons.moreVertical, size: 18, color: context.colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _HoverActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _HoverActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.bgInput,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
