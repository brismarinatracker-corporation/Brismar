import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../datos/fuente_datos_cuadres_web.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';
import '../../servicios/servicio_exportacion.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

// ─── Estado ──────────────────────────────────────────────────────────────────

class EstadoCuadresWeb {
  final bool cargando;
  final bool exportando;
  final String? error;
  final List<CuadreWebModelo> cuadres;
  final Map<String, CuadreWebModelo> _indice;
  final int paginaActual;
  final bool hayMasPaginas;
  final DateTime? filtroDesde;
  final DateTime? filtroHasta;
  final String? cuadreSeleccionadoId;

  const EstadoCuadresWeb({
    this.cargando = false,
    this.exportando = false,
    this.error,
    this.cuadres = const [],
    this.paginaActual = 1,
    this.hayMasPaginas = true,
    this.filtroDesde,
    this.filtroHasta,
    this.cuadreSeleccionadoId,
  }) : _indice = const {};

  EstadoCuadresWeb._conIndice({
    required this.cargando,
    required this.exportando,
    this.error,
    required this.cuadres,
    required Map<String, CuadreWebModelo> indice,
    required this.paginaActual,
    required this.hayMasPaginas,
    this.filtroDesde,
    this.filtroHasta,
    this.cuadreSeleccionadoId,
  }) : _indice = indice;

  CuadreWebModelo? get cuadreSeleccionado => _indice[cuadreSeleccionadoId];

  EstadoCuadresWeb copiarCon({
    bool? cargando,
    bool? exportando,
    String? error,
    List<CuadreWebModelo>? cuadres,
    int? paginaActual,
    bool? hayMasPaginas,
    Object? filtroDesde = _sentinel,
    Object? filtroHasta = _sentinel,
    String? cuadreSeleccionadoId,
    bool limpiarError = false,
    bool limpiarSeleccion = false,
  }) {
    final nuevosCuadres = cuadres ?? this.cuadres;
    final nuevoIndice = cuadres != null 
        ? {for (final c in nuevosCuadres) c.id: c} 
        : _indice;

    return EstadoCuadresWeb._conIndice(
      cargando: cargando ?? this.cargando,
      exportando: exportando ?? this.exportando,
      error: limpiarError ? null : (error ?? this.error),
      cuadres: nuevosCuadres,
      indice: nuevoIndice,
      paginaActual: paginaActual ?? this.paginaActual,
      hayMasPaginas: hayMasPaginas ?? this.hayMasPaginas,
      filtroDesde: filtroDesde == _sentinel ? this.filtroDesde : filtroDesde as DateTime?,
      filtroHasta: filtroHasta == _sentinel ? this.filtroHasta : filtroHasta as DateTime?,
      cuadreSeleccionadoId: limpiarSeleccion ? null : (cuadreSeleccionadoId ?? this.cuadreSeleccionadoId),
    );
  }
}

// Sentinel object para distinguir 'no se pasó valor' de 'se pasó null' en copiarCon.
const _sentinel = Object();

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
/// Gestiona: listado, filtros de fecha, selección de fila y delegación
/// de exportación a Excel.
/// Usa [ref.keepAlive()] para evitar re-fetches al navegar entre módulos.
class ControladorCuadresWeb extends Notifier<EstadoCuadresWeb> {
  late FuenteDatosCuadresWeb _fuente;

  @override
  EstadoCuadresWeb build() {
    ref.keepAlive();
    _fuente = ref.watch(fuenteCuadresWebProvider);
    scheduleMicrotask(cargarCuadres);
    return const EstadoCuadresWeb(cargando: true);
  }

  /// Carga cuadres aplicando los filtros activos del estado y paginación.
  Future<void> cargarCuadres({bool esCargaMas = false}) async {
    final nuevaPagina = esCargaMas ? state.paginaActual + 1 : 1;
    final limit = 50;
    final offset = (nuevaPagina - 1) * limit;

    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      final lista = await _fuente.obtenerTodos(
        desde: state.filtroDesde,
        hasta: state.filtroHasta,
        limit: limit,
        offset: offset,
      );
      
      final nuevosCuadres = esCargaMas ? [...state.cuadres, ...lista] : lista;
      
      state = state.copiarCon(
        cargando: false, 
        cuadres: nuevosCuadres,
        paginaActual: nuevaPagina,
        hayMasPaginas: lista.length == limit,
      );
    } on Exception catch (e) {
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
    if (id == null || state.cuadreSeleccionadoId == id) {
      state = state.copiarCon(limpiarSeleccion: true);
    } else {
      state = state.copiarCon(cuadreSeleccionadoId: id);
    }
  }

  /// Exporta un cuadre específico con sus relaciones a un archivo Excel.
  ///
  /// Si el cuadre no tiene [CuadreWebModelo.nombreBahia] (cuadres registrados
  /// antes del JOIN con usuarios), usa el nombre del usuario actualmente
  /// autenticado como fallback para no romper la plantilla.
  Future<void> exportarCuadreAExcel(CuadreWebModelo cuadre) async {
    state = state.copiarCon(exportando: true);
    try {
      // Fallback: si el cuadre antiguo no trajo nombreBahia del JOIN,
      // usar el nombre del usuario actualmente logueado.
      final cuadreConNombre = cuadre.nombreBahia != null
          ? cuadre
          : cuadre.conNombreBahia(ref.read(proveedorAutenticacion).nombreReal);
      await ServicioExportacion.exportarCuadreUnicoAExcel(cuadreConNombre);
      state = state.copiarCon(exportando: false);
    } on Exception catch (e) {
      state = state.copiarCon(exportando: false, error: 'Error al exportar: $e');
    }
  }
}
