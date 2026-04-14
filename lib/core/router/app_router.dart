import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/mfa_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/invoices/presentation/screens/invoices_list_screen.dart';
import '../../features/invoices/presentation/screens/invoice_create_screen.dart';
import '../../features/invoices/presentation/screens/invoice_detail_screen.dart';
import '../../features/invoices/presentation/screens/invoice_documents_screen.dart';
import '../../features/compliance/presentation/screens/quick_check_screen.dart';
import '../../features/compliance/presentation/screens/results_screen.dart';
import '../../features/audit/presentation/screens/audit_screen.dart';
import '../../features/fiscal/presentation/screens/fiscal_screen.dart';
import '../../features/fiscal/presentation/screens/optimization_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/layouts/app_shell.dart';
import 'route_names.dart';

/// Clave del navigator raíz para la app shell.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Clave del navigator del shell (para páginas dentro del sidebar).
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Public routes that don't require authentication.
const _publicPaths = {
  RoutePaths.login,
  RoutePaths.mfa,
  RoutePaths.forgotPassword,
  RoutePaths.onboarding,
};

/// Adapter that converts Riverpod provider changes into a [Listenable]
/// so GoRouter can re-evaluate its redirect when auth state changes.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// Router provider that integrates with auth state for route guards.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRefreshListenable(ref);
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.login,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.isBootstrapping) return null;

      final isLoggedIn = authState.isAuthenticated;
      final currentPath = state.uri.path;
      final isPublicRoute = _publicPaths.contains(currentPath);

      if (!isLoggedIn && !isPublicRoute) return RoutePaths.login;
      if (isLoggedIn && isPublicRoute) return RoutePaths.dashboard;
      return null;
    },
    routes: [
      // ── Auth Routes (sin shell) ──
      GoRoute(
        name: RouteNames.login,
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: RouteNames.mfa,
        path: RoutePaths.mfa,
        builder: (context, state) => const MfaScreen(),
      ),
      GoRoute(
        name: RouteNames.forgotPassword,
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: RouteNames.onboarding,
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── App Routes (con AppShell: sidebar + topbar) ──
      // Todas las rutas dentro del shell usan NoTransitionPage para evitar
      // que la transición de MaterialPage muestre la pantalla anterior
      // (y sus animaciones flutter_animate) durante el cambio de ruta.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            name: RouteNames.dashboard,
            path: RoutePaths.dashboard,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            name: RouteNames.invoices,
            path: RoutePaths.invoices,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InvoicesListScreen()),
            routes: [
              GoRoute(
                name: RouteNames.invoiceCreate,
                path: 'new',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: InvoiceCreateScreen()),
              ),
              GoRoute(
                name: RouteNames.invoiceDocuments,
                path: 'documents',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: InvoiceDocumentsScreen()),
              ),
              GoRoute(
                name: RouteNames.invoiceDetail,
                path: ':id',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: InvoiceDetailScreen(
                    invoiceId: state.pathParameters['id'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            name: RouteNames.compliance,
            path: RoutePaths.compliance,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QuickCheckScreen()),
            routes: [
              GoRoute(
                name: RouteNames.complianceResults,
                path: 'results/:id',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: ResultsScreen(
                    checkId: state.pathParameters['id'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            name: RouteNames.fiscal,
            path: RoutePaths.fiscal,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FiscalScreen()),
            routes: [
              GoRoute(
                name: RouteNames.optimizationDetail,
                path: 'optimizations/:id',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: OptimizationDetailScreen(
                    optimizationId: state.pathParameters['id'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            name: RouteNames.audit,
            path: RoutePaths.audit,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AuditScreen()),
          ),
          GoRoute(
            name: RouteNames.settings,
            path: RoutePaths.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    refreshListenable.dispose();
    router.dispose();
  });

  return router;
});
