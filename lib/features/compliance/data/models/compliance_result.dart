import 'finding.dart';

/// Nivel de cumplimiento resultante del análisis.
enum ComplianceLevel { pass, warnings, fail }

/// Resultado de un análisis de compliance sobre un documento.
class ComplianceResult {
  final String id;
  final String invoiceId;
  final int score;
  final ComplianceLevel level;
  final List<Finding> findings;
  final String regulationId;
  final String regulationVersion;
  final DateTime analyzedAt;
  final String documentHash;

  const ComplianceResult({
    required this.id,
    required this.invoiceId,
    required this.score,
    required this.level,
    required this.findings,
    required this.regulationId,
    required this.regulationVersion,
    required this.analyzedAt,
    required this.documentHash,
  });
}
