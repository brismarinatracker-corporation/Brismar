import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../modulos/autenticacion/presentacion/pantallas/login_pantalla.dart';
import '../../modulos/registro/presentacion/pantallas/registro_pantalla.dart';

part 'enrutador.g.dart';

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginPantalla();
}

@TypedGoRoute<RegistroRoute>(path: '/registro')
class RegistroRoute extends GoRouteData with $RegistroRoute {
  const RegistroRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegistroPantalla();
}

/// Configuración de rutas declarativas mediante GoRouter generadas.
final GoRouter enrutador = GoRouter(
  initialLocation: '/login',
  routes: $appRoutes,
);
