import 'package:flutter/material.dart';
import '../../dominio/entidades/registro_entidad.dart';

/// Lista que muestra el historial de capturas y gastos registrados con diseño premium.
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, color: Colors.white.withValues(alpha: 0.2), size: 40),
              const SizedBox(height: 12),
              Text(
                'No hay embarcaciones registradas hoy.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEncabezadoCard(reg),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 10),
          _buildDetalleCard(reg),
        ],
      ),
    );
  }

  Widget _buildEncabezadoCard(RegistroEntidad reg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_boat_rounded, color: Color(0xFF00E5FF), size: 18),
            const SizedBox(width: 8),
            Text(
              reg.nombreEmbarcacion.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        _buildIconoSincronizacion(reg.sincronizado),
      ],
    );
  }

  Widget _buildIconoSincronizacion(bool sincronizado) {
    final colorStatus = sincronizado ? const Color(0xFF00E676) : Colors.orangeAccent;
    final labelStatus = sincronizado ? 'SINCRONIZADO' : 'PENDIENTE (OFFLINE)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorStatus.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorStatus.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sincronizado ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
            color: colorStatus,
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            labelStatus,
            style: TextStyle(
              color: colorStatus,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleCard(RegistroEntidad reg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Especie: ${reg.producto}  |  Muelle: ${reg.muelleInicio}  |  Cajas: ${reg.cajas}',
                style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                '${_formatearNumero(reg.kilos, decimales: 1)} kg a S/ ${_formatearNumero(reg.precioPorKilo)} /kg',
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Text(
                    'Utilidad Neta: ',
                    style: TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                  Text(
                    'S/ ${_formatearNumero(reg.utilidadNeta)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E676),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => onGenerarPDF(reg),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.white),
          label: const Text(
            'PDF',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: Size.zero,
            elevation: 2,
          ),
        ),
      ],
    );
  }

  String _formatearNumero(double valor, {int decimales = 2}) {
    String str = valor.toStringAsFixed(decimales);
    List<String> partes = str.split('.');
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    partes[0] = partes[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
    return partes.join('.');
  }
}
