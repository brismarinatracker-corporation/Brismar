import 'package:flutter/material.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'dialogo_gasto.dart';

class SeccionGastos extends StatelessWidget {
  final List<GastoWebModelo> gastos;
  final Function(GastoWebModelo) onGuardar;
  final Function(String) onEliminar;

  const SeccionGastos({
    super.key,
    required this.gastos,
    required this.onGuardar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gastos (Flete y Otros)', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Color(0xFFF1F5F9), height: 32),
          
          if (gastos.isEmpty) 
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No hay gastos registrados.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            ),
          
          ...gastos.map((g) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('${g.tipo} - ${g.concepto}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              subtitle: Text('Cant: ${g.cantidad} @ S/ ${g.costoUnitario}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('S/ ${g.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFFEA580C), size: 20),
                    onPressed: () => DialogoGasto.mostrar(context, g, onGuardar),
                    tooltip: 'Editar gasto',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => onEliminar(g.id),
                    tooltip: 'Eliminar gasto',
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => DialogoGasto.mostrar(context, null, onGuardar),
            icon: const Icon(Icons.add_rounded, color: Color(0xFFEA580C), size: 18),
            label: const Text('Añadir gasto', style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEA580C)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
    );
  }
}
