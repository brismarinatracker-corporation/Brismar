import 'package:flutter/material.dart';

/// Selector de pestañas para cambiar entre el formulario de registro y la lista de registros.
class TabSelector extends StatelessWidget {
  final int indiceActivo;
  final int totalRegistros;
  final ValueChanged<int> onTabChanged;

  const TabSelector({
    super.key,
    required this.indiceActivo,
    required this.totalRegistros,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTabItem("+ NUEVO REGISTRO", 0),
        _buildTabItem("⚓ REGISTRADOS ($totalRegistros)", 1),
      ],
    );
  }

  Widget _buildTabItem(String label, int index) {
    final active = indiceActivo == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.lightBlue : Colors.transparent,
            borderRadius: active ? const BorderRadius.only(topRight: Radius.circular(20)) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
