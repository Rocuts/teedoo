import 'package:intl/intl.dart';

/// Funciones de formateo para la UI de TeeDoo.
///
/// Centraliza el formateo de monedas, fechas, identificadores fiscales
/// y números de factura para mantener consistencia en toda la app.
abstract final class Formatters {
  // ── Currency ──

  static final _currencyFormatEs = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '\u20AC',
    decimalDigits: 2,
  );

  static final _currencyFormatEn = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\u20AC',
    decimalDigits: 2,
  );

  /// Formatea un valor numérico como moneda EUR.
  ///
  /// [locale] acepta 'es' o 'en'. Por defecto 'es'.
  /// Ejemplo: `1234.5` -> `1.234,50 €` (es) o `€1,234.50` (en)
  static String currency(double amount, {String locale = 'es'}) {
    return switch (locale) {
      'en' => _currencyFormatEn.format(amount),
      _ => _currencyFormatEs.format(amount),
    };
  }

  /// Formatea un valor como cantidad compacta (ej: 1.2k, 3.4M).
  static String compactCurrency(double amount, {String locale = 'es'}) {
    final compact = NumberFormat.compactCurrency(
      locale: locale == 'es' ? 'es_ES' : 'en_US',
      symbol: '\u20AC',
      decimalDigits: 1,
    );
    return compact.format(amount);
  }

  // ── Dates ──

  /// Formatea un [DateTime] en formato corto.
  ///
  /// Es: `25/02/2026`  En: `02/25/2026`
  static String dateShort(DateTime date, {String locale = 'es'}) {
    final format = switch (locale) {
      'en' => DateFormat('MM/dd/yyyy'),
      _ => DateFormat('dd/MM/yyyy'),
    };
    return format.format(date);
  }

  /// Formatea un [DateTime] en formato largo legible.
  ///
  /// Es: `25 de febrero de 2026`  En: `February 25, 2026`
  static String dateLong(DateTime date, {String locale = 'es'}) {
    final format = switch (locale) {
      'en' => DateFormat.yMMMMd('en_US'),
      _ => DateFormat.yMMMMd('es_ES'),
    };
    return format.format(date);
  }

  /// Formatea un [DateTime] con hora.
  ///
  /// Es: `25/02/2026 14:30`  En: `02/25/2026 2:30 PM`
  static String dateTime(DateTime date, {String locale = 'es'}) {
    final format = switch (locale) {
      'en' => DateFormat('MM/dd/yyyy h:mm a'),
      _ => DateFormat('dd/MM/yyyy HH:mm'),
    };
    return format.format(date);
  }

  /// Formatea una fecha relativa: "Hace 5 min", "Hace 2h", "Ayer", etc.
  static String dateRelative(DateTime date, {String locale = 'es'}) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return locale == 'es' ? 'Ahora mismo' : 'Just now';
    }
    if (diff.inMinutes < 60) {
      final min = diff.inMinutes;
      return locale == 'es' ? 'Hace $min min' : '${min}m ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return locale == 'es' ? 'Hace ${hours}h' : '${hours}h ago';
    }
    if (diff.inDays == 1) {
      return locale == 'es' ? 'Ayer' : 'Yesterday';
    }
    if (diff.inDays < 7) {
      final days = diff.inDays;
      return locale == 'es' ? 'Hace $days días' : '${days}d ago';
    }
    return dateShort(date, locale: locale);
  }

  // ── NIF / CIF ──

  /// Formatea un NIF/CIF para presentación visual.
  ///
  /// Ejemplo: `12345678A` -> `12.345.678-A`
  /// Ejemplo: `B12345678` -> `B-12345678`
  static String nifCif(String value) {
    final cleaned = value.trim().toUpperCase().replaceAll(RegExp(r'[\s.-]'), '');

    if (cleaned.isEmpty) return '';

    // CIF: letra + 8 dígitos
    if (RegExp(r'^[A-Z]\d{8}$').hasMatch(cleaned)) {
      return '${cleaned[0]}-${cleaned.substring(1)}';
    }

    // NIF: 8 dígitos + letra
    if (RegExp(r'^\d{8}[A-Z]$').hasMatch(cleaned)) {
      return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}-${cleaned[8]}';
    }

    // NIE: letra + 7 dígitos + letra
    if (RegExp(r'^[XYZ]\d{7}[A-Z]$').hasMatch(cleaned)) {
      return '${cleaned[0]}-${cleaned.substring(1, 8)}-${cleaned[8]}';
    }

    // No reconocido, devolver tal cual en mayúsculas
    return cleaned;
  }

  // ── Invoice Number ──

  /// Formatea un número de factura con prefijo y padding.
  ///
  /// Ejemplo: `invoiceNumber(42, prefix: 'FAC')` -> `FAC-2026-00042`
  static String invoiceNumber(
    int number, {
    String prefix = 'FAC',
    int? year,
  }) {
    final y = year ?? DateTime.now().year;
    final padded = number.toString().padLeft(5, '0');
    return '$prefix-$y-$padded';
  }

  // ── Percentages ──

  /// Formatea un valor como porcentaje.
  ///
  /// Ejemplo: `0.21` -> `21%`  /  `21.0` -> `21%`
  static String percentage(double value, {int decimals = 0}) {
    final normalized = value > 1 ? value : value * 100;
    return '${normalized.toStringAsFixed(decimals)}%';
  }

  // ── Numbers ──

  /// Formatea un número con separadores de miles.
  static String number(num value, {String locale = 'es'}) {
    final format = NumberFormat.decimalPattern(
      locale == 'es' ? 'es_ES' : 'en_US',
    );
    return format.format(value);
  }

  // ── Duration ──

  /// Formatea una duración en días como texto legible.
  ///
  /// Ejemplo: `32` -> `32 días` (es) / `32 days` (en)
  static String durationDays(int days, {String locale = 'es'}) {
    if (days == 1) {
      return locale == 'es' ? '1 día' : '1 day';
    }
    return locale == 'es' ? '$days días' : '$days days';
  }
}
