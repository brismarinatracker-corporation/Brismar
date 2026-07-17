import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../datos/fuente_datos_transito.dart';
import '../../datos/repositorio_edicion_zarpe.dart';
import '../../dominio/modelos/zarpe_modelo.dart';

// ─── Providers de infraestructura ─────────────────────────────────────────────

/// Provider interno del cliente Supabase para el módulo de Tránsito.
final _proveedorClienteSupabase = Provider((_) => Supabase.instance.client);

/// Provider de la fuente de datos remota para el módulo de Tránsitos.
final proveedorFuenteDatosTransito = Provider<FuenteDatosTransito>((ref) {
  return FuenteDatosTransito(ref.watch(_proveedorClienteSupabase));
});

/// Provider del repositorio de edición de zarpes.
final proveedorRepositorioEdicionZarpe = Provider<RepositorioEdicionZarpe>((ref) {
  return RepositorioEdicionZarpe(ref.watch(_proveedorClienteSupabase));
});

// ─── Filtro ───────────────────────────────────────────────────────────────────

/// Provider del filtro activo en la pantalla de Tránsito.
///
/// Separado de [PantallaTransito] para respetar SRP: el estado del filtro
/// pertenece a la capa de lógica, no a la vista.
final proveedorFiltroTransito =
    NotifierProvider<FiltroTransitoNotifier, String>(FiltroTransitoNotifier.new);

/// Notifier que gestiona el filtro temporal de zarpes.
class FiltroTransitoNotifier extends Notifier<String> {
  @override
  String build() => 'todos';

  /// Actualiza el filtro activo. El [ControladorTransito] reacciona
  /// automáticamente al cambio por estar vinculado con [ref.watch].
  void establecerFiltro(String nuevoFiltro) => state = nuevoFiltro;
}

// ─── Controlador principal ────────────────────────────────────────────────────

/// Provider principal del módulo de Tránsito.
///
/// Usa [ref.keepAlive()] para preservar los datos al navegar entre módulos
/// y evitar re-fetches innecesarios a Supabase.
final proveedorTransito =
    AsyncNotifierProvider<ControladorTransito, List<ZarpeModelo>>(
  ControladorTransito.new,
);

/// Controlador del módulo de Tránsito/Zarpes.
///
/// Escucha el filtro activo ([proveedorFiltroTransito]) y recarga los datos
/// automáticamente cuando cambia. Mantiene el estado vivo entre navegaciones.
class ControladorTransito
    extends AsyncNotifier<List<ZarpeModelo>> {
  late FuenteDatosTransito _fuente;

  @override
  Future<List<ZarpeModelo>> build() async {
    ref.keepAlive();
    _fuente = ref.watch(proveedorFuenteDatosTransito);
    final filtro = ref.watch(proveedorFiltroTransito);
    return _fuente.obtenerZarpes(filtro: filtro);
  }

  /// Fuerza una recarga completa de zarpes desde Supabase.
  Future<void> recargar() async {
    state = const AsyncValue.loading();
    final filtro = ref.read(proveedorFiltroTransito);
    state = await AsyncValue.guard(
      () => _fuente.obtenerZarpes(filtro: filtro),
    );
  }

  /// Carga la siguiente página de registros desde Supabase (Paginación Real).
  Future<void> cargarMas() async {
    if (state.isLoading || state.hasError) return;
    
    final actuales = state.value ?? [];
    final filtro = ref.read(proveedorFiltroTransito);
    
    // Obtenemos los siguientes 30 registros
    final nuevos = await _fuente.obtenerZarpes(
      filtro: filtro, 
      offset: actuales.length,
      limite: 30,
    );
    
    if (nuevos.isNotEmpty) {
      state = AsyncData([...actuales, ...nuevos]);
    }
  }

  /// Registra la recepción de un zarpe en la planta procesadora.
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
    } on Exception catch (e) {
      throw Exception('No se pudo registrar la recepción en planta: $e');
    }
  }

  /// Obtiene un zarpe específico por su ID único.
  Future<ZarpeModelo?> obtenerZarpePorId(String id) async {
    try {
      return await _fuente.obtenerZarpePorId(id);
    } on Exception catch (e) {
      throw Exception('No se pudo obtener el zarpe: $e');
    }
  }
}
