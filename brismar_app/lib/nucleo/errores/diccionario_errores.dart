/// Representa un error detallado de la aplicación con su código respectivo.
class DetalleError {
  /// Código identificador del error (ej. 001).
  final String codigo;

  /// Mensaje explicativo en español dirigido al usuario.
  final String mensaje;

  /// Descripción técnica del error para depuración.
  final String descripcion;

  const DetalleError({
    required this.codigo,
    required this.mensaje,
    required this.descripcion,
  });

  @override
  String toString() => '($codigo) $mensaje';
}

/// Diccionario global de errores de la aplicación.
///
/// Centraliza los códigos de error para facilitar el diagnóstico
/// de incidencias tanto online como offline.
class DiccionarioErrores {
  /// Mapa global que relaciona códigos de error con su detalle.
  static const Map<String, DetalleError> _errores = {
    'AUTH-001': DetalleError(
      codigo: 'AUTH-001',
      mensaje: 'Usuario o contraseña incorrectos.',
      descripcion: 'Error de autenticación por credenciales inválidas.',
    ),
    'AUTH-002': DetalleError(
      codigo: 'AUTH-002',
      mensaje: 'PIN de acceso incorrecto.',
      descripcion: 'La comparación del PIN local falló contra el hash cifrado.',
    ),
    'AUTH-004': DetalleError(
      codigo: 'AUTH-004',
      mensaje: 'Acceso denegado. Rol de usuario no autorizado.',
      descripcion: 'No hay un usuario autenticado válido para esta operación.',
    ),
    'NET-002': DetalleError(
      codigo: 'NET-002',
      mensaje: 'Tiempo de espera de conexión agotado.',
      descripcion: 'La petición al servidor excedió el tiempo límite.',
    ),
    'NET-003': DetalleError(
      codigo: 'NET-003',
      mensaje: 'Error en la sincronización de datos con el servidor.',
      descripcion: 'Falló el volcado de datos locales a Supabase remoto.',
    ),
    'DB-001': DetalleError(
      codigo: 'DB-001',
      mensaje: 'No se pudo inicializar la base de datos local.',
      descripcion: 'Error crítico al abrir la base de datos SQLite.',
    ),
    'DB-002': DetalleError(
      codigo: 'DB-002',
      mensaje: 'Error al escribir datos locales.',
      descripcion: 'Falló la ejecución de una escritura en SQLite.',
    ),
    'BIO-001': DetalleError(
      codigo: 'BIO-001',
      mensaje:
          'El sensor biométrico no está disponible o no tiene huellas registradas.',
      descripcion:
          'Fallo al inicializar autenticación por hardware local_auth.',
    ),
    'BIO-003': DetalleError(
      codigo: 'BIO-003',
      mensaje: 'Autenticación biométrica fallida o cancelada.',
      descripcion: 'El hardware local_auth devolvió falso en la verificación.',
    ),
    'DB-003': DetalleError(
      codigo: 'DB-003',
      mensaje: 'Error de almacenamiento seguro local.',
      descripcion: 'No se pudo acceder a las llaves de FlutterSecureStorage.',
    ),
    'DB-004': DetalleError(
      codigo: 'DB-004',
      mensaje: 'Corrupción de base de datos local detectada.',
      descripcion: 'Falló una lectura crítica de SQLite.',
    ),
    'SRV-002': DetalleError(
      codigo: 'SRV-002',
      mensaje: 'Error en la consulta del servidor.',
      descripcion: 'Supabase devolvió un error de base de datos.',
    ),
    'GEN-001': DetalleError(
      codigo: 'GEN-001',
      mensaje: 'Ocurrió un error inesperado en el sistema.',
      descripcion:
          'Excepción desconocida no capturada por los manejadores estándar.',
    ),
  };

  /// Obtiene el detalle de un error a partir de su código.
  static DetalleError obtener(String codigo) {
    return _errores[codigo] ?? _errores['GEN-001']!;
  }

  /// Mapea una excepción o mensaje genérico a un [DetalleError].
  static DetalleError mapear(Object excepcion) {
    if (excepcion is ExcepcionApp) {
      return excepcion.detalle;
    }

    final str = excepcion.toString().toLowerCase();
    if (str.contains('contraseña incorrecta') ||
        str.contains('incorrectos') ||
        str.contains('invalid login credentials') ||
        str.contains('invalid claim')) {
      return obtener('AUTH-001');
    }
    if (str.contains('sincronización') || str.contains('sync')) {
      return obtener('NET-003');
    }
    if (str.contains('red') ||
        str.contains('socketexception') ||
        str.contains('network') ||
        str.contains('connection')) {
      return obtener('NET-002');
    }
    if (str.contains('biomet') ||
        str.contains('notavailable') ||
        str.contains('no registered')) {
      return obtener('BIO-001');
    }
    if (str.contains('pin incorrecto')) {
      return obtener('AUTH-002');
    }
    if (str.contains('sqlite') || str.contains('base de datos local')) {
      return obtener('DB-002');
    }
    if (str.contains('securestorage') || str.contains('almacenamiento')) {
      return obtener('DB-003');
    }
    if (str.contains('postgrest') ||
        str.contains('row level security') ||
        str.contains('database') ||
        str.contains('violat')) {
      return obtener('SRV-002');
    }
    return obtener('GEN-001');
  }
}

/// Excepción de aplicación que conserva el código de error de dominio.
class ExcepcionApp implements Exception {
  final String codigo;
  final String? mensajeTecnico;
  final Object? causa;
  final StackTrace? stackTrace;

  const ExcepcionApp(
    this.codigo, {
    this.mensajeTecnico,
    this.causa,
    this.stackTrace,
  });

  DetalleError get detalle => DiccionarioErrores.obtener(codigo);

  @override
  String toString() => detalle.toString();
}

/// Excepción específica para errores de Base de Datos.
class ExcepcionBaseDatos extends ExcepcionApp {
  const ExcepcionBaseDatos({required String mensaje, Object? causa})
      : super('DB-002', mensajeTecnico: mensaje, causa: causa);
}

/// Excepción específica para errores de Red.
class ExcepcionRed extends ExcepcionApp {
  const ExcepcionRed({required String mensaje, Object? causa})
      : super('NET-002', mensajeTecnico: mensaje, causa: causa);
}
