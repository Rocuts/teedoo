/// Funciones de validación para formularios y datos de negocio.
///
/// Cada validador retorna `null` si el valor es válido,
/// o un mensaje de error descriptivo si es inválido.
abstract final class Validators {
  // ── Required Field ──

  /// Valida que un campo no esté vacío.
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  // ── Email ──

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );

  /// Valida formato de correo electrónico.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Formato de correo electrónico inválido';
    }
    return null;
  }

  // ── Password Strength ──

  /// Valida la fortaleza de una contraseña.
  ///
  /// Requiere al menos 8 caracteres, una mayúscula, una minúscula,
  /// un dígito y un carácter especial.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Debe contener al menos un carácter especial';
    }
    return null;
  }

  /// Evalúa la fortaleza de la contraseña como puntuación 0-4.
  static PasswordStrength passwordStrength(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (value.contains(RegExp(r'[0-9]')) &&
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score++;
    }
    return switch (score) {
      0 => PasswordStrength.weak,
      1 => PasswordStrength.fair,
      2 => PasswordStrength.good,
      3 => PasswordStrength.strong,
      _ => PasswordStrength.veryStrong,
    };
  }

  // ── NIF / CIF (Spanish Tax ID) ──

  static final _nifRegex = RegExp(r'^[0-9]{8}[A-Z]$');
  static final _nieRegex = RegExp(r'^[XYZ][0-9]{7}[A-Z]$');
  static final _cifRegex = RegExp(r'^[ABCDEFGHJNPQRSUVW][0-9]{7}[0-9A-J]$');

  static const _nifLetters = 'TRWAGMYFPDXBNJZSQVHLCKE';

  /// Valida un NIF/CIF/NIE español.
  ///
  /// Acepta NIF (12345678A), NIE (X1234567A) y CIF (B12345678).
  static String? nifCif(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El NIF/CIF es obligatorio';
    }

    final cleaned = value.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

    // NIF validation
    if (_nifRegex.hasMatch(cleaned)) {
      final number = int.parse(cleaned.substring(0, 8));
      final expectedLetter = _nifLetters[number % 23];
      if (cleaned[8] != expectedLetter) {
        return 'La letra del NIF no es correcta';
      }
      return null;
    }

    // NIE validation
    if (_nieRegex.hasMatch(cleaned)) {
      final prefix = switch (cleaned[0]) {
        'X' => '0',
        'Y' => '1',
        'Z' => '2',
        _ => '',
      };
      final number = int.parse('$prefix${cleaned.substring(1, 8)}');
      final expectedLetter = _nifLetters[number % 23];
      if (cleaned[8] != expectedLetter) {
        return 'La letra del NIE no es correcta';
      }
      return null;
    }

    // CIF validation
    if (_cifRegex.hasMatch(cleaned)) {
      return _validateCif(cleaned);
    }

    return 'Formato de NIF/CIF inválido';
  }

  /// Algoritmo de validación del dígito de control CIF.
  static String? _validateCif(String cif) {
    final digits = cif.substring(1, 8);
    var sumEven = 0;
    var sumOdd = 0;

    for (var i = 0; i < 7; i++) {
      final digit = int.parse(digits[i]);
      if (i.isEven) {
        // Posiciones impares (1-indexed): multiplicar por 2
        final doubled = digit * 2;
        sumOdd += (doubled > 9) ? doubled - 9 : doubled;
      } else {
        sumEven += digit;
      }
    }

    final total = sumOdd + sumEven;
    final control = (10 - (total % 10)) % 10;
    final lastChar = cif[8];

    // Algunos CIF terminan en letra, otros en número
    final letterControl = String.fromCharCode(64 + control); // A=1, B=2...
    if (lastChar == '$control' || lastChar == letterControl) {
      return null;
    }

    return 'El dígito de control del CIF no es válido';
  }

  // ── MFA Code ──

  /// Valida un código MFA de 6 dígitos.
  static String? mfaCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El código es obligatorio';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'El código debe ser de 6 dígitos';
    }
    return null;
  }

  // ── Postal Code (Spain) ──

  /// Valida un código postal español (5 dígitos, 01-52).
  static String? postalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El código postal es obligatorio';
    }
    if (!RegExp(r'^(?:0[1-9]|[1-4]\d|5[0-2])\d{3}$').hasMatch(value.trim())) {
      return 'Código postal español inválido';
    }
    return null;
  }
}

/// Nivel de fortaleza de contraseña.
enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
  veryStrong;

  String get label => switch (this) {
    PasswordStrength.weak => 'Débil',
    PasswordStrength.fair => 'Aceptable',
    PasswordStrength.good => 'Buena',
    PasswordStrength.strong => 'Fuerte',
    PasswordStrength.veryStrong => 'Muy fuerte',
  };

  double get normalizedScore => switch (this) {
    PasswordStrength.weak => 0.0,
    PasswordStrength.fair => 0.25,
    PasswordStrength.good => 0.5,
    PasswordStrength.strong => 0.75,
    PasswordStrength.veryStrong => 1.0,
  };
}
