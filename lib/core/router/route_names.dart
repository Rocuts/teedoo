/// Constantes de rutas para navegación type-safe.
abstract final class RouteNames {
  // ── Auth ──
  static const login = 'login';
  static const mfa = 'mfa';
  static const forgotPassword = 'forgot-password';
  static const onboarding = 'onboarding';

  // ── Main App ──
  static const dashboard = 'dashboard';

  // ── Invoices ──
  static const invoices = 'invoices';
  static const invoiceCreate = 'invoice-create';
  static const invoiceDetail = 'invoice-detail';
  static const invoiceDocuments = 'invoice-documents';

  // ── Compliance ──
  static const compliance = 'compliance';
  static const complianceResults = 'compliance-results';

  // ── Audit ──
  static const audit = 'audit';

  // ── Settings ──
  static const settings = 'settings';
}

/// Paths de rutas.
abstract final class RoutePaths {
  // ── Auth ──
  static const login = '/login';
  static const mfa = '/mfa';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';

  // ── Main App ──
  static const dashboard = '/dashboard';

  // ── Invoices ──
  static const invoices = '/invoices';
  static const invoiceCreate = '/invoices/new';
  static const invoiceDocuments = '/invoices/documents';
  static String invoiceDetail(String id) => '/invoices/$id';

  // ── Compliance ──
  static const compliance = '/compliance';
  static String complianceResults(String id) => '/compliance/results/$id';

  // ── Audit ──
  static const audit = '/audit';

  // ── Settings ──
  static const settings = '/settings';
}
