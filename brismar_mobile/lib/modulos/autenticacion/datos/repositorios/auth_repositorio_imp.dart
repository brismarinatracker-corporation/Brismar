import '../../dominio/entidades/usuario.dart';
import '../../dominio/repositorios/auth_repositorio.dart';
import '../fuentes_datos/auth_remoto_datasource.dart';
import '../../../../nucleo/seguridad/secure_storage_helper.dart';

/// Implementación concreta del repositorio de autenticación.
class AuthRepositorioImp implements AuthRepositorio {
  final AuthRemotoDatasource _remotoDatasource;
  final SecureStorageHelper _secureStorage;

  /// Constructor de [AuthRepositorioImp].
  AuthRepositorioImp({
    required AuthRemotoDatasource remotoDatasource,
    required SecureStorageHelper secureStorage,
  })  : _remotoDatasource = remotoDatasource,
        _secureStorage = secureStorage;

  @override
  Future<Usuario> iniciarSesion({
    required String usuario,
    required String password,
  }) async {
    // Normalizar usuario a email si no contiene @
    final correoNormalized = usuario.contains('@') ? usuario : '$usuario@brismar.com.pe';

    final user = await _remotoDatasource.iniciarSesion(
      correo: correoNormalized,
      password: password,
    );

    // Guardar token simulado o real en almacenamiento seguro
    await _secureStorage.guardarToken(user.id);
    return user;
  }

  @override
  Future<void> cerrarSesion() async {
    await _remotoDatasource.cerrarSesion();
    await _secureStorage.eliminarToken();
  }

  @override
  Future<Usuario?> obtenerUsuarioActual() async {
    final token = await _secureStorage.obtenerToken();
    if (token == null) return null;

    // En un flujo real con Supabase, podríamos verificar si el token sigue activo.
    // De momento, retornamos el usuario simulado o consultamos si hay sesión activa.
    return Usuario(
      id: token,
      nombreUsuario: 'usuario@brismar.com.pe',
      nombreReal: 'Daniel',
      rol: 'bahia',
    );
  }
}
