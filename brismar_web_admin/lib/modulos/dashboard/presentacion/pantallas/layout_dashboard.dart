import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  int _indiceSeleccionado = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(proveedorAutenticacion);
    final esAdmin = authState.rol == 'administrador';
    final nombre = authState.nombreReal ?? 'Usuario';
    final rolTexto = (authState.rol ?? '').toUpperCase();
    final esExtendido = MediaQuery.of(context).size.width >= 1200;
    final anchoSidebar = esExtendido ? 260.0 : 80.0;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navy Premium (Mismo gradiente/marca unificada)
          Container(
            width: anchoSidebar,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A2440), // Navy profundo
                  Color(0xFF123A5C), // Navy medio
                ],
              ),
              border: Border(
                right: BorderSide(color: Color(0xFF1E293B), width: 1),
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
                            color: const Color(0xFFF59E0B).withOpacity(0.12), // Amber tint
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.anchor_rounded, color: Color(0xFFF59E0B), size: 28),
                        ),
                        if (esExtendido) ...[
                          const SizedBox(width: 12),
                          Text(
                            'Brismar',
                            style: GoogleFonts.fraunces(
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
                          icono: Icons.dashboard_outlined,
                          iconoSeleccionado: Icons.dashboard_rounded,
                          etiqueta: 'Dashboard',
                          esExtendido: esExtendido,
                          onTap: () {
                            setState(() => _indiceSeleccionado = 0);
                            const RutaDashboard().go(context);
                          },
                        ),
                        _itemMenu(
                          index: 1,
                          icono: Icons.local_shipping_outlined,
                          iconoSeleccionado: Icons.local_shipping_rounded,
                          etiqueta: 'Tránsito',
                          esExtendido: esExtendido,
                          onTap: () {
                            setState(() => _indiceSeleccionado = 1);
                            const RutaTransito().go(context);
                          },
                        ),
                        _itemMenu(
                          index: 2,
                          icono: Icons.table_view_outlined,
                          iconoSeleccionado: Icons.table_view_rounded,
                          etiqueta: 'Cuadres',
                          esExtendido: esExtendido,
                          onTap: () {
                            setState(() => _indiceSeleccionado = 2);
                            const RutaCuadres().go(context);
                          },
                        ),
                        if (esAdmin)
                          _itemMenu(
                            index: 3,
                            icono: Icons.people_alt_outlined,
                            iconoSeleccionado: Icons.people_alt_rounded,
                            etiqueta: 'Usuarios',
                            esExtendido: esExtendido,
                            onTap: () {
                              setState(() => _indiceSeleccionado = 3);
                              const RutaUsuarios().go(context);
                            },
                          ),
                        _itemMenu(
                          index: esAdmin ? 4 : 3,
                          icono: Icons.person_outline,
                          iconoSeleccionado: Icons.person_rounded,
                          etiqueta: 'Perfil',
                          esExtendido: esExtendido,
                          onTap: () {
                            setState(() => _indiceSeleccionado = esAdmin ? 4 : 3);
                            const RutaPerfil().go(context);
                          },
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
                            onTap: () {
                              setState(() => _indiceSeleccionado = esAdmin ? 4 : 3);
                              const RutaPerfil().go(context);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFF14B8A6).withOpacity(0.2), // Sea green
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
                                          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
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
                            backgroundColor: const Color(0xFF14B8A6).withOpacity(0.2),
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
                        
                        // Botón de Cerrar Sesión (Ámbar / Rojo suave)
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFF59E0B)), // Amber logout
                          tooltip: 'Cerrar Sesión',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.08),
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
              color: const Color(0xFFEEF3F1),
              child: widget.hijo,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir los ítems del menú con estilo personalizado
  Widget _itemMenu({
    required int index,
    required IconData icono,
    required IconData iconoSeleccionado,
    required String etiqueta,
    required bool esExtendido,
    required VoidCallback onTap,
  }) {
    final esActivo = _indiceSeleccionado == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: esActivo ? const Color(0xFF1E293B).withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: esActivo ? const Color(0xFFF59E0B) : Colors.transparent, // Borde ámbar en item activo
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: esExtendido ? 16 : 0, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: esExtendido
            ? Text(
                etiqueta,
                style: GoogleFonts.inter(
                  color: esActivo ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                  fontWeight: esActivo ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              )
            : null,
        leading: SizedBox(
          width: esExtendido ? null : double.infinity,
          child: Icon(
            esActivo ? iconoSeleccionado : icono,
            color: esActivo ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
            size: 20,
          ),
        ),
      ),
    );
  }
}
