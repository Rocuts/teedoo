import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../data/models/user_model.dart';

/// Estado inmutable de autenticación.
class AuthState {
  static const _sentinel = Object();

  final bool isAuthenticated;
  final bool isLoading;
  final bool isBootstrapping;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isBootstrapping = false,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isBootstrapping,
    Object? user = _sentinel,
    Object? accessToken = _sentinel,
    Object? refreshToken = _sentinel,
    Object? error = _sentinel,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      user: identical(user, _sentinel) ? this.user : user as UserModel?,
      accessToken: identical(accessToken, _sentinel)
          ? this.accessToken
          : accessToken as String?,
      refreshToken: identical(refreshToken, _sentinel)
          ? this.refreshToken
          : refreshToken as String?,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.isBootstrapping == isBootstrapping &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
    isAuthenticated,
    isLoading,
    isBootstrapping,
    user,
    accessToken,
    refreshToken,
    error,
  );
}

class _AuthSession {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  const _AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });
}

/// Notifier de autenticación con estado persistido.
class AuthNotifier extends Notifier<AuthState> {
  static const bool _demoAuthEnabled = bool.fromEnvironment(
    'DEMO_AUTH_ENABLED',
    defaultValue: false,
  );

  static const _demoEmail = 'demo@teedoo.app';
  static const _demoPassword = 'Demo123!';

  @override
  AuthState build() {
    unawaited(_restoreSession());
    return const AuthState(isBootstrapping: true);
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(AppConstants.authTokenKey);
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      final userJson = prefs.getString(AppConstants.authUserKey);

      if (accessToken == null || userJson == null) {
        state = const AuthState(isBootstrapping: false);
        return;
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      state = AuthState(
        isAuthenticated: true,
        isBootstrapping: false,
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } catch (_) {
      state = const AuthState(
        isBootstrapping: false,
        error: 'No se pudo restaurar la sesión local.',
      );
    }
  }

  Future<void> _persistSession(_AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, session.accessToken);
    await prefs.setString(
      AppConstants.authUserKey,
      jsonEncode(session.user.toJson()),
    );

    if (session.refreshToken != null && session.refreshToken!.isNotEmpty) {
      await prefs.setString(
        AppConstants.refreshTokenKey,
        session.refreshToken!,
      );
    } else {
      await prefs.remove(AppConstants.refreshTokenKey);
    }
  }

  Future<void> _clearPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.authUserKey);
  }

  /// Login principal de producción.
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final session = _demoAuthEnabled
          ? await _loginDemo(email: email, password: password)
          : await _loginViaApi(email: email, password: password);

      await _persistSession(session);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isBootstrapping: false,
        user: session.user,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isBootstrapping: false,
        error: _humanizeError(e),
      );
    }
  }

  Future<_AuthSession> _loginDemo({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != _demoEmail || password != _demoPassword) {
      throw Exception(
        'Credenciales inválidas. Demo: $_demoEmail / $_demoPassword',
      );
    }

    return _buildDemoSession(email: normalizedEmail);
  }

  _AuthSession _buildDemoSession({String email = _demoEmail}) {
    final user = UserModel(
      id: 'usr_demo_001',
      email: email,
      name: 'Usuario Demo',
      organizationId: 'org_demo_001',
      role: 'admin',
      locale: 'es',
    );

    return _AuthSession(
      accessToken: 'demo_access_token',
      refreshToken: 'demo_refresh_token',
      user: user,
    );
  }

  Future<_AuthSession> _loginViaApi({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final body = _decodeResponseBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          _extractMessage(body) ??
          'Login fallido (HTTP ${response.statusCode}).';
      throw Exception(message);
    }

    final accessToken =
        _extractToken(body, 'access') ??
        _extractToken(body, 'accessToken') ??
        _extractToken(body, 'token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Respuesta inválida: falta access token en /auth/login.');
    }

    final refreshToken =
        _extractToken(body, 'refresh') ?? _extractToken(body, 'refreshToken');
    final user = _extractUser(body, fallbackEmail: email.trim());

    return _AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  /// Passkey demo: permite acceso inmediato con usuario hardcodeado.
  Future<void> loginWithPasskey() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final session = _buildDemoSession();

      await _persistSession(session);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isBootstrapping: false,
        user: session.user,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isBootstrapping: false,
        error: _humanizeError(e),
      );
    }
  }

  /// Cierra la sesión del usuario.
  void logout() {
    unawaited(_clearPersistedSession());
    state = const AuthState(isBootstrapping: false);
  }

  /// Limpia el estado de error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  static Map<String, dynamic> _decodeResponseBody(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  static String? _extractToken(Map<String, dynamic> body, String key) {
    final direct = body[key];
    if (direct is String && direct.isNotEmpty) return direct;

    final snake = body['${key}_token'];
    if (snake is String && snake.isNotEmpty) return snake;

    if (body case {'tokens': final Map<String, dynamic> tokens}) {
      final fromTokens = tokens[key] ?? tokens['${key}_token'];
      if (fromTokens is String && fromTokens.isNotEmpty) return fromTokens;
    }
    return null;
  }

  static UserModel _extractUser(
    Map<String, dynamic> body, {
    required String fallbackEmail,
  }) {
    final rawUser = body['user'];
    if (rawUser is Map<String, dynamic>) {
      final normalized = {
        'id': (rawUser['id'] ?? rawUser['user_id'] ?? 'unknown').toString(),
        'email': (rawUser['email'] ?? fallbackEmail).toString(),
        'name': (rawUser['name'] ?? rawUser['full_name'] ?? 'Usuario')
            .toString(),
        'organizationId':
            (rawUser['organizationId'] ?? rawUser['organization_id'])
                ?.toString(),
        'role': (rawUser['role'] ?? 'admin').toString(),
        'locale': (rawUser['locale'] ?? 'es').toString(),
      };
      return UserModel.fromJson(normalized);
    }

    return UserModel(id: 'unknown', email: fallbackEmail, name: 'Usuario');
  }

  static String? _extractMessage(Map<String, dynamic> body) {
    if (body case {'message': final String message}) return message;
    if (body case {'error': final String error}) return error;
    if (body case {'detail': final String detail}) return detail;
    if (body case {'error': {'message': final String message}}) return message;
    return null;
  }

  static String _humanizeError(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) {
      return 'No se pudo completar la autenticación.';
    }
    return raw;
  }
}

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).accessToken;
});

/// Provider global de autenticación.
/// No autoDispose — auth state must persist across navigation.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
