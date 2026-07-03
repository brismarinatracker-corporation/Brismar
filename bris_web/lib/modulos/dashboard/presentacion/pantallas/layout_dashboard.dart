import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../nucleo/enrutador/enrutador.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

/// Layout principal del Dashboard con NavRail persistente.
///
/// El índice activo del [NavigationRail] se deriva directamente de la URL
/// actual del router para evitar desincronizaciones al navegar por código
/// o por URL directa.
class LayoutDashboard extends ConsumerWidget {
  /// Widget hijo inyectado por el ShellRoute (la pantalla activa).
  final Widget hijo;

  const LayoutDashboard({super.key, required this.hijo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha solo los campos necesarios para evitar rebuilds extras.
    final authState = ref.watch(
      proveedorAutenticacion.select((s) => (
        rol: s.rol,
        nombreReal: s.nombreReal,
        fotoPerfil: s.fotoPerfil,
        isAuthenticated: s.isAuthenticated,
      )),
    );

    final esAdmin = authState.rol == 'administrador';
    final nombre = authState.nombreReal ?? 'Usuario';
    final rolTexto = (authState.rol ?? '').toUpperCase();
    final rutaActual = GoRouterState.of(context).uri.path;
    final indiceActivo = _calcularIndice(rutaActual, esAdmin);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _construirNavRail(context, ref, esAdmin, nombre, rolTexto, indiceActivo, authState.fotoPerfil),
          // Área principal sin animaciones de transición, cambio instantáneo.
          // Cada pantalla maneja su propio estado de carga (ej. Shimmer).
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: hijo,
            ),
          ),
        ],
      ),
    );
  }



  /// Calcula el índice correcto del [NavigationRail] a partir de la ruta.
  ///
  /// Considera si el usuario es admin para ajustar las posiciones.
  int _calcularIndice(String path, bool esAdmin) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/transito')) return 1;
    if (path.startsWith('/cuadres')) return 2;
    if (esAdmin && path.startsWith('/usuarios')) return 3;
    if (esAdmin && path.startsWith('/perfil')) return 4;
    if (!esAdmin && path.startsWith('/perfil')) return 3;
    return 0;
  }

  /// Navega a la ruta correspondiente al índice seleccionado.
  void _navegarAlIndice(BuildContext context, int index, bool esAdmin) {
    switch (index) {
      case 0: const RutaDashboard().go(context);
      case 1: const RutaTransito().go(context);
      case 2: const RutaCuadres().go(context);
      case 3: esAdmin ? const RutaUsuarios().go(context) : const RutaPerfil().go(context);
      case 4: if (esAdmin) const RutaPerfil().go(context);
    }
  }

  /// Construye el panel de navegación lateral completo.
  Widget _construirNavRail(
    BuildContext context,
    WidgetRef ref,
    bool esAdmin,
    String nombre,
    String rolTexto,
    int indiceActivo,
    String? fotoPerfil,
  ) {
    final esExtendido = MediaQuery.of(context).size.width >= 1200;

    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF090E17),
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                extended: esExtendido,
                minExtendedWidth: 260,
                selectedIndex: indiceActivo,
                onDestinationSelected: (index) => _navegarAlIndice(context, index, esAdmin),
                leading: _construirEncabezadoNav(esExtendido),
                selectedIconTheme: const IconThemeData(color: Color(0xFF10B981), size: 24),
                unselectedIconTheme: const IconThemeData(color: Color(0xFF94A3B8), size: 24),
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                useIndicator: true,
                indicatorColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                destinations: _construirDestinos(esAdmin),
              ),
            ),
            _construirPieNav(context, ref, esExtendido, nombre, rolTexto, fotoPerfil, esAdmin),
          ],
        ),
      ),
    );
  }

  /// Construye el logo/encabezado superior del NavigationRail.
  Widget _construirEncabezadoNav(bool esExtendido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.anchor_rounded, color: Color(0xFF10B981), size: 32),
          ),
          if (esExtendido) ...[
            const SizedBox(width: 12),
            const Text(
              'Brismar',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  /// Construye la lista de destinos del NavigationRail según el rol.
  List<NavigationRailDestination> _construirDestinos(bool esAdmin) {
    return [
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
    ];
  }

  /// Construye el pie del NavigationRail con avatar, nombre y botón de logout.
  Widget _construirPieNav(
    BuildContext context,
    WidgetRef ref,
    bool esExtendido,
    String nombre,
    String rolTexto,
    String? fotoPerfil,
    bool esAdmin,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (esExtendido) _construirTarjetaUsuario(context, esAdmin, nombre, rolTexto, fotoPerfil),
          const SizedBox(height: 16),
          _construirBotonLogout(ref),
        ],
      ),
    );
  }

  /// Tarjeta inferior del usuario autenticado (solo visible con rail extendido).
  Widget _construirTarjetaUsuario(
    BuildContext context,
    bool esAdmin,
    String nombre,
    String rolTexto,
    String? fotoPerfil,
  ) {
    return InkWell(
      onTap: () => const RutaPerfil().go(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            _construirAvatar(nombre, fotoPerfil),
            const SizedBox(width: 12),
            SizedBox(
              width: 130,
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
    );
  }

  /// Avatar circular del usuario con fallback a inicial del nombre.
  Widget _construirAvatar(String nombre, String? fotoPerfil) {
    final tieneFoto = fotoPerfil != null && fotoPerfil.isNotEmpty;
    return CircleAvatar(
      backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
      backgroundImage: tieneFoto ? NetworkImage(fotoPerfil) : null,
      child: tieneFoto
          ? null
          : Text(
              nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
              style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
            ),
    );
  }

  /// Botón de cierre de sesión.
  Widget _construirBotonLogout(WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
      tooltip: 'Cerrar Sesión',
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => ref.read(proveedorAutenticacion.notifier).cerrarSesion(),
    );
  }
}
