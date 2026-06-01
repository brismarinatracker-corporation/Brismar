import 'package:flutter/material.dart';

/// Sección que muestra los consolidados de Venta, Gastos y Utilidad Neta.
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
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF321A98),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL NETO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Venta - Gastos',
                    style: TextStyle(color: Colors.white54, fontSize: 9),
                  ),
                ],
              ),
              Text(
                'S/ ${totalNeto.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniLabel("VENTA", totalVenta),
              _buildMiniLabel("GASTOS", totalGastos),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLabel(String label, double val) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'S/ ${val.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
