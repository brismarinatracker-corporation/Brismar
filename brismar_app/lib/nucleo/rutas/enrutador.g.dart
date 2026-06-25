// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrutador.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $loginRoute,
  $configurarPinRoute,
  $configurarBiometriaRoute,
  $accesoRapidoRoute,
  $registroRoute,
];

RouteBase get $loginRoute =>
    GoRouteData.$route(path: '/login', factory: $LoginRoute._fromState);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

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

RouteBase get $configurarPinRoute => GoRouteData.$route(
  path: '/configurar-pin',
  factory: $ConfigurarPinRoute._fromState,
);

mixin $ConfigurarPinRoute on GoRouteData {
  static ConfigurarPinRoute _fromState(GoRouterState state) =>
      const ConfigurarPinRoute();

  @override
  String get location => GoRouteData.$location('/configurar-pin');

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

RouteBase get $configurarBiometriaRoute => GoRouteData.$route(
  path: '/configurar-biometria',
  factory: $ConfigurarBiometriaRoute._fromState,
);

mixin $ConfigurarBiometriaRoute on GoRouteData {
  static ConfigurarBiometriaRoute _fromState(GoRouterState state) =>
      const ConfigurarBiometriaRoute();

  @override
  String get location => GoRouteData.$location('/configurar-biometria');

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

RouteBase get $accesoRapidoRoute => GoRouteData.$route(
  path: '/acceso-rapido',
  factory: $AccesoRapidoRoute._fromState,
);

mixin $AccesoRapidoRoute on GoRouteData {
  static AccesoRapidoRoute _fromState(GoRouterState state) => AccesoRapidoRoute(
    preferencia: state.uri.queryParameters['preferencia'] ?? 'pin',
  );

  AccesoRapidoRoute get _self => this as AccesoRapidoRoute;

  @override
  String get location => GoRouteData.$location(
    '/acceso-rapido',
    queryParams: {
      if (_self.preferencia != 'pin') 'preferencia': _self.preferencia,
    },
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

RouteBase get $registroRoute =>
    GoRouteData.$route(path: '/', factory: $RegistroRoute._fromState);

mixin $RegistroRoute on GoRouteData {
  static RegistroRoute _fromState(GoRouterState state) => const RegistroRoute();

  @override
  String get location => GoRouteData.$location('/');

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
