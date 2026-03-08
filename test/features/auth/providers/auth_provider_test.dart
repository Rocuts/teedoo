import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teedoo/core/constants/app_constants.dart';
import 'package:teedoo/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier', () {
    test('restaura sesión persistida al iniciar', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.authTokenKey: 'token_123',
        AppConstants.refreshTokenKey: 'refresh_123',
        AppConstants.authUserKey: jsonEncode({
          'id': 'usr_001',
          'email': 'demo@teedoo.app',
          'name': 'Demo User',
          'organizationId': 'org_001',
          'role': 'admin',
          'locale': 'es',
        }),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await _awaitAuthReady(container);
      expect(state.isBootstrapping, isFalse);
      expect(state.isAuthenticated, isTrue);
      expect(state.accessToken, 'token_123');
      expect(state.user?.email, 'demo@teedoo.app');
    });

    test('logout limpia estado de sesión', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await _awaitAuthReady(container);
      container.read(authProvider.notifier).logout();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.accessToken, isNull);
      expect(state.user, isNull);
    });
  });
}

Future<AuthState> _awaitAuthReady(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final state = container.read(authProvider);
    if (!state.isBootstrapping) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  return container.read(authProvider);
}
