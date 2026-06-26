class CompraEntidad {
  final String id;
  final String cuadreId;
  final String embarcacion;
  final String producto;
  final double kilos;
  final double precioUnitario;
  final double total;

  const CompraEntidad({
    required this.id,
    required this.cuadreId,
    required this.embarcacion,
    required this.producto,
    required this.kilos,
    required this.precioUnitario,
    required this.total,
  });
}

class GastoEntidad {
  final String id;
  final String cuadreId;
  final String tipo; // 'Muelle' o 'Admin'
  final String concepto;
  final double cantidad;
  final double costoUnitario;
  final double total;

  const GastoEntidad({
    required this.id,
    required this.cuadreId,
    required this.tipo,
    required this.concepto,
    required this.cantidad,
    required this.costoUnitario,
    required this.total,
  });
}

class VentaEntidad {
  final String id;
  final String cuadreId;
  final String lugar;
  final String producto;
  final double kilos;
  final double precioUnitario;
  final double total;

  const VentaEntidad({
    required this.id,
    required this.cuadreId,
    required this.lugar,
    required this.producto,
    required this.kilos,
    required this.precioUnitario,
    required this.total,
  });
}

class CuadreEntidad {
  final String id;
  final String usuarioId;
  final String placa;
  final String? fechaZarpe;
  final String? fechaCuadre;
  final String estado; // 'borrador', 'completo'
  final String? urlPdfCloud;
  final String? urlExcelCloud;
  final bool sincronizado;

  final List<CompraEntidad> compras;
  final List<GastoEntidad> gastos;
  final List<VentaEntidad> ventas;

  const CuadreEntidad({
    required this.id,
    required this.usuarioId,
    required this.placa,
    this.fechaZarpe,
    this.fechaCuadre,
    this.estado = 'borrador',
    this.urlPdfCloud,
    this.urlExcelCloud,
    this.sincronizado = false,
    this.compras = const [],
    this.gastos = const [],
    this.ventas = const [],
  });
}
