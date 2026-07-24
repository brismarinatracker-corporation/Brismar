/// Excepción del dominio lanzada cuando se intenta realizar un cálculo financiero inválido.
final class ExcepcionCalculoMatematico implements Exception {
  /// Mensaje explicativo del fallo matemático.
  final String mensaje;

  /// Constructor inmutable de la excepción.
  const ExcepcionCalculoMatematico(this.mensaje);

  @override
  String toString() => 'ExcepcionCalculoMatematico: $mensaje';
}

/// Motor del dominio encargado de realizar los cálculos matemáticos y financieros de los cuadres.
///
/// Centraliza la precisión monetaria (2 decimales) evitando errores de coma flotante IEEE 754.
abstract final class MotorCalculosCuadre {
  MotorCalculosCuadre._();

  /// Redondea un valor numérico a exactamente dos decimales monetarios seguros.
  static double redondearMoneda(double valor) {
    if (valor.isNaN || valor.isInfinite) {
      throw const ExcepcionCalculoMatematico('Intento de redondear un valor no numérico o infinito.');
    }
    return (valor * 100).roundToDouble() / 100.0;
  }

  /// Calcula la utilidad bruta (Total Ventas - Total Compras).
  static double calcularUtilidadBruta(double totalVentas, double totalCompras) {
    _validarPositivoOMontosValidos(totalVentas, 'Total Ventas');
    _validarPositivoOMontosValidos(totalCompras, 'Total Compras');
    return redondearMoneda(totalVentas - totalCompras);
  }

  /// Calcula la utilidad operativa (Utilidad Bruta - Gastos Muelle).
  static double calcularUtilidadOperativa(double utilidadBruta, double totalGastosMuelle) {
    _validarPositivoOMontosValidos(totalGastosMuelle, 'Gastos Muelle');
    return redondearMoneda(utilidadBruta - totalGastosMuelle);
  }

  /// Calcula la utilidad antes de reparto (Utilidad Operativa - Gastos Administrativos).
  static double calcularUtilidadAntesReparto(double utilidadOperativa, double totalGastosAdmin) {
    _validarPositivoOMontosValidos(totalGastosAdmin, 'Gastos Administrativos');
    return redondearMoneda(utilidadOperativa - totalGastosAdmin);
  }

  /// Calcula el reparto equitativo del 50% entre las partes.
  static double calcularReparto5050(double utilidad) {
    return redondearMoneda(utilidad / 2.0);
  }

  /// Calcula la diferencia de rendimiento en kilos entre la venta y la compra.
  static double calcularRendimientoKilos(double kilosVenta, double kilosCompra) {
    _validarPositivoOMontosValidos(kilosVenta, 'Kilos Venta');
    _validarPositivoOMontosValidos(kilosCompra, 'Kilos Compra');
    return redondearMoneda(kilosVenta - kilosCompra);
  }

  /// Calcula el precio promedio por kilo evitando divisiones por cero.
  static double calcularPrecioPromedioPorKilo(double totalMonto, double totalKilos) {
    if (totalKilos <= 0) return 0.0;
    return redondearMoneda(totalMonto / totalKilos);
  }

  /// Valida que el monto no sea NaN ni Infinito (seguridad de entrada).
  static void _validarPositivoOMontosValidos(double valor, String campo) {
    if (valor.isNaN || valor.isInfinite) {
      throw ExcepcionCalculoMatematico('El valor para $campo es inválido ($valor).');
    }
  }
}
