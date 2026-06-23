import '../../dominio/entidades/registro_entidad.dart';
import '../../dominio/repositorios/registro_repositorio.dart';
import '../fuentes_datos/fuente_datos_registro_local.dart';
import '../fuentes_datos/fuente_datos_registro_remota.dart';
import '../modelos/registro_modelo.dart';

/// Implementación concreta del repositorio de registro de pesca.
/// Coordina la lógica de sincronización e integración de datos locales (SQLite) y remotos (Supabase).
class RegistroRepositorioImp implements RegistroRepositorio {
  final FuenteDatosRegistroLocal _fuenteDatosLocal;
  final FuenteDatosRegistroRemota _fuenteDatosRemota;

  /// Constructor de [RegistroRepositorioImp].
  RegistroRepositorioImp({
    required FuenteDatosRegistroLocal fuenteDatosLocal,
    required FuenteDatosRegistroRemota fuenteDatosRemota,
  }) : _fuenteDatosLocal = fuenteDatosLocal,
       _fuenteDatosRemota = fuenteDatosRemota;

  @override
  Future<void> guardarRegistro(RegistroEntidad registro) async {
    // 1. Convertir a modelo e insertar localmente de forma incondicional
    final modelo = RegistroModelo.fromEntidad(registro);
    await _fuenteDatosLocal.guardarRegistro(modelo);

    // 2. Intentar subir inmediatamente a Supabase (si falla, se queda guardado localmente)
    try {
      await _fuenteDatosRemota.subirRegistros([modelo]);
      // Si tuvo éxito, marcamos como sincronizado
      await _fuenteDatosLocal.marcarComoSincronizados([modelo.id]);
    } catch (_) {
      // Ignoramos el error en guardado remoto para permitir flujo offline
    }
  }

  @override
  Future<List<RegistroEntidad>> obtenerHistorial() async {
    // Retorna la fuente local para que cargue al instante y funcione offline
    return await _fuenteDatosLocal.obtenerHistorialLocal();
  }

  @override
  Future<void> sincronizarPendientes() async {
    // 1. Obtener registros locales sin sincronizar
    final pendientes = await _fuenteDatosLocal.obtenerPendientesSincronizar();
    if (pendientes.isEmpty) return;

    // 2. Subir en lote a Supabase
    await _fuenteDatosRemota.subirRegistros(pendientes);

    // 3. Marcar localmente como sincronizados
    final ids = pendientes.map((p) => p.id).toList();
    await _fuenteDatosLocal.marcarComoSincronizados(ids);
  }
}
