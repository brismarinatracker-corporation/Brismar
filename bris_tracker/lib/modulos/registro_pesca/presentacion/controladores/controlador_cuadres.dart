import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/cuadre_modelo.dart';
import '../../dominio/entidades/cuadre_entidad.dart';
import '../../datos/repositorios/cuadre_repositorio_imp.dart';
import '../../../../nucleo/red/verificador_conexion.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../../registro_pesca_inyeccion.dart';

/// Provider del historial de cuadres del usuario autenticado.
///
/// Usa [AsyncNotifierProvider] (Riverpod 2.x). El estado es la lista de
/// cuadres del usuario: se carga automáticamente al construirse y se
/// sincroniza con Supabase si hay conexión disponible.
///
/// Reacciona automáticamente a cambios en el estado de autenticación:
/// si el usuario cierra sesión, el provider se reconstruye y limpia el estado.
final cuadresProvider =
    AsyncNotifierProvider<CuadresNotifier, List<CuadreEntidad>>(
      CuadresNotifier.new,
    );

/// Controlador del historial de cuadres (registros de pesca).
///
/// **Responsabilidad única:** cargar, guardar y mantener sincronizados
/// los cuadres del usuario autenticado entre SQLite local y Supabase.
///
/// **Estrategia:** Offline-First.
/// 1. Se carga desde SQLite local (instantáneo, sin red).
/// 2. Si hay conexión, se sincronizan pendientes y se recarga.
class CuadresNotifier extends AsyncNotifier<List<CuadreEntidad>> {
  late final CuadreRepositorioImp _repositorio;

  @override
  Future<List<CuadreEntidad>> build() async {
    _repositorio = ref.read(cuadreRepositorioProvider);

    // Reacciona al estado de autenticación: si el usuario cambia o
    // cierra sesión, este provider se invalida y reconstruye.
    final authState = ref.watch(proveedorControladorAutenticacion);

    if (authState is! EstadoAutenticacionAutenticado) {
      // Sin usuario autenticado: lista vacía, no intentar acceder a SQLite.
      return [];
    }

    return _cargarYSincronizar(authState.usuario.id);
  }

  // ─── Métodos públicos ──────────────────────────────────────────────────────

  /// Recarga el historial de cuadres desde SQLite y sincroniza si hay red.
  ///
  /// Se puede llamar manualmente desde la UI para forzar un refresco.
  Future<void> cargarHistorial() async {
    final authState = ref.read(proveedorControladorAutenticacion);
    if (authState is! EstadoAutenticacionAutenticado) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _cargarYSincronizar(authState.usuario.id),
    );
  }

  /// Guarda un cuadre localmente y recarga la lista para reflejar el cambio.
  ///
  /// Lanza excepción si la persistencia local falla (error crítico).
  Future<void> guardarCuadre(CuadreEntidad cuadre) async {
    await _repositorio.guardarCuadre(cuadre);
    await cargarHistorial();
  }

  /// Agrega un gasto a un cuadre existente y persiste el cambio.
  ///
  /// Solo opera si el estado actual tiene datos válidos y el cuadre existe.
  Future<void> agregarGasto(String cuadreId, GastoEntidad nuevoGasto) async {
    final cuadresActuales = state.valueOrNull;
    if (cuadresActuales == null) return;

    final idx = cuadresActuales.indexWhere((c) => c.id == cuadreId);
    if (idx == -1) return;

    final cuadre = cuadresActuales[idx];
    final cuadreActualizado = CuadreModelo(
      id: cuadre.id,
      usuarioId: cuadre.usuarioId,
      placa: cuadre.placa,
      fechaZarpe: cuadre.fechaZarpe,
      fechaCuadre: cuadre.fechaCuadre,
      estado: cuadre.estado,
      urlPdfCloud: cuadre.urlPdfCloud,
      urlExcelCloud: cuadre.urlExcelCloud,
      sincronizado: false, // Marca para re-sincronizar con Supabase.
      fotoZarpeUrl: cuadre.fotoZarpeUrl,
      pesoTotal: cuadre.pesoTotal,
      cajasLlenas: cuadre.cajasLlenas,
      cajasVacias: cuadre.cajasVacias,
      tipoProducto: cuadre.tipoProducto,
      muellePartida: cuadre.muellePartida,
      pesador: cuadre.pesador,
      tipo: cuadre.tipo,
      cuadrilla: cuadre.cuadrilla,
      compras: cuadre.compras,
      gastos: List<GastoEntidad>.from(cuadre.gastos)..add(nuevoGasto),
      ventas: cuadre.ventas,
    );

    await guardarCuadre(cuadreActualizado);
  }

  // ─── Privados ──────────────────────────────────────────────────────────────

  /// Carga los cuadres locales y, si hay red, sincroniza pendientes y recarga.
  Future<List<CuadreEntidad>> _cargarYSincronizar(String usuarioId) async {
    // Paso 1: Carga local (siempre disponible, sin red).
    final cuadres = await _repositorio.obtenerHistorial(usuarioId);

    // Paso 2: Sincronización opcional con Supabase si hay conectividad.
    final verificador = VerificadorConexionImpl();
    if (await verificador.hayConexion()) {
      await _repositorio.sincronizarPendientes(usuarioId);
      return _repositorio.obtenerHistorial(usuarioId);
    }

    return cuadres;
  }
}
