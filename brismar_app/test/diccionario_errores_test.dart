import 'package:flutter_test/flutter_test.dart';
import 'package:brismar_mobile/nucleo/errores/diccionario_errores.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('DiccionarioErrores Tests', () {
    test('Debe devolver el mensaje por defecto para errores desconocidos', () {
      final error = DiccionarioErrores.obtener('CODIGO_INVENTADO');
      expect(error.codigo, equals('GEN-001'));
      expect(error.descripcion, equals('Excepción desconocida no capturada por los manejadores estándar.'));
      expect(error.mensaje, equals('Ocurrió un error inesperado en el sistema.'));
    });

    test('Debe mapear ExcepcionApp correctamente', () {
      const excepcion = ExcepcionApp('NET-002', mensajeTecnico: 'Timeout');
      final error = DiccionarioErrores.mapear(excepcion);
      expect(error.codigo, equals('NET-002'));
      expect(error.mensaje, equals('Tiempo de espera de conexión agotado.'));
    });

    test('Debe mapear AuthException de Supabase a error de Autenticación genérico', () {
      final authEx = const AuthException('Invalid login credentials', statusCode: '400');
      final error = DiccionarioErrores.mapear(authEx);
      expect(error.codigo, equals('AUTH-001'));
      expect(error.mensaje, equals('Usuario o contraseña incorrectos.'));
    });

    test('Debe mapear PostgrestException a error de Base de Datos', () {
      final dbEx = const PostgrestException(message: 'Row level security violation');
      final error = DiccionarioErrores.mapear(dbEx);
      expect(error.codigo, equals('SRV-002'));
      expect(error.mensaje, equals('Error en la consulta del servidor.'));
    });
  });
}
