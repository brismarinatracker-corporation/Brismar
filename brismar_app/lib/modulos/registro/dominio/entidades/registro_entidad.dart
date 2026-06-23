/// Entidad de dominio pura que representa un registro de pesca y gastos asociados.
class RegistroEntidad {
  final String id;
  final String usuarioId;
  final String nombreEmbarcacion;
  final String producto;
  final String? placaCarro;
  final double kilos;
  final double precioPorKilo;
  final String fecha;
  final String hora;
  final String muelleInicio;
  final double gastoFacturacion;
  final double gastoPersonal;
  final double gastoApoyo;
  final double gastoAgua;
  final double gastoClorox;
  final double gastoFlete;
  final double gastoHielo;
  final double gastoOtros;
  final bool sincronizado;

  /// Constructor de [RegistroEntidad].
  const RegistroEntidad({
    required this.id,
    required this.usuarioId,
    required this.nombreEmbarcacion,
    required this.producto,
    this.placaCarro,
    required this.kilos,
    required this.precioPorKilo,
    required this.fecha,
    required this.hora,
    required this.muelleInicio,
    this.gastoFacturacion = 0,
    this.gastoPersonal = 0,
    this.gastoApoyo = 0,
    this.gastoAgua = 0,
    this.gastoClorox = 0,
    this.gastoFlete = 0,
    this.gastoHielo = 0,
    this.gastoOtros = 0,
    this.sincronizado = false,
  });

  /// Calcula el ingreso bruto (Kilos * Precio/kg).
  double get ingresoBruto => kilos * precioPorKilo;

  /// Calcula la suma de todos los gastos operativos del muelle.
  double get totalGastos =>
      gastoFacturacion +
      gastoPersonal +
      gastoApoyo +
      gastoAgua +
      gastoClorox +
      gastoFlete +
      gastoHielo +
      gastoOtros;

  /// Calcula la utilidad neta (Ingreso Bruto - Total Gastos).
  double get utilidadNeta => ingresoBruto - totalGastos;
}
