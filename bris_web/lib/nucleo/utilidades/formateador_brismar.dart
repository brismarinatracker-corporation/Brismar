import 'package:intl/intl.dart';

/// Utilidad estática centralizada para el formateo estandarizado de moneda, pesos y porcentajes en BRISMAR Web.
abstract final class FormateadorBrismar {
  FormateadorBrismar._();

  static final NumberFormat _formatoMoneda = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
    locale: 'es_PE',
  );

  static final NumberFormat _formatoNumero = NumberFormat.decimalPattern('es_PE');

  /// Formatea un monto numérico a moneda oficial soles (ej. S/ 1,250.50).
  static String formatearMoneda(double valor) {
    if (valor.isNaN || valor.isInfinite) return 'S/ 0.00';
    return _formatoMoneda.format(valor);
  }

  /// Formatea una cantidad en kilogramos (ej. 1,250.00 kg).
  static String formatearKilos(double valor, {int decimales = 2}) {
    if (valor.isNaN || valor.isInfinite) return '0.00 kg';
    final texto = valor.toStringAsFixed(decimales);
    final partes = texto.split('.');
    final entera = _formatoNumero.format(int.tryParse(partes[0]) ?? 0);
    return decimales > 0 && partes.length > 1
        ? '$entera.${partes[1]} kg'
        : '$entera kg';
  }

  /// Formatea un porcentaje (ej. 12.50%).
  static String formatearPorcentaje(double valor, {int decimales = 2}) {
    if (valor.isNaN || valor.isInfinite) return '0.00%';
    return '${valor.toStringAsFixed(decimales)}%';
  }
}
