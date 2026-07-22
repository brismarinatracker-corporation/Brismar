import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../dominio/entidades/log_zarpe_entidad.dart';
import '../../datos/fuentes_datos/fuente_datos_log_local.dart';
import '../../datos/fuentes_datos/fuente_datos_log_remota.dart';
import '../../datos/repositorios/log_zarpe_repositorio_imp.dart';

/// Provider del repositorio de logs — se inyecta en toda la app.
final proveedorLogZarpe = Provider<LogZarpeRepositorioImp>((ref) {
  return LogZarpeRepositorioImp(
    local: FuenteDatosLogLocal(),
    remota: FuenteDatosLogRemota(),
  );
});

/// Provider de los logs de un cuadre específico.
///
/// Se observa con [ref.watch] para reconstruir el widget automáticamente
/// cuando se registra un nuevo evento.
final proveedorLogsPorCuadre =
    FutureProvider.family<List<LogZarpeEntidad>, String>((ref, cuadreId) async {
      final repo = ref.watch(proveedorLogZarpe);
      return repo.obtenerLogsPorCuadre(cuadreId);
    });

/// Registra un evento de auditoría para un cuadre.
///
/// Se llama cada vez que el operador guarda o actualiza un cuadre.
/// Opera de forma silenciosa: no lanza errores al usuario.
Future<void> registrarEventoCuadre({
  required WidgetRef ref,
  required String cuadreId,
  required String zarpeId,
  required String usuarioId,
  required String nombreUsuario,
  required AccionLog accion,
  Map<String, dynamic>? detalle,
}) async {
  try {
    final repo = ref.read(proveedorLogZarpe);
    final log = LogZarpeEntidad(
      id: const Uuid().v4(),
      zarpeId: zarpeId.isEmpty ? null : zarpeId,
      cuadreId: cuadreId,
      usuarioId: usuarioId,
      nombreUsuario: nombreUsuario,
      origen: OrigenLog.app,
      accion: accion,
      detalle: detalle != null ? jsonEncode(detalle) : null,
      timestamp: DateTime.now().toUtc(),
    );
    await repo.registrarEvento(log);
  } catch (e) {
    // El audit log nunca debe bloquear el flujo principal de la app.
    // Si falla, se registra silenciosamente.
    debugPrint('⚠️ Audit log falló silenciosamente: $e');
  }
}

/// Registra un evento de auditoría para un zarpe.
Future<void> registrarEventoZarpe({
  required WidgetRef ref,
  required String zarpeId,
  required String usuarioId,
  required String nombreUsuario,
  required AccionLog accion,
  Map<String, dynamic>? detalle,
}) async {
  try {
    final repo = ref.read(proveedorLogZarpe);
    final log = LogZarpeEntidad(
      id: const Uuid().v4(),
      zarpeId: zarpeId,
      cuadreId: null,
      usuarioId: usuarioId,
      nombreUsuario: nombreUsuario,
      origen: OrigenLog.app,
      accion: accion,
      detalle: detalle != null ? jsonEncode(detalle) : null,
      timestamp: DateTime.now().toUtc(),
    );
    await repo.registrarEvento(log);
  } catch (e) {
    debugPrint('⚠️ Audit log zarpe falló silenciosamente: $e');
  }
}

/// Sincroniza los logs pendientes hacia Supabase.
Future<void> sincronizarLogsPendientes(WidgetRef ref) async {
  try {
    final repo = ref.read(proveedorLogZarpe);
    await repo.sincronizarLogsPendientes();
  } catch (e) {
    debugPrint('⚠️ Error sincronizando logs de auditoría: $e');
  }
}
