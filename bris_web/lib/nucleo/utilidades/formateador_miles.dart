import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormateadorMiles extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Solo números y puntos
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Evitar múltiples puntos
    if (newText.indexOf('.') != newText.lastIndexOf('.')) {
      newText = newText.substring(0, newText.lastIndexOf('.'));
    }

    final partes = newText.split('.');
    String enteros = partes[0];
    String decimalesTexto = partes.length > 1 ? '.${partes[1]}' : '';

    if (enteros.isNotEmpty) {
      final intValue = int.tryParse(enteros) ?? 0;
      final formatter = NumberFormat('#,###', 'en_US');
      enteros = formatter.format(intValue);
    }

    String resultText = enteros + decimalesTexto;

    int offset =
        newValue.selection.end + (resultText.length - newValue.text.length);
    if (offset < 0) offset = 0;
    if (offset > resultText.length) offset = resultText.length;

    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  static double parseDouble(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text.replaceAll(',', '')) ?? 0.0;
  }
}
