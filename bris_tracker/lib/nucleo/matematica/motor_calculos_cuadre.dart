/// Excepción del dominio lanzada cuando se intenta realizar un cálculo financiero inválido en el tracker.
final class ExcepcionCalculoMatematicoTracker implements Exception {
  /// Mensaje explicativo del fallo matemático.
  final String mensaje;

  /// Constructor inmutable de la excepción.
  const ExcepcionCalculoMatematicoTracker(this.mensaje);

  @override
  String toString() => 'ExcepcionCalculoMatematicoTracker: $mensaje';
}

/// Motor del dominio encargado de realizar los cálculos matemáticos y financieros de los cuadres en el tracker.
///
/// Centraliza la precisión monetaria (2 decimales) evitando errores de coma flotante IEEE 754.
abstract final class MotorCalculosCuadre {
  MotorCalculosCuadre._();

  /// Redondea un valor numérico a exactamente dos decimales monetarios seguros.
  static double redondearMoneda(double valor) {
    if (valor.isNaN || valor.isInfinite) {
      throw const ExcepcionCalculoMatematicoTracker('Intento de redondear un valor no numérico o infinito.');
    }
    return (valor * 100).roundToDouble() / 100.0;
  }

  /// Calcula la utilidad bruta (Total Ventas - Total Compras).
  static double calcularUtilidadBruta(double totalVentas, double totalCompras) {
    _validarMontosValidos(totalVentas, 'Total Ventas');
    _validarMontosValidos(totalCompras, 'Total Compras');
    return redondearMoneda(totalVentas - totalCompras);
  }

  /// Calcula la utilidad operativa (Utilidad Bruta - Gastos Muelle).
  static double calcularUtilidadOperativa(double utilidadBruta, double totalGastosMuelle) {
    _validarMontosValidos(totalGastosMuelle, 'Gastos Muelle');
    return redondearMoneda(utilidadBruta - totalGastosMuelle);
  }

  /// Calcula el reparto equitativo del 50% entre las partes.
  static double calcularReparto5050(double utilidad) {
    return redondearMoneda(utilidad / 2.0);
  }

  /// Calcula la diferencia de rendimiento en kilos entre la venta y la compra.
  static double calcularRendimientoKilos(double kilosVenta, double kilosCompra) {
    _validarMontosValidos(kilosVenta, 'Kilos Venta');
    _validarMontosValidos(kilosCompra, 'Kilos Compra');
    return redondearMoneda(kilosVenta - kilosCompra);
  }

  /// Calcula el precio promedio por kilo evitando divisiones por cero.
  static double calcularPrecioPromedioPorKilo(double totalMonto, double totalKilos) {
    if (totalKilos <= 0) return 0.0;
    return redondearMoneda(totalMonto / totalKilos);
  }

  /// Valida que el monto no sea NaN ni Infinito (seguridad de entrada).
  static void _validarMontosValidos(double valor, String campo) {
    if (valor.isNaN || valor.isInfinite) {
      throw ExcepcionCalculoMatematicoTracker('El valor para $campo es inválido ($valor).');
    }
  }
}
