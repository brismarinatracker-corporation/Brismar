import 'package:supabase_flutter/supabase_flutter.dart';

class ServicioDNI {
  /// Consulta un DNI invocando una Edge Function en Supabase.
  Future<Map<String, String>> consultarDNI(String dni) async {
    if (dni.length != 8) {
      throw Exception('El DNI debe tener exactamente 8 dígitos.');
    }

    try {
      final respuesta = await Supabase.instance.client.functions.invoke(
        'consulta_dni',
        body: {'dni': dni},
      );

      if (respuesta.status == 200) {
        final datos = respuesta.data;
        if (datos['nombres'] != null && datos['apellidoPaterno'] != null && datos['apellidoMaterno'] != null) {
          return {
            'nombres': datos['nombres'].toString(),
            'apellidoPaterno': datos['apellidoPaterno'].toString(),
            'apellidoMaterno': datos['apellidoMaterno'].toString(),
            'nombreCompleto': '${datos['nombres']} ${datos['apellidoPaterno']} ${datos['apellidoMaterno']}',
          };
        } else {
          throw Exception('Estructura de datos inesperada desde la API.');
        }
      } else {
        throw Exception('El DNI no fue encontrado o hubo un error.');
      }
    } on FunctionException catch (e) {
      throw Exception('Error en el servidor al consultar DNI: ${e.details ?? e.reasonPhrase}');
    } catch (e) {
      throw Exception('No se pudo verificar el DNI. Revisa tu conexión a internet o ingresa el nombre manualmente.');
    }
  }
}
