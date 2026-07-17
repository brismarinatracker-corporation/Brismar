import 'package:bris_tracker/modulos/registro_pesca/dominio/entidades/estado_cuadre.dart';

/// Entidad que representa la compra de pescado a una embarcación.
class CompraEntidad {
  /// Identificador único de la compra.
  final String id;

  /// Identificador del cuadre al que pertenece la compra.
  final String cuadreId;

  /// Nombre de la embarcación proveedora.
  final String embarcacion;

  /// Nombre del producto comprado.
  final String producto;

  /// Cantidad en kilos del producto.
  final double kilos;

  /// Precio acordado por kilo.
  final double precioUnitario;

  /// Adelanto entregado al proveedor (embarcación) en efectivo.
  final double adelanto;

  /// Monto total de la compra (kilos * precioUnitario).
  final double total;

  /// Constructor de [CompraEntidad].
  const CompraEntidad({
    required this.id,
    required this.cuadreId,
    required this.embarcacion,
    required this.producto,
    required this.kilos,
    required this.precioUnitario,
    this.adelanto = 0.0,
    required this.total,
  });
}

/// Entidad que representa un gasto operativo del cuadre.
class GastoEntidad {
  /// Identificador único del gasto.
  final String id;

  /// Identificador del cuadre asociado.
  final String cuadreId;

  /// Tipo de gasto (ej. 'Muelle', 'Admin').
  final String tipo;

  /// Concepto o descripción del gasto.
  final String concepto;

  /// Cantidad de unidades consumidas/compradas.
  final double cantidad;

  /// Costo por unidad.
  final double costoUnitario;

  /// Costo total (cantidad * costoUnitario).
  final double total;

  /// Constructor de [GastoEntidad].
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

/// Entidad que representa la venta de pescado a un cliente/lugar.
class VentaEntidad {
  /// Identificador único de la venta.
  final String id;

  /// Identificador del cuadre asociado.
  final String cuadreId;

  /// Lugar de la venta / cliente.
  final String lugar;

  /// Nombre del producto vendido.
  final String producto;

  /// Cantidad en kilos vendida.
  final double kilos;

  /// Precio unitario de venta.
  final double precioUnitario;

  /// Monto total de la venta (kilos * precioUnitario).
  final double total;

  /// Constructor de [VentaEntidad].
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

/// Entidad principal que representa un Cuadre de lote de pesca diario.
class CuadreEntidad {
  /// Identificador único del cuadre.
  final String id;

  /// ID del usuario (Bahía) que creó el cuadre.
  final String usuarioId;

  /// Placa de la cámara de transporte.
  final String placa;

  /// Fecha y hora del zarpe.
  final String? fechaZarpe;

  /// Fecha y hora del cuadre final.
  final String? fechaCuadre;

  /// Estado del cuadre (ej. EstadoCuadre.borrador, EstadoCuadre.completo).
  final EstadoCuadre estado;

  /// URL del PDF de reporte generado y subido a la nube.
  final String? urlPdfCloud;

  /// URL del Excel de reporte generado y subido a la nube.
  final String? urlExcelCloud;

  /// Indica si el cuadre ha sido sincronizado con Supabase.
  final bool sincronizado;

  /// URL de la foto de zarpe de cámara subida.
  final String? fotoZarpeUrl;

  /// Peso total del lote.
  final double? pesoTotal;

  /// Número de cajas llenas reportadas.
  final int? cajasLlenas;

  /// Número de cajas vacías reportadas.
  final int? cajasVacias;

  /// Tipo de producto (ID de especie).
  final int? tipoProducto;

  /// Muelle o planta de destino.
  final String? muellePartida;

  /// Pesador (opcional)
  final String? pesador;

  /// Tipo (opcional)
  final String? tipo;

  /// Cuadrilla (opcional)
  final String? cuadrilla;

  /// Detalle de las compras de pescado asociadas.
  final List<CompraEntidad> compras;

  /// Detalle de los gastos operativos asociados.
  final List<GastoEntidad> gastos;

  /// Detalle de las ventas asociadas.
  final List<VentaEntidad> ventas;

  /// Constructor de [CuadreEntidad].
  const CuadreEntidad({
    required this.id,
    required this.usuarioId,
    required this.placa,
    this.fechaZarpe,
    this.fechaCuadre,
    this.estado = EstadoCuadre.borrador,
    this.urlPdfCloud,
    this.urlExcelCloud,
    this.sincronizado = false,
    this.fotoZarpeUrl,
    this.pesoTotal,
    this.cajasLlenas,
    this.cajasVacias,
    this.tipoProducto,
    this.muellePartida,
    this.pesador,
    this.tipo,
    this.cuadrilla,
    this.compras = const [],
    this.gastos = const [],
    this.ventas = const [],
  });
}
