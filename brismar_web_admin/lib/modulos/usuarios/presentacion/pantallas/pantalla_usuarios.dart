import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../controladores/controlador_usuarios.dart';
import '../widgets/dialogo_formulario_usuario.dart';
import '../../dominio/modelos/usuario_admin_modelo.dart';

class PantallaUsuarios extends ConsumerWidget {
  const PantallaUsuarios({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorUsuariosProvider);
    final ctrl = ref.read(controladorUsuariosProvider.notifier);
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Usuarios',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea y administra cuentas para operarios y administradores en todas las sedes.',
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'Cerrar',
                    barrierColor: Colors.black54,
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, anim1, anim2) => const DialogoFormularioUsuario(),
                    transitionBuilder: (context, anim1, anim2, child) {
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
                        child: child,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add_rounded, color: Color(0xFF070E22), size: 20),
                label: const Text('Nuevo Usuario', style: TextStyle(color: Color(0xFF070E22), fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B142B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // Header de la Tabla
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Usuario', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                        Expanded(flex: 2, child: Text('Documento', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                        Expanded(flex: 2, child: Text('Sede / Rol', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                        Expanded(flex: 1, child: Text('Estado', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                        SizedBox(width: 100, child: Text('Acciones', textAlign: TextAlign.right, style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                      ],
                    ),
                  ),
                  
                  // Cuerpo de la Tabla
                  Expanded(
                    child: estado.cargando && estado.usuarios.isEmpty
                        ? _construirShimmerLoading()
                        : estado.error != null && estado.usuarios.isEmpty
                            ? Center(child: Text('Error: ${estado.error}', style: const TextStyle(color: Colors.redAccent)))
                            : ListView.builder(
                                itemCount: estado.usuarios.length,
                                itemBuilder: (context, index) {
                                  final u = estado.usuarios[index];
                                  return _FilaTablaUsuario(usuario: u, controlador: ctrl);
                                },
                              ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _construirShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.02),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.02))),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 120, height: 12, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 180, height: 10, color: Colors.white),
                  ])
                ])),
                Expanded(flex: 2, child: Container(width: 80, height: 12, color: Colors.white)),
                Expanded(flex: 2, child: Container(width: 100, height: 12, color: Colors.white)),
                Expanded(flex: 1, child: Container(width: 60, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                const SizedBox(width: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilaTablaUsuario extends StatelessWidget {
  final UsuarioAdminModelo usuario;
  final ControladorUsuarios controlador;

  const _FilaTablaUsuario({required this.usuario, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          // Usuario
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: usuario.activo ? const Color(0xFF00E5FF).withOpacity(0.1) : Colors.white10,
                  child: Text(
                    usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: usuario.activo ? const Color(0xFF00E5FF) : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(usuario.correo.isNotEmpty ? usuario.correo : 'Sin correo registrado', style: const TextStyle(color: Colors.white54, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Documento
          Expanded(
            flex: 2,
            child: Text(usuario.dni.isNotEmpty ? usuario.dni : 'Sin documento', style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
          ),
          // Sede / Rol
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario.sede, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(usuario.rol.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.5)),
              ],
            ),
          ),
          // Estado
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: usuario.activo ? const Color(0xFF00E5FF).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: usuario.activo ? const Color(0xFF00E5FF).withOpacity(0.3) : Colors.transparent),
              ),
              child: Text(
                usuario.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: usuario.activo ? const Color(0xFF00E5FF) : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Acciones
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                  tooltip: 'Editar',
                  splashRadius: 20,
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Cerrar',
                      barrierColor: Colors.black54,
                      transitionDuration: const Duration(milliseconds: 300),
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
                  icon: Icon(usuario.activo ? Icons.block_flipped : Icons.check_circle_outline, color: usuario.activo ? Colors.redAccent.withOpacity(0.8) : Colors.greenAccent.withOpacity(0.8), size: 20),
                  tooltip: usuario.activo ? 'Desactivar' : 'Activar',
                  splashRadius: 20,
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
