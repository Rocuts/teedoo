import 'package:flutter_test/flutter_test.dart';
import 'package:teedoo/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('acepta email válido', () {
      expect(Validators.email('usuario@empresa.com'), isNull);
    });

    test('rechaza email inválido', () {
      expect(
        Validators.email('usuario@@empresa'),
        'Formato de correo electrónico inválido',
      );
    });
  });

  group('Validators.password', () {
    test('rechaza contraseña débil', () {
      expect(Validators.password('abc123'), isNotNull);
    });

    test('acepta contraseña fuerte', () {
      expect(Validators.password('Abc12345!'), isNull);
    });
  });

  group('Validators.nifCif', () {
    test('valida NIF español correcto', () {
      expect(Validators.nifCif('12345678Z'), isNull);
    });

    test('rechaza NIF con letra incorrecta', () {
      expect(Validators.nifCif('12345678A'), 'La letra del NIF no es correcta');
    });
  });
}
