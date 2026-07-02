import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controladores/controlador_usuarios.dart';
import '../widgets/dialogo_formulario_usuario.dart';
import '../../dominio/modelos/usuario_admin_modelo.dart';
import 'package:brismar_web_admin/nucleo/componentes/carga_orbital.dart';

class PantallaUsuarios extends ConsumerWidget {
  const PantallaUsuarios({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorUsuariosProvider);
    final ctrl = ref.read(controladorUsuariosProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: estado.cargando && estado.usuarios.isEmpty
          ? const Center(child: CargaOrbital(tamano: 80))
          : Column(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Accesos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Administra roles, sedes y estados de las cuentas de la plataforma.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: 'Cerrar',
                            barrierColor: Colors.black.withValues(alpha: 0.6),
                            transitionDuration: const Duration(milliseconds: 250),
                            pageBuilder: (context, anim1, anim2) => const DialogoFormularioUsuario(),
                            transitionBuilder: (context, anim1, anim2, child) {
                              return SlideTransition(
                                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                    .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
                                child: child,
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Nuevo acceso',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B), // Dark green matching mockup
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rest of the screen
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header de la Tabla
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: Text('PERFIL', style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                                Expanded(flex: 2, child: Text('DOCUMENTO', style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                                Expanded(flex: 2, child: Text('ROL & SEDE', style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                                Expanded(flex: 1, child: Text('ESTADO', style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                                SizedBox(width: 120, child: Text('ACCIONES', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                              ],
                            ),
                          ),

                          Expanded(
                            child: estado.error != null && estado.usuarios.isEmpty
                                    ? Center(child: Text('Error: ${estado.error}', style: const TextStyle(color: Colors.redAccent)))
                                    : ListView.separated(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        itemCount: estado.usuarios.length,
                                        separatorBuilder: (context, index) => Divider(color: const Color(0xFFE2E8F0), height: 1),
                                        itemBuilder: (context, index) {
                                          final u = estado.usuarios[index];
                                          return _FilaTablaUsuarioPremium(usuario: u, controlador: ctrl);
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class _FilaTablaUsuarioPremium extends StatelessWidget {
  final UsuarioAdminModelo usuario;
  final ControladorUsuarios controlador;

  const _FilaTablaUsuarioPremium({required this.usuario, required this.controlador});

  @override
  Widget build(BuildContext context) {
    final colorRol = usuario.rol == 'administrador' ? const Color(0xFF8B5CF6) :
                     (usuario.rol == 'supervisor' ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          // Usuario
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: usuario.activo ? colorRol.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: usuario.activo ? colorRol.withValues(alpha: 0.3) : Colors.transparent),
                    image: usuario.fotoPerfil != null && usuario.fotoPerfil!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(usuario.fotoPerfil!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: usuario.fotoPerfil == null || usuario.fotoPerfil!.isEmpty
                      ? Center(
                          child: Text(
                            usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: usuario.activo ? colorRol : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario.nombre, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(usuario.correo.isNotEmpty ? usuario.correo : 'Sin correo registrado', style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Documento
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.badge_rounded, color: Color(0xFF64748B), size: 16),
                const SizedBox(width: 8),
                Text(
                  usuario.dni.isNotEmpty ? usuario.dni : 'No especificado',
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ),
          // Sede / Rol
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF00838F), size: 14),
                    const SizedBox(width: 4),
                    Text(usuario.sede, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorRol.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorRol.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    usuario.rol.toUpperCase(),
                    style: TextStyle(color: colorRol, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                  ),
                ),
              ],
            ),
          ),
          // Estado
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: usuario.activo ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: usuario.activo ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: usuario.activo ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      usuario.activo ? 'ACTIVO' : 'SUSPENDIDO',
                      style: TextStyle(
                        color: usuario.activo ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Acciones
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Color(0xFF64748B), size: 22),
                  tooltip: 'Editar Perfil',
                  hoverColor: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Cerrar',
                      barrierColor: Colors.black.withValues(alpha: 0.6),
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (context, anim1, anim2) => DialogoFormularioUsuario(usuarioAEditar: usuario),
                      transitionBuilder: (context, anim1, anim2, child) {
                        return SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
                          child: child,
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    usuario.activo ? Icons.block_rounded : Icons.check_circle_rounded,
                    color: usuario.activo ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    size: 22
                  ),
                  tooltip: usuario.activo ? 'Suspender Acceso' : 'Reactivar Acceso',
                  hoverColor: usuario.activo ? const Color(0xFFEF4444).withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1),
                  onPressed: () {
                    controlador.alternarEstadoUsuario(usuario.uid, !usuario.activo);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
