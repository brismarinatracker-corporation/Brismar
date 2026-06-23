import '../../dominio/entidades/registro_entidad.dart';
import '../../dominio/repositorios/registro_repositorio.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
import '../fuentes_datos/fuente_datos_registro_local.dart';
import '../fuentes_datos/fuente_datos_registro_remota.dart';
import '../modelos/registro_modelo.dart';

/// Implementación concreta del repositorio de registro de pesca.
/// Coordina la lógica de sincronización e integración de datos locales (SQLite) y remotos (Supabase).
class RegistroRepositorioImp implements RegistroRepositorio {
  final FuenteDatosRegistroLocal _localDatasource;
  final FuenteDatosRegistroRemota _remotoDatasource;

  /// Constructor de [RegistroRepositorioImp].
  RegistroRepositorioImp({
    required FuenteDatosRegistroLocal localDatasource,
    required FuenteDatosRegistroRemota remotoDatasource,
  }) : _localDatasource = localDatasource,
       _remotoDatasource = remotoDatasource;

  @override
  Future<void> guardarRegistro(RegistroEntidad registro) async {
    // 1. Convertir a modelo e insertar localmente de forma incondicional
    final modelo = RegistroModelo.fromEntidad(registro);
    await _localDatasource.guardarRegistro(modelo);

    // 2. Intentar subir inmediatamente a Supabase (si falla, se queda guardado localmente)
    try {
      await _remotoDatasource.subirRegistros([modelo]);
      // Si tuvo éxito, marcamos como sincronizado
      await _localDatasource.marcarComoSincronizados([modelo.id]);
    } catch (_) {
      // Ignoramos el error en guardado remoto para permitir flujo offline
    }
  }

  @override
  Future<List<RegistroEntidad>> obtenerHistorial() async {
    // Retorna la fuente local para que cargue al instante y funcione offline
    return await _localDatasource.obtenerHistorialLocal();
  }

  @override
  Future<void> sincronizarPendientes() async {
    // 1. Obtener registros locales sin sincronizar
    final pendientes = await _localDatasource.obtenerPendientesSincronizar();
    if (pendientes.isEmpty) return;

    final pendientesConUsuario = pendientes
        .where((registro) => registro.usuarioId.trim().isNotEmpty)
        .toList();
    final hayRegistrosSinUsuario =
        pendientesConUsuario.length != pendientes.length;

    // 2. Subir en lote a Supabase
    if (pendientesConUsuario.isNotEmpty) {
      await _remotoDatasource.subirRegistros(pendientesConUsuario);

      // 3. Marcar localmente como sincronizados
      final ids = pendientesConUsuario.map((p) => p.id).toList();
      await _localDatasource.marcarComoSincronizados(ids);
    }

    if (hayRegistrosSinUsuario) {
      throw const ExcepcionApp(
        'NET-003',
        mensajeTecnico:
            'Existen registros locales antiguos sin usuario_id; no se sincronizaron.',
      );
    }
  }
}
