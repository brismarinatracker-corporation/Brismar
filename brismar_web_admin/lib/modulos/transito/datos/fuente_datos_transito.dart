import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Fuente de datos remota para el módulo de Tránsitos/Zarpes.
class FuenteDatosTransito {
  final SupabaseClient _cliente;

  FuenteDatosTransito(this._cliente);

  /// Obtiene todos los zarpes ordenados por fecha.
  Future<List<Map<String, dynamic>>> obtenerZarpes() async {
    final datos = await _cliente
        .from('vista_zarpes_detallados')
        .select()
        .order('fecha_zarpe', ascending: false);
    return List<Map<String, dynamic>>.from(datos);
  }

  /// Registra la recepción final de una cámara/zarpe en la planta procesadora.
  Future<void> registrarRecepcionEnPlanta({
    required String id,
    required String planta,
    required String especie,
    required double kilos,
    required double precio,
  }) async {
    // 1. Actualizar el estado del Zarpe a recibido
    await _cliente.from('zarpes').update({'estado': 'RECIBIDO_LAMBAYEQUE'}).eq('id', id);

    // 2. Asegurar que exista el cuadre y actualizar sus datos de venta final
    final existeCuadre = await _cliente.from('cuadres').select('id').eq('id', id).maybeSingle();
    if (existeCuadre == null) {
      await _cliente.from('cuadres').insert({
        'id': id,
        'usuario_id': _cliente.auth.currentUser?.id ?? '',
        'placa': '', 
        'fecha_zarpe': DateTime.now().toIso8601String().substring(0, 10),
        'estado': 'completado',
        'planta_destino': planta,
        'peso_total': kilos,
      });
    } else {
      await _cliente.from('cuadres').update({
        'estado': 'completado',
        'planta_destino': planta,
        'peso_total': kilos,
      }).eq('id', id);
    }

    // 3. Registrar o actualizar la Venta asociada
    await _cliente.from('ventas').delete().eq('cuadre_id', id);
    await _cliente.from('ventas').insert({
      'id': const Uuid().v4(),
      'cuadre_id': id,
      'lugar': planta,
      'producto': especie,
      'kilos': kilos,
      'precio_unitario': precio,
      'total': kilos * precio,
    });
  }

  /// Obtiene un zarpe por su ID único.
  Future<Map<String, dynamic>?> obtenerZarpePorId(String id) async {
    return await _cliente
        .from('vista_zarpes_detallados')
        .select()
        .eq('id', id)
        .maybeSingle();
  }
}
