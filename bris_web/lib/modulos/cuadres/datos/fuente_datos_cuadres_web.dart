// ============================================================
// Módulo   : Cuadres — Web Admin
// Archivo  : fuente_datos_cuadres_web.dart
// Última modificación: 2026-06-29
// Autor    : Antigravity IDE
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../dominio/modelos/cuadre_web_modelo.dart';

/// Fuente de datos remota para Cuadres en la Web Admin.
///
/// Sigue el patrón Repository: consulta Supabase en dos fases:
/// 1. Query filtrada de `cuadres`.
/// 2. Carga paralela de `compras`, `gastos` y `ventas` por ID.
class FuenteDatosCuadresWeb {
  final SupabaseClient _cliente;

  const FuenteDatosCuadresWeb(this._cliente);

  /// Obtiene todos los cuadres con sus relaciones (compras, gastos, ventas).
  ///
  /// Parámetros opcionales de filtro:
  /// - [desde]: Fecha de zarpe mínima.
  /// - [hasta]: Fecha de zarpe máxima.
  /// - [sede]: Filtro por sede (no implementado aún — Issue #004 futuro).
    String? sede,
    String? placa,
    int? limit,
    int? offset,
  }) async {
    try {
      final cuadresRaw = await _consultarCuadresFiltrados(desde, hasta, placa, limit, offset);
      if (cuadresRaw.isEmpty) return [];

      final ids = cuadresRaw.map((c) => c['id'] as String).toList();
      final relaciones = await _cargarRelaciones(ids);
      return _ensamblarCuadres(cuadresRaw, relaciones);
    } catch (e) {
      throw Exception('FuenteDatosCuadresWeb.obtenerTodos: $e');
    }
  }

  /// Obtiene un cuadre específico por su ID junto con todas sus relaciones.
  Future<CuadreWebModelo?> obtenerPorId(String id) async {
    try {
      final cuadreRaw = await _cliente.from('cuadres').select().eq('id', id).maybeSingle();
      if (cuadreRaw == null) return null;

      final relaciones = await _cargarRelaciones([id]);
      final lista = _ensamblarCuadres([cuadreRaw], relaciones);
      return lista.isNotEmpty ? lista.first : null;
    } catch (e) {
      throw Exception('FuenteDatosCuadresWeb.obtenerPorId: $e');
    }
  }

  // ─── Privados ─────────────────────────────────────────────

  /// Consulta la tabla `cuadres` con filtros opcionales de rango de fecha.
  Future<List<Map<String, dynamic>>> _consultarCuadresFiltrados(
    DateTime? desde,
    DateTime? hasta,
    String? placa,
    int? limit,
    int? offset,
  ) async {
    var query = _cliente.from('cuadres').select();
    if (desde != null) {
      query = query.gte('fecha_zarpe', desde.toIso8601String());
    }
    if (hasta != null) {
      query = query.lte('fecha_zarpe', hasta.toIso8601String());
    }
    if (placa != null && placa.trim().isNotEmpty) {
      query = query.ilike('placa', '%${placa.trim()}%');
    }
    final result = await query.order('fecha_zarpe', ascending: false).range(offset ?? 0, (offset ?? 0) + (limit ?? 50) - 1);
    return List<Map<String, dynamic>>.from(result as List);
  }

  /// Carga compras, gastos y ventas en paralelo para una lista de IDs.
  Future<Map<String, Map<String, List<Map<String, dynamic>>>>> _cargarRelaciones(
    List<String> ids,
  ) async {
    final results = await Future.wait([
      _cliente.from('compras').select().inFilter('cuadre_id', ids),
      _cliente.from('gastos').select().inFilter('cuadre_id', ids),
      _cliente.from('ventas').select().inFilter('cuadre_id', ids),
    ]);

    // Inicializar el mapa de relaciones vacías para cada ID
    final mapa = <String, Map<String, List<Map<String, dynamic>>>>{
      for (final id in ids)
        id: {'compras': [], 'gastos': [], 'ventas': []},
    };

    _agruparPorCuadreId(results[0] as List, mapa, 'compras');
    _agruparPorCuadreId(results[1] as List, mapa, 'gastos');
    _agruparPorCuadreId(results[2] as List, mapa, 'ventas');

    return mapa;
  }

  /// Agrupa filas de Supabase por su `cuadre_id` dentro del [mapa].
  void _agruparPorCuadreId(
    List<dynamic> datos,
    Map<String, Map<String, List<Map<String, dynamic>>>> mapa,
    String tipo,
  ) {
    for (final item in datos) {
      final id = item['cuadre_id'] as String?;
      if (id != null && mapa.containsKey(id)) {
        mapa[id]![tipo]!.add(Map<String, dynamic>.from(item as Map));
      }
    }
  }

  /// Ensambla [CuadreWebModelo] completos con sus relaciones ya cargadas.
  List<CuadreWebModelo> _ensamblarCuadres(
    List<Map<String, dynamic>> cuadresRaw,
    Map<String, Map<String, List<Map<String, dynamic>>>> relaciones,
  ) {
    return cuadresRaw.map((json) {
      final cuadre = CuadreWebModelo.desdeJson(json);
      final rel = relaciones[cuadre.id];
      return cuadre.conRelaciones(
        compras: (rel?['compras'] ?? []).map(CompraWebModelo.desdeJson).toList(),
        gastos: (rel?['gastos'] ?? []).map(GastoWebModelo.desdeJson).toList(),
        ventas: (rel?['ventas'] ?? []).map(VentaWebModelo.desdeJson).toList(),
      );
    }).toList();
  }
}
