/// Registro de integridad en la cadena de operaciones.
class IntegrityRecord {
  final String hash;
  final String previousHash;
  final int sequenceNumber;
  final DateTime timestamp;
  final bool isValid;

  const IntegrityRecord({
    required this.hash,
    required this.previousHash,
    required this.sequenceNumber,
    required this.timestamp,
    required this.isValid,
  });
}
