import 'package:flutter/material.dart';

/// Cabecera que muestra el nombre del usuario activo y la fecha/hora actual.
/// Sigue el principio de Responsabilidad Única (SRP).
class EncabezadoUsuario extends StatelessWidget {
  final String nombreUsuario;

  const EncabezadoUsuario({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildInfoUsuario()),
        const SizedBox(width: 8),
        Expanded(child: _buildInfoFecha()),
      ],
    );
  }

  Widget _buildInfoUsuario() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A357D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.lightBlue,
            radius: 14,
            child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'USUARIO ACTIVO',
                style: TextStyle(color: Colors.white70, fontSize: 8),
              ),
              Text(
                nombreUsuario,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFecha() {
    final now = DateTime.now();
    final fechaStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A357D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            fechaStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Bahía Activa',
            style: TextStyle(color: Colors.lightBlueAccent, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
