import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTablaCarga extends StatelessWidget {
  final int filas;
  final bool oscuro;

  const ShimmerTablaCarga({super.key, this.filas = 5, this.oscuro = true});

  @override
  Widget build(BuildContext context) {
    final baseColor = oscuro ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = oscuro ? Colors.grey[700]! : Colors.grey[100]!;
    final bgColor = oscuro ? const Color(0xFF1E201E) : Colors.white;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(filas, (index) => _construirFila(baseColor, highlightColor)),
      ),
    );
  }

  Widget _construirFila(Color baseColor, Color highlightColor) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(height: 16, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Container(height: 16, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Container(height: 16, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Container(height: 24, width: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            ),
          ],
        ),
      ),
    );
  }
}
