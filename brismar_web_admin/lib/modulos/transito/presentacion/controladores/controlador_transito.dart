import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../datos/fuente_datos_transito.dart';
import '../pantallas/pantalla_transito.dart';

final proveedorFuenteDatosTransito = Provider<FuenteDatosTransito>((ref) {
  return FuenteDatosTransito(Supabase.instance.client);
});

final proveedorTransito = AsyncNotifierProvider<ControladorTransito, List<Map<String, dynamic>>>(() {
  return ControladorTransito();
});

class ControladorTransito extends AsyncNotifier<List<Map<String, dynamic>>> {
  late FuenteDatosTransito _fuente;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    _fuente = ref.watch(proveedorFuenteDatosTransito);
    final filtro = ref.watch(proveedorFiltroTransito);
    return _fuente.obtenerZarpes(filtro: filtro);
  }

  Future<void> recargar() async {
    state = const AsyncValue.loading();
    final filtro = ref.read(proveedorFiltroTransito);
    state = await AsyncValue.guard(() => _fuente.obtenerZarpes(filtro: filtro));
  }

  Future<void> registrarRecepcionEnPlanta({
    required String id,
    required String planta,
    required String especie,
    required double kilos,
    required double precio,
  }) async {
    try {
      await _fuente.registrarRecepcionEnPlanta(
        id: id,
        planta: planta,
        especie: especie,
        kilos: kilos,
        precio: precio,
      );
      await recargar();
    } catch (e) {
      throw Exception('No se pudo registrar la recepción en planta: $e');
    }
  }

  Future<Map<String, dynamic>?> obtenerZarpePorId(String id) async {
    try {
      return await _fuente.obtenerZarpePorId(id);
    } catch (e) {
      throw Exception('No se pudo obtener el zarpe: $e');
    }
  }
}
