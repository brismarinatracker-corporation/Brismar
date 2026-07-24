import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores_app.dart';

/// Fábrica responsable de construir las configuraciones [ThemeData] de la aplicación.
///
/// Aplica el patrón Factory para desacoplar los estilos de la interfaz de usuario.
abstract final class FabricaTemaApp {
  FabricaTemaApp._();

  /// Crea la configuración de tema claro optimizada con accesibilidad WCAG.
  static ThemeData crearTemaClaro() {
    final esquema = _crearEsquemaClaro();
    final textoBase = ThemeData(brightness: Brightness.light).textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: ColoresApp.fondoClaro,
      textTheme: _crearTipografia(textoBase, ColoresApp.textoOscuro),
    );
  }

  /// Crea la configuración de tema oscuro optimizada para ambientes nocturnos.
  static ThemeData crearTemaOscuro() {
    final esquema = _crearEsquemaOscuro();
    final textoBase = ThemeData(brightness: Brightness.dark).textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: ColoresApp.azulFondo,
      textTheme: _crearTipografia(textoBase, ColoresApp.textoClaro),
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

  /// Aplica las fuentes Sora e Inter con el color de texto especificado.
  static TextTheme _crearTipografia(TextTheme base, Color colorTexto) {
    final interTheme = GoogleFonts.interTextTheme(base);
    final soraStyle = GoogleFonts.sora(
      textStyle: base.titleLarge?.copyWith(color: colorTexto),
    );
    return interTheme
        .copyWith(
          displayLarge: soraStyle,
          displayMedium: soraStyle,
          titleLarge: soraStyle,
        )
        .apply(bodyColor: colorTexto, displayColor: colorTexto);
  }
}
