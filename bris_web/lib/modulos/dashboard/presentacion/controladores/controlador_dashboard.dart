import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../datos/fuente_datos_dashboard.dart';

// ─── Estado ──────────────────────────────────────────────────────────────────

class EstadoDashboard {
  final bool cargando;
  final String? error;
  final DashboardKpis kpis;

  const EstadoDashboard({
    this.cargando = false,
    this.error,
    this.kpis = const DashboardKpis(),
  });

  EstadoDashboard copiarCon({
    bool? cargando,
    String? error,
    DashboardKpis? kpis,
    bool limpiarError = false,
  }) {
    return EstadoDashboard(
      cargando: cargando ?? this.cargando,
      error: limpiarError ? null : (error ?? this.error),
      kpis: kpis ?? this.kpis,
    );
  }
}

// ─── Proveedores ──────────────────────────────────────────────────────────────

final fuenteDashboardProvider = Provider<FuenteDatosDashboard>((ref) {
  return FuenteDatosDashboard(Supabase.instance.client);
});

final controladorDashboardProvider =
    NotifierProvider<ControladorDashboard, EstadoDashboard>(
      ControladorDashboard.new,
    );

// ─── Controlador ──────────────────────────────────────────────────────────────

/// Controlador del Dashboard de la Web Admin.
///
/// Carga los KPIs del negocio al inicializar y permite recargar manualmente.
/// Usa [ref.keepAlive()] para evitar re-fetches innecesarios al navegar entre
/// módulos y volver al Dashboard.
class ControladorDashboard extends Notifier<EstadoDashboard> {
  late FuenteDatosDashboard _fuente;

  @override
  EstadoDashboard build() {
    // Mantiene el provider vivo aunque el widget se desmonte (navegación).
    ref.keepAlive();
    _fuente = ref.watch(fuenteDashboardProvider);
    // scheduleMicrotask evita el double-render que causaba Future.microtask
    // al lanzarse ANTES de que build() retorne el estado inicial.
    scheduleMicrotask(cargarKpis);
    return const EstadoDashboard(cargando: true);
  }

  /// Carga o recarga los KPIs desde Supabase.
  Future<void> cargarKpis() async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      final kpis = await _fuente.obtenerKpis();
      state = state.copiarCon(cargando: false, kpis: kpis);
    } catch (e, st) {
      debugPrint('=== ERROR EN DASHBOARD ===\n$e\n$st');
      state = state.copiarCon(
        cargando: false,
        error: 'Ocurrió un error inesperado: $e',
      );
    }
  }
}
