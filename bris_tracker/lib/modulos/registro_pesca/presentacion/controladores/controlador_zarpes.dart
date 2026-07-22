import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../dominio/entidades/zarpe_entidad.dart';
import '../../dominio/repositorios/zarpe_repositorio.dart';
import '../../registro_pesca_inyeccion.dart';

/// Provider del controlador de zarpes.
///
/// Usa [AsyncNotifierProvider] (Riverpod 2.x) en lugar del deprecated
/// [StateNotifierProvider]. El estado expuesto es [AsyncValue<void>]:
/// - [AsyncData(null)] → operación completada o sin actividad.
/// - [AsyncLoading] → registrando zarpe en curso.
/// - [AsyncError] → fallo al guardar zarpe (nunca por errores de sync, esos son silenciosos).
final proveedorZarpes =
    AsyncNotifierProvider<ControladorZarpes, void>(ControladorZarpes.new);

/// Controlador de zarpes offline-first.
///
/// Gestiona el ciclo de vida completo de un zarpe:
/// 1. Persistencia local inmediata en SQLite (nunca pierde datos sin red).
/// 2. Sincronización upstream a Supabase cuando hay conectividad.
/// 3. Descarga downstream de cambios de estado desde Supabase.
class ControladorZarpes extends AsyncNotifier<void> {
  late final ZarpeRepositorio _repositorio;

  @override
  Future<void> build() async {
    // Lee el repositorio desde el grafo de dependencias de Riverpod.
    // No inicializa datos aquí: los zarpes no se muestran en una lista
    // desde este provider; el estado es solo el resultado de la última acción.
    _repositorio = ref.read(proveedorZarpeRepositorio);
  }

  /// Registra un zarpe localmente y lo intenta subir a Supabase.
  ///
  /// Emite [AsyncLoading] mientras guarda y [AsyncError] si falla.
  /// Relanza la excepción para que la UI del formulario pueda mostrar un mensaje
  /// de error al usuario sin depender del estado del provider.
  Future<void> registrarZarpe(ZarpeEntidad zarpe) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repositorio.guardarZarpe(zarpe));
    // Si guard capturó un error, lo relanzamos para que el formulario
    // pueda mostrar el SnackBar de error correspondiente.
    final error = state.error;
    if (error != null) throw error;
  }

  /// Sincroniza todos los zarpes con [sincronizado == 0] hacia Supabase.
  ///
  /// Operación en background: los errores no cambian el estado del provider
  /// para no mostrar errores innecesarios al usuario durante el auto-sync.
  Future<void> sincronizarZarpesPendientes() async {
    try {
      await _repositorio.sincronizarPendientes();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ControladorZarpes] Error en sincronización upstream: $e');
      }
    }
  }

  /// Descarga cambios de estado de negocio desde Supabase al SQLite local.
  ///
  /// Consulta zarpes actualizados en los últimos días configurados en
  /// [AppConstants.diasSyncDownstreamZarpes] y actualiza la BD local.
  Future<void> sincronizarZarpesDownstream() async {
    try {
      await _repositorio.sincronizarZarpesDownstream();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ControladorZarpes] Error en sincronización downstream: $e');
      }
    }
  }
}
