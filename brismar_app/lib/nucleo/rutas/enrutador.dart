import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../modulos/autenticacion/dominio/entidades/preferencia_acceso.dart';
import '../../modulos/autenticacion/presentacion/pantallas/login_pantalla.dart';
import '../../modulos/autenticacion/presentacion/pantallas/configurar_pin_pantalla.dart';
import '../../modulos/autenticacion/presentacion/pantallas/configurar_biometria_pantalla.dart';
import '../../modulos/autenticacion/presentacion/pantallas/acceso_rapido_pantalla.dart';
import '../../modulos/registro_pesca/presentacion/pantallas/dashboard_cuadres.dart';

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

/// Configuración de rutas declarativas mediante GoRouter generadas.
final GoRouter enrutador = GoRouter(
  initialLocation: '/login',
  routes: $appRoutes,
);
