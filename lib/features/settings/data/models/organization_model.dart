/// Modelo de datos para la organización.
///
/// Contiene toda la información de configuración de la empresa,
/// certificados digitales, y numeración de facturas.
class Organization {
  final String id;
  final String name;
  final String nif;
  final String address;
  final String country;
  final String postalCode;
  final String? logoUrl;
  final String? certificateName;
  final DateTime? certificateExpiry;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String defaultLanguage;
  final String defaultCurrency;

  const Organization({
    required this.id,
    required this.name,
    required this.nif,
    required this.address,
    required this.country,
    required this.postalCode,
    this.logoUrl,
    this.certificateName,
    this.certificateExpiry,
    required this.invoicePrefix,
    required this.nextInvoiceNumber,
    required this.defaultLanguage,
    required this.defaultCurrency,
  });

  /// Datos de ejemplo para desarrollo.
  static final mock = Organization(
    id: 'org_001',
    name: 'TeeDoo S.L.',
    nif: 'B12345678',
    address: 'Calle Gran Vía 28, 28010 Madrid',
    country: 'ES',
    postalCode: '28010',
    certificateName: 'certificado_teedoo_2026.p12',
    certificateExpiry: DateTime(2027, 10, 15),
    invoicePrefix: 'FACT-',
    nextInvoiceNumber: 142,
    defaultLanguage: 'es',
    defaultCurrency: 'EUR',
  );

  Organization copyWith({
    String? id,
    String? name,
    String? nif,
    String? address,
    String? country,
    String? postalCode,
    String? logoUrl,
    String? certificateName,
    DateTime? certificateExpiry,
    String? invoicePrefix,
    int? nextInvoiceNumber,
    String? defaultLanguage,
    String? defaultCurrency,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      nif: nif ?? this.nif,
      address: address ?? this.address,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      logoUrl: logoUrl ?? this.logoUrl,
      certificateName: certificateName ?? this.certificateName,
      certificateExpiry: certificateExpiry ?? this.certificateExpiry,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }

  /// Genera la vista previa del número de factura.
  String get invoicePreview =>
      '$invoicePrefix${nextInvoiceNumber.toString().padLeft(6, '0')}';
}
