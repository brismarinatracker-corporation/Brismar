import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:go_router/go_router.dart';

class PantallaPerfil extends ConsumerWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAuth = ref.watch(proveedorControladorAutenticacion);
    final nombre = 'Usuario';
    final rol = 'Rol no definido';
    
    // As EstadoAutenticacion can be different instances depending on login
    // Let's get the latest data if it is EstadoLogueado (or similar).
    // Brismar app has different states.
    // Let's fallback gracefully if no data.
    String nombreReal = nombre;
    String correo = 'Sin correo';
    String sede = 'Sede no definida';
    String rolTexto = rol;
    String? fotoUrl;

    if (estadoAuth is EstadoAutenticacionAutenticado) {
       nombreReal = estadoAuth.usuario.nombreReal;
       correo = estadoAuth.usuario.nombreUsuario; 
       sede = estadoAuth.usuario.sede; 
       rolTexto = estadoAuth.usuario.rol;
       fotoUrl = estadoAuth.usuario.fotoPerfil;
    } else if (estadoAuth is EstadoConfigurarPin) {
       nombreReal = estadoAuth.usuario.nombreReal;
       correo = estadoAuth.usuario.nombreUsuario; 
       sede = estadoAuth.usuario.sede; 
       rolTexto = estadoAuth.usuario.rol;
       fotoUrl = estadoAuth.usuario.fotoPerfil;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF040B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 3),
                  image: fotoUrl != null && fotoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(fotoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: fotoUrl == null || fotoUrl.isEmpty
                    ? Center(
                        child: Text(
                          nombreReal.isNotEmpty ? nombreReal.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                nombreReal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                correo,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1D3F),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF143068)),
                ),
                child: Column(
                  children: [
                    _InfoTile(icono: Icons.admin_panel_settings_rounded, titulo: 'Rol', valor: rolTexto.toUpperCase()),
                    const Divider(color: Color(0xFF143068), height: 32),
                    _InfoTile(icono: Icons.location_on_rounded, titulo: 'Sede/Bahía', valor: sede.toUpperCase()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _InfoTile({required this.icono, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF040B1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: const Color(0xFF00E5FF), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
