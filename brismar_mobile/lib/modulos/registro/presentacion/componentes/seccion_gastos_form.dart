import 'package:flutter/material.dart';

class SeccionGastosForm extends StatelessWidget {
  final TextEditingController facturacionController;
  final TextEditingController personalController;
  final TextEditingController apoyoController;
  final TextEditingController aguaController;
  final TextEditingController cloroxController;
  final TextEditingController fleteController;
  final TextEditingController hieloController;
  final TextEditingController otrosController;

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF8B3A0F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: const Text(
            '💵 DESGLOSE DE GASTOS DEL MUELLE',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        "FACTURACIÓN", "0.0", facturacionController,
                        isNumeric: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                        "PERSONAL/ESTIBAS", "0.0", personalController,
                        isNumeric: true),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        "APOYO OPERATIVO", "0.0", apoyoController,
                        isNumeric: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                        "AGUA potable", "0.0", aguaController,
                        isNumeric: true),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        "CLOROX / LIMPIEZA", "0.0", cloroxController,
                        isNumeric: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                        "FLETE / TRANSPORTE", "0.0", fleteController,
                        isNumeric: true),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        "HIELO DE CONSERVACIÓN", "0.0", hieloController,
                        isNumeric: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField("OTROS GASTOS", "0.0", otrosController,
                        isNumeric: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {bool isNumeric = false, bool esObligatorio = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: const TextStyle(fontSize: 12),
          decoration: _inputDecoration(hint),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade100)),
    );
  }
}
