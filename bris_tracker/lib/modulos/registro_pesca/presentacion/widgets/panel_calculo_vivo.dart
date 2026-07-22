import 'package:flutter/material.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';

class PanelCalculoVivo extends StatelessWidget {
  final double totalKilosCompras;
  final double totalCostoCompras;
  final double totalGastosOperativos;
  final bool guardando;
  final VoidCallback onGuardar;

  const PanelCalculoVivo({
    super.key,
    required this.totalKilosCompras,
    required this.totalCostoCompras,
    required this.totalGastosOperativos,
    required this.guardando,
    required this.onGuardar,
  });

  String _formatearNumero(double valor, {int decimales = 2}) {
    String str = valor.toStringAsFixed(decimales);
    List<String> partes = str.split('.');
    String entera = partes[0];
    String decimal = partes.length > 1 ? partes[1] : '';

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String enteraFormateada = entera.replaceAllMapped(
      reg,
      (Match m) => '${m[1]},',
    );

    if (decimales > 0 && decimal.isNotEmpty) {
      return '$enteraFormateada.$decimal';
    }
    return enteraFormateada;
  }

  Widget _buildSummary() {
    return Column(
      children: [
        _buildFilaResumen(
          'Kilos Totales',
          '${_formatearNumero(totalKilosCompras)} kg',
          const Color(0xFF1F2937),
        ),
        const Divider(color: Color(0xFFE5E7EB), height: 24),
        _buildFilaResumen(
          'Poder de Compra',
          'S/ ${_formatearNumero(totalCostoCompras)}',
          const Color(0xFF1F2937),
        ),
        _buildFilaResumen(
          'Gastos Muelle',
          '- S/ ${_formatearNumero(totalGastosOperativos)}',
          const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _buildEstimatesContainer() {
    final utilidadBruta = totalCostoCompras - totalGastosOperativos;
    final reparto = utilidadBruta / 2;
    final pagoEmbarcacionFinal = totalCostoCompras;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'ESTIMADO UTILIDAD (50/50)',
            style: TextStyle(
              color: Color(0xFF064E3B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'S/ ${_formatearNumero(reparto)} c/u',
            style: const TextStyle(
              color: Color(0xFF047857),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Divider(color: Color(0xFFA7F3D0), height: 24),
          const Text(
            'PAGO LÍQUIDO A EMBARCACIÓN',
            style: TextStyle(
              color: Color(0xFF064E3B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'S/ ${_formatearNumero(pagoEmbarcacionFinal)}',
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 64,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004236),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: guardando ? null : onGuardar,
        icon: guardando
            ? const CargaOrbital(tamano: 24, colorPrimario: Colors.white)
            : const Icon(Icons.save_rounded, size: 28),
        label: Text(
          guardando ? 'GUARDANDO...' : 'CONFIRMAR DESPACHO',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _buildContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildColumnChildren(),
      ),
    );
  }

  Decoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: const Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    );
  }

  List<Widget> _buildColumnChildren() {
    return [
      const Text(
        'CUADRE EN VIVO',
        style: TextStyle(
          color: Color(0xFF064E3B),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      _buildSummary(),
      const Divider(color: Color(0xFFE5E7EB), height: 32, thickness: 1),
      _buildEstimatesContainer(),
      const SizedBox(height: 24),
      const Text(
        '⚠️ Al guardar, el lote quedará en estado "Borrador" hasta el pesaje en planta.',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      _buildSaveButton(),
    ];
  }

  Widget _buildFilaResumen(String etiqueta, String valor, Color colorValor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 15),
          ),
          Text(
            valor,
            style: TextStyle(
              color: colorValor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
