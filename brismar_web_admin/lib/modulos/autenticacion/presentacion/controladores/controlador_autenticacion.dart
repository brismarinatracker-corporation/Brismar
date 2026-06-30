import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstadoAutenticacion {
  final User? usuario;
  final String? rol;
  final String? nombreReal;
  final bool cargando;
  final String? error;

  EstadoAutenticacion({
    this.usuario,
    this.rol,
    this.nombreReal,
    this.cargando = true,
    this.error,
  });

  bool get isAuthenticated => usuario != null;
}

class ControladorAutenticacion extends Notifier<EstadoAutenticacion> {
  @override
  EstadoAutenticacion build() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    
    // Si hay usuario inicial, lo cargamos asíncronamente
    if (currentUser != null) {
      Future.microtask(() => _cargarPerfil(currentUser));
    }
    
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _cargarPerfil(user);
      } else {
        state = EstadoAutenticacion(usuario: null, rol: null, cargando: false);
      }
    });

    return EstadoAutenticacion(usuario: currentUser, cargando: currentUser != null);
  }

  Future<void> _cargarPerfil(User user) async {
    try {
      // Validar si el usuario sigue existiendo en Auth
      await Supabase.instance.client.auth.getUser();

      // Consultar el rol y nombre_real en public.usuarios
      final res = await Supabase.instance.client
          .from('usuarios')
          .select('rol, nombre_real')
          .eq('id', user.id)
          .maybeSingle();

      final rol = res?['rol'] as String?;
      final nombreReal = res?['nombre_real'] as String?;
      
      state = EstadoAutenticacion(
        usuario: user,
        rol: rol ?? 'bahia',
        nombreReal: nombreReal ?? 'Usuario',
        cargando: false,
      );
    } catch (e) {
      // Si falla la validación o el perfil no existe, forzamos cierre
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
    await Supabase.instance.client.auth.signOut();
    state = EstadoAutenticacion(usuario: null, rol: null, cargando: false);
  }

  Future<void> cerrarSesionConError(String mensaje) async {
    await Supabase.instance.client.auth.signOut();
    state = EstadoAutenticacion(usuario: null, rol: null, cargando: false, error: mensaje);
  }
}

final proveedorAutenticacion = NotifierProvider<ControladorAutenticacion, EstadoAutenticacion>(() {
  return ControladorAutenticacion();
});
