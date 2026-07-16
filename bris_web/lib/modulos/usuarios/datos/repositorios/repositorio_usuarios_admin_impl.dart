import '../../dominio/modelos/usuario_admin_modelo.dart';
import '../../dominio/repositorios/repositorio_usuarios_admin.dart';
import '../fuentes/fuente_datos_usuarios_admin.dart';

class RepositorioUsuariosAdminImpl implements RepositorioUsuariosAdmin {
  final FuenteDatosUsuariosAdmin _fuenteDatos;

  RepositorioUsuariosAdminImpl(this._fuenteDatos);

  @override
  Future<List<UsuarioAdminModelo>> obtenerUsuarios() {
    return _fuenteDatos.obtenerUsuarios();
  }

  @override
  Future<void> crearUsuario(UsuarioAdminModelo usuario, String password) {
    return _fuenteDatos.crearUsuario(usuario, password);
  }

  @override
  Future<void> actualizarUsuario(
    UsuarioAdminModelo usuario, {
    String? nuevaPassword,
  }) {
    return _fuenteDatos.actualizarUsuario(
      usuario,
      nuevaPassword: nuevaPassword,
    );
  }

  @override
  Future<void> alternarEstadoUsuario(String uid, bool activar) {
    return _fuenteDatos.alternarEstadoUsuario(uid, activar);
  }

  @override
  Future<void> eliminarUsuario(String uid) {
    return _fuenteDatos.eliminarUsuario(uid);
  }

  @override
  Future<String> subirAvatar(
    String idUnico,
    dynamic archivoBytes,
    String extension,
  ) {
    return _fuenteDatos.subirAvatar(idUnico, archivoBytes, extension);
  }
}
