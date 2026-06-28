import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../modulos/dashboard/presentacion/pantallas/layout_dashboard.dart';
import '../../modulos/transito/presentacion/pantallas/pantalla_transito.dart';
import '../../modulos/cuadres/presentacion/pantallas/pantalla_cuadres.dart';
import '../../modulos/usuarios/presentacion/pantallas/pantalla_usuarios.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modulos/autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../../modulos/autenticacion/presentacion/pantallas/pantalla_login.dart';

part 'enrutador.g.dart';

final proveedorEnrutador = Provider<GoRouter>((ref) {
  final authState = ref.watch(proveedorAutenticacion);

  return GoRouter(
    initialLocation: const RutaTransito().location,
    routes: $appRoutes,
    redirect: (context, state) {
      // 1. Validar autenticación
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuth && !isLoggingIn) return const RutaLogin().location;
      if (isAuth && isLoggingIn) return const RutaTransito().location;

      // 2. Si está cargando el perfil, no forzar redirecciones extrañas (esperar)
      if (authState.cargando) return null;

      // 3. Control de Acceso Basado en Roles (RBAC)
      final rol = authState.rol;

      // Si el rol es bahia, no tiene acceso al sistema web, lo devolvemos al login
      if (rol == 'bahia') {
        // Ejecutamos cierre de sesión automático de forma diferida para no interferir con el build
        Future.microtask(() => ref.read(proveedorAutenticacion.notifier).cerrarSesion());
        return const RutaLogin().location;
      }

      // Si es operario y trata de acceder a usuarios, lo devolvemos a transito
      if (rol == 'operario' && state.uri.path.startsWith('/usuarios')) {
        return const RutaTransito().location;
      }

      return null;
    },
  );
});

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

@TypedGoRoute<RutaLogin>(path: '/login')
class RutaLogin extends GoRouteData with $RutaLogin {
  const RutaLogin();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PantallaLogin();
  }
}
