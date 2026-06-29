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
    GoRouteData.$route(path: '/transito', factory: $RutaTransito._fromState),
    GoRouteData.$route(path: '/cuadres', factory: $RutaCuadres._fromState),
    GoRouteData.$route(path: '/usuarios', factory: $RutaUsuarios._fromState),
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
  static RutaTransito _fromState(GoRouterState state) => const RutaTransito();

  @override
  String get location => GoRouteData.$location('/transito');

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
