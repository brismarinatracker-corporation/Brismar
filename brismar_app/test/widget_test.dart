import 'package:flutter_test/flutter_test.dart';
import 'package:brismar_mobile/modulos/registro/dominio/entidades/registro_entidad.dart';
import 'package:brismar_mobile/modulos/registro/datos/modelos/registro_modelo.dart';
import 'package:brismar_mobile/nucleo/seguridad/servicio_cifrado.dart';

void main() {
  group('RegistroEntidad Tests de Cálculos Financieros', () {
    test('Cálculo correcto de Ingreso Bruto, Gastos y Utilidad Neta', () {
      const registro = RegistroEntidad(
        id: 'test-uuid-12345',
        usuarioId: 'usuario-uuid-12345',
        nombreEmbarcacion: 'Don Jose',
        producto: 'POTA',
        kilos: 1000.0,
        precioPorKilo: 5.50,
        fecha: '2026-05-26',
        hora: '10:00',
        muelleInicio: 'Muelle A',
        gastoFacturacion: 100.0,
        gastoPersonal: 150.0,
        gastoApoyo: 50.0,
        gastoAgua: 20.0,
        gastoClorox: 10.0,
        gastoFlete: 300.0,
        gastoHielo: 200.0,
        gastoOtros: 50.0,
      );

      // Ingreso bruto: 1000 * 5.50 = 5500
      expect(registro.ingresoBruto, equals(5500.0));

      // Total gastos: 100 + 150 + 50 + 20 + 10 + 300 + 200 + 50 = 880
      expect(registro.totalGastos, equals(880.0));

      // Utilidad neta: 5500 - 880 = 4620
      expect(registro.utilidadNeta, equals(4620.0));
    });
  });

  group('RegistroModelo Tests de Mapeo', () {
    test('Incluye usuario_id en payload Supabase para soportar RLS', () {
      const registro = RegistroModelo(
        id: '11111111-1111-4111-8111-111111111111',
        usuarioId: '22222222-2222-4222-8222-222222222222',
        nombreEmbarcacion: 'Don Jose',
        producto: 'POTA',
        kilos: 1000,
        precioPorKilo: 5.5,
        fecha: '2026-05-26',
        hora: '10:00',
        muelleInicio: 'Muelle A',
      );

      expect(
        registro.toJson()['usuario_id'],
        equals('22222222-2222-4222-8222-222222222222'),
      );
    });

    test('fromJson acepta sincronizado booleano, entero y decimal string', () {
      final baseJson = {
        'id': '11111111-1111-4111-8111-111111111111',
        'usuario_id': '22222222-2222-4222-8222-222222222222',
        'nombre_embarcacion': 'Don Jose',
        'producto': 'POTA',
        'placa_carro': null,
        'kilos': '1000.25',
        'precio_por_kilo': '5.50',
        'fecha': '2026-05-26',
        'hora': '10:00',
        'muelle_inicio': 'Muelle A',
        'gasto_facturacion': '100.00',
        'gasto_personal': '150.00',
        'gasto_apoyo': '50.00',
        'gasto_agua': '20.00',
        'gasto_clorox': '10.00',
        'gasto_flete': '300.00',
        'gasto_hielo': '200.00',
        'gasto_otros': '50.00',
      };

      final boolJson = RegistroModelo.fromJson({
        ...baseJson,
        'sincronizado': true,
      });
      final intJson = RegistroModelo.fromJson({...baseJson, 'sincronizado': 1});

      expect(boolJson.sincronizado, isTrue);
      expect(intJson.sincronizado, isTrue);
      expect(intJson.kilos, equals(1000.25));
      expect(intJson.precioPorKilo, equals(5.5));
    });
  });

  group('ServicioCifrado AES-256-CBC Tests', () {
    test('Cifrado y descifrado correcto', () {
      const textoOriginal = 'Hola Mundo Brismar';
      const clave = 'clave-secreta-super-larga-32ch';
      const iv = 'vector-inicial16';

      final cifrado = ServicioCifrado.cifrarAes(textoOriginal, clave, iv);
      expect(cifrado, isNot(equals(textoOriginal)));

      final descifrado = ServicioCifrado.descifrarAes(cifrado, clave, iv);
      expect(descifrado, equals(textoOriginal));
    });
  });
}
