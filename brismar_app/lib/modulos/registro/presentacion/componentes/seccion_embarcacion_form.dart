import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController placaController;
  final TextEditingController muelleController;
  final String? productoSeleccionado;
  final ValueChanged<String?> onProductoChanged;

  const SeccionEmbarcacionForm({
    super.key,
    required this.index,
    required this.mostrarBotonEliminar,
    this.onEliminar,
    required this.nombreNaveController,
    required this.kilosController,
    required this.placaController,
    required this.muelleController,
    required this.productoSeleccionado,
    required this.onProductoChanged,
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
                  esObligatorio: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🐟 PRODUCTO *',
                      style: TextStyle(
                        color: Color(0xFF00E5FF), // Color turquesa neón para máxima legibilidad
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: productoSeleccionado,
                      dropdownColor: const Color(0xFF0E1938), // Fondo del desplegable
                      iconEnabledColor: const Color(0xFF00E5FF),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00E5FF)),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      hint: const Text(
                        "Seleccionar..",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      decoration: _inputDecoration(""),
                      items: ["POTA", "JUREL", "BONITO", "CABALLA"]
                          .map(
                            (e) {
                              final Map<String, Color> coloresProductos = {
                                "POTA": const Color(0xFFE040FB), // Magenta/Morado
                                "JUREL": const Color(0xFF29B6F6), // Celeste
                                "BONITO": const Color(0xFF00E676), // Verde brillante
                                "CABALLA": const Color(0xFFFFB74D), // Ámbar/Naranja
                              };
                              final colorTag = coloresProductos[e] ?? const Color(0xFF00E5FF);
                              return DropdownMenuItem(
                                value: e,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: colorTag,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorTag.withValues(alpha: 0.4),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      e,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                          .toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return ["POTA", "JUREL", "BONITO", "CABALLA"].map((e) {
                          final Map<String, Color> coloresProductos = {
                            "POTA": const Color(0xFFE040FB),
                            "JUREL": const Color(0xFF29B6F6),
                            "BONITO": const Color(0xFF00E676),
                            "CABALLA": const Color(0xFFFFB74D),
                          };
                          final colorTag = coloresProductos[e] ?? const Color(0xFF00E5FF);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colorTag,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Placa de Cámara",
                  "Ej: ABC123",
                  placaController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    LengthLimitingTextInputFormatter(6),
                    _UpperCaseTextFormatter(),
                  ],
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (v.trim().length != 6) {
                        return 'Exactamente 6 caracteres';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
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
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumeric = false,
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
          decoration: _inputDecoration(hint),
          inputFormatters: [
            if (isNumeric) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF070E22), // Fondo oscuro de los campos de la imagen
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
