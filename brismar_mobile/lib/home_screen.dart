import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Importamos la pantalla de perfil

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Gestión - BRISMAR'),
        backgroundColor: const Color(0xFF0D255F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // BOTÓN DE PERFIL
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Mi Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          // BOTÓN DE CERRAR SESIÓN
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabecera de bienvenida con diseño redondeado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFF0D255F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, Bienvenida',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  'Sistema Pesquero Brismar',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 22, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // Lista de opciones de gestión
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _buildListOption(
                  context,
                  'Registro de Embarcaciones',
                  'Gestión de capturas y bahía',
                  Icons.directions_boat,
                  Colors.blue.shade700,
                ),
                _buildListOption(
                  context,
                  'Control de Inventario',
                  'Entrada y salida de suministros',
                  Icons.inventory_2,
                  Colors.teal,
                ),
                _buildListOption(
                  context,
                  'Liquidación de Pesca',
                  'Cálculo de pagos y boletas',
                  Icons.account_balance_wallet,
                  Colors.indigo,
                ),
                _buildListOption(
                  context,
                  'Reportes y Estadísticas',
                  'Análisis de producción mensual',
                  Icons.bar_chart,
                  Colors.deepPurple,
                ),
                _buildListOption(
                  context,
                  'Configuración de Usuarios',
                  'Administrar accesos al sistema',
                  Icons.admin_panel_settings,
                  Colors.blueGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget funcional para crear cada fila de la lista
  Widget _buildListOption(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
	        leading: Container(
	          padding: const EdgeInsets.all(10),
	          decoration: BoxDecoration(
	            color: color.withAlpha(26),
	            borderRadius: BorderRadius.circular(10),
	          ),
	          child: Icon(icon, color: color, size: 30),
	        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
	        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
	        onTap: () {
	          // Aquí puedes agregar la navegación a cada módulo específico
	          debugPrint('Navegando a: $title');
	        },
	      ),
	    );
	  }
}
