import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage abstraction for sensitive data (tokens, credentials).
///
/// On mobile (iOS/Android) uses flutter_secure_storage which leverages
/// Keychain (iOS) and EncryptedSharedPreferences (Android).
///
/// On web, falls back to SharedPreferences (localStorage) since
/// flutter_secure_storage is not supported. For production web apps,
/// consider HTTP-only cookies via your backend instead.
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Reads a value by key. Returns null if not found.
  static Future<String?> read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _storage.read(key: key);
  }

  /// Writes a key-value pair securely.
  static Future<void> write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  /// Deletes a value by key.
  static Future<void> delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }
    await _storage.delete(key: key);
  }
}
