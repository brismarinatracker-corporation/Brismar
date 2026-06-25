import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../nucleo/base_datos/gestor_base_datos.dart';
import '../../../../nucleo/red/verificador_conexion.dart';
import '../../datos/fuentes_datos/fuente_datos_cuadres_local.dart';
import '../../datos/fuentes_datos/fuente_datos_cuadres_remota.dart';
import '../../datos/repositorios/cuadre_repositorio_imp.dart';
import '../../dominio/entidades/cuadre_entidad.dart';

final cuadreRepositorioProvider = Provider<CuadreRepositorioImp>((ref) {
  final local = FuenteDatosCuadresLocal(GestorBaseDatos.instance);
  final remota = FuenteDatosCuadresRemota(Supabase.instance.client);
  return CuadreRepositorioImp(local: local, remota: remota);
});

final cuadresProvider = StateNotifierProvider<CuadresNotifier, AsyncValue<List<CuadreEntidad>>>((ref) {
  return CuadresNotifier(ref.watch(cuadreRepositorioProvider));
});

class CuadresNotifier extends StateNotifier<AsyncValue<List<CuadreEntidad>>> {
  final CuadreRepositorioImp _repositorio;

  CuadresNotifier(this._repositorio) : super(const AsyncValue.loading()) {
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    try {
      state = const AsyncValue.loading();
      final cuadres = await _repositorio.obtenerHistorial();
      state = AsyncValue.data(cuadres);
      
      // Auto-sincronizar si hay internet
      // Sincronizar en la nube si hay red
      if (await VerificadorConexion.hayConexion()) {
        await _repositorio.sincronizarPendientes();
        final actualizados = await _repositorio.obtenerHistorial();
        state = AsyncValue.data(actualizados);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> guardarCuadre(CuadreEntidad cuadre) async {
    try {
      await _repositorio.guardarCuadre(cuadre);
      await cargarHistorial(); // Refrescar UI
    } catch (e) {
      rethrow;
    }
  }
}
