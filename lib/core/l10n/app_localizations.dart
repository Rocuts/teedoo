import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'strings_en.dart';
import 'strings_es.dart';

/// Provider para el locale actual de la aplicación.
///
/// Cambia este valor para alternar entre idiomas en runtime.
final localeProvider = StateProvider<Locale>(
  (_) => const Locale('es'),
);

/// Provider que expone la instancia de [AppLocalizations] reactiva.
///
/// Se recalcula automáticamente cuando cambia [localeProvider].
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return AppLocalizations(locale);
});

/// Sistema de localización key-based para TeeDoo.
///
/// Uso desde widgets con Riverpod:
/// ```dart
/// final l = ref.watch(appLocalizationsProvider);
/// Text(l.t('login_title'));
/// ```
///
/// Uso desde BuildContext (requiere que TeeDooLocalizationsDelegate
/// esté registrado en el MaterialApp):
/// ```dart
/// final l = AppLocalizations.of(context);
/// Text(l.t('dashboard'));
/// ```
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  /// Obtiene la instancia desde el BuildContext.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Mapa de strings indexado por código de idioma.
  static const _localizedStrings = <String, Map<String, String>>{
    'es': stringsEs,
    'en': stringsEn,
  };

  /// Traduce una clave a la cadena localizada.
  ///
  /// Si la clave no existe en el idioma actual, intenta con español
  /// como fallback. Si tampoco existe, devuelve la propia clave.
  ///
  /// Soporta interpolación con placeholders `{key}`:
  /// ```dart
  /// l.t('step_x_of_y', {'step': '1', 'total': '3'})
  /// // -> "Paso 1 de 3"
  /// ```
  String t(String key, [Map<String, String>? params]) {
    final strings = _localizedStrings[locale.languageCode] ?? stringsEs;
    var value = strings[key] ?? stringsEs[key] ?? key;

    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }

    return value;
  }

  /// Obtiene el código de idioma actual.
  String get languageCode => locale.languageCode;

  /// Verifica si el idioma actual es español.
  bool get isSpanish => locale.languageCode == 'es';

  /// Verifica si el idioma actual es inglés.
  bool get isEnglish => locale.languageCode == 'en';

  /// Locales soportados por la aplicación.
  static const supportedLocales = [
    Locale('es'),
    Locale('en'),
  ];
}

/// Delegate de localización para integrar con MaterialApp.
class TeeDooLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const TeeDooLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(TeeDooLocalizationsDelegate old) => false;
}
