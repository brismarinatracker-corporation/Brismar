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
    super.gastoFacturacion,
    super.gastoPersonal,
    super.gastoApoyo,
    super.gastoAgua,
    super.gastoClorox,
    super.gastoFlete,
    super.gastoHielo,
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
      gastoFacturacion: e.gastoFacturacion,
      gastoPersonal: e.gastoPersonal,
      gastoApoyo: e.gastoApoyo,
      gastoAgua: e.gastoAgua,
      gastoClorox: e.gastoClorox,
      gastoFlete: e.gastoFlete,
      gastoHielo: e.gastoHielo,
      gastoOtros: e.gastoOtros,
      sincronizado: e.sincronizado,
    );
  }

  /// Mapea un registro desde SQLite (donde booleans son 0 o 1).
  factory RegistroModelo.fromSqlite(Map<String, dynamic> map) {
    return RegistroModelo(
      id: map['id'] as String,
      usuarioId: map['usuario_id'] as String? ?? '',
      nombreEmbarcacion: map['nombre_embarcacion'] as String,
      producto: map['producto'] as String,
      placaCarro: map['placa_carro'] as String?,
      kilos: _leerDecimal(map['kilos'], 'kilos'),
      precioPorKilo: _leerDecimal(map['precio_por_kilo'], 'precio_por_kilo'),
      fecha: map['fecha'] as String,
      hora: map['hora'] as String,
      muelleInicio: map['muelle_inicio'] as String,
      gastoFacturacion: _leerDecimal(
        map['gasto_facturacion'],
        'gasto_facturacion',
      ),
      gastoPersonal: _leerDecimal(map['gasto_personal'], 'gasto_personal'),
      gastoApoyo: _leerDecimal(map['gasto_apoyo'], 'gasto_apoyo'),
      gastoAgua: _leerDecimal(map['gasto_agua'], 'gasto_agua'),
      gastoClorox: _leerDecimal(map['gasto_clorox'], 'gasto_clorox'),
      gastoFlete: _leerDecimal(map['gasto_flete'], 'gasto_flete'),
      gastoHielo: _leerDecimal(map['gasto_hielo'], 'gasto_hielo'),
      gastoOtros: _leerDecimal(map['gasto_otros'], 'gasto_otros'),
      sincronizado: _leerBool(map['sincronizado']),
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
      'gasto_facturacion': gastoFacturacion,
      'gasto_personal': gastoPersonal,
      'gasto_apoyo': gastoApoyo,
      'gasto_agua': gastoAgua,
      'gasto_clorox': gastoClorox,
      'gasto_flete': gastoFlete,
      'gasto_hielo': gastoHielo,
      'gasto_otros': gastoOtros,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  /// Mapea un registro desde un JSON de Supabase (PostgreSQL).
  factory RegistroModelo.fromJson(Map<String, dynamic> json) {
    return RegistroModelo(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String? ?? '',
      nombreEmbarcacion: json['nombre_embarcacion'] as String,
      producto: json['producto'] as String,
      placaCarro: json['placa_carro'] as String?,
      kilos: _leerDecimal(json['kilos'], 'kilos'),
      precioPorKilo: _leerDecimal(json['precio_por_kilo'], 'precio_por_kilo'),
      fecha: json['fecha'] as String,
      hora: json['hora'] as String,
      muelleInicio: json['muelle_inicio'] as String,
      gastoFacturacion: _leerDecimal(
        json['gasto_facturacion'],
        'gasto_facturacion',
      ),
      gastoPersonal: _leerDecimal(json['gasto_personal'], 'gasto_personal'),
      gastoApoyo: _leerDecimal(json['gasto_apoyo'], 'gasto_apoyo'),
      gastoAgua: _leerDecimal(json['gasto_agua'], 'gasto_agua'),
      gastoClorox: _leerDecimal(json['gasto_clorox'], 'gasto_clorox'),
      gastoFlete: _leerDecimal(json['gasto_flete'], 'gasto_flete'),
      gastoHielo: _leerDecimal(json['gasto_hielo'], 'gasto_hielo'),
      gastoOtros: _leerDecimal(json['gasto_otros'], 'gasto_otros'),
      sincronizado: _leerBool(json['sincronizado']),
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
      'gasto_facturacion': gastoFacturacion,
      'gasto_personal': gastoPersonal,
      'gasto_apoyo': gastoApoyo,
      'gasto_agua': gastoAgua,
      'gasto_clorox': gastoClorox,
      'gasto_flete': gastoFlete,
      'gasto_hielo': gastoHielo,
      'gasto_otros': gastoOtros,
    };
  }

  static double _leerDecimal(Object? valor, String campo) {
    if (valor is num) return valor.toDouble();
    if (valor is String) return double.parse(valor);
    throw FormatException('El campo $campo no es numérico: $valor');
  }

  static bool _leerBool(Object? valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;
    if (valor is String) {
      final normalizado = valor.trim().toLowerCase();
      return normalizado == 'true' || normalizado == '1';
    }
    return false;
  }
}
