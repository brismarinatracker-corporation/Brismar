import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/entidades/zarpe_entidad.dart';
import '../../dominio/repositorios/zarpe_repositorio.dart';
import '../../registro_pesca_inyeccion.dart';
import 'package:flutter/foundation.dart';

final proveedorZarpes =
    StateNotifierProvider<ControladorZarpes, AsyncValue<void>>((ref) {
  return ControladorZarpes(ref.read(proveedorZarpeRepositorio));
});

/// Controlador de zarpes offline-first.
///
/// Persiste primero en SQLite y luego intenta sincronizar con Supabase
/// gracias a la implementación de [ZarpeRepositorio].
class ControladorZarpes extends StateNotifier<AsyncValue<void>> {
  final ZarpeRepositorio _repositorio;

  ControladorZarpes(this._repositorio) : super(const AsyncValue.data(null));

  /// Registra un zarpe localmente y lo intenta subir a Supabase.
  Future<void> registrarZarpe(ZarpeEntidad zarpe) async {
    state = const AsyncValue.loading();
    try {
      await _repositorio.guardarZarpe(zarpe);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Sincroniza todos los zarpes con [sincronizado = 0] hacia Supabase.
  Future<void> sincronizarZarpesPendientes() async {
    try {
      await _repositorio.sincronizarPendientes();
    } catch (e) {
      debugPrint('Error auto-sincronizando Zarpes: $e');
    }
  }

  /// Descarga los cambios de estado de negocio desde Supabase al SQLite local.
  Future<void> sincronizarZarpesDownstream() async {
    try {
      await _repositorio.sincronizarZarpesDownstream();
    } catch (e) {
      debugPrint('Error sincronizando downstream Zarpes: $e');
    }
  }
}
