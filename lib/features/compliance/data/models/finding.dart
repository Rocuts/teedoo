/// Prioridad de un hallazgo de compliance.
enum FindingPriority { high, medium, low }

/// Hallazgo individual dentro de un análisis de compliance.
class Finding {
  final String id;
  final FindingPriority priority;
  final String title;
  final String description;
  final String? fieldPath;
  final String? xPath;
  final String? recommendation;

  const Finding({
    required this.id,
    required this.priority,
    required this.title,
    required this.description,
    this.fieldPath,
    this.xPath,
    this.recommendation,
  });
}
