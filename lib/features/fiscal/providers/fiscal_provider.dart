import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/services/fiscal_explanation_service.dart';
import '../data/models/fiscal_profile.dart';
import '../data/models/optimization_report.dart';
import '../domain/fiscal_analyzer.dart';

/// Estado del perfil fiscal editable.
class FiscalProfileNotifier extends AutoDisposeNotifier<FiscalProfile> {
  @override
  FiscalProfile build() {
    final now = DateTime.now();
    return FiscalProfile(
      id: 'fp_demo_001',
      userId: 'usr_demo_001',
      legalForm: LegalForm.autonomo,
      fiscalRegime: FiscalRegime.estimacionDirectaSimplificada,
      ivaRegime: IvaRegime.general,
      nif: '12345678A',
      autonomousCommunity: 'Madrid',
      iaeCode: '6201',
      iaeDescription: 'Programación informática',
      annualRevenue: 85000,
      annualExpenses: 32000,
      worksFromHome: true,
      homeOfficePercentage: 30,
      fiscalYear: 2026,
      createdAt: now,
      updatedAt: now,
    );
  }

  void update(FiscalProfile Function(FiscalProfile) updater) {
    state = updater(state);
  }
}

/// Provider del perfil fiscal.
final fiscalProfileProvider =
    AutoDisposeNotifierProvider<FiscalProfileNotifier, FiscalProfile>(
      FiscalProfileNotifier.new,
    );

/// Estado del análisis fiscal.
class FiscalAnalysisState {
  final OptimizationReport? report;
  final bool isLoading;
  final String? error;

  const FiscalAnalysisState({this.report, this.isLoading = false, this.error});

  FiscalAnalysisState copyWith({
    OptimizationReport? report,
    bool? isLoading,
    String? error,
  }) {
    return FiscalAnalysisState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FiscalAnalysisNotifier extends AutoDisposeNotifier<FiscalAnalysisState> {
  @override
  FiscalAnalysisState build() {
    return const FiscalAnalysisState();
  }

  void setReport(OptimizationReport report) {
    state = FiscalAnalysisState(report: report);
  }

  Future<void> runAnalysis() async {
    final profile = ref.read(fiscalProfileProvider);

    state = state.copyWith(isLoading: true, error: null);

    try {
      FiscalExplanationService? explanationService;
      try {
        explanationService = ref.read(fiscalExplanationServiceProvider);
      } catch (_) {
        // Service not available — run without AI explanations
      }

      final analyzer = FiscalAnalyzer(explanationService: explanationService);

      // Separar facturas emitidas y recibidas del mock
      final invoices = MockData.invoices;
      final issued = invoices.where((i) => i.issuerNif == profile.nif).toList();
      final received = invoices
          .where((i) => i.issuerNif != profile.nif)
          .toList();

      final report = await analyzer.analyze(
        profile: profile,
        issuedInvoices: issued,
        receivedInvoices: received,
        includeAiExplanations: true, // Siempre genera justificaciones locales
      );

      state = FiscalAnalysisState(report: report);
    } catch (e) {
      state = FiscalAnalysisState(error: 'Error al ejecutar el análisis: $e');
    }
  }
}

/// Provider del análisis fiscal.
final fiscalAnalysisProvider =
    AutoDisposeNotifierProvider<FiscalAnalysisNotifier, FiscalAnalysisState>(
      FiscalAnalysisNotifier.new,
    );
