import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _MascaraMilesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanText = newValue.text.replaceAll(',', '');

    // Permite números con un único punto decimal
    final regExp = RegExp(r'^\d*\.?\d*$');
    if (!regExp.hasMatch(cleanText)) {
      return oldValue;
    }

    List<String> partes = cleanText.split('.');
    String entero = partes[0];
    String decimal = partes.length > 1 ? '.${partes[1]}' : '';

    if (entero.isNotEmpty) {
      final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
      entero = entero.replaceAllMapped(reg, (Match m) => '${m[1]},');
    }

    final formatted = entero + decimal;

    // Coloca el cursor al final del texto formateado
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class SeccionEmbarcacionForm extends StatelessWidget {
  final int index;
  final bool mostrarBotonEliminar;
  final VoidCallback? onEliminar;
  final TextEditingController nombreNaveController;
  final TextEditingController kilosController;
  final TextEditingController precioVentaController;

  const SeccionEmbarcacionForm({
    super.key,
    required this.index,
    required this.mostrarBotonEliminar,
    this.onEliminar,
    required this.nombreNaveController,
    required this.kilosController,
    required this.precioVentaController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1938), // Color de la imagen
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1C2A54), // Borde de la imagen
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.anchor_rounded, color: Color(0xFF00E5FF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'EMBARCACIÓN #${index + 1}',
                    style: TextStyle(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              if (mostrarBotonEliminar)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.orangeAccent, size: 20),
                  onPressed: onEliminar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  tooltip: "Eliminar embarcación",
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(
            "Nombre de la Embarcación *",
            "Ej: DON JOSÉ I",
            nombreNaveController,
            esObligatorio: true,
            inputFormatters: [_UpperCaseTextFormatter()],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Kilos capturados *",
                  "0.0",
                  kilosController,
                  isNumeric: true,
                  isFormatted: true,
                  esObligatorio: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  "Precio de venta (Kg) *",
                  "0.00",
                  precioVentaController,
                  isNumeric: true,
                  isCurrency: true,
                  esObligatorio: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumeric = false,
    bool isCurrency = false,
    bool isFormatted = false,
    bool esObligatorio = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: _inputDecoration(hint, isCurrency: isCurrency),
          inputFormatters: [
            if (isNumeric) ...[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              if (isCurrency || isFormatted) _MascaraMilesFormatter() else FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            ...?inputFormatters,
          ],
          validator: validator ?? (v) {
            if (esObligatorio && (v == null || v.trim().isEmpty)) {
              return 'Requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {required bool isCurrency}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF070E22), // Fondo oscuro de los campos de la imagen
      prefixText: isCurrency ? 'S/ ' : null,
      prefixStyle: const TextStyle(
        color: Color(0xFF00E5FF),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)), // Borde de los campos de la imagen
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
    );
  }
}

