import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../datos/fuente_datos_cuadres_web.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';
import '../../servicios/servicio_exportacion.dart';

// ─── Estado ──────────────────────────────────────────────────────────────────

class EstadoCuadresWeb {
  final bool cargando;
  final bool exportando;
  final String? error;
  final List<CuadreWebModelo> cuadres;
  final DateTime? filtroDesde;
  final DateTime? filtroHasta;
  final String? cuadreSeleccionadoId;

  const EstadoCuadresWeb({
    this.cargando = false,
    this.exportando = false,
    this.error,
    this.cuadres = const [],
    this.filtroDesde,
    this.filtroHasta,
    this.cuadreSeleccionadoId,
  });

  CuadreWebModelo? get cuadreSeleccionado =>
      cuadres.where((c) => c.id == cuadreSeleccionadoId).firstOrNull;

  EstadoCuadresWeb copiarCon({
    bool? cargando,
    bool? exportando,
    String? error,
    List<CuadreWebModelo>? cuadres,
    DateTime? filtroDesde,
    DateTime? filtroHasta,
    String? cuadreSeleccionadoId,
    bool limpiarError = false,
    bool limpiarSeleccion = false,
  }) {
    return EstadoCuadresWeb(
      cargando: cargando ?? this.cargando,
      exportando: exportando ?? this.exportando,
      error: limpiarError ? null : (error ?? this.error),
      cuadres: cuadres ?? this.cuadres,
      filtroDesde: filtroDesde ?? this.filtroDesde,
      filtroHasta: filtroHasta ?? this.filtroHasta,
      cuadreSeleccionadoId: limpiarSeleccion ? null : (cuadreSeleccionadoId ?? this.cuadreSeleccionadoId),
    );
  }
}

// ─── Proveedores ──────────────────────────────────────────────────────────────

final fuenteCuadresWebProvider = Provider<FuenteDatosCuadresWeb>((ref) {
  return FuenteDatosCuadresWeb(Supabase.instance.client);
});

final controladorCuadresWebProvider =
    NotifierProvider<ControladorCuadresWeb, EstadoCuadresWeb>(
  ControladorCuadresWeb.new,
);

// ─── Controlador ──────────────────────────────────────────────────────────────

/// Controlador de la pantalla de Cuadres de la Web Admin.
///
/// Gestiona: listado, filtros de fecha, selección de fila y delegación de exportación a Excel.
class ControladorCuadresWeb extends Notifier<EstadoCuadresWeb> {
  late FuenteDatosCuadresWeb _fuente;

  @override
  EstadoCuadresWeb build() {
    _fuente = ref.watch(fuenteCuadresWebProvider);
    Future.microtask(cargarCuadres);
    return const EstadoCuadresWeb();
  }

  /// Carga cuadres aplicando los filtros activos del estado.
  Future<void> cargarCuadres() async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      final lista = await _fuente.obtenerTodos(
        desde: state.filtroDesde,
        hasta: state.filtroHasta,
      );
      state = state.copiarCon(cargando: false, cuadres: lista);
    } catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
    }
  }

  /// Actualiza el filtro de fecha inicio y recarga.
  Future<void> aplicarFiltroDesde(DateTime? fecha) async {
    state = state.copiarCon(filtroDesde: fecha);
    await cargarCuadres();
  }

  /// Actualiza el filtro de fecha fin y recarga.
  Future<void> aplicarFiltroHasta(DateTime? fecha) async {
    state = state.copiarCon(filtroHasta: fecha);
    await cargarCuadres();
  }

  /// Selecciona o deselecciona un cuadre para ver su detalle lateral.
  void seleccionarCuadre(String? id) {
    if (state.cuadreSeleccionadoId == id) {
      state = state.copiarCon(limpiarSeleccion: true);
    } else {
      state = state.copiarCon(cuadreSeleccionadoId: id);
    }
  }

  /// Exporta un cuadre específico con sus relaciones a un archivo Excel delegando en el servicio.
  Future<void> exportarCuadreAExcel(CuadreWebModelo cuadre) async {
    state = state.copiarCon(exportando: true);
    try {
      await ServicioExportacion.exportarCuadreUnicoAExcel(cuadre);
      state = state.copiarCon(exportando: false);
    } catch (e) {
      state = state.copiarCon(exportando: false, error: 'Error al exportar: $e');
    }
  }
}
