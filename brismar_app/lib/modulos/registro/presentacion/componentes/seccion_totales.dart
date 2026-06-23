import 'package:flutter/material.dart';

/// Sección que muestra los consolidados de Venta, Gastos y Utilidad Neta con un diseño premium.
class SeccionTotales extends StatelessWidget {
  final double totalVenta;
  final double totalGastos;
  final double totalNeto;

  const SeccionTotales({
    super.key,
    required this.totalVenta,
    required this.totalGastos,
    required this.totalNeto,
  });

  @override
  Widget build(BuildContext context) {
    final esPositivo = totalNeto >= 0;
    final colorNeto = esPositivo ? const Color(0xFF00E676) : const Color(0xFFFF1744);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F224A).withValues(alpha: 0.75),
            const Color(0xFF13254C).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        esPositivo ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: colorNeto,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'UTILIDAD NETA TOTAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ingresos de Venta - Gastos de Muelle',
                    style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 0.3),
                  ),
                ],
              ),
              Text(
                'S/ ${_formatearNumero(totalNeto)}',
                style: TextStyle(
                  color: colorNeto,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: colorNeto.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniLabel("INGRESOS", totalVenta, const Color(0xFF00E676), Icons.arrow_upward_rounded),
              Container(
                width: 1.2,
                height: 30,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _buildMiniLabel("GASTOS", totalGastos, const Color(0xFFFF7043), Icons.arrow_downward_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLabel(String label, double val, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'S/ ${_formatearNumero(val)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
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
