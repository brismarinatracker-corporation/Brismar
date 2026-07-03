import '../modelos/usuario_admin_modelo.dart';

abstract class RepositorioUsuariosAdmin {
  Future<List<UsuarioAdminModelo>> obtenerUsuarios();
  Future<void> crearUsuario(UsuarioAdminModelo usuario, String password);
  Future<void> actualizarUsuario(UsuarioAdminModelo usuario, {String? nuevaPassword});
  Future<void> alternarEstadoUsuario(String uid, bool activar);
  Future<String> subirAvatar(String idUnico, dynamic archivoBytes, String extension);
}
