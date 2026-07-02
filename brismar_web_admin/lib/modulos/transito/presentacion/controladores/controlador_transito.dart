import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final proveedorTransito = AsyncNotifierProvider<ControladorTransito, List<Map<String, dynamic>>>(() {
  return ControladorTransito();
});

class ControladorTransito extends AsyncNotifier<List<Map<String, dynamic>>> {
  final _cliente = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _cargarZarpes();
  }

  Future<List<Map<String, dynamic>>> _cargarZarpes() async {
    final datos = await _cliente.from('vista_zarpes_detallados').select().order('fecha_zarpe', ascending: false);
    return List<Map<String, dynamic>>.from(datos);
  }

  Future<void> recargar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_cargarZarpes);
  }

  Future<void> registrarRecepcionEnPlanta({
    required String id,
    required String planta,
    required String especie,
    required double kilos,
    required double precio,
  }) async {
    try {
      // 1. Actualizar el estado del Zarpe a recibido
      await _cliente.from('zarpes').update({'estado': 'RECIBIDO_LAMBAYEQUE'}).eq('id', id);

      // 2. Asegurar que exista el cuadre y actualizar sus datos de venta final
      final existeCuadre = await _cliente.from('cuadres').select('id').eq('id', id).maybeSingle();
      if (existeCuadre == null) {
        await _cliente.from('cuadres').insert({
          'id': id,
          'usuario_id': _cliente.auth.currentUser?.id ?? '',
          'placa': '', // Se sincronizará al guardar o recargar
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

      await recargar();
    } catch (e) {
      throw Exception('No se pudo registrar la recepción en planta: $e');
    }
  }

  Future<Map<String, dynamic>?> obtenerZarpePorId(String id) async {
    try {
      return await _cliente.from('vista_zarpes_detallados').select().eq('id', id).maybeSingle();
    } catch (e) {
      throw Exception('No se pudo obtener el zarpe: $e');
    }
  }
}
