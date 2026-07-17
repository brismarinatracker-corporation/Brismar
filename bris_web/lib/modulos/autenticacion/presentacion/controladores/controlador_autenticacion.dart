import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../transito/presentacion/controladores/controlador_transito.dart';
import '../../../usuarios/presentacion/controladores/controlador_usuarios.dart';
import '../../../maestros/presentacion/controladores/controlador_maestros.dart';
import '../../../dashboard/presentacion/controladores/controlador_dashboard.dart';
import '../../../cuadres/presentacion/controladores/controlador_cuadres.dart';
class EstadoAutenticacion {
  final User? usuario;
  final String? rol;
  final String? nombreReal;
  final String? fotoPerfil;
  final String? sede;
  final bool cargando;
  final String? error;

  EstadoAutenticacion({
    this.usuario,
    this.rol,
    this.nombreReal,
    this.fotoPerfil,
    this.sede,
    this.cargando = true,
    this.error,
  });

  bool get isAuthenticated => usuario != null;
}

class ControladorAutenticacion extends Notifier<EstadoAutenticacion> {
  @override
  EstadoAutenticacion build() {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser != null) {
      Future.microtask(() => _cargarPerfil(currentUser));
    }

    // Registra la suscripción y la cancela cuando el provider se destruye.
    // Previene memory leaks y listeners duplicados en hot reload.
    final suscripcion = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _cargarPerfil(user);
      } else {
        state = EstadoAutenticacion(usuario: null, rol: null, fotoPerfil: null, sede: null, cargando: false);
      }
    });
    ref.onDispose(suscripcion.cancel);

    return EstadoAutenticacion(usuario: currentUser, cargando: currentUser != null);
  }

  Future<void> _cargarPerfil(User user) async {
    try {
      await Supabase.instance.client.auth.getUser();

      final res = await Supabase.instance.client
          .from('usuarios')
          .select('rol, nombre_real, foto_perfil, sede')
          .eq('id', user.id)
          .maybeSingle();

      final rol = res?['rol'] as String?;
      final nombreReal = res?['nombre_real'] as String?;
      final fotoPerfil = res?['foto_perfil'] as String?;
      final sede = res?['sede'] as String?;

      state = EstadoAutenticacion(
        usuario: user,
        rol: rol,
        nombreReal: nombreReal,
        fotoPerfil: fotoPerfil,
        sede: sede,
        cargando: false,
      );
    } on Exception {
      // Si la validación falla o el perfil no existe, se fuerza cierre de sesión.
      await cerrarSesion();
    }
  }

  Future<void> iniciarSesion(String correo, String contrasena) async {
    state = EstadoAutenticacion(cargando: true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: correo,
        password: contrasena,
      );
      // El onAuthStateChange atrapará el evento y llamará a _cargarPerfil
    } catch (e) {
      state = EstadoAutenticacion(
        cargando: false, 
        error: 'Error al iniciar sesión. Verifica tus credenciales.'
      );
    }
  }

  Future<void> cerrarSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}

    ref.invalidate(proveedorTransito);
    ref.invalidate(proveedorFiltroTransito);
    ref.invalidate(controladorUsuariosProvider);
    ref.invalidate(controladorMaestrosProvider);
    ref.invalidate(controladorDashboardProvider);
    ref.invalidate(controladorCuadresWebProvider);

    await Supabase.instance.client.auth.signOut();
    state = EstadoAutenticacion(usuario: null, rol: null, cargando: false);
  }

  Future<void> cerrarSesionConError(String mensaje) async {
    await Supabase.instance.client.auth.signOut();
    state = EstadoAutenticacion(usuario: null, rol: null, cargando: false, error: mensaje);
  }

  /// Actualiza los campos del perfil del usuario autenticado.
  ///
  /// Lanza [Exception] con mensaje descriptivo si el UPDATE falla,
  /// para que la UI pueda mostrar el error al usuario.
  Future<void> actualizarPerfil({String? nombreReal, String? fotoPerfil}) async {
    final user = state.usuario;
    if (user == null) return;

    final Map<String, dynamic> updates = {};
    if (nombreReal != null) updates['nombre_real'] = nombreReal;
    if (fotoPerfil != null) updates['foto_perfil'] = fotoPerfil;

    if (updates.isEmpty) return;

    try {
      await Supabase.instance.client
          .from('usuarios')
          .update(updates)
          .eq('id', user.id);
      await _cargarPerfil(user);
    } on Exception catch (e) {
      throw Exception('No se pudo actualizar el perfil: $e');
    }
  }

  /// Recarga los datos del perfil actual (sede, rol, foto, etc.) desde la base de datos de Supabase.
  Future<void> recargarPerfil() async {
    final user = state.usuario;
    if (user != null) {
      await _cargarPerfil(user);
    }
  }
}

final proveedorAutenticacion = NotifierProvider<ControladorAutenticacion, EstadoAutenticacion>(() {
  return ControladorAutenticacion();
});
