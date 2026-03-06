import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_model.dart';

/// Estado inmutable de autenticación.
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.user == user &&
        other.error == error;
  }

  @override
  int get hashCode =>
      Object.hash(isAuthenticated, isLoading, user, error);
}

/// Notifier de autenticación con patrón moderno Riverpod.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Simula login con email y contraseña.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Reemplazar con llamada real a API
      await Future<void>.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: 'usr_001',
        email: email,
        name: 'Usuario Demo',
        organizationId: 'org_001',
        role: 'admin',
        locale: 'es',
      );

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Simula login con passkey/biometrics.
  Future<void> loginWithPasskey() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Reemplazar con autenticación WebAuthn real
      await Future<void>.delayed(const Duration(seconds: 1));

      const user = UserModel(
        id: 'usr_001',
        email: 'usuario@empresa.com',
        name: 'Usuario Demo',
        organizationId: 'org_001',
        role: 'admin',
        locale: 'es',
      );

      state = const AuthState(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cierra la sesión del usuario.
  void logout() {
    state = const AuthState();
  }

  /// Limpia el estado de error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global de autenticación.
/// No autoDispose — auth state must persist across navigation.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
