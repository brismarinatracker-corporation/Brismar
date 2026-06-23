import '../../dominio/entidades/registro_entidad.dart';

/// Modelo de datos que añade mapeo SQLite y JSON a la entidad [RegistroEntidad].
class RegistroModelo extends RegistroEntidad {
  const RegistroModelo({
    required super.id,
    required super.usuarioId,
    required super.nombreEmbarcacion,
    required super.producto,
    super.placaCarro,
    required super.kilos,
    required super.precioPorKilo,
    required super.fecha,
    required super.hora,
    required super.muelleInicio,
    super.cajas,
    super.gastoFacturacion,
    super.gastoPersonal,
    super.gastoApoyo,
    super.gastoAgua,
    super.gastoClorox,
    super.gastoFlete,
    super.gastoHielo,
    super.gastoPesador,
    super.gastoOtros,
    super.sincronizado,
  });

  /// Convierte una entidad genérica a una instancia de este modelo.
  factory RegistroModelo.fromEntidad(RegistroEntidad e) {
    return RegistroModelo(
      id: e.id,
      usuarioId: e.usuarioId,
      nombreEmbarcacion: e.nombreEmbarcacion,
      producto: e.producto,
      placaCarro: e.placaCarro,
      kilos: e.kilos,
      precioPorKilo: e.precioPorKilo,
      fecha: e.fecha,
      hora: e.hora,
      muelleInicio: e.muelleInicio,
      cajas: e.cajas,
      gastoFacturacion: e.gastoFacturacion,
      gastoPersonal: e.gastoPersonal,
      gastoApoyo: e.gastoApoyo,
      gastoAgua: e.gastoAgua,
      gastoClorox: e.gastoClorox,
      gastoFlete: e.gastoFlete,
      gastoHielo: e.gastoHielo,
      gastoPesador: e.gastoPesador,
      gastoOtros: e.gastoOtros,
      sincronizado: e.sincronizado,
    );
  }

  /// Mapea un registro desde SQLite (donde booleans son 0 o 1).
  factory RegistroModelo.fromSqlite(Map<String, dynamic> map) {
    return RegistroModelo(
      id: map['id'] as String,
      usuarioId: map['usuario_id'] as String,
      nombreEmbarcacion: map['nombre_embarcacion'] as String,
      producto: map['producto'] as String,
      placaCarro: map['placa_carro'] as String?,
      kilos: (map['kilos'] as num).toDouble(),
      precioPorKilo: (map['precio_por_kilo'] as num).toDouble(),
      fecha: map['fecha'] as String,
      hora: map['hora'] as String,
      muelleInicio: map['muelle_inicio'] as String,
      cajas: map['cajas'] as int? ?? 0,
      gastoFacturacion: (map['gasto_facturacion'] as num).toDouble(),
      gastoPersonal: (map['gasto_personal'] as num).toDouble(),
      gastoApoyo: (map['gasto_apoyo'] as num).toDouble(),
      gastoAgua: (map['gasto_agua'] as num).toDouble(),
      gastoClorox: (map['gasto_clorox'] as num).toDouble(),
      gastoFlete: (map['gasto_flete'] as num).toDouble(),
      gastoHielo: (map['gasto_hielo'] as num).toDouble(),
      gastoPesador: (map['gasto_pesador'] as num? ?? 0.0).toDouble(),
      gastoOtros: (map['gasto_otros'] as num).toDouble(),
      sincronizado: (map['sincronizado'] as int) == 1,
    );
  }

  /// Mapea de este modelo a un Map compatible con SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre_embarcacion': nombreEmbarcacion,
      'producto': producto,
      'placa_carro': placaCarro,
      'kilos': kilos,
      'precio_por_kilo': precioPorKilo,
      'fecha': fecha,
      'hora': hora,
      'muelle_inicio': muelleInicio,
      'cajas': cajas,
      'gasto_facturacion': gastoFacturacion,
      'gasto_personal': gastoPersonal,
      'gasto_apoyo': gastoApoyo,
      'gasto_agua': gastoAgua,
      'gasto_clorox': gastoClorox,
      'gasto_flete': gastoFlete,
      'gasto_hielo': gastoHielo,
      'gasto_pesador': gastoPesador,
      'gasto_otros': gastoOtros,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  /// Mapea un registro desde un JSON de Supabase (PostgreSQL).
  factory RegistroModelo.fromJson(Map<String, dynamic> json) {
    return RegistroModelo(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      nombreEmbarcacion: json['nombre_embarcacion'] as String,
      producto: json['producto'] as String,
      placaCarro: json['placa_carro'] as String?,
      kilos: (json['kilos'] as num).toDouble(),
      precioPorKilo: (json['precio_por_kilo'] as num).toDouble(),
      fecha: json['fecha'] as String,
      hora: json['hora'] as String,
      muelleInicio: json['muelle_inicio'] as String,
      cajas: json['cajas'] as int? ?? 0,
      gastoFacturacion: (json['gasto_facturacion'] as num).toDouble(),
      gastoPersonal: (json['gasto_personal'] as num).toDouble(),
      gastoApoyo: (json['gasto_apoyo'] as num).toDouble(),
      gastoAgua: (json['gasto_agua'] as num).toDouble(),
      gastoClorox: (json['gasto_clorox'] as num).toDouble(),
      gastoFlete: (json['gasto_flete'] as num).toDouble(),
      gastoHielo: (json['gasto_hielo'] as num).toDouble(),
      gastoPesador: (json['gasto_pesador'] as num? ?? 0.0).toDouble(),
      gastoOtros: (json['gasto_otros'] as num).toDouble(),
      sincronizado: json['sincronizado'] as bool? ?? false,
    );
  }

  /// Mapea de este modelo a un JSON compatible con Supabase (excluye flag local).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre_embarcacion': nombreEmbarcacion,
      'producto': producto,
      'placa_carro': placaCarro,
      'kilos': kilos,
      'precio_por_kilo': precioPorKilo,
      'fecha': fecha,
      'hora': hora,
      'muelle_inicio': muelleInicio,
      'cajas': cajas,
      'gasto_facturacion': gastoFacturacion,
      'gasto_personal': gastoPersonal,
      'gasto_apoyo': gastoApoyo,
      'gasto_agua': gastoAgua,
      'gasto_clorox': gastoClorox,
      'gasto_flete': gastoFlete,
      'gasto_hielo': gastoHielo,
      'gasto_pesador': gastoPesador,
      'gasto_otros': gastoOtros,
    };
  }
}
