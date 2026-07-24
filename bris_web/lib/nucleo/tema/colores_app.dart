import 'package:flutter/material.dart';
import '../configuracion/configuracion_branding.dart';

/// Tokens de colores semánticos globales para la aplicación BRISMAR Web.
///
/// Vincula la paleta con [ConfiguracionBranding] garantizando control en un solo punto.
abstract final class ColoresApp {
  ColoresApp._();

  // ─── Colores Corporativos Vinculados al Branding ────────────────────

  /// Verde marino institucional principal.
  static const Color verdeCorporativo = ConfiguracionBranding.colorPrimarioBase;

  /// Cian resplandeciente para acentos y elementos interactivos.
  static const Color cianBrismar = ConfiguracionBranding.colorAcentoBase;

  /// Azul profundo nocturno para fondos oscuros.
  static const Color azulFondo = Color(0xFF070E22);

  // ─── Superficies y Fondos ────────────────────────────────────────────

  /// Fondo principal en modo claro.
  static const Color fondoClaro = Color(0xFFF2F6F3);

  /// Superficie de tarjetas y modales en modo claro.
  static const Color superficieClara = Color(0xFFFFFFFF);

  /// Superficie de tarjetas y paneles en modo oscuro.
  static const Color superficieOscura = Color(0xFF0F224A);

  // ─── Tipografía y Neutrales ──────────────────────────────────────────

  /// Texto primario sobre fondos claros.
  static const Color textoOscuro = Color(0xFF15181A);

  /// Texto primario sobre fondos oscuros.
  static const Color textoClaro = Color(0xFFF0F4F8);

  /// Texto secundario con alto contraste legibilidad.
  static const Color textoSecundario = Color(0xFF64748B);

  // ─── Estado de Negocio (Semánticos) ─────────────────────────────────

  /// Color de estado para operaciones exitosas.
  static const Color exito = Color(0xFF10B981);

  /// Color de estado para advertencias y alertas.
  static const Color advertencia = Color(0xFFF59E0B);

  /// Color de estado para errores críticos o destructivos.
  static const Color error = Color(0xFFEF4444);
}
