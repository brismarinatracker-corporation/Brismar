import 'package:flutter/material.dart';
import 'package:brismar_mobile/nucleo/componentes/carga_orbital.dart';

class PanelCalculoVivo extends StatelessWidget {
  final double totalKilosCompras;
  final double totalCostoCompras;
  final double totalGastosOperativos;
  final double totalAdelantos;
  final bool guardando;
  final VoidCallback onGuardar;

  const PanelCalculoVivo({
    super.key,
    required this.totalKilosCompras,
    required this.totalCostoCompras,
    required this.totalGastosOperativos,
    required this.totalAdelantos,
    required this.guardando,
    required this.onGuardar,
  });

  String _formatearNumero(double valor, {int decimales = 2}) {
    String str = valor.toStringAsFixed(decimales);
    List<String> partes = str.split('.');
    String entera = partes[0];
    String decimal = partes.length > 1 ? partes[1] : '';

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String enteraFormateada = entera.replaceAllMapped(reg, (Match m) => '${m[1]},');

    if (decimales > 0 && decimal.isNotEmpty) return '$enteraFormateada.$decimal';
    return enteraFormateada;
  }

  @override
  Widget build(BuildContext context) {
    // Cálculo estimado de la partición (50/50).
    final utilidadBruta = totalCostoCompras - totalGastosOperativos;
    final reparto = utilidadBruta / 2;
    // Si hay adelantos, se restan del pago final a la embarcación
    final pagoEmbarcacionFinal = totalCostoCompras - totalAdelantos;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF040B1E),
        border: Border(left: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.3), width: 2)),
        boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.05), blurRadius: 30, offset: const Offset(-5, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CUADRE EN VIVO',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFilaResumen('Kilos Totales', '${_formatearNumero(totalKilosCompras)} kg', Colors.white),
          const Divider(color: Colors.white12, height: 24),
          _buildFilaResumen('Poder de Compra', 'S/ ${_formatearNumero(totalCostoCompras)}', Colors.white),
          _buildFilaResumen('Adelantos (Cash)', '- S/ ${_formatearNumero(totalAdelantos)}', const Color(0xFFFFB74D)),
          _buildFilaResumen('Gastos Muelle', '- S/ ${_formatearNumero(totalGastosOperativos)}', Colors.redAccent),
          const Divider(color: Colors.white24, height: 32, thickness: 1),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F224A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
            ),
            child: Column(
              children: [
                const Text('ESTIMADO UTILIDAD (50/50)', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'S/ ${_formatearNumero(reparto)} c/u',
                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const Divider(color: Colors.white12, height: 24),
                const Text('PAGO LÍQUIDO A EMBARCACIÓN', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'S/ ${_formatearNumero(pagoEmbarcacionFinal)}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            '⚠️ Al guardar, el lote quedará en estado "Borrador" hasta el pesaje en planta.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 64, // Botón POS gigante
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: const Color(0xFF040B1E),
                elevation: 10,
                shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: guardando ? null : onGuardar,
              icon: guardando
                  ? const CargaOrbital(tamano: 24, colorPrimario: Color(0xFF040B1E))
                  : const Icon(Icons.save_rounded, size: 28),
              label: Text(
                guardando ? 'GUARDANDO...' : 'CONFIRMAR DESPACHO',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaResumen(String etiqueta, String valor, Color colorValor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Text(valor, style: TextStyle(color: colorValor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
