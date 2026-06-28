import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../nucleo/enrutador/enrutador.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

class LayoutDashboard extends ConsumerStatefulWidget {
  final Widget hijo;
  const LayoutDashboard({super.key, required this.hijo});

  @override
  ConsumerState<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends ConsumerState<LayoutDashboard> {
  int _indiceSeleccionado = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(proveedorAutenticacion);
    final esAdmin = authState.rol == 'administrador';

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
              if (index == 2 && esAdmin) const RutaUsuarios().go(context);
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
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.local_shipping_rounded),
                label: Text('Tránsito'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.table_view_rounded),
                label: Text('Exportar'),
              ),
              if (esAdmin)
                const NavigationRailDestination(
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
                    onPressed: () {
                      ref.read(proveedorAutenticacion.notifier).cerrarSesion();
                    },
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
