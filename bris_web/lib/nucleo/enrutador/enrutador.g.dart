// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrutador.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$rutaDashboardShell, $rutaLogin];

RouteBase get $rutaDashboardShell => ShellRouteData.$route(
  factory: $RutaDashboardShellExtension._fromState,
  routes: [
    GoRouteData.$route(path: '/dashboard', factory: $RutaDashboard._fromState),
    GoRouteData.$route(
      path: '/transito/:sector',
      factory: $RutaTransito._fromState,
      routes: [
        GoRouteData.$route(
          path: 'editar/:id',
          factory: $RutaEdicionTransito._fromState,
        ),
      ],
    ),
    GoRouteData.$route(path: '/cuadres', factory: $RutaCuadres._fromState),
    GoRouteData.$route(path: '/usuarios', factory: $RutaUsuarios._fromState),
    GoRouteData.$route(path: '/perfil', factory: $RutaPerfil._fromState),
  ],
);

extension $RutaDashboardShellExtension on RutaDashboardShell {
  static RutaDashboardShell _fromState(GoRouterState state) =>
      const RutaDashboardShell();
}

mixin $RutaDashboard on GoRouteData {
  static RutaDashboard _fromState(GoRouterState state) => const RutaDashboard();

  @override
  String get location => GoRouteData.$location('/dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RutaTransito on GoRouteData {
  static RutaTransito _fromState(GoRouterState state) =>
      RutaTransito(sector: state.pathParameters['sector'] ?? 'pendientes');

  RutaTransito get _self => this as RutaTransito;

  @override
  String get location =>
      GoRouteData.$location('/transito/${Uri.encodeComponent(_self.sector)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RutaEdicionTransito on GoRouteData {
  static RutaEdicionTransito _fromState(GoRouterState state) =>
      RutaEdicionTransito(
        sector: state.pathParameters['sector']!,
        id: state.pathParameters['id']!,
      );

  RutaEdicionTransito get _self => this as RutaEdicionTransito;

  @override
  String get location => GoRouteData.$location(
    '/transito/${Uri.encodeComponent(_self.sector)}/editar/${Uri.encodeComponent(_self.id)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RutaCuadres on GoRouteData {
  static RutaCuadres _fromState(GoRouterState state) => const RutaCuadres();

  @override
  String get location => GoRouteData.$location('/cuadres');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RutaUsuarios on GoRouteData {
  static RutaUsuarios _fromState(GoRouterState state) => const RutaUsuarios();

  @override
  String get location => GoRouteData.$location('/usuarios');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RutaPerfil on GoRouteData {
  static RutaPerfil _fromState(GoRouterState state) => const RutaPerfil();

  @override
  String get location => GoRouteData.$location('/perfil');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $rutaLogin =>
    GoRouteData.$route(path: '/login', factory: $RutaLogin._fromState);

mixin $RutaLogin on GoRouteData {
  static RutaLogin _fromState(GoRouterState state) => const RutaLogin();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
