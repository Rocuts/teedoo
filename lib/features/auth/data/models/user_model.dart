/// Modelo de usuario para el módulo de autenticación.
///
/// Roles disponibles: admin, finance, auditor, viewer.
/// Locales: es, en.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? organizationId;
  final String role;
  final String locale;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.organizationId,
    this.role = 'admin',
    this.locale = 'es',
  });

  /// Crea una instancia desde un mapa JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      organizationId: json['organizationId'] as String?,
      role: json['role'] as String? ?? 'admin',
      locale: json['locale'] as String? ?? 'es',
    );
  }

  /// Serializa a mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'organizationId': organizationId,
      'role': role,
      'locale': locale,
    };
  }

  /// Crea una copia con campos modificados.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? organizationId,
    String? role,
    String? locale,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.organizationId == organizationId &&
        other.role == role &&
        other.locale == locale;
  }

  @override
  int get hashCode =>
      Object.hash(id, email, name, organizationId, role, locale);

  @override
  String toString() {
    return 'UserModel(id: $id, role: $role, locale: $locale)';
  }
}
