import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../modulos/dashboard/presentacion/pantallas/layout_dashboard.dart';
import '../../modulos/dashboard/presentacion/pantallas/pantalla_dashboard.dart';
import '../../modulos/transito/presentacion/pantallas/pantalla_transito.dart';
import '../../modulos/transito/presentacion/pantallas/pantalla_edicion_transito.dart';
import '../../modulos/cuadres/presentacion/pantallas/pantalla_cuadres.dart';
import '../../modulos/usuarios/presentacion/pantallas/pantalla_usuarios.dart';
import '../../modulos/perfil/presentacion/pantallas/pantalla_perfil.dart';
import '../../modulos/productos/presentacion/pantallas/pantalla_productos.dart';
import '../../modulos/camaras/presentacion/pantallas/pantalla_camaras.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modulos/autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../../modulos/autenticacion/presentacion/pantallas/pantalla_login.dart';

part 'enrutador.g.dart';

final proveedorEnrutador = Provider<GoRouter>((ref) {
  // Usamos un ValueNotifier como refreshListenable para que GoRouter
  // evalúe el redirect SIN destruir y recrear toda la instancia del router.
  final authNotifier = ValueNotifier<EstadoAutenticacion>(
    ref.read(proveedorAutenticacion),
  );

  ref.listen<EstadoAutenticacion>(proveedorAutenticacion, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: const RutaDashboard().location,
    refreshListenable: authNotifier,
    routes: $appRoutes,
    redirect: (context, state) {
      // 1. Validar autenticación usando read, ya que estamos notificados por refreshListenable
      final authState = ref.read(proveedorAutenticacion);
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuth && !isLoggingIn) return const RutaLogin().location;
      if (isAuth && isLoggingIn) return const RutaDashboard().location;

      // 2. Si está cargando el perfil, no forzar redirecciones extrañas (esperar)
      if (authState.cargando) return null;

      // 3. Control de Acceso Basado en Roles (RBAC)
      final rol = authState.rol;

      // Si el rol es bahia, no tiene acceso al sistema web, lo devolvemos al login
      if (rol == 'bahia') {
        // Ejecutamos cierre de sesión automático de forma diferida para no interferir con el build
        Future.microtask(
          () => ref.read(proveedorAutenticacion.notifier).cerrarSesion(),
        );
        return const RutaLogin().location;
      }

      // Si no es administrador y trata de acceder a rutas exclusivas, lo devolvemos al dashboard
      if (rol != 'administrador' &&
          (state.uri.path.startsWith('/usuarios') ||
              state.uri.path.startsWith('/productos') ||
              state.uri.path.startsWith('/camaras'))) {
        return const RutaDashboard().location;
      }

      return null;
    },
  );
});

@TypedShellRoute<RutaDashboardShell>(
  routes: [
    TypedGoRoute<RutaDashboard>(path: '/dashboard'),
    TypedGoRoute<RutaTransito>(
      path: '/transito',
      routes: [TypedGoRoute<RutaEdicionTransito>(path: 'editar/:id')],
    ),
    TypedGoRoute<RutaCuadres>(path: '/cuadres'),
    TypedGoRoute<RutaUsuarios>(path: '/usuarios'),
    TypedGoRoute<RutaProductos>(path: '/productos'),
    TypedGoRoute<RutaCamaras>(path: '/camaras'),
    TypedGoRoute<RutaPerfil>(path: '/perfil'),
  ],
)
class RutaDashboardShell extends ShellRouteData {
  const RutaDashboardShell();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return LayoutDashboard(hijo: navigator);
  }
}

class RutaDashboard extends GoRouteData with $RutaDashboard {
  const RutaDashboard();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: PantallaDashboard());
  }
}

class RutaTransito extends GoRouteData with $RutaTransito {
  const RutaTransito();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: PantallaTransito());
  }
}

class RutaEdicionTransito extends GoRouteData with $RutaEdicionTransito {
  final String id;
  const RutaEdicionTransito({required this.id});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(child: PantallaEdicionTransito(id: id));
  }
}

class RutaCuadres extends GoRouteData with $RutaCuadres {
  const RutaCuadres();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: PantallaCuadres());
  }
}

class RutaUsuarios extends GoRouteData with $RutaUsuarios {
  const RutaUsuarios();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: PantallaUsuarios());
  }
}

class RutaProductos extends GoRouteData with $RutaProductos {
  const RutaProductos();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: PantallaProductos());
  }
}

class RutaCamaras extends GoRouteData with $RutaCamaras {
  const RutaCamaras();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: PantallaCamaras());
  }
}

class RutaPerfil extends GoRouteData with $RutaPerfil {
  const RutaPerfil();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: PantallaPerfil());
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
