import 'package:flutter/material.dart';
import '../../../../nucleo/enrutador/enrutador.dart';

class LayoutDashboard extends StatefulWidget {
  final Widget hijo;
  const LayoutDashboard({super.key, required this.hijo});

  @override
  State<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends State<LayoutDashboard> {
  int _indiceSeleccionado = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF0C1D3F),
            selectedIndex: _indiceSeleccionado,
            onDestinationSelected: (int index) {
              setState(() {
                _indiceSeleccionado = index;
              });
              if (index == 0) const RutaTransito().go(context);
              if (index == 1) const RutaCuadres().go(context);
              if (index == 2) const RutaUsuarios().go(context);
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(Icons.anchor_rounded, color: Color(0xFF00E5FF), size: 40),
                  const SizedBox(height: 8),
                  const Text('BRISMAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            selectedIconTheme: const IconThemeData(color: Color(0xFF00E5FF)),
            unselectedIconTheme: const IconThemeData(color: Colors.white54),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping_rounded),
                label: Text('Tránsito'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.table_view_rounded),
                label: Text('Exportar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_alt_rounded),
                label: Text('Usuarios'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    tooltip: 'Cerrar Sesión',
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF143068)),
          Expanded(
            child: Container(
              color: const Color(0xFF070E22), 
              child: widget.hijo,
            ),
          ),
        ],
      ),
    );
  }
}
