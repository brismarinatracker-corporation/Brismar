import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:go_router/go_router.dart';
import '../../../autenticacion/dominio/entidades/usuario.dart';

class PantallaPerfil extends ConsumerStatefulWidget {
  const PantallaPerfil({super.key});

  @override
  ConsumerState<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends ConsumerState<PantallaPerfil> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proveedorControladorAutenticacion.notifier).refrescarPerfil();
    });
  }

  Usuario? _obtenerUsuario(EstadoAutenticacion state) {
    if (state is EstadoAutenticacionAutenticado) return state.usuario;
    if (state is EstadoConfigurarPin) return state.usuario;
    return null;
  }

  Widget _buildAvatar(String nombreReal, String? fotoUrl) {
    final tieneFoto = fotoUrl != null && fotoUrl.isNotEmpty;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF006B54), width: 3),
        image: tieneFoto
            ? DecorationImage(image: NetworkImage(fotoUrl), fit: BoxFit.cover)
            : null,
      ),
      child: !tieneFoto ? Center(child: _buildAvatarLetra(nombreReal)) : null,
    );
  }

  Widget _buildAvatarLetra(String nombreReal) {
    final letra = nombreReal.isNotEmpty
        ? nombreReal.substring(0, 1).toUpperCase()
        : 'U';
    return Text(
      letra,
      style: const TextStyle(
        color: Color(0xFF006B54),
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHeader(String nombreReal, String correo) {
    return Column(
      children: [
        Text(
          nombreReal,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          correo,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoContainer(String rol, String sede) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _InfoTile(
            icono: Icons.admin_panel_settings_rounded,
            titulo: 'Rol',
            valor: rol.toUpperCase(),
          ),
          const Divider(color: Color(0xFFE5E7EB), height: 32),
          _InfoTile(
            icono: Icons.location_on_rounded,
            titulo: 'Sede/Bahía',
            valor: sede.toUpperCase(),
          ),
        ],
      ),
    );
  }

  void _mostrarConfirmacionCerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          '¿Estás seguro de salir de tu cuenta?',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(proveedorControladorAutenticacion.notifier)
                  .cerrarSesion();
            },
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black87,
        ),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Mi Perfil',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estadoAuth = ref.watch(proveedorControladorAutenticacion);
    final user = _obtenerUsuario(estadoAuth);
    final nombreReal = user?.nombreReal ?? 'Usuario';
    final correo = user?.nombreUsuario ?? 'Sin correo';
    final rol = user?.rol ?? 'Rol no definido';
    final sede = user?.sede ?? 'Sede no definida';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildAvatar(nombreReal, user?.fotoPerfil),
              const SizedBox(height: 24),
              _buildHeader(nombreReal, correo),
              const SizedBox(height: 40),
              _buildInfoContainer(rol, sede),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _mostrarConfirmacionCerrarSesion,
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

  const _InfoTile({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icono, color: const Color(0xFF006B54), size: 24),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 16),
        Expanded(child: _buildDetails()),
      ],
    );
  }
}
