/// Constantes globales de la aplicación TeeDoo.
///
/// Centraliza valores fijos para evitar strings/números mágicos.
/// Todos los campos son `const` y la clase no es instanciable.
abstract final class AppConstants {
  // ── App Identity ──
  static const String appName = 'TeeDoo';
  static const String appVersion = '0.1.0';
  static const String appTaglineEs = 'Facturación electrónica inteligente';
  static const String appTaglineEn = 'Smart electronic invoicing';

  // ── API ──
  // Same-origin por defecto: el Flutter Web build se sirve desde el mismo
  // deploy de Vercel que expone `/api/*`. Para dev local contra el
  // `dev_server.js` en 3001 pasar `--dart-define=TEEDOO_API_BASE_URL=http://localhost:3001/api`.
  static const String apiBaseUrl = String.fromEnvironment(
    'TEEDOO_API_BASE_URL',
    defaultValue: '/api',
  );
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ── Layout Dimensions ──
  // For layout dimensions, prefer AppDimensions in core/theme/app_dimensions.dart.
  static const double contentPaddingHorizontal = 32;
  static const double contentPaddingVertical = 28;
  static const double contentGap = 24;

  // ── Pagination ──
  static const int defaultPageSize = 25;
  static const int maxPageSize = 100;

  // ── Validation ──
  static const int passwordMinLength = 8;
  static const int mfaCodeLength = 6;
  static const int maxFileUploadMB = 2;

  // ── Supported Locales ──
  static const String defaultLocale = 'es';
  static const List<String> supportedLocales = ['es', 'en'];

  // ── Storage Keys ──
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String authUserKey = 'auth_user';
  static const String localeKey = 'locale';

  // ── Invoice Defaults ──
  static const String defaultInvoicePrefix = 'FAC';
  static const String defaultCurrency = 'EUR';
  static const double defaultTaxRate = 21.0;
}
