import 'package:flutter/material.dart';

/// Configuración centralizada de marca e identidad corporativa para BRISMAR Web.
///
/// Permite modificar los colores institucionales y parámetros de marca en un solo lugar.
abstract final class ConfiguracionBranding {
  ConfiguracionBranding._();

  /// Nombre comercial oficial de la organización.
  static const String nombreEmpresa = 'BRISMAR';

  /// Color primario corporativo predeterminado (Verde Marino).
  static const Color colorPrimarioBase = Color(0xFF0E3E2C);

  /// Color secundario o de acento predeterminado (Cian Resplandeciente).
  static const Color colorAcentoBase = Color(0xFF00E5FF);

  /// Versión actual del sistema.
  static const String versionSistema = '3.0.0';
}
