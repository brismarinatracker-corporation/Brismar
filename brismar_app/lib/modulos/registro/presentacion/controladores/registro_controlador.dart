import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../dominio/entidades/registro_entidad.dart';
import '../../dominio/repositorios/registro_repositorio.dart';
import '../../dominio/casos_uso/guardar_registro_caso_uso.dart';
import '../../dominio/casos_uso/obtener_historial_caso_uso.dart';
import '../../dominio/casos_uso/sincronizar_pendientes_caso_uso.dart';
import '../../datos/fuentes_datos/fuente_datos_registro_local.dart';
import '../../datos/fuentes_datos/fuente_datos_registro_remota.dart';
import '../../datos/repositorios/registro_repositorio_imp.dart';

/// Proveedor para la instancia de [RegistroRepositorio].
final proveedorRegistroRepositorio = Provider<RegistroRepositorio>((ref) {
  return RegistroRepositorioImp(
    fuenteDatosLocal: FuenteDatosRegistroLocal(),
    fuenteDatosRemota: FuenteDatosRegistroRemota(),
  );
});

/// Proveedor del caso de uso para guardar registros.
final proveedorGuardarRegistro = Provider<GuardarRegistroCasoUso>((ref) {
  final repositorio = ref.read(proveedorRegistroRepositorio);
  return GuardarRegistroCasoUso(repositorio);
});

/// Proveedor del caso de uso para obtener el historial.
final proveedorObtenerHistorial = Provider<ObtenerHistorialCasoUso>((ref) {
  final repositorio = ref.read(proveedorRegistroRepositorio);
  return ObtenerHistorialCasoUso(repositorio);
});

/// Proveedor del caso de uso para sincronizar registros pendientes.
final proveedorSincronizarPendientes = Provider<SincronizarPendientesCasoUso>((
  ref,
) {
  final repositorio = ref.read(proveedorRegistroRepositorio);
  return SincronizarPendientesCasoUso(repositorio);
});

/// Controlador del historial de registros de pesca.
/// Administra el estado de la lista cargada en pantalla.
final proveedorHistorialController =
    StateNotifierProvider<HistorialNotifier, AsyncValue<List<RegistroEntidad>>>(
      (ref) {
        final obtenerUsecase = ref.read(proveedorObtenerHistorial);
        final guardarUsecase = ref.read(proveedorGuardarRegistro);
        return HistorialNotifier(
          obtenerHistorial: obtenerUsecase,
          guardarRegistro: guardarUsecase,
        );
      },
    );

class HistorialNotifier
    extends StateNotifier<AsyncValue<List<RegistroEntidad>>> {
  final ObtenerHistorialCasoUso _obtenerHistorial;
  final GuardarRegistroCasoUso _guardarRegistro;

  HistorialNotifier({
    required ObtenerHistorialCasoUso obtenerHistorial,
    required GuardarRegistroCasoUso guardarRegistro,
  }) : _obtenerHistorial = obtenerHistorial,
       _guardarRegistro = guardarRegistro,
       super(const AsyncValue.loading()) {
    cargarHistorial();
  }

  /// Carga el historial desde la base de datos local SQLite.
  Future<void> cargarHistorial() async {
    state = const AsyncValue.loading();
    try {
      final lista = await _obtenerHistorial.ejecutar();
      state = AsyncValue.data(lista);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Guarda un nuevo registro (local + intento remoto) y refresca la lista.
  Future<void> registrarNuevaEmbarcacion(RegistroEntidad registro) async {
    try {
      await _guardarRegistro.ejecutar(registro);
      await cargarHistorial(); // Refrescamos el historial local
    } catch (e) {
      throw Exception('Error al guardar registro: $e');
    }
  }
}

/// Controlador para la sincronización automática offline-first.
final proveedorSyncController =
    StateNotifierProvider<SyncNotifier, AsyncValue<void>>((ref) {
      final syncUsecase = ref.read(proveedorSincronizarPendientes);
      return SyncNotifier(syncUsecase: syncUsecase, ref: ref);
    });

class SyncNotifier extends StateNotifier<AsyncValue<void>> {
  final SincronizarPendientesCasoUso _syncUsecase;
  final Ref _ref;

  SyncNotifier({
    required SincronizarPendientesCasoUso syncUsecase,
    required Ref ref,
  }) : _syncUsecase = syncUsecase,
       _ref = ref,
       super(const AsyncValue.data(null)) {
    // Escucha cambios de conectividad en segundo plano
    Connectivity().onConnectivityChanged.listen((results) {
      // connectivity_plus v6.0+ devuelve una lista de ConnectivityResult
      final hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );

      if (hasConnection) {
        ejecutarSincronizacion();
      }
    });
  }

  /// Ejecuta la sincronización de registros pendientes hacia Supabase.
  Future<void> ejecutarSincronizacion() async {
    state = const AsyncValue.loading();
    try {
      await _syncUsecase.ejecutar();
      state = const AsyncValue.data(null);
      // Recargar historial si se sincronizó correctamente
      _ref.read(proveedorHistorialController.notifier).cargarHistorial();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
