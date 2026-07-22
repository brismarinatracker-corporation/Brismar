import 'package:supabase_flutter/supabase_flutter.dart';
import '../dominio/modelos/maestros_modelo.dart';

/// Fuente de datos remota para las tablas maestras de BRISMAR.
///
/// Consulta Supabase para obtener catálogos de negocio que cambian poco:
/// especies de pesca y tipos de gasto. Estos datos alimentan los dropdowns
/// y selectores en toda la Web Admin.
class FuenteDatosMaestros {
  final SupabaseClient _cliente;

  const FuenteDatosMaestros(this._cliente);

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
