import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../dominio/entidades/log_zarpe_entidad.dart';
import '../controladores/controlador_logs.dart';

/// Widget de línea de tiempo que muestra el historial de auditoría de un cuadre.
///
/// Solo es visible para usuarios con rol administrador.
/// Cada entrada muestra: icono, usuario, timestamp legible, origen y detalle.
class TimelineAuditLog extends ConsumerWidget {
  /// ID del cuadre del que se cargan los logs.
  final String cuadreId;

  /// Constructor.
  const TimelineAuditLog({super.key, required this.cuadreId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(proveedorLogsPorCuadre(cuadreId));

    return asyncLogs.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Color(0xFF006B54)),
        ),
      ),
      error: (e, _) => _buildError(e.toString()),
      data: (logs) => logs.isEmpty ? _buildEmpty() : _buildTimeline(logs),
    );
  }

  /// Construye la lista de eventos en formato timeline.
  Widget _buildTimeline(List<LogZarpeEntidad> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(logs.length),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) =>
              _buildEntrada(logs[index], index, logs.length),
        ),
      ],
    );
  }

  /// Cabecera del timeline con conteo de eventos.
  Widget _buildHeader(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: Color(0xFF006B54), size: 20),
          const SizedBox(width: 8),
          Text(
            'Historial de cambios',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$total evento${total != 1 ? 's' : ''}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF006B54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una entrada individual del timeline.
  Widget _buildEntrada(LogZarpeEntidad log, int index, int total) {
    final esUltimo = index == total - 1;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIndicadorTiempo(log.accion, esUltimo),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : 12, right: 16),
              child: _buildTarjetaEvento(log),
            ),
          ),
        ],
      ),
    );
  }

  /// Línea vertical y punto del timeline.
  Widget _buildIndicadorTiempo(AccionLog accion, bool esUltimo) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _colorAccion(accion).withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _colorAccion(accion), width: 1.5),
            ),
            child: Icon(
              _iconoAccion(accion),
              size: 18,
              color: _colorAccion(accion),
            ),
          ),
          if (!esUltimo)
            Expanded(
              child: Container(
                width: 2,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.only(top: 4),
              ),
            ),
        ],
      ),
    );
  }

  /// Tarjeta de contenido con los datos del evento.
  Widget _buildTarjetaEvento(LogZarpeEntidad log) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _labelAccion(log.accion),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              _buildChipOrigen(log.origen),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            log.nombreUsuario,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatearTimestamp(log.timestamp),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          if (!log.sincronizado) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 12,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  'Pendiente de sincronización',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Chip de origen: APP (celeste) o WEB (verde).
  Widget _buildChipOrigen(OrigenLog origen) {
    final esWeb = origen == OrigenLog.web;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: esWeb
            ? const Color(0xFF006B54).withValues(alpha: 0.1)
            : const Color(0xFF0891B2).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esWeb ? Icons.language_rounded : Icons.smartphone_rounded,
            size: 10,
            color: esWeb ? const Color(0xFF006B54) : const Color(0xFF0891B2),
          ),
          const SizedBox(width: 3),
          Text(
            esWeb ? 'WEB' : 'APP',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: esWeb ? const Color(0xFF006B54) : const Color(0xFF0891B2),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget vacío cuando no hay logs aún.
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 36,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin historial registrado',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de error.
  Widget _buildError(String mensaje) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Error al cargar historial: $mensaje',
        style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent),
      ),
    );
  }

  // ─── Utilidades de presentación ──────────────────────────────────────────

  /// Color por tipo de acción.
  Color _colorAccion(AccionLog accion) {
    switch (accion) {
      case AccionLog.zarpeCreado:
        return const Color(0xFF8B5CF6);
      case AccionLog.cuadreCreado:
        return const Color(0xFF006B54);
      case AccionLog.cuadreActualizado:
        return const Color(0xFF0891B2);
      case AccionLog.cuadreEditadoWeb:
        return const Color(0xFFF59E0B);
      case AccionLog.sincronizadoNube:
        return const Color(0xFF10B981);
      case AccionLog.otro:
        return const Color(0xFF6B7280);
    }
  }

  /// Icono por tipo de acción.
  IconData _iconoAccion(AccionLog accion) {
    switch (accion) {
      case AccionLog.zarpeCreado:
        return Icons.anchor_rounded;
      case AccionLog.cuadreCreado:
        return Icons.add_circle_outline_rounded;
      case AccionLog.cuadreActualizado:
        return Icons.edit_note_rounded;
      case AccionLog.cuadreEditadoWeb:
        return Icons.language_rounded;
      case AccionLog.sincronizadoNube:
        return Icons.cloud_done_rounded;
      case AccionLog.otro:
        return Icons.info_outline_rounded;
    }
  }

  /// Etiqueta legible por tipo de acción.
  String _labelAccion(AccionLog accion) {
    switch (accion) {
      case AccionLog.zarpeCreado:
        return 'Zarpe creado';
      case AccionLog.cuadreCreado:
        return 'Cuadre registrado';
      case AccionLog.cuadreActualizado:
        return 'Cuadre actualizado';
      case AccionLog.cuadreEditadoWeb:
        return 'Editado desde web';
      case AccionLog.sincronizadoNube:
        return 'Sincronizado con la nube';
      case AccionLog.otro:
        return 'Evento del sistema';
    }
  }

  /// Formatea un DateTime UTC a texto legible en hora local.
  String _formatearTimestamp(DateTime utc) {
    final local = utc.toLocal();
    final ahora = DateTime.now();
    final diferencia = ahora.difference(local);

    if (diferencia.inMinutes < 1) return 'Justo ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) {
      return 'Hoy ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    if (diferencia.inDays == 1) {
      return 'Ayer ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }

    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${local.day} ${meses[local.month - 1]}, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
