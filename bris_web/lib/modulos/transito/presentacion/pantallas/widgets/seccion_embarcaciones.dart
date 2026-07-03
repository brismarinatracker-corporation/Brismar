import 'package:flutter/material.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'dialogo_compra.dart';

class SeccionEmbarcaciones extends StatelessWidget {
  final List<CompraWebModelo> compras;
  final Function(CompraWebModelo) onGuardar;
  final Function(String) onEliminar;

  const SeccionEmbarcaciones({
    super.key,
    required this.compras,
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
          const Text('Embarcaciones Asociadas (Compras)', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Color(0xFFF1F5F9), height: 32),
          
          if (compras.isEmpty) 
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No hay embarcaciones registradas.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            ),
          
          ...compras.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('${c.embarcacion} - ${c.producto}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              subtitle: Text('${c.kilos}kg @ S/ ${c.precioUnitario}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('S/ ${c.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF00796B), size: 20),
                    onPressed: () => DialogoCompra.mostrar(context, c, onGuardar),
                    tooltip: 'Editar embarcación',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => onEliminar(c.id),
                    tooltip: 'Eliminar embarcación',
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => DialogoCompra.mostrar(context, null, onGuardar),
            icon: const Icon(Icons.add_rounded, color: Color(0xFF00796B), size: 18),
            label: const Text('Añadir embarcación', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00796B)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
    );
  }
}
