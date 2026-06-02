import 'dart:convert';
import '../../../../nucleo/seguridad/servicio_cifrado.dart';
import '../../dominio/entidades/usuario.dart';
import '../../dominio/repositorios/repositorio_autenticacion.dart';
import '../fuentes_datos/fuente_datos_autenticacion_remota.dart';
import '../../../../nucleo/seguridad/gestor_almacenamiento_seguro.dart';
import '../../../../nucleo/red/verificador_conexion.dart';

/// Implementación concreta del repositorio de autenticación.
class RepositorioAutenticacionImpl implements RepositorioAutenticacion {
  final FuenteDatosAutenticacionRemota _remotoDatasource;
  final GestorAlmacenamientoSeguro _secureStorage;

  /// Constructor de [RepositorioAutenticacionImpl].
  RepositorioAutenticacionImpl({
    required FuenteDatosAutenticacionRemota remotoDatasource,
    required GestorAlmacenamientoSeguro secureStorage,
  }) : _remotoDatasource = remotoDatasource,
       _secureStorage = secureStorage;

  @override
  Future<Usuario> iniciarSesion({
    required String usuario,
    required String password,
  }) async {
    final correoNormalized = usuario.contains('@')
        ? usuario
        : '$usuario@brismar.com.pe';

    final tieneInternet = await VerificadorConexion.hayConexion();

    if (tieneInternet) {
      // Flujo Online
      final user = await _remotoDatasource.iniciarSesion(
        correo: correoNormalized,
        password: password,
      );

      // Guardar token y credenciales offline hasheadas con BCrypt
      final hashedPass = ServicioCifrado.hashearPasswordBcrypt(password);
      
      await _secureStorage.guardarToken(user.id);
      await _secureStorage.guardarCredencialesOffline(
        hashedPass,
        jsonEncode(user.toJson()),
      );
      return user;
    } else {
      // Flujo Offline
      final savedHash = await _secureStorage.obtenerHashOffline();
      final savedUserStr = await _secureStorage.obtenerDatosUsuarioOffline();

      if (savedHash == null || savedUserStr == null) {
        throw Exception(
          'No hay conexión a internet y no existen datos offline guardados.',
        );
      }

      if (ServicioCifrado.verificarPasswordBcrypt(password, savedHash)) {
        final userData = jsonDecode(savedUserStr);
        final user = Usuario.fromJson(userData);
        // Opcional: Podríamos reinyectar el token al storage
        await _secureStorage.guardarToken(user.id);
        return user;
      } else {
        throw Exception('Contraseña incorrecta (Modo Offline).');
      }
    }
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

    final savedUserStr = await _secureStorage.obtenerDatosUsuarioOffline();
    if (savedUserStr != null) {
      final userData = jsonDecode(savedUserStr);
      return Usuario.fromJson(userData);
    }

    return null;
  }
}
