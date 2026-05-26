import 'package:flutter/material.dart';
import '../../dominio/entidades/registro_entidad.dart';

/// Lista que muestra el historial de capturas y gastos registrados.
class HistorialLista extends StatelessWidget {
  final List<RegistroEntidad> registros;
  final ValueChanged<RegistroEntidad> onGenerarPDF;

  const HistorialLista({
    super.key,
    required this.registros,
    required this.onGenerarPDF,
  });

  @override
  Widget build(BuildContext context) {
    if (registros.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No hay embarcaciones registradas hoy.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final reg = registros[index];
        return _buildCardRegistro(reg);
      },
    );
  }

  Widget _buildCardRegistro(RegistroEntidad reg) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildEncabezadoCard(reg),
            const Divider(),
            _buildDetalleCard(reg),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezadoCard(RegistroEntidad reg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_boat, color: Color(0xFF0D255F)),
            const SizedBox(width: 8),
            Text(
              reg.nombreEmbarcacion.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D255F)),
            ),
          ],
        ),
        _buildIconoSincronizacion(reg.sincronizado),
      ],
    );
  }

  Widget _buildIconoSincronizacion(bool sincronizado) {
    if (sincronizado) {
      return const Row(
        children: [
          Icon(Icons.cloud_done, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text('Sincronizado', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
    }
    return const Row(
      children: [
        Icon(Icons.cloud_upload, color: Colors.orange, size: 16),
        SizedBox(width: 4),
        Text('Pendiente (Offline)', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetalleCard(RegistroEntidad reg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Especie: ${reg.producto} | Muelle: ${reg.muelleInicio}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
            Text('${reg.kilos} kg a S/ ${reg.precioPorKilo.toStringAsFixed(2)} /kg', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text('Utilidad Neta: S/ ${reg.utilidadNeta.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => onGenerarPDF(reg),
          icon: const Icon(Icons.picture_as_pdf, size: 14, color: Colors.white),
          label: const Text('PDF', style: TextStyle(color: Colors.white, fontSize: 10)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1F31),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }
}
