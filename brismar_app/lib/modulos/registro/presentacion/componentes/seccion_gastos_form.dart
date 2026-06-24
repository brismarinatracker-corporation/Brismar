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

class SeccionGastosForm extends StatelessWidget {
  final TextEditingController facturacionController;
  final TextEditingController personalController;
  final TextEditingController apoyoController;
  final TextEditingController aguaController;
  final TextEditingController cloroxController;
  final TextEditingController fleteController;
  final TextEditingController hieloController;
  final TextEditingController otrosController;
  final TextEditingController pesadorController;
  final TextEditingController observacionesController;

  const SeccionGastosForm({
    super.key,
    required this.facturacionController,
    required this.personalController,
    required this.apoyoController,
    required this.aguaController,
    required this.cloroxController,
    required this.fleteController,
    required this.hieloController,
    required this.otrosController,
    required this.pesadorController,
    required this.observacionesController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1938),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1C2A54),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_rounded, color: Color(0xFFFFD54F), size: 18),
              SizedBox(width: 8),
              Text(
                'DESGLOSE DE GASTOS DEL MUELLE',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Facturación",
                  "0.0",
                  facturacionController,
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  "Personal / Estibas",
                  "0.0",
                  personalController,
                  isNumeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Apoyo Operativo",
                  "0.0",
                  apoyoController,
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  "Agua Potable",
                  "0.0",
                  aguaController,
                  isNumeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Clorox / Limpieza",
                  "0.0",
                  cloroxController,
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  "Flete / Transporte",
                  "0.0",
                  fleteController,
                  isNumeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Hielo de Conservación",
                  "0.0",
                  hieloController,
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  "Otros Gastos",
                  "0.0",
                  otrosController,
                  isNumeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Pesador",
                  "0.0",
                  pesadorController,
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "OBSERVACIONES / NOTAS",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: observacionesController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: _inputDecoration("Escribe algún problema o nota adicional...", isNumeric: false),
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
    bool esObligatorio = false,
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
          decoration: _inputDecoration(hint, isNumeric: isNumeric),
          inputFormatters: [
            if (isNumeric) ...[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              _MascaraMilesFormatter(),
            ],
          ],
          validator: (v) {
            if (esObligatorio && (v == null || v.trim().isEmpty)) {
              return 'Requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {required bool isNumeric}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF070E22), // Fondo oscuro uniforme
      prefixText: isNumeric ? 'S/ ' : null,
      prefixStyle: const TextStyle(
        color: Color(0xFF00E5FF),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)), // Borde azul oscuro uniforme
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

