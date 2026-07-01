import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

class PantallaPerfil extends ConsumerWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAuth = ref.watch(proveedorAutenticacion);
    final nombre = estadoAuth.nombreReal ?? 'Usuario';
    final correo = estadoAuth.usuario?.email ?? 'Sin correo';
    final rol = (estadoAuth.rol ?? 'Rol no definido').toUpperCase();
    final sede = (estadoAuth.sede ?? 'Sede no definida').toUpperCase();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark Blue Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F2D4A), // Deep navy blue
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Información de tu cuenta y sesión activa.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Main profile card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00796B).withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00796B).withOpacity(0.3), width: 2),
                            image: estadoAuth.fotoPerfil != null && estadoAuth.fotoPerfil!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(estadoAuth.fotoPerfil!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: estadoAuth.fotoPerfil == null || estadoAuth.fotoPerfil!.isEmpty
                              ? Center(
                                  child: Text(
                                    nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: Color(0xFF00796B),
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                correo,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  _InfoChip(icono: Icons.admin_panel_settings_rounded, titulo: 'Rol', valor: rol),
                                  const SizedBox(width: 16),
                                  _InfoChip(icono: Icons.location_on_rounded, titulo: 'Sede', valor: sede),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _InfoChip({required this.icono, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: const Color(0xFF00796B), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
