import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dominio/modelos/usuario_admin_modelo.dart';
import '../../datos/fuentes/fuente_datos_usuarios_admin.dart';
import '../../datos/repositorios/repositorio_usuarios_admin_impl.dart';

// Proveedores Base
final fuenteDatosUsuariosProvider = Provider<FuenteDatosUsuariosAdmin>((ref) {
  return FuenteDatosUsuariosAdmin(Supabase.instance.client);
});

final repositorioUsuariosProvider = Provider<RepositorioUsuariosAdminImpl>((ref) {
  final fuenteDatos = ref.watch(fuenteDatosUsuariosProvider);
  return RepositorioUsuariosAdminImpl(fuenteDatos);
});

// Estado del Controlador
class EstadoUsuarios {
  final bool cargando;
  final String? error;
  final List<UsuarioAdminModelo> usuarios;

  EstadoUsuarios({
    this.cargando = false,
    this.error,
    this.usuarios = const [],
  });

  EstadoUsuarios copiarCon({
    bool? cargando,
    String? error,
    List<UsuarioAdminModelo>? usuarios,
    bool limpiarError = false,
  }) {
    return EstadoUsuarios(
      cargando: cargando ?? this.cargando,
      error: limpiarError ? null : (error ?? this.error),
      usuarios: usuarios ?? this.usuarios,
    );
  }
}

// Controlador Principal
class ControladorUsuarios extends Notifier<EstadoUsuarios> {
  late RepositorioUsuariosAdminImpl _repositorio;

  @override
  EstadoUsuarios build() {
    _repositorio = ref.watch(repositorioUsuariosProvider);
    // Para cargar datos inicialmente sin bloquear el build
    Future.microtask(() => cargarUsuarios());
    return EstadoUsuarios();
  }

  Future<void> cargarUsuarios() async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      final usuarios = await _repositorio.obtenerUsuarios();
      state = state.copiarCon(cargando: false, usuarios: usuarios);
    } catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
    }
  }

  Future<bool> crearUsuario(UsuarioAdminModelo usuario, String password) async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      await _repositorio.crearUsuario(usuario, password);
      await cargarUsuarios(); // Refrescamos la lista completa
      return true;
    } catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarUsuario(UsuarioAdminModelo usuario, {String? nuevaPassword}) async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      await _repositorio.actualizarUsuario(usuario, nuevaPassword: nuevaPassword);
      await cargarUsuarios();
      return true;
    } catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
      return false;
    }
  }

  Future<bool> alternarEstadoUsuario(String uid, bool activar) async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      await _repositorio.alternarEstadoUsuario(uid, activar);
      await cargarUsuarios();
      return true;
    } catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
      return false;
    }
  }
}

final controladorUsuariosProvider = NotifierProvider<ControladorUsuarios, EstadoUsuarios>(() {
  return ControladorUsuarios();
});
