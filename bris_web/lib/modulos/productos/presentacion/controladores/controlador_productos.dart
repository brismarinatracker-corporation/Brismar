import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/modelos/producto_modelo.dart';
import '../../datos/fuentes/fuente_datos_productos.dart';

final fuenteDatosProductosProvider = Provider((ref) => FuenteDatosProductos());

final controladorProductosProvider = AsyncNotifierProvider<ControladorProductos, List<Producto>>(() {
  return ControladorProductos();
});

class ControladorProductos extends AsyncNotifier<List<Producto>> {
  late FuenteDatosProductos _fuenteDatos;

  @override
  FutureOr<List<Producto>> build() async {
    _fuenteDatos = ref.watch(fuenteDatosProductosProvider);
    return _fuenteDatos.obtenerProductos();
  }

  Future<void> guardarProducto(Producto producto) async {
    try {
      if (producto.id.isEmpty) {
        final nuevo = await _fuenteDatos.crearProducto(producto);
        if (state.hasValue) {
          state = AsyncValue.data([nuevo, ...state.value!]);
        }
      } else {
        final actualizado = await _fuenteDatos.actualizarProducto(producto);
        if (state.hasValue) {
          final listaActualizada = state.value!.map((e) => e.id == actualizado.id ? actualizado : e).toList();
          state = AsyncValue.data(listaActualizada);
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> alternarEstado(Producto producto) async {
    try {
      final actualizado = producto.copyWith(estadoActivo: !producto.estadoActivo);
      await guardarProducto(actualizado);
    } catch (e) {
      rethrow;
    }
  }
}
