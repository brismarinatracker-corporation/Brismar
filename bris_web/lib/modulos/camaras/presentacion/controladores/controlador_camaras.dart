import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/modelos/camara_modelo.dart';
import '../../datos/fuentes/fuente_datos_camaras.dart';

final fuenteDatosCamarasProvider = Provider((ref) => FuenteDatosCamaras());

final controladorCamarasProvider =
    AsyncNotifierProvider<ControladorCamaras, List<Camara>>(() {
      return ControladorCamaras();
    });

class ControladorCamaras extends AsyncNotifier<List<Camara>> {
  late FuenteDatosCamaras _fuenteDatos;

  @override
  FutureOr<List<Camara>> build() async {
    _fuenteDatos = ref.watch(fuenteDatosCamarasProvider);
    return _fuenteDatos.obtenerCamaras();
  }

  Future<void> guardarCamara(Camara camara) async {
    try {
      if (camara.id.isEmpty) {
        final nuevo = await _fuenteDatos.crearCamara(camara);
        if (state.hasValue) {
          state = AsyncValue.data([nuevo, ...state.value!]);
        }
      } else {
        final actualizado = await _fuenteDatos.actualizarCamara(camara);
        if (state.hasValue) {
          final listaActualizada = state.value!
              .map((e) => e.id == actualizado.id ? actualizado : e)
              .toList();
          state = AsyncValue.data(listaActualizada);
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> alternarEstado(Camara camara) async {
    try {
      final actualizado = camara.copyWith(estadoActivo: !camara.estadoActivo);
      await guardarCamara(actualizado);
    } catch (e) {
      rethrow;
    }
  }
}
