import 'package:supabase_flutter/supabase_flutter.dart';
import '../dominio/modelos/maestros_modelo.dart';

class FuenteDatosMaestros {
  final SupabaseClient _cliente;

  FuenteDatosMaestros(this._cliente);

  Future<List<EspecieModelo>> obtenerEspecies() async {
    try {
      final respuesta = await _cliente
          .from('especies_pesca')
          .select()
          .eq('activo', true)
          .order('orden', ascending: true);

      return (respuesta as List)
          .map((json) => EspecieModelo.desdeJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener especies: $e');
    }
  }

  Future<List<TipoGastoModelo>> obtenerTiposGasto() async {
    try {
      final respuesta = await _cliente
          .from('tipos_gasto')
          .select()
          .eq('activo', true)
          .order('orden', ascending: true);

      return (respuesta as List)
          .map((json) => TipoGastoModelo.desdeJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tipos de gasto: $e');
    }
  }
}
