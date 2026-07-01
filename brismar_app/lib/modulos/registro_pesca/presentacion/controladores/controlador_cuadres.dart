import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../nucleo/base_datos/gestor_base_datos.dart';
import '../../../../nucleo/red/verificador_conexion.dart';
import '../../datos/fuentes_datos/fuente_datos_cuadres_local.dart';
import '../../datos/fuentes_datos/fuente_datos_cuadres_remota.dart';
import '../../datos/repositorios/cuadre_repositorio_imp.dart';
import '../../dominio/entidades/cuadre_entidad.dart';

import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

final cuadreRepositorioProvider = Provider<CuadreRepositorioImp>((ref) {
  final local = FuenteDatosCuadresLocal(GestorBaseDatos.instance);
  final remota = FuenteDatosCuadresRemota(Supabase.instance.client);
  return CuadreRepositorioImp(local: local, remota: remota);
});

final cuadresProvider = StateNotifierProvider<CuadresNotifier, AsyncValue<List<CuadreEntidad>>>((ref) {
  final authState = ref.watch(proveedorControladorAutenticacion);
  String usuarioId = '';
  if (authState is EstadoAutenticacionAutenticado) {
    usuarioId = authState.usuario.id;
  }
  return CuadresNotifier(ref.watch(cuadreRepositorioProvider), usuarioId);
});

class CuadresNotifier extends StateNotifier<AsyncValue<List<CuadreEntidad>>> {
  final CuadreRepositorioImp _repositorio;
  final String _usuarioId;

  CuadresNotifier(this._repositorio, this._usuarioId) : super(const AsyncValue.loading()) {
    if (_usuarioId.isNotEmpty) {
      cargarHistorial();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> cargarHistorial() async {
    if (_usuarioId.isEmpty) return;
    try {
      state = const AsyncValue.loading();
      final cuadres = await _repositorio.obtenerHistorial(_usuarioId);
      state = AsyncValue.data(cuadres);
      
      // Auto-sincronizar si hay internet
      // Sincronizar en la nube si hay red
      final verificador = VerificadorConexionImpl();
    if (await verificador.hayConexion()) {
        await _repositorio.sincronizarPendientes(_usuarioId);
        final actualizados = await _repositorio.obtenerHistorial(_usuarioId);
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
