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
    final nombre = authState.nombreReal ?? 'Usuario';
    final rolTexto = (authState.rol ?? '').toUpperCase();

    return Scaffold(
      body: Row(
        children: [
          // NavigationRail Premium
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF090E17),
              border: Border(
                right: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: NavigationRail(
                      backgroundColor: Colors.transparent,
                      extended: MediaQuery.of(context).size.width >= 1200,
                      minExtendedWidth: 260,
                      selectedIndex: _indiceSeleccionado,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _indiceSeleccionado = index;
                        });
                        if (index == 0) const RutaDashboard().go(context);
                        if (index == 1) const RutaTransito().go(context);
                        if (index == 2) const RutaCuadres().go(context);
                        if (esAdmin) {
                          if (index == 3) const RutaUsuarios().go(context);
                          if (index == 4) const RutaPerfil().go(context);
                        } else {
                          if (index == 3) const RutaPerfil().go(context);
                        }
                      },
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.anchor_rounded, color: Color(0xFF00E5FF), size: 32),
                            ),
                            if (MediaQuery.of(context).size.width >= 1200) ...[
                              const SizedBox(width: 12),
                              const Text(
                                'BRISMAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      selectedIconTheme: const IconThemeData(color: Color(0xFF00E5FF), size: 28),
                      unselectedIconTheme: const IconThemeData(color: Color(0xFF94A3B8), size: 24),
                      selectedLabelTextStyle: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelTextStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      useIndicator: true,
                      indicatorColor: const Color(0xFF00E5FF).withOpacity(0.15),
                      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      destinations: [
                        const NavigationRailDestination(
                          icon: Icon(Icons.dashboard_outlined),
                          selectedIcon: Icon(Icons.dashboard_rounded),
                          label: Text('Dashboard'),
                        ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.local_shipping_outlined),
                          selectedIcon: Icon(Icons.local_shipping_rounded),
                          label: Text('Tránsito'),
                        ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.table_view_outlined),
                          selectedIcon: Icon(Icons.table_view_rounded),
                          label: Text('Cuadres'),
                        ),
                        if (esAdmin)
                          const NavigationRailDestination(
                            icon: Icon(Icons.people_alt_outlined),
                            selectedIcon: Icon(Icons.people_alt_rounded),
                            label: Text('Usuarios'),
                          ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person_rounded),
                          label: Text('Perfil'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (MediaQuery.of(context).size.width >= 1200)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
                                  backgroundImage: authState.fotoPerfil != null && authState.fotoPerfil!.isNotEmpty 
                                    ? NetworkImage(authState.fotoPerfil!) 
                                    : null,
                                  child: authState.fotoPerfil == null || authState.fotoPerfil!.isEmpty
                                    ? Text(
                                        nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
                                        style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                                      )
                                    : null,
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 130, // Ancho fijo para evitar crash de IntrinsicWidth
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        rolTexto,
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                          tooltip: 'Cerrar Sesión',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            ref.read(proveedorAutenticacion.notifier).cerrarSesion();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Área Principal de Contenido
          Expanded(
            child: Container(
              color: const Color(0xFF0F172A), 
              child: widget.hijo,
            ),
          ),
        ],
      ),
    );
  }
}
