import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Excepción del dominio lanzada cuando ocurre un error al procesar el tema.
final class ExcepcionTema implements Exception {
  /// Mensaje descriptivo de la falla.
  final String mensaje;

  /// Constante de construcción con mensaje inicial.
  const ExcepcionTema(this.mensaje);

  @override
  String toString() => 'ExcepcionTema: $mensaje';
}

/// Notificador de estado encargado de gestionar y validar el [ThemeMode] activo.
final class ControladorTema extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Cambia el modo de tema validando defensivamente el parámetro de entrada.
  void cambiarModo(ThemeMode nuevoModo) {
    try {
      state = _validarModo(nuevoModo);
    } catch (e) {
      throw ExcepcionTema('Error al cambiar el tema de la aplicación: $e');
    }
  }

  /// Valida que el modo sea una opción válida (protección ante estados corruptos).
  ThemeMode _validarModo(ThemeMode modo) {
    return ThemeMode.values.contains(modo) ? modo : ThemeMode.system;
  }
}

/// Proveedor global Riverpod para controlar el tema de la aplicación.
final proveedorControladorTema =
    NotifierProvider<ControladorTema, ThemeMode>(ControladorTema.new);
