import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';

/// Provider para el modo de tema actual de la aplicación.
///
/// Cambia este valor para alternar entre temas en runtime:
/// ```dart
/// ref.read(themeModeProvider.notifier).state = AppThemeMode.light;
/// ```
final themeModeProvider = StateProvider<AppThemeMode>(
  (ref) => AppThemeMode.light,
);
