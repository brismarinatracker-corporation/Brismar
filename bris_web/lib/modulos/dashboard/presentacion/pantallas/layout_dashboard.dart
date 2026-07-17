import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../nucleo/enrutador/enrutador.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

class LayoutDashboard extends ConsumerStatefulWidget {
  final Widget hijo;
  const LayoutDashboard({super.key, required this.hijo});

  @override
  ConsumerState<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends ConsumerState<LayoutDashboard> {
  /// Deriva el índice activo directamente desde la ruta actual del GoRouter.
  /// Esta es la ÚNICA fuente de verdad para el estado de navegación.
  /// Así se elimina el bug donde el sidebar siempre mostraba "Dashboard" activo.
  int _calcularIndiceActivo(String rutaActual, bool esAdmin) {
    if (rutaActual.startsWith('/dashboard')) return 0;
    if (rutaActual.startsWith('/transito')) return 1;
    if (rutaActual.startsWith('/cuadres')) return 2;
    if (esAdmin && rutaActual.startsWith('/usuarios')) return 3;
    if (rutaActual.startsWith('/perfil')) return esAdmin ? 4 : 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(proveedorAutenticacion);
    final esAdmin = authState.rol == 'administrador';
    final nombre = authState.nombreReal ?? 'Usuario';
    final rolTexto = (authState.rol ?? '').toUpperCase();
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esMovil = anchoPantalla < 800;
    final esExtendido = anchoPantalla >= 1200;
    final anchoSidebar = esExtendido ? 260.0 : 80.0;

    // Leer la ruta actual desde GoRouter como fuente de verdad.
    final rutaActual = GoRouterState.of(context).uri.path;
    final indiceActivo = _calcularIndiceActivo(rutaActual, esAdmin);

    return Scaffold(
      bottomNavigationBar: esMovil ? _construirBottomNavigationBar(esAdmin, indiceActivo) : null,
      body: Row(
        children: [
          if (!esMovil)
            // Sidebar Navy Premium (Mismo gradiente/marca unificada)
          Container(
            width: anchoSidebar,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0E3E2C), // Verde dominante
              border: Border(
                right: BorderSide(color: Color(0xFF0E3E2C), width: 1),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Logo / Cabecera Brismar (Fraunces)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: esExtendido ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7EBFC9).withValues(alpha: 0.2), // Celeste tint
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.anchor_rounded, color: Color(0xFF7EBFC9), size: 28),
                        ),
                        if (esExtendido) ...[
                          const SizedBox(width: 12),
                          Text(
                            'Brismar',
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lista de navegación personalizada
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _itemMenu(
                          index: 0,
                          indiceActivo: indiceActivo,
                          icono: Icons.dashboard_outlined,
                          iconoSeleccionado: Icons.dashboard_rounded,
                          etiqueta: 'Dashboard',
                          esExtendido: esExtendido,
                          onTap: () => const RutaDashboard().go(context),
                        ),
                        _itemMenu(
                          index: 1,
                          indiceActivo: indiceActivo,
                          icono: Icons.local_shipping_outlined,
                          iconoSeleccionado: Icons.local_shipping_rounded,
                          etiqueta: 'Tránsito',
                          esExtendido: esExtendido,
                          onTap: () => const RutaTransito().go(context),
                        ),
                        _itemMenu(
                          index: 2,
                          indiceActivo: indiceActivo,
                          icono: Icons.table_view_outlined,
                          iconoSeleccionado: Icons.table_view_rounded,
                          etiqueta: 'Cuadres',
                          esExtendido: esExtendido,
                          onTap: () => const RutaCuadres().go(context),
                        ),
                        if (esAdmin)
                          _itemMenu(
                            index: 3,
                            indiceActivo: indiceActivo,
                            icono: Icons.people_alt_outlined,
                            iconoSeleccionado: Icons.people_alt_rounded,
                            etiqueta: 'Usuarios',
                            esExtendido: esExtendido,
                            onTap: () => const RutaUsuarios().go(context),
                          ),
                        _itemMenu(
                          index: esAdmin ? 4 : 3,
                          indiceActivo: indiceActivo,
                          icono: Icons.person_outline,
                          iconoSeleccionado: Icons.person_rounded,
                          etiqueta: 'Perfil',
                          esExtendido: esExtendido,
                          onTap: () => const RutaPerfil().go(context),
                        ),
                      ],
                    ),
                  ),

                  // Sección inferior de usuario
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (esExtendido)
                          InkWell(
                            onTap: () => const RutaPerfil().go(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.2), // Sea green
                                    backgroundImage: authState.fotoPerfil != null && authState.fotoPerfil!.isNotEmpty 
                                      ? NetworkImage(authState.fotoPerfil!) 
                                      : null,
                                    child: authState.fotoPerfil == null || authState.fotoPerfil!.isEmpty
                                      ? Text(
                                          nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
                                          style: GoogleFonts.inter(color: const Color(0xFF14B8A6), fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          rolTexto,
                                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                            backgroundImage: authState.fotoPerfil != null && authState.fotoPerfil!.isNotEmpty 
                              ? NetworkImage(authState.fotoPerfil!) 
                              : null,
                            child: authState.fotoPerfil == null || authState.fotoPerfil!.isEmpty
                              ? Text(
                                  nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
                                  style: GoogleFonts.inter(color: const Color(0xFF14B8A6), fontWeight: FontWeight.bold),
                                )
                              : null,
                          ),
                        const SizedBox(height: 12),
                        
                        // Botón de Cerrar Sesión
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          tooltip: 'Cerrar Sesión',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(10),
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
              color: const Color(0xFFF2F6F3),
              child: widget.hijo,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la barra de navegación inferior para móvil.
  /// Recibe [indiceActivo] calculado desde la URL para mantener sincronía con el sidebar.
  Widget _construirBottomNavigationBar(bool esAdmin, int indiceActivo) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: indiceActivo,
        onTap: (index) {
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
        backgroundColor: const Color(0xFF0E3E2C),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7EBFC9),
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 10),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Resumen'),
          const BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping_rounded), label: 'Tránsito'),
          const BottomNavigationBarItem(icon: Icon(Icons.table_view_outlined), activeIcon: Icon(Icons.table_view_rounded), label: 'Cuadres'),
          if (esAdmin)
            const BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt_rounded), label: 'Usuarios'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }

  /// Construye un ítem del menú lateral.
  /// Compara [index] con [indiceActivo] (derivado de la URL) para determinar si está seleccionado.
  Widget _itemMenu({
    required int index,
    required int indiceActivo,
    required IconData icono,
    required IconData iconoSeleccionado,
    required String etiqueta,
    required bool esExtendido,
    required VoidCallback onTap,
  }) {
    return _ItemMenuHover(
      esActivo: indiceActivo == index,
      icono: icono,
      iconoSeleccionado: iconoSeleccionado,
      etiqueta: etiqueta,
      esExtendido: esExtendido,
      onTap: onTap,
    );
  }
}

// Widget Stateful privado para manejar el estado y la animación de Hover en cada botón del menú
class _ItemMenuHover extends StatefulWidget {
  const _ItemMenuHover({
    required this.esActivo,
    required this.icono,
    required this.iconoSeleccionado,
    required this.etiqueta,
    required this.esExtendido,
    required this.onTap,
  });

  final bool esActivo;
  final IconData icono;
  final IconData iconoSeleccionado;
  final String etiqueta;
  final bool esExtendido;
  final VoidCallback onTap;

  @override
  State<_ItemMenuHover> createState() => _ItemMenuHoverState();
}

class _ItemMenuHoverState extends State<_ItemMenuHover> {
  bool _estaCerniendo = false; // Is hovering

  @override
  Widget build(BuildContext context) {
    // Definimos el color del texto/ícono según el estado activo o hover
    final colorResaltado = widget.esActivo
        ? Colors.white
        : (_estaCerniendo ? Colors.white : Colors.white70);

    return MouseRegion(
      onEnter: (_) => setState(() => _estaCerniendo = true),
      onExit: (_) => setState(() => _estaCerniendo = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: widget.esActivo
              ? const Color(0xFF7EBFC9) // Celeste badge
              : (_estaCerniendo ? Colors.white.withValues(alpha: 0.1) : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.esActivo
                ? const Color(0xFF7EBFC9)
                : (_estaCerniendo ? Colors.white.withValues(alpha: 0.15) : Colors.transparent),
            width: 1.5,
          ),
        ),
        child: ListTile(
          onTap: widget.onTap,
          dense: true,
          hoverColor: Colors.transparent, // Desactivamos el hover por defecto para usar la animación del Container
          mouseCursor: SystemMouseCursors.click,
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.esExtendido ? 16 : 0, 
            vertical: 2
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: widget.esExtendido
              ? Text(
                  widget.etiqueta,
                  style: GoogleFonts.inter(
                    color: colorResaltado,
                    fontWeight: widget.esActivo ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                )
              : null,
          leading: SizedBox(
            width: widget.esExtendido ? null : double.infinity,
            child: Icon(
              widget.esActivo ? widget.iconoSeleccionado : widget.icono,
              color: colorResaltado,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
