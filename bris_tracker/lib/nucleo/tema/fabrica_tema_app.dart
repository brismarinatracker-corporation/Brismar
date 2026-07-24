import 'package:flutter/material.dart';
import 'colores_app.dart';

/// Fábrica responsable de construir las configuraciones [ThemeData] para BRISMAR Tracker.
///
/// Aplica el patrón Factory para desacoplar los estilos de la interfaz móvil.
abstract final class FabricaTemaApp {
  FabricaTemaApp._();

  /// Crea la configuración de tema oscuro predeterminada para trabajo en campo.
  static ThemeData crearTemaOscuro() {
    final esquema = _crearEsquemaOscuro();
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: ColoresApp.azulFondoNoche,
      primaryColor: ColoresApp.azulFondoNoche,
    );
  }

  /// Crea la configuración de tema claro para alta visibilidad diurna.
  static ThemeData crearTemaClaro() {
    final esquema = _crearEsquemaClaro();
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: ColoresApp.fondoClaro,
      primaryColor: ColoresApp.verdeCorporativo,
    );
  }

  /// Genera el [ColorScheme] semántico para modo oscuro.
  static ColorScheme _crearEsquemaOscuro() {
    return ColorScheme.fromSeed(
      seedColor: ColoresApp.cianBrismar,
      brightness: Brightness.dark,
      primary: ColoresApp.cianBrismar,
      secondary: ColoresApp.verdeCorporativo,
      surface: ColoresApp.superficieOscura,
      error: ColoresApp.error,
    );
  }

  /// Genera el [ColorScheme] semántico para modo claro.
  static ColorScheme _crearEsquemaClaro() {
    return ColorScheme.fromSeed(
      seedColor: ColoresApp.verdeCorporativo,
      brightness: Brightness.light,
      primary: ColoresApp.verdeCorporativo,
      secondary: ColoresApp.cianBrismar,
      surface: ColoresApp.superficieClara,
      error: ColoresApp.error,
    );
  }
}
