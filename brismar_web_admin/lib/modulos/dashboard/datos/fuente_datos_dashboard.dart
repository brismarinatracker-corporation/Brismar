// ============================================================
// Módulo   : Dashboard — Web Admin
// Archivo  : fuente_datos_dashboard.dart
// Última modificación: 2026-06-29
// Autor    : Antigravity IDE
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

/// KPIs del Dashboard de la Web Admin.
///
/// Objeto de valor inmutable con todos los indicadores del negocio.
class DashboardKpis {
  final int totalZarpesMes;
  final int zarpesPendientes;
  final int zarpesRecibidos;
  final int usuariosActivos;
  final double totalKilosMes;

  const DashboardKpis({
    this.totalZarpesMes = 0,
    this.zarpesPendientes = 0,
    this.zarpesRecibidos = 0,
    this.usuariosActivos = 0,
    this.totalKilosMes = 0,
  });
}

/// Fuente de datos para el Dashboard de la Web Admin.
///
/// Realiza **5 queries paralelas** a Supabase para obtener los KPIs del
/// negocio en un solo round-trip conceptual, usando [Future.wait].
class FuenteDatosDashboard {
  final SupabaseClient _cliente;

  const FuenteDatosDashboard(this._cliente);

  /// Carga todos los KPIs del dashboard en paralelo.
  ///
  /// Lanza [Exception] con mensaje descriptivo si alguna query falla.
  Future<DashboardKpis> obtenerKpis() async {
    try {
      final inicioMes = _inicioDelMesActual();
      final results = await Future.wait([
        _contarZarpesMes(inicioMes),
        _contarZarpesPorEstado('DESPACHADO_PIURA'),
        _contarZarpesPorEstado('RECIBIDO_LAMBAYEQUE'),
        _contarUsuariosActivos(),
        _sumarKilosMes(inicioMes),
      ]);

      return DashboardKpis(
        totalZarpesMes: results[0] as int,
        zarpesPendientes: results[1] as int,
        zarpesRecibidos: results[2] as int,
        usuariosActivos: results[3] as int,
        totalKilosMes: results[4] as double,
      );
    } catch (e) {
      throw Exception('FuenteDatosDashboard.obtenerKpis: $e');
    }
  }

  // ─── Queries privadas ─────────────────────────────────────

  /// Cuenta los zarpes del mes actual.
  Future<int> _contarZarpesMes(DateTime desde) async {
    final datos = await _cliente
        .from('zarpes')
        .select('id')
        .gte('fecha_zarpe', desde.toIso8601String());
    return (datos as List).length;
  }

  /// Cuenta los zarpes que se encuentran en un estado específico.
  Future<int> _contarZarpesPorEstado(String estado) async {
    final datos = await _cliente
        .from('zarpes')
        .select('id')
        .eq('estado', estado);
    return (datos as List).length;
  }

  /// Cuenta los usuarios con la cuenta activa.
  Future<int> _contarUsuariosActivos() async {
    final datos = await _cliente
        .from('usuarios')
        .select('id')
        .eq('activo', true);
    return (datos as List).length;
  }

  /// Suma los kilos totales de cuadres del mes actual.
  Future<double> _sumarKilosMes(DateTime desde) async {
    final datos = await _cliente
        .from('cuadres')
        .select('peso_total')
        .gte('fecha_zarpe', desde.toIso8601String())
        .not('peso_total', 'is', null);
    return (datos as List).fold<double>(
      0.0,
      (suma, row) => suma + ((row['peso_total'] as num?)?.toDouble() ?? 0),
    );
  }

  /// Retorna la fecha del primer día del mes en curso (00:00:00 UTC).
  DateTime _inicioDelMesActual() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, 1);
  }
}
