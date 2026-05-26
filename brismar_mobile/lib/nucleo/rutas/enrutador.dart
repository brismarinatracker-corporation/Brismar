import 'package:go_router/go_router.dart';
import '../../modulos/autenticacion/presentacion/pantallas/login_pantalla.dart';
import '../../modulos/registro/presentacion/pantallas/registro_pantalla.dart';

/// Configuración de rutas declarativas mediante GoRouter.
final GoRouter enrutador = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPantalla(),
    ),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegistroPantalla(),
    ),
  ],
);
