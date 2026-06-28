import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modulos/autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../../modulos/autenticacion/dominio/entidades/preferencia_acceso.dart';
import '../../modulos/autenticacion/presentacion/pantallas/login_pantalla.dart';
import '../../modulos/autenticacion/presentacion/pantallas/configurar_pin_pantalla.dart';
import '../../modulos/autenticacion/presentacion/pantallas/configurar_biometria_pantalla.dart';
import '../../modulos/autenticacion/presentacion/pantallas/acceso_rapido_pantalla.dart';
import '../../modulos/registro_pesca/presentacion/pantallas/dashboard_cuadres.dart';
import '../../modulos/registro_pesca/presentacion/pantallas/formulario_zarpe_pantalla.dart';
import '../../modulos/registro_pesca/presentacion/pantallas/formulario_cuadre_tabs.dart';
import '../../modulos/registro_pesca/dominio/entidades/cuadre_entidad.dart';
part 'enrutador.g.dart';

/// Ruta de la pantalla de login completo (correo + contraseña).
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginPantalla();
}

/// Ruta de la pantalla de configuración de PIN (post login inicial).
@TypedGoRoute<ConfigurarPinRoute>(path: '/configurar-pin')
class ConfigurarPinRoute extends GoRouteData with $ConfigurarPinRoute {
  const ConfigurarPinRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ConfigurarPinPantalla();
}

/// Ruta de la pantalla de configuración de biometría (opcional).
@TypedGoRoute<ConfigurarBiometriaRoute>(path: '/configurar-biometria')
class ConfigurarBiometriaRoute extends GoRouteData with $ConfigurarBiometriaRoute {
  const ConfigurarBiometriaRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ConfigurarBiometriaPantalla();
}

/// Ruta de la pantalla de acceso rápido diario (PIN o Huella).
///
/// Recibe la preferencia del usuario como parámetro de query.
@TypedGoRoute<AccesoRapidoRoute>(path: '/acceso-rapido')
class AccesoRapidoRoute extends GoRouteData with $AccesoRapidoRoute {
  /// Preferencia de acceso: 'pin' o 'huella'. Por defecto 'pin'.
  final String preferencia;

  const AccesoRapidoRoute({this.preferencia = 'pin'});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AccesoRapidoPantalla(
      preferencia: PreferenciaAcceso.fromString(preferencia),
    );
  }
}

/// Ruta de la pantalla principal (Dashboard).
@TypedGoRoute<RegistroRoute>(path: '/')
class RegistroRoute extends GoRouteData with $RegistroRoute {
  const RegistroRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DashboardCuadresPantalla();
}

/// Ruta para registrar un nuevo Zarpe
@TypedGoRoute<NuevoZarpeRoute>(path: '/nuevo-zarpe')
class NuevoZarpeRoute extends GoRouteData with $NuevoZarpeRoute {
  const NuevoZarpeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FormularioZarpePantalla();
}

/// Ruta para registrar o editar un Cuadre
@TypedGoRoute<NuevoCuadreRoute>(path: '/nuevo-cuadre')
class NuevoCuadreRoute extends GoRouteData with $NuevoCuadreRoute {
  final CuadreEntidad? $extra;

  const NuevoCuadreRoute({this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FormularioCuadreTabs(cuadreInicial: $extra);
}

/// Configuración de rutas declarativas mediante GoRouter generadas y protegidas por Riverpod.
final enrutadorProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(proveedorControladorAutenticacion);

  return GoRouter(
    initialLocation: '/login',
    routes: $appRoutes,
    redirect: (context, state) {
      final path = state.uri.path;

      // ── Mientras la sesión se evalúa, no redirigir ─────────────────────────
      if (authState is EstadoAutenticacionInicial ||
          authState is EstadoAutenticacionCargando) {
        return null;
      }

      // ── Sin sesión → siempre al login ──────────────────────────────────────
      if (authState is EstadoAutenticacionNoAutenticado) {
        return path == '/login' ? null : '/login';
      }

      // ── Primer login: usuario debe configurar PIN ──────────────────────────
      if (authState is EstadoConfigurarPin) {
        return path == '/configurar-pin' ? null : '/configurar-pin';
      }

      // ── PIN guardado: usuario puede configurar biometría ───────────────────
      if (authState is EstadoConfigurarBiometria) {
        return path == '/configurar-biometria' ? null : '/configurar-biometria';
      }

      // ── Periodo de gracia expiró: acceso rápido (PIN/huella) ───────────────
      if (authState is EstadoAccesoRapidoRequerido) {
        return path == '/acceso-rapido' ? null : '/acceso-rapido';
      }

      // ── Sesión activa: acceso al dashboard ─────────────────────────────────
      if (authState is EstadoAutenticacionAutenticado) {
        // Evitar que el usuario regrese al login o a pantallas de setup
        const pantallasSetup = ['/login', '/configurar-pin', '/configurar-biometria', '/acceso-rapido'];
        if (pantallasSetup.contains(path)) return '/';
        return null;
      }

      return null;
    },
  );
});
