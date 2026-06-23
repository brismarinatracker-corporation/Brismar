import 'dart:convert';
import '../../../../nucleo/errores/diccionario_errores.dart';
import '../../../../nucleo/seguridad/servicio_cifrado.dart';
import '../../dominio/entidades/usuario.dart';
import '../../dominio/repositorios/repositorio_autenticacion.dart';
import '../fuentes_datos/fuente_datos_autenticacion_remota.dart';
import '../fuentes_datos/fuente_datos_biometria.dart';
import '../../../../nucleo/seguridad/gestor_almacenamiento_seguro.dart';
import '../../../../nucleo/red/verificador_conexion.dart';

/// Implementación concreta del [RepositorioAutenticacion].
///
/// Cubre todos los nodos del FLUJO_01_AUTENTICACION.bpmn:
/// - Gateway_NetworkCheck → bifurcación online/offline
/// - Gateway_GracePeriod → validación timestamp 12h
/// - Task_SaveSession → persistencia token + hash + PIN + timestamp
/// - Task_OfflineAuth → verificación BCrypt offline
/// - Task_SetupPIN → configuración PIN 4 dígitos
/// - Task_ProvideBiometrics → autenticación biométrica
/// - Task_ClearSession → invalidación total de bóveda
class RepositorioAutenticacionImpl implements RepositorioAutenticacion {
  final FuenteDatosAutenticacionRemota _remotoDatasource;
  final GestorAlmacenamientoSeguro _secureStorage;
  final FuenteDatosBiometria _biometria;

  /// Constructor de [RepositorioAutenticacionImpl].
  RepositorioAutenticacionImpl({
    required FuenteDatosAutenticacionRemota remotoDatasource,
    required GestorAlmacenamientoSeguro secureStorage,
    FuenteDatosBiometria? biometria,
  }) : _remotoDatasource = remotoDatasource,
       _secureStorage = secureStorage,
       _biometria = biometria ?? FuenteDatosBiometria();

  @override
  Future<Usuario> iniciarSesion({
    required String usuario,
    required String password,
  }) async {
    final correoNormalized = _normalizarCorreo(usuario);
    final tieneInternet = await VerificadorConexion.hayConexion();

    if (tieneInternet) {
      return _iniciarSesionOnline(correoNormalized, password);
    }
    return _iniciarSesionOffline(password);
  }

  @override
  Future<Usuario?> obtenerUsuarioActual() async {
    final token = await _secureStorage.obtenerToken();
    if (token == null) return null;

    final pinConfigurado = await _secureStorage.obtenerPin();
    if (pinConfigurado == null) return null;

    final graciaVigente = await _secureStorage.esPeriodoGraciaVigente();
    if (!graciaVigente) throw const SesionExpiradaException();

    return _reconstruirUsuarioDesdeCache();
  }

  @override
  Future<void> configurarPin(String pin) async {
    final pinHash = ServicioCifrado.hashearPasswordBcrypt(pin);
    await _secureStorage.guardarPin(pinHash);
    await _secureStorage.guardarTimestamp();
  }

  @override
  Future<bool> verificarPin(String pin) async {
    final pinHash = await _secureStorage.obtenerPin();
    if (pinHash == null) return false;

    final coincide = ServicioCifrado.verificarPasswordBcrypt(pin, pinHash);
    if (coincide) await _secureStorage.guardarTimestamp();
    return coincide;
  }

  @override
  Future<bool> verificarBiometria() async {
    final exitoso = await _biometria.autenticarConHuella();
    if (exitoso) await _secureStorage.guardarTimestamp();
    return exitoso;
  }

  @override
  Future<void> guardarPreferenciaAcceso(String preferencia) async {
    await _secureStorage.guardarPreferenciaAcceso(preferencia);
  }

  @override
  Future<void> cerrarSesion() async {
    await _remotoDatasource.cerrarSesion();
    await _secureStorage.invalidarBoveda();
  }

  @override
  Future<void> invalidarPinYToken() async {
    await _secureStorage.invalidarAccesoRapido();
  }

  // ─── Helpers privados ─────────────────────────────────────────────────────

  /// Normaliza el correo agregando dominio brismar si no lo tiene.
  String _normalizarCorreo(String usuario) {
    return usuario.contains('@') ? usuario : '$usuario@brismar.com.pe';
  }

  /// Ejecuta el flujo de autenticación online contra Supabase.
  Future<Usuario> _iniciarSesionOnline(String correo, String password) async {
    final user = await _remotoDatasource.iniciarSesion(
      correo: correo,
      password: password,
    );
    await _persistirSesion(user, password);
    return user;
  }

  /// Persiste token + hash offline + timestamp en la bóveda tras login online.
  Future<void> _persistirSesion(Usuario user, String password) async {
    final hashedPass = ServicioCifrado.hashearPasswordBcrypt(password);
    await _secureStorage.guardarToken(user.id);
    await _secureStorage.guardarCredencialesOffline(
      hashedPass,
      jsonEncode(user.toJson()),
    );
    await _secureStorage.guardarTimestamp();
  }

  /// Ejecuta el flujo offline verificando el hash BCrypt guardado.
  Future<Usuario> _iniciarSesionOffline(String password) async {
    final savedHash = await _secureStorage.obtenerHashOffline();
    final savedUserStr = await _secureStorage.obtenerDatosUsuarioOffline();

    _validarDatosOfflineExistentes(savedHash, savedUserStr);
    _validarPasswordOffline(password, savedHash!);

    final user = Usuario.fromJson(jsonDecode(savedUserStr!));
    await _secureStorage.guardarToken(user.id);
    await _secureStorage.guardarTimestamp();
    return user;
  }

  /// Lanza [ExcepcionApp] si no hay datos offline guardados.
  void _validarDatosOfflineExistentes(String? hash, String? userStr) {
    if (hash == null || userStr == null) {
      throw const ExcepcionApp(
        'NET-002',
        mensajeTecnico:
            'Sin conexión y sin sesión offline previa en la bóveda.',
      );
    }
  }

  /// Lanza [ExcepcionApp] si el password no coincide con el hash BCrypt.
  void _validarPasswordOffline(String password, String hash) {
    if (!ServicioCifrado.verificarPasswordBcrypt(password, hash)) {
      throw const ExcepcionApp(
        'AUTH-001',
        mensajeTecnico: 'Contraseña incorrecta en modo offline.',
      );
    }
  }

  /// Reconstruye el [Usuario] desde los datos cacheados en la bóveda.
  Future<Usuario?> _reconstruirUsuarioDesdeCache() async {
    final savedUserStr = await _secureStorage.obtenerDatosUsuarioOffline();
    if (savedUserStr == null) return null;
    return Usuario.fromJson(jsonDecode(savedUserStr));
  }
}
