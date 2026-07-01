import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../../datos/fuente_datos_cuadres_web.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';

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
    bool? cargando, bool? exportando, String? error,
    List<CuadreWebModelo>? cuadres, DateTime? filtroDesde, DateTime? filtroHasta,
    String? cuadreSeleccionadoId, bool limpiarError = false,
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
/// Gestiona: listado, filtros de fecha, selección de fila y exportación a Excel.
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

  /// Exporta un cuadre específico con sus relaciones a un archivo Excel.
  Future<void> exportarCuadreAExcel(CuadreWebModelo cuadre) async {
    state = state.copiarCon(exportando: true);
    try {
      final bytes = _generarExcel(cuadre);
      final nombreArchivo = 'Cuadre_${cuadre.placa}_${DateTime.now().millisecondsSinceEpoch}';
      await FileSaver.instance.saveFile(
        name: nombreArchivo,
        bytes: bytes,
        mimeType: MimeType.microsoftExcel,
      );
      state = state.copiarCon(exportando: false);
    } catch (e) {
      state = state.copiarCon(exportando: false, error: 'Error al exportar: $e');
    }
  }

  /// Genera los bytes del archivo Excel para un cuadre.
  Uint8List _generarExcel(CuadreWebModelo cuadre) {
    final fmt = NumberFormat('#,##0.00', 'es_PE');
    final excel = Excel.createExcel();
    _agregarHojaCabecera(excel, cuadre, fmt);
    _agregarHojaCompras(excel, cuadre, fmt);
    _agregarHojaGastos(excel, cuadre, fmt);
    _agregarHojaVentas(excel, cuadre, fmt);
    return Uint8List.fromList(excel.save()!);
  }

  void _agregarHojaCabecera(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Resumen'];
    excel.setDefaultSheet('Resumen');
    _fila(hoja, ['CUADRE BRISMAR - RESUMEN']);
    _fila(hoja, ['Placa:', c.placa]);
    _fila(hoja, ['Fecha Zarpe:', c.fechaZarpe ?? '-']);
    _fila(hoja, ['Estado:', c.estado.toUpperCase()]);
    _fila(hoja, ['Planta Destino:', c.plantaDestino ?? '-']);
    _fila(hoja, ['Peso Total (kg):', c.pesoTotal?.toString() ?? '-']);
    _fila(hoja, ['']);
    _fila(hoja, ['TOTALES']);
    _fila(hoja, ['Total Compras:', 'S/ ${fmt.format(c.totalCompras)}']);
    _fila(hoja, ['Total Gastos:', 'S/ ${fmt.format(c.totalGastos)}']);
    _fila(hoja, ['Total Ventas:', 'S/ ${fmt.format(c.totalVentas)}']);
    _fila(hoja, ['Utilidad Neta:', 'S/ ${fmt.format(c.utilidadNeta)}']);
  }

  void _agregarHojaCompras(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Compras'];
    _fila(hoja, ['Embarcación', 'Producto', 'Kilos', 'Precio Unit.', 'Total']);
    for (var item in c.compras) {
      _fila(hoja, [item.embarcacion, item.producto, item.kilos, fmt.format(item.precioUnitario), fmt.format(item.total)]);
    }
  }

  void _agregarHojaGastos(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Gastos'];
    _fila(hoja, ['Tipo', 'Concepto', 'Cantidad', 'Costo Unit.', 'Total']);
    for (var item in c.gastos) {
      _fila(hoja, [item.tipo, item.concepto, item.cantidad, fmt.format(item.costoUnitario), fmt.format(item.total)]);
    }
  }

  void _agregarHojaVentas(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Ventas'];
    _fila(hoja, ['Lugar', 'Producto', 'Kilos', 'Precio Unit.', 'Total']);
    for (var item in c.ventas) {
      _fila(hoja, [item.lugar, item.producto, item.kilos, fmt.format(item.precioUnitario), fmt.format(item.total)]);
    }
  }

  void _fila(Sheet hoja, List<dynamic> valores) {
    hoja.appendRow(valores.map((v) => TextCellValue(v.toString())).toList());
  }
}
