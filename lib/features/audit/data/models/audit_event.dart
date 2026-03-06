/// Tipo de evento de auditoría.
enum AuditEventType {
  create,
  update,
  send,
  complianceCheck,
  export,
  login,
  delete,
}

/// Evento individual de auditoría en el log de operaciones.
class AuditEvent {
  final String id;
  final AuditEventType type;
  final String title;
  final String? description;
  final String userId;
  final String? userName;
  final DateTime timestamp;
  final String? relatedEntityId;
  final Map<String, dynamic>? metadata;

  const AuditEvent({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.userId,
    this.userName,
    required this.timestamp,
    this.relatedEntityId,
    this.metadata,
  });
}
