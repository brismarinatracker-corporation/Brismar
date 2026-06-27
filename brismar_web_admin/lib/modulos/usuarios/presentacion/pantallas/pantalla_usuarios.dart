import 'package:flutter/material.dart';

class PantallaUsuarios extends StatelessWidget {
  const PantallaUsuarios({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Gestión de Usuarios',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Crea y administra cuentas para operarios de Piura y administradores de Lambayeque.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          SizedBox(height: 48),
          Center(
            child: Text('Módulo de Gestión de Usuarios - Próximamente', style: TextStyle(color: Colors.white54)),
          )
        ],
      ),
    );
  }
}
