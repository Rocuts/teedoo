import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../../../shared/widgets/stepper/teedoo_stepper.dart';
import '../widgets/invoice_wizard/invoice_line_data.dart';
import '../widgets/invoice_wizard/invoice_helpers.dart';
import '../widgets/invoice_wizard/step_partes.dart';
import '../widgets/invoice_wizard/step_lineas.dart';
import '../widgets/invoice_wizard/step_totales.dart';
import '../widgets/invoice_wizard/step_revision.dart';

/// Pantalla de creación de factura (wizard 4 pasos).
///
/// Ref Pencil: Invoice - Create Wizard (DBnBX) — 1440x900
/// Steps: Partes -> Líneas -> Totales -> Revisión
class InvoiceCreateScreen extends StatefulWidget {
  const InvoiceCreateScreen({super.key});

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  int _currentStep = 0;
  bool _isSaving = false;
  final _scrollController = ScrollController();

  // Step 1: Partes
  final _receptorNameController = TextEditingController();
  final _receptorNifController = TextEditingController();
  final _receptorAddressController = TextEditingController();

  // Step 2: Líneas
  final List<InvoiceLineData> _lines = [
    InvoiceLineData(
      description: 'Consultoría de sistemas ERP',
      quantity: '40',
      unitPrice: '85,00',
      taxRate: '21',
    ),
  ];

  // Step 3: Totales
  String? _paymentMethod;
  final _dueDateController = TextEditingController();
  final _notesController = TextEditingController();

  static const _steps = [
    StepItem(label: 'Partes'),
    StepItem(label: 'Líneas'),
    StepItem(label: 'Totales'),
    StepItem(label: 'Revisión'),
  ];

  // Mock emisor data
  static const _emisorName = 'Mi Empresa S.L.';
  static const _emisorNif = 'B12345678';
  static const _emisorAddress = 'Calle Mayor 15, 28001 Madrid';

  @override
  void dispose() {
    _scrollController.dispose();
    _receptorNameController.dispose();
    _receptorNifController.dispose();
    _receptorAddressController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _steps.length) {
      setState(() => _currentStep = step);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _nextStep() => _goToStep(_currentStep + 1);
  void _prevStep() => _goToStep(_currentStep - 1);

  void _addLine() {
    setState(() {
      _lines.add(InvoiceLineData());
    });
  }

  void _removeLine(int index) {
    if (_lines.length > 1) {
      setState(() {
        _lines[index].dispose();
        _lines.removeAt(index);
      });
    }
  }

  double get _subtotal {
    double total = 0;
    for (final line in _lines) {
      final qty = int.tryParse(line.quantity) ?? 0;
      final price = parseNumber(line.unitPrice);
      total += qty * price;
    }
    return total;
  }

  double get _taxAmount {
    double tax = 0;
    for (final line in _lines) {
      final qty = int.tryParse(line.quantity) ?? 0;
      final price = parseNumber(line.unitPrice);
      final rate = (int.tryParse(line.taxRate) ?? 0) / 100;
      tax += qty * price * rate;
    }
    return tax;
  }

  double get _total => _subtotal + _taxAmount;

  double _lineTotal(int index) {
    final line = _lines[index];
    final qty = int.tryParse(line.quantity) ?? 0;
    final price = parseNumber(line.unitPrice);
    final rate = (int.tryParse(line.taxRate) ?? 0) / 100;
    return qty * price * (1 + rate);
  }

  Future<void> _onSubmit() async {
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Factura emitida con éxito',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: context.colors.statusSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.badgeAll),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      ),
    );
    context.go(RoutePaths.invoices);
  }

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
            const BreadcrumbItem(label: 'Nueva factura'),
          ],
        ),
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
                  Text(
                    'Crear nueva factura',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete los datos para emitir una factura electrónica',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  TeeDooStepper(
                    steps: _steps,
                    currentStep: _currentStep,
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: switch (_currentStep) {
                      0 => StepPartes(
                          emisorName: _emisorName,
                          emisorNif: _emisorNif,
                          emisorAddress: _emisorAddress,
                          receptorNameController: _receptorNameController,
                          receptorNifController: _receptorNifController,
                          receptorAddressController: _receptorAddressController,
                          onNext: _nextStep,
                        ),
                      1 => StepLineas(
                          lines: _lines,
                          onAddLine: _addLine,
                          onRemoveLine: _removeLine,
                          onNext: _nextStep,
                          onPrev: _prevStep,
                          onChanged: () => setState(() {}),
                          lineTotal: _lineTotal,
                        ),
                      2 => StepTotales(
                          subtotal: _subtotal,
                          taxAmount: _taxAmount,
                          total: _total,
                          paymentMethod: _paymentMethod,
                          onPaymentMethodChanged: (value) =>
                              setState(() => _paymentMethod = value),
                          dueDateController: _dueDateController,
                          notesController: _notesController,
                          onNext: _nextStep,
                          onPrev: _prevStep,
                        ),
                      3 => StepRevision(
                          emisorName: _emisorName,
                          emisorNif: _emisorNif,
                          emisorAddress: _emisorAddress,
                          receptorName:
                              _receptorNameController.text.isNotEmpty
                                  ? _receptorNameController.text
                                  : 'Sin especificar',
                          receptorNif: _receptorNifController.text.isNotEmpty
                              ? _receptorNifController.text
                              : 'Sin especificar',
                          receptorAddress:
                              _receptorAddressController.text.isNotEmpty
                                  ? _receptorAddressController.text
                                  : 'Sin especificar',
                          lines: _lines,
                          subtotal: _subtotal,
                          taxAmount: _taxAmount,
                          total: _total,
                          lineTotal: _lineTotal,
                          isSaving: _isSaving,
                          onPrev: _prevStep,
                          onSubmit: _onSubmit,
                        ),
                      _ => const SizedBox.shrink(),
                    },
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
