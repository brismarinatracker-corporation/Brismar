import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaCamaras extends StatelessWidget {
  const PantallaCamaras({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_filled_outlined, size: 80, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              'Módulo de Cámaras en Construcción',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente podrás registrar y gestionar las cámaras isotérmicas (vehículos) aquí.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
