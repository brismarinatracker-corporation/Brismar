import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../modulos/dashboard/presentacion/pantallas/layout_dashboard.dart';
import '../../modulos/transito/presentacion/pantallas/pantalla_transito.dart';
import '../../modulos/cuadres/presentacion/pantallas/pantalla_cuadres.dart';
import '../../modulos/usuarios/presentacion/pantallas/pantalla_usuarios.dart';

part 'enrutador.g.dart';

final enrutadorApp = GoRouter(
  initialLocation: const RutaTransito().location,
  routes: $appRoutes,
);

@TypedShellRoute<RutaDashboardShell>(
  routes: [
    TypedGoRoute<RutaTransito>(path: '/transito'),
    TypedGoRoute<RutaCuadres>(path: '/cuadres'),
    TypedGoRoute<RutaUsuarios>(path: '/usuarios'),
  ],
)
class RutaDashboardShell extends ShellRouteData {
  const RutaDashboardShell();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return LayoutDashboard(hijo: navigator);
  }
}

class RutaTransito extends GoRouteData with $RutaTransito {
  const RutaTransito();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PantallaTransito();
  }
}

class RutaCuadres extends GoRouteData with $RutaCuadres {
  const RutaCuadres();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PantallaCuadres();
  }
}

class RutaUsuarios extends GoRouteData with $RutaUsuarios {
  const RutaUsuarios();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PantallaUsuarios();
  }
}
