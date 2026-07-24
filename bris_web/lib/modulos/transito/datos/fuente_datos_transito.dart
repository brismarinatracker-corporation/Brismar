import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../dominio/enums/estado_zarpe.dart';
import '../dominio/modelos/zarpe_modelo.dart';

/// Fuente de datos remota para el módulo de Tránsitos/Zarpes.
///
/// Retorna modelos tipados ([ZarpeModelo]) en lugar de `Map<String, dynamic>`,
/// garantizando que cualquier cambio de campo en la DB falle en compile time.
class FuenteDatosTransito {
  final SupabaseClient _cliente;

  FuenteDatosTransito(this._cliente);

  // ─── Consultas ────────────────────────────────────────────────────────────

  /// Obtiene zarpes paginados y ordenados por fecha desde la vista de Supabase.
  ///
  /// Aplica filtro temporal ([filtro]) y limita a [limite] registros desde [offset].
  Future<List<ZarpeModelo>> obtenerZarpes({
    String filtro = 'todos',
    int limite = 30,
    int offset = 0,
  }) async {
    var query = _cliente.from('vista_zarpes_detallados').select();

    query = _aplicarFiltroTemporal(query, filtro);

    final datos = await query
        .order('fecha_zarpe', ascending: false)
        .range(offset, offset + limite - 1);

    return (datos as List)
        .map((m) => ZarpeModelo.desdeJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene un zarpe por su ID único.
  ///
  /// Retorna `null` si no existe en la base de datos.
  Future<ZarpeModelo?> obtenerZarpePorId(String id) async {
    final datos = await _cliente
        .from('vista_zarpes_detallados')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (datos == null) return null;
    return ZarpeModelo.desdeJson(datos);
  }

  // ─── Mutaciones ───────────────────────────────────────────────────────────

  /// Registra la recepción final de un zarpe en la planta procesadora.
  ///
  /// Actualiza el estado del zarpe, el cuadre asociado, y registra la venta.
  /// Las operaciones se ejecutan en secuencia para evitar inconsistencias.
  Future<void> registrarRecepcionEnPlanta({
    required String id,
    required String planta,
    required String especie,
    required double kilos,
    required double precio,
  }) async {
    await _actualizarEstadoZarpe(id, EstadoZarpe.recibido);
    await _upsertCuadreRecepcion(id: id, planta: planta, kilos: kilos);
    await _registrarVenta(
      id: id,
      planta: planta,
      especie: especie,
      kilos: kilos,
      precio: precio,
    );
  }

  // ─── Helpers privados ────────────────────────────────────────────────────

  /// Aplica el filtro temporal a la query de Supabase.
  dynamic _aplicarFiltroTemporal(dynamic query, String filtro) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final ayer = hoy.subtract(const Duration(days: 1));

    String format(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return switch (filtro) {
      'hoy' =>
        query
            .gte('fecha_zarpe', format(hoy))
            .lt('fecha_zarpe', format(hoy.add(const Duration(days: 1)))),
      'ayer' =>
        query.gte('fecha_zarpe', format(ayer)).lt('fecha_zarpe', format(hoy)),
      'semana' => query.gte(
        'fecha_zarpe',
        format(
          hoy.subtract(Duration(days: hoy.weekday - 1)),
        ), // Desde el lunes de esta semana
      ),
      'mes' => query.gte(
        'fecha_zarpe',
        format(DateTime(ahora.year, ahora.month, 1)), // Desde el inicio del mes
      ),
      _ => query,
    };
  }

  /// Actualiza el estado del zarpe en la tabla `zarpes`.
  Future<void> _actualizarEstadoZarpe(String id, EstadoZarpe estado) async {
    await _cliente
        .from('zarpes')
        .update({'estado': estado.valorDb})
        .eq('id', id);
  }

  /// Inserta o actualiza el cuadre asociado al zarpe recibido.
  Future<void> _upsertCuadreRecepcion({
    required String id,
    required String planta,
    required double kilos,
  }) async {
    final existeCuadre = await _cliente
        .from('cuadres')
        .select('id')
        .eq('id', id)
        .maybeSingle();

    if (existeCuadre == null) {
      await _cliente.from('cuadres').insert({
        'id': id,
        'usuario_id': _cliente.auth.currentUser?.id ?? '',
        'placa': '',
        'fecha_zarpe': DateTime.now().toIso8601String().substring(0, 10),
        'estado': 'completado',
        'planta_destino': planta,
        'peso_total': kilos,
      });
    } else {
      final updateData = <String, dynamic>{
        'estado': 'completado',
        'planta_destino': planta,
        'peso_total': kilos,
      };
      if (_cliente.auth.currentUser?.id != null) {
        updateData['usuario_id'] = _cliente.auth.currentUser!.id;
      }
      await _cliente
          .from('cuadres')
          .update(updateData)
          .eq('id', id);
    }
  }

  /// Elimina ventas anteriores e inserta la venta definitiva del zarpe.
  Future<void> _registrarVenta({
    required String id,
    required String planta,
    required String especie,
    required double kilos,
    required double precio,
  }) async {
    await _cliente.from('ventas').delete().eq('cuadre_id', id);
    await _cliente.from('ventas').insert({
      'id': Uuid().v4(),
      'cuadre_id': id,
      'lugar': planta,
      'producto': especie,
      'kilos': kilos,
      'precio_unitario': precio,
      'total': kilos * precio,
    });
  }
}
