import 'dart:convert';
import '../../../../nucleo/seguridad/servicio_cifrado.dart';
import '../../dominio/entidades/usuario.dart';
import '../../dominio/repositorios/repositorio_autenticacion.dart';
import '../fuentes_datos/fuente_datos_autenticacion_remota.dart';
import '../../../../nucleo/seguridad/gestor_almacenamiento_seguro.dart';
import '../../../../nucleo/red/verificador_conexion.dart';

/// Implementación concreta del repositorio de autenticación.
class RepositorioAutenticacionImpl implements RepositorioAutenticacion {
  final FuenteDatosAutenticacionRemota _fuenteDatosRemota;
  final GestorAlmacenamientoSeguro _almacenamientoSeguro;

  /// Constructor de [RepositorioAutenticacionImpl].
  RepositorioAutenticacionImpl({
    required FuenteDatosAutenticacionRemota fuenteDatosRemota,
    required GestorAlmacenamientoSeguro almacenamientoSeguro,
  }) : _fuenteDatosRemota = fuenteDatosRemota,
       _almacenamientoSeguro = almacenamientoSeguro;

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
      final user = await _fuenteDatosRemota.iniciarSesion(
        correo: correoNormalized,
        password: password,
      );

      // Guardar token y credenciales offline hasheadas con BCrypt
      final hashedPass = ServicioCifrado.hashearPasswordBcrypt(password);
      
      await _almacenamientoSeguro.guardarToken(user.id);
      await _almacenamientoSeguro.guardarCredencialesOffline(
        hashedPass,
        jsonEncode(user.toJson()),
      );
      return user;
    } else {
      // Flujo Offline
      final savedHash = await _almacenamientoSeguro.obtenerHashOffline();
      final savedUserStr = await _almacenamientoSeguro.obtenerDatosUsuarioOffline();

      if (savedHash == null || savedUserStr == null) {
        throw Exception(
          'No hay conexión a internet y no existen datos offline guardados.',
        );
      }

      if (ServicioCifrado.verificarPasswordBcrypt(password, savedHash)) {
        final userData = jsonDecode(savedUserStr);
        final user = Usuario.fromJson(userData);
        // Opcional: Podríamos reinyectar el token al storage
        await _almacenamientoSeguro.guardarToken(user.id);
        return user;
      } else {
        throw Exception('Contraseña incorrecta (Modo Offline).');
      }
    }
  }

  @override
  Future<void> cerrarSesion() async {
    await _fuenteDatosRemota.cerrarSesion();
    await _almacenamientoSeguro.eliminarToken();
  }

  @override
  Future<Usuario?> obtenerUsuarioActual() async {
    final token = await _almacenamientoSeguro.obtenerToken();
    if (token == null) return null;

    final savedUserStr = await _almacenamientoSeguro.obtenerDatosUsuarioOffline();
    if (savedUserStr != null) {
      final userData = jsonDecode(savedUserStr);
      return Usuario.fromJson(userData);
    }

    return null;
  }
}
