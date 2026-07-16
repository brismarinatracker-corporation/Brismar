import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:bris_web/compartido/widgets/cabecera_pagina_web.dart';

class PantallaPerfil extends ConsumerWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAuth = ref.watch(proveedorAutenticacion);
    final nombre = estadoAuth.nombreReal ?? 'Usuario';
    final correo = estadoAuth.usuario?.email ?? 'Sin correo';
    final rol = (estadoAuth.rol ?? 'Rol no definido').toUpperCase();
    final sede = (estadoAuth.sede ?? 'Sede no definida').toUpperCase();
    final esMovil = MediaQuery.of(context).size.width < 600;

    return Container(
      color: const Color(0xFFF2F6F3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CabeceraPaginaWeb(
            titulo: 'Mi Perfil',
            subtitulo: 'Información de tu cuenta y sesión activa.',
          ),
          // Main profile card
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(esMovil ? 16 : 40),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(esMovil ? 20 : 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Flex(
                        direction: esMovil ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: esMovil
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00796B,
                              ).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0xFF00796B,
                                ).withValues(alpha: 0.3),
                                width: 2,
                              ),
                              image:
                                  estadoAuth.fotoPerfil != null &&
                                      estadoAuth.fotoPerfil!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        estadoAuth.fotoPerfil!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                estadoAuth.fotoPerfil == null ||
                                    estadoAuth.fotoPerfil!.isEmpty
                                ? Center(
                                    child: Text(
                                      nombre.isNotEmpty
                                          ? nombre.substring(0, 1).toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Color(0xFF00796B),
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(
                            width: esMovil ? 0 : 32,
                            height: esMovil ? 24 : 0,
                          ),

                          // Details Section
                          Builder(
                            builder: (ctx) {
                              final details = Column(
                                crossAxisAlignment: esMovil
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    textAlign: esMovil
                                        ? TextAlign.center
                                        : TextAlign.start,
                                    style: const TextStyle(
                                      color: Color(0xFF15181A),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    correo,
                                    textAlign: esMovil
                                        ? TextAlign.center
                                        : TextAlign.start,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    alignment: esMovil
                                        ? WrapAlignment.center
                                        : WrapAlignment.start,
                                    children: [
                                      _InfoChip(
                                        icono:
                                            Icons.admin_panel_settings_rounded,
                                        titulo: 'Rol',
                                        valor: rol,
                                      ),
                                      _InfoChip(
                                        icono: Icons.location_on_rounded,
                                        titulo: 'Sede',
                                        valor: sede,
                                      ),
                                    ],
                                  ),
                                ],
                              );

                              return esMovil
                                  ? details
                                  : Expanded(child: details);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  const _InfoChip({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

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
                  color: Color(0xFF15181A),
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
