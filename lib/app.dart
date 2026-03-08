import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart' show appRouterProvider;
import 'core/services/ai_voice_service.dart';

/// Riverpod provider for the AI voice service.
final aiVoiceProvider = ChangeNotifierProvider<AiVoiceService>((ref) {
  return AiVoiceService();
});

/// Widget raíz de la aplicación TeeDoo.
///
/// Integra:
/// - Tema reactivo (dark/light/gray) via Riverpod
/// - Router (go_router)
/// - Localización (es/en) reactiva via Riverpod
class TeeDooApp extends ConsumerWidget {
  const TeeDooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    final ThemeMode flutterThemeMode = switch (themeMode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TeDoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: flutterThemeMode,
      routerConfig: router,

      // ── Localization ──
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        TeeDooLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
