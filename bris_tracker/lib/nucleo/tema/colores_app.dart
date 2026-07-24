import 'package:flutter/material.dart';
import '../configuracion/configuracion_branding.dart';

/// Tokens de colores semánticos globales para BRISMAR Tracker (móvil).
///
/// Vincula la paleta con [ConfiguracionBranding] garantizando control en un solo punto.
abstract final class ColoresApp {
  ColoresApp._();

  // ─── Colores Primarios y de Marca Móvil ──────────────────────────────

  /// Cian resplandeciente característico del tracker.
  static const Color cianBrismar = ConfiguracionBranding.colorPrimarioBase;

  /// Verde marino profundo corporativo.
  static const Color verdeCorporativo = ConfiguracionBranding.colorAcentoBase;

  /// Azul oscuro nocturno para fondo de tarjetas y scaffolds.
  static const Color azulFondoNoche = Color(0xFF0D255F);

  /// Azul muy profundo para fondos absolutos.
  static const Color azulFondoProfundo = Color(0xFF051138);

  // ─── Superficies y Contenedores ──────────────────────────────────────

  /// Superficie nocturna para contenedores y tarjetas.
  static const Color superficieOscura = Color(0xFF162D6E);

  /// Superficie clara para modo día.
  static const Color superficieClara = Color(0xFFFFFFFF);

  /// Fondo claro para modo día.
  static const Color fondoClaro = Color(0xFFF4F6F9);

  // ─── Tipografía y Neutrales ──────────────────────────────────────────

  /// Texto primario sobre fondos oscuros.
  static const Color textoClaro = Color(0xFFFFFFFF);

  /// Texto secundario o deshabilitado en fondos oscuros.
  static const Color textoSecundarioModoOscuro = Color(0xFFB0BEC5);

  /// Texto primario sobre fondos claros.
  static const Color textoOscuro = Color(0xFF15181A);

  // ─── Estados Semánticos de Registro ──────────────────────────────────

  /// Estado de éxito o zarpe completado.
  static const Color exito = Color(0xFF10B981);

  /// Estado de advertencia o cuadre pendiente.
  static const Color advertencia = Color(0xFFF59E0B);

  /// Estado de error o cancelación.
  static const Color error = Color(0xFFEF4444);
}
