import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final datos = await _cliente.from('zarpes').select().order('fecha_zarpe', ascending: false);
    return List<Map<String, dynamic>>.from(datos);
  }

  Future<void> recargar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_cargarZarpes);
  }

  Future<void> marcarComoRecibido(String id) async {
    try {
      await _cliente.from('zarpes').update({'estado': 'RECIBIDO_LAMBAYEQUE'}).eq('id', id);
      await recargar(); // Refrescar el estado después de actualizar
    } catch (e) {
      throw Exception('No se pudo actualizar el estado en Supabase: $e');
    }
  }
}
