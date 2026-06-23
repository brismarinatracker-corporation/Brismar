import 'package:flutter/material.dart';

/// Selector de pestañas para cambiar entre el formulario de registro y la lista de registros.
class SelectorPestanas extends StatelessWidget {
  final int indiceActivo;
  final int totalRegistros;
  final ValueChanged<int> onTabChanged;

  const SelectorPestanas({
    super.key,
    required this.indiceActivo,
    required this.totalRegistros,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _buildTabItem("➕ NUEVO REGISTRO", 0),
          _buildTabItem("⚓ REGISTRADOS ($totalRegistros)", 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final active = indiceActivo == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0077C2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
