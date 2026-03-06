/// Regulación / marco normativo disponible para validación.
class Regulation {
  final String id;
  final String country;
  final String name;
  final String version;
  final bool isActive;
  final String? description;

  const Regulation({
    required this.id,
    required this.country,
    required this.name,
    required this.version,
    required this.isActive,
    this.description,
  });
}
