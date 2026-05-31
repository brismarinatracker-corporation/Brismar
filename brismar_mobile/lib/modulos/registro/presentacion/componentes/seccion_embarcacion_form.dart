import 'package:flutter/material.dart';

class SeccionEmbarcacionForm extends StatelessWidget {
  final TextEditingController nombreNaveController;
  final TextEditingController kilosController;
  final TextEditingController placaController;
  final TextEditingController muelleController;
  final String? productoSeleccionado;
  final ValueChanged<String?> onProductoChanged;

  const SeccionEmbarcacionForm({
    super.key,
    required this.nombreNaveController,
    required this.kilosController,
    required this.placaController,
    required this.muelleController,
    required this.productoSeleccionado,
    required this.onProductoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF0D255F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: const Text(
            '⚓ DATOS DE LA EMBARCACIÓN',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                "Nombre de la Embarcación *",
                "Ej: Don José I",
                nombreNaveController,
                esObligatorio: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Kilos capturados *",
                      "0.0",
                      kilosController,
                      isNumeric: true,
                      esObligatorio: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🐟 PRODUCTO *',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: productoSeleccionado,
                          decoration: _inputDecoration("Seleccionar.."),
                          items: ["POTA", "JUREL", "BONITO", "CABALLA"]
                              .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 11))))
                              .toList(),
                          onChanged: onProductoChanged,
                          validator: (v) => v == null ? 'Obligatorio' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Placa de Cámara",
                      "Ej: ABC-123",
                      placaController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      "Muelle de Partida *",
                      "Ej: Muelle A",
                      muelleController,
                      esObligatorio: true,
                    ),
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
