import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teedoo/core/constants/app_constants.dart';
import 'package:teedoo/features/auth/providers/auth_provider.dart';

// Channel name used internally by flutter_secure_storage.
// Unit tests run on the Dart VM (not web), so SecureStorageService hits the
// native MethodChannel path; we shim it with an in-memory store so we don't
// need platform plugins.
const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> fakeSecureStore;

  setUp(() {
    fakeSecureStore = <String, String>{};

    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      final key = args['key'] as String?;

      switch (call.method) {
        case 'read':
          return key == null ? null : fakeSecureStore[key];
        case 'readAll':
          return Map<String, String>.from(fakeSecureStore);
        case 'write':
          if (key != null) {
            fakeSecureStore[key] = (args['value'] as String?) ?? '';
          }
          return null;
        case 'delete':
          if (key != null) fakeSecureStore.remove(key);
          return null;
        case 'deleteAll':
          fakeSecureStore.clear();
          return null;
        case 'containsKey':
          return key != null && fakeSecureStore.containsKey(key);
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  group('AuthNotifier', () {
    test('restaura sesión persistida al iniciar', () async {
      fakeSecureStore.addAll({
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

    test('loginWithPasskey autentica con cuenta demo hardcodeada', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await _awaitAuthReady(container);
      await container.read(authProvider.notifier).loginWithPasskey();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.error, isNull);
      expect(state.user?.email, 'demo@teedoo.app');
      expect(state.accessToken, 'demo_access_token');
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
