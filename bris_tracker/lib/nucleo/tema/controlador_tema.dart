import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Excepción del dominio lanzada cuando ocurre un error al procesar el tema en el tracker.
final class ExcepcionTemaTracker implements Exception {
  /// Mensaje explicativo del fallo.
  final String mensaje;

  /// Constructor inmutable de la excepción.
  const ExcepcionTemaTracker(this.mensaje);

  @override
  String toString() => 'ExcepcionTemaTracker: $mensaje';
}

/// Notificador de estado para la gestión y validación del [ThemeMode] en la app móvil.
final class ControladorTemaTracker extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  /// Actualiza el modo visual verificando la validez del estado.
  void cambiarModo(ThemeMode nuevoModo) {
    try {
      state = _validarModo(nuevoModo);
    } catch (e) {
      throw ExcepcionTemaTracker('Fallo al actualizar tema en tracker: $e');
    }
  }

  /// Valida que el tema recibido no sea nulo ni inválido (defensa ante estado corrupto).
  ThemeMode _validarModo(ThemeMode modo) {
    return ThemeMode.values.contains(modo) ? modo : ThemeMode.dark;
  }
}

/// Proveedor Riverpod global para el controlador de temas del Tracker.
final proveedorControladorTemaTracker =
    NotifierProvider<ControladorTemaTracker, ThemeMode>(ControladorTemaTracker.new);
