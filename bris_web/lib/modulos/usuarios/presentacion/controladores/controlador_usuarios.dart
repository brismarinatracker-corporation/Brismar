import 'dart:async';
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

  /// Inicializa el controlador y carga los usuarios.
  ///
  /// [ref.keepAlive()] evita que el provider se destruya al navegar a otra
  /// pantalla, eliminando re-fetches innecesarios al regresar al módulo.
  @override
  EstadoUsuarios build() {
    ref.keepAlive();
    _repositorio = ref.watch(repositorioUsuariosProvider);
    // scheduleMicrotask garantiza que build() retorne antes de la carga.
    scheduleMicrotask(cargarUsuarios);
    return EstadoUsuarios(cargando: true);
  }

  Future<void> cargarUsuarios() async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      final usuarios = await _repositorio.obtenerUsuarios();
      state = state.copiarCon(cargando: false, usuarios: usuarios);
    } on Exception catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
    }
  }

  Future<bool> crearUsuario(UsuarioAdminModelo usuario, String password) async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      await _repositorio.crearUsuario(usuario, password);
      await cargarUsuarios();
      return true;
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarUsuario(String uid) async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      await _repositorio.eliminarUsuario(uid);
      await cargarUsuarios();
      return true;
    } on Exception catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
      return false;
    }
  }

  Future<String?> subirAvatar(dynamic bytes, String extension) async {
    state = state.copiarCon(cargando: true, limpiarError: true);
    try {
      final idUnico = DateTime.now().millisecondsSinceEpoch.toString();
      final url = await _repositorio.subirAvatar(idUnico, bytes, extension);
      state = state.copiarCon(cargando: false);
      return url;
    } catch (e) {
      state = state.copiarCon(cargando: false, error: e.toString());
      return null;
    }
  }
}

final controladorUsuariosProvider = NotifierProvider<ControladorUsuarios, EstadoUsuarios>(() {
  return ControladorUsuarios();
});
