import 'package:flutter/services.dart';

/// Formateador de texto que convierte todo el contenido a mayúsculas.
class UpperCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Formateador de placas vehiculares peruanas (Ej: AAA-123).
///
/// Convierte a mayúsculas, limita a 6 caracteres alfanuméricos
/// e inserta automáticamente el guión en la posición 4.
class PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();
    if (text.length > 6) {
      return oldValue;
    }
    String formatted = text;
    if (text.length > 3) {
      formatted = '${text.substring(0, 3)}-${text.substring(3)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
