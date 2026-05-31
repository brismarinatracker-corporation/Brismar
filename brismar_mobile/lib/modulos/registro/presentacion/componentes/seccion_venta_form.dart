import 'package:flutter/material.dart';

class SeccionVentaForm extends StatelessWidget {
  final TextEditingController precioKiloVentaController;
  final double totalVenta;

  const SeccionVentaForm({
    super.key,
    required this.precioKiloVentaController,
    required this.totalVenta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF006B3D),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: const Text(
            '\$ PRECIO Y VENTA',
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
              _buildTextField(
                "PRECIO DE VENTA POR KILO *",
                "0.00",
                precioKiloVentaController,
                isNumeric: true,
                esObligatorio: true,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL DE VENTA ESTIMADO',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                  Text(
                    'S/ ${totalVenta.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
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
