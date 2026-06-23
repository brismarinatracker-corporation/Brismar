import 'package:flutter/material.dart';

/// Cabecera que muestra la Fecha y la Hora del registro en formato de tarjetas side-by-side.
/// Cumple con el diseño exacto de la imagen (iconos amarillos y fondo azul oscuro).
class EncabezadoUsuario extends StatelessWidget {
  final String nombreUsuario;
  final DateTime? fechaSeleccionada;
  final VoidCallback? onTapFecha;

  const EncabezadoUsuario({
    super.key,
    required this.nombreUsuario,
    this.fechaSeleccionada,
    this.onTapFecha,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = fechaSeleccionada ?? DateTime.now();
    final fechaStr =
        '${fecha.day.toString().padLeft(2, '0')} / ${fecha.month.toString().padLeft(2, '0')} / ${fecha.year}';
    final now = DateTime.now();
    final horaStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        // Tarjeta de Fecha (Editable si onTapFecha no es nulo)
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTapFecha,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1938),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: onTapFecha != null 
                        ? const Color(0xFFFFD54F).withValues(alpha: 0.3) 
                        : const Color(0xFF1C2A54),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFFFFD54F), // Amarillo/Dorado de la imagen
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Fecha',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fechaStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Tarjeta de Hora
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1938),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF1C2A54),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFFFFD54F), // Amarillo/Dorado de la imagen
                  size: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hora',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      horaStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
