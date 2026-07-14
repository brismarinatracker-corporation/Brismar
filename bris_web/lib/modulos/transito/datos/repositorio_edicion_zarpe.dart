// ============================================================
// Módulo   : Tránsito — Web Admin
// Archivo  : repositorio_edicion_zarpe.dart
// Propósito: Repositorio único para todas las operaciones de
//            escritura en la pantalla de edición de zarpes.
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../dominio/modelos/zarpe_modelo.dart';
import '../../cuadres/dominio/modelos/cuadre_web_modelo.dart';

/// Parámetros de entrada para guardar una edición de zarpe.
///
/// Desacopla la UI del repositorio: la pantalla construye este objeto
/// y el repositorio lo persiste, sin conocer la implementación de DB.
class EdicionZarpeParams {
  final String id;
  final String placa;
  final String chofer;
  final String muellePartida;
  final String? muelleDestino;
  final String? observaciones;
  final double? pesoTotal;
  final int? cajasLlenas;
  final int? cajasVacias;
  final int? tipoProducto;
  final String? pesador;
  final String? tipo;
  final String? cuadrilla;
  final List<CompraWebModelo> compras;
  final List<GastoWebModelo> gastos;
  final List<VentaWebModelo> ventas;

  const EdicionZarpeParams({
    required this.id,
    required this.placa,
    required this.chofer,
    required this.muellePartida,
    this.muelleDestino,
    this.observaciones,
    this.pesoTotal,
    this.cajasLlenas,
    this.cajasVacias,
    this.tipoProducto,
    this.pesador,
    this.tipo,
    this.cuadrilla,
    this.compras = const [],
    this.gastos = const [],
    this.ventas = const [],
  });
}

/// Repositorio de escritura para la edición de zarpes.
///
/// Centraliza todas las operaciones de INSERT/UPDATE/DELETE relacionadas
/// con un zarpe y sus relaciones (compras, gastos). La UI solo llama a
/// [guardarEdicion] sin saber qué tablas se tocan.
///
/// **Patrón:** Repository (no singleton — se instancia vía Provider).
class RepositorioEdicionZarpe {
  final SupabaseClient _cliente;
  final Uuid _uuid;

  RepositorioEdicionZarpe(this._cliente, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  // ─── Consultas ────────────────────────────────────────────────────────────

  /// Carga los datos actuales del zarpe para pre-rellenar el formulario.
  ///
  /// Retorna `null` si el zarpe no existe en la base de datos.
  Future<ZarpeModelo?> cargarZarpe(String id) async {
    final datos = await _cliente
        .from('vista_zarpes_detallados')
        .select()
        .eq('id', id)
        .maybeSingle();

    return datos != null ? ZarpeModelo.desdeJson(datos) : null;
  }

  /// Carga los datos del cuadre asociado (pesos, cajas, etc.)
  Future<CuadreWebModelo?> cargarCuadre(String id) async {
    final datos = await _cliente
        .from('cuadres')
        .select()
        .eq('id', id)
        .maybeSingle();
        
    return datos != null ? CuadreWebModelo.desdeJson(datos) : null;
  }

  /// Carga las compras actuales asociadas al zarpe.
  Future<List<CompraWebModelo>> cargarCompras(String zarpeId) async {
    final datos = await _cliente
        .from('compras')
        .select()
        .eq('cuadre_id', zarpeId);

    return (datos as List).map((m) => CompraWebModelo.desdeJson(m as Map<String, dynamic>)).toList();
  }

  /// Carga los gastos actuales asociados al zarpe.
  Future<List<GastoWebModelo>> cargarGastos(String zarpeId) async {
    final datos = await _cliente
        .from('gastos')
        .select()
        .eq('cuadre_id', zarpeId);

    return (datos as List).map((m) => GastoWebModelo.desdeJson(m as Map<String, dynamic>)).toList();
  }

  /// Carga las ventas actuales asociadas al zarpe.
  Future<List<VentaWebModelo>> cargarVentas(String zarpeId) async {
    final datos = await _cliente
        .from('ventas')
        .select()
        .eq('cuadre_id', zarpeId);

    return (datos as List).map((m) => VentaWebModelo.desdeJson(m as Map<String, dynamic>)).toList();
  }

  // ─── Mutaciones ───────────────────────────────────────────────────────────

  /// Guarda los cambios de la pantalla de edición en la base de datos.
  ///
  /// Ejecuta las operaciones en este orden:
  /// 1. Actualiza los campos principales del zarpe.
  /// 2. Reemplaza las compras (delete + insert).
  /// 3. Reemplaza los gastos (delete + insert).
  ///
  /// Lanza [Exception] con mensaje descriptivo si cualquier paso falla.
  /// Si ocurre un error, el estado parcialmente actualizado puede quedar
  /// en la DB — para producción crítica, migrar a una Supabase Edge Function
  /// que encapsule todo en una sola transacción SQL.
  Future<void> guardarEdicion(EdicionZarpeParams params) async {
    try {
      await _actualizarZarpe(params);
      await _actualizarCuadre(params);
      await _reemplazarCompras(params.id, params.compras);
      await _reemplazarGastos(params.id, params.gastos);
      await _reemplazarVentas(params.id, params.ventas);
    } on Exception catch (e) {
      throw Exception('Error al guardar la edición del zarpe ${params.id}: $e');
    }
  }

  // ─── Helpers privados ────────────────────────────────────────────────────

  Future<void> _actualizarZarpe(EdicionZarpeParams params) async {
    final payload = <String, dynamic>{
      'placa_camara': params.placa.toUpperCase(),
      'chofer': params.chofer,
      'muelle_partida': params.muellePartida,
    };
    if (params.muelleDestino != null) payload['muelle_destino'] = params.muelleDestino;
    if (params.observaciones != null) payload['observaciones'] = params.observaciones;

    await _cliente.from('zarpes').update(payload).eq('id', params.id);
  }

  Future<void> _actualizarCuadre(EdicionZarpeParams params) async {
    final payload = <String, dynamic>{
      'id': params.id, // Importante para el upsert
      'placa': params.placa.toUpperCase(),
      if (params.muellePartida.isNotEmpty) 'planta_destino': params.muellePartida,
      'estado': 'borrador', // Por defecto si se crea nuevo
      'usuario_id': _cliente.auth.currentUser?.id ?? '',
    };
    
    if (params.pesoTotal != null) payload['peso_total'] = params.pesoTotal;
    if (params.cajasLlenas != null) payload['cajas_llenas'] = params.cajasLlenas;
    if (params.cajasVacias != null) payload['cajas_vacias'] = params.cajasVacias;
    if (params.tipoProducto != null) {
      payload['tipo_producto'] = params.tipoProducto;
    }

    // Usar un UPDATE en lugar de un UPSERT para no sobreescribir campos del Bahia
    final existe = await _cliente.from('cuadres').select('id').eq('id', params.id).maybeSingle();
    if (existe != null) {
      await _cliente.from('cuadres').update(payload).eq('id', params.id);
    } else {
      await _cliente.from('cuadres').insert(payload);
    }
  }

  Future<void> _reemplazarCompras(String zarpeId, List<CompraWebModelo> compras) async {
    await _cliente.from('compras').delete().eq('cuadre_id', zarpeId);
    if (compras.isEmpty) return;

    final rows = compras.map((c) => _compraARow(zarpeId, c)).toList();
    await _cliente.from('compras').insert(rows);
  }

  Future<void> _reemplazarGastos(String zarpeId, List<GastoWebModelo> gastos) async {
    await _cliente.from('gastos').delete().eq('cuadre_id', zarpeId);
    if (gastos.isEmpty) return;

    final rows = gastos.map((g) => _gastoARow(zarpeId, g)).toList();
    await _cliente.from('gastos').insert(rows);
  }

  Future<void> _reemplazarVentas(String zarpeId, List<VentaWebModelo> ventas) async {
    await _cliente.from('ventas').delete().eq('cuadre_id', zarpeId);
    if (ventas.isEmpty) return;

    final rows = ventas.map((v) => _ventaARow(zarpeId, v)).toList();
    await _cliente.from('ventas').insert(rows);
  }

  Map<String, dynamic> _compraARow(String zarpeId, CompraWebModelo c) {
    return {
      'id': c.id.isEmpty ? _uuid.v4() : c.id,
      'cuadre_id': zarpeId,
      'embarcacion': c.embarcacion,
      'producto': c.producto,
      'kilos': c.kilos,
      'precio_unitario': c.precioUnitario,
      'total': c.total,
      if (c.adelanto != null) 'adelanto': c.adelanto,
    };
  }

  Map<String, dynamic> _gastoARow(String zarpeId, GastoWebModelo g) {
    return {
      'id': g.id.isEmpty ? _uuid.v4() : g.id,
      'cuadre_id': zarpeId,
      'tipo': g.tipo,
      'concepto': g.concepto,
      'cantidad': g.cantidad,
      'costo_unitario': g.costoUnitario,
      'total': g.total,
    };
  }

  Map<String, dynamic> _ventaARow(String zarpeId, VentaWebModelo v) {
    return {
      'id': v.id.isEmpty ? _uuid.v4() : v.id,
      'cuadre_id': zarpeId,
      'lugar': v.lugar,
      'producto': v.producto,
      'kilos': v.kilos,
      'precio_unitario': v.precioUnitario,
      'total': v.total,
    };
  }
}
