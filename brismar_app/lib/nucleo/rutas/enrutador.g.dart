// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrutador.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$loginRoute, $registroRoute];

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

RouteBase get $registroRoute =>
    GoRouteData.$route(path: '/registro', factory: $RegistroRoute._fromState);

mixin $RegistroRoute on GoRouteData {
  static RegistroRoute _fromState(GoRouterState state) => const RegistroRoute();

  @override
  String get location => GoRouteData.$location('/registro');

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
