import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/cuadre_modelo.dart';
import '../../dominio/entidades/cuadre_entidad.dart';
import '../../datos/repositorios/cuadre_repositorio_imp.dart';
import '../../../../nucleo/red/verificador_conexion.dart';

import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../../registro_pesca_inyeccion.dart';

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

  Future<void> agregarGasto(String cuadreId, GastoEntidad nuevoGasto) async {
    if (state is AsyncData) {
      final cuadres = state.value!;
      final idx = cuadres.indexWhere((c) => c.id == cuadreId);
      if (idx != -1) {
        final cuadre = cuadres[idx];
        final nuevosGastos = List<GastoEntidad>.from(cuadre.gastos)..add(nuevoGasto);
        
        final cuadreActualizado = CuadreModelo(
          id: cuadre.id,
          usuarioId: cuadre.usuarioId,
          placa: cuadre.placa,
          fechaZarpe: cuadre.fechaZarpe,
          fechaCuadre: cuadre.fechaCuadre,
          estado: cuadre.estado,
          urlPdfCloud: cuadre.urlPdfCloud,
          urlExcelCloud: cuadre.urlExcelCloud,
          sincronizado: false, // Forzar sync
          fotoZarpeUrl: cuadre.fotoZarpeUrl,
          pesoTotal: cuadre.pesoTotal,
          cajasLlenas: cuadre.cajasLlenas,
          cajasVacias: cuadre.cajasVacias,
          tipoProducto: cuadre.tipoProducto,
          muellePartida: cuadre.muellePartida,
          pesador: cuadre.pesador,
          tipo: cuadre.tipo,
          cuadrilla: cuadre.cuadrilla,
          compras: cuadre.compras,
          gastos: nuevosGastos,
          ventas: cuadre.ventas,
        );
        
        await guardarCuadre(cuadreActualizado);
      }
    }
  }
}
