import 'package:flutter/material.dart';

enum EstadoCuadre {
  borrador,
  zarpe,
  completo,
  borrado,
  anulado,
  eliminado,
  desconocido;

  static EstadoCuadre desdeString(String? valor) {
    if (valor == null) return EstadoCuadre.borrador;

    switch (valor.toLowerCase()) {
      case 'borrador':
        return EstadoCuadre.borrador;
      case 'zarpe':
        return EstadoCuadre.zarpe;
      case 'completo':
        return EstadoCuadre.completo;
      case 'borrado':
        return EstadoCuadre.borrado;
      case 'anulado':
        return EstadoCuadre.anulado;
      case 'eliminado':
        return EstadoCuadre.eliminado;
      default:
        return EstadoCuadre.desconocido;
    }
  }

  String get valor {
    if (this == EstadoCuadre.desconocido) return 'desconocido';
    return name; // Uses enum name directly for string matching ('borrador', 'zarpe', etc.)
  }
}

extension EstadoCuadreUI on EstadoCuadre {
  Color get colorUi {
    switch (this) {
      case EstadoCuadre.completo:
        return Colors.greenAccent;
      case EstadoCuadre.zarpe:
        return const Color(0xFF00E5FF);
      case EstadoCuadre.borrador:
        return Colors.orangeAccent;
      case EstadoCuadre.borrado:
      case EstadoCuadre.anulado:
      case EstadoCuadre.eliminado:
        return Colors.redAccent;
      case EstadoCuadre.desconocido:
        return Colors.grey;
    }
  }

  Color get badgeBg {
    return colorUi.withValues(alpha: 0.15);
  }

  String etiquetaUi(String originalStateString) {
    switch (this) {
      case EstadoCuadre.completo:
        return 'COMPLETO';
      case EstadoCuadre.zarpe:
        return 'EN CAMINO';
      case EstadoCuadre.borrador:
        return 'BORRADOR';
      case EstadoCuadre.desconocido:
        return originalStateString.toUpperCase();
      default:
        return name.toUpperCase(); // 'BORRADO', 'ANULADO', etc.
    }
  }
}
