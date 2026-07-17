// ============================================================
// Módulo   : Cuadres — Web Admin
// Archivo  : cuadre_web_modelo.dart
// Última modificación: 2026-06-29
// Autor    : Antigravity IDE
// ============================================================

/// Modelo de datos para un Cuadre de Pesca en la Web Admin.
///
/// Mapea el resultado de un JOIN entre las tablas:
/// `cuadres`, `compras`, `gastos`, `ventas` desde Supabase.
class CuadreWebModelo {
  final String id;
  final String usuarioId;
  final String placa;
  final String? fechaZarpe;
  final String? fechaCuadre;
  final String estado;
  final String? urlPdfCloud;
  final String? urlExcelCloud;
  final String? fotoZarpeUrl;
  final double? pesoTotal;
  final int? cajasLlenas;
  final int? cajasVacias;
  final int? tipoProducto;
  final String? pesador;
  final String? tipo;
  final String? cuadrilla;
  final String? chofer;
  final String? numeroChofer;
  final String? plantaDestino;

  /// Nombre real del usuario (bahía) que registró el zarpe.
  /// Obtenido mediante JOIN con public.usuarios en la fuente de datos.
  final String? nombreBahia;

  final List<CompraWebModelo> compras;
  final List<GastoWebModelo> gastos;
  final List<VentaWebModelo> ventas;

  const CuadreWebModelo({
    required this.id,
    required this.usuarioId,
    required this.placa,
    this.fechaZarpe,
    this.fechaCuadre,
    this.estado = 'borrador',
    this.urlPdfCloud,
    this.urlExcelCloud,
    this.fotoZarpeUrl,
    this.pesoTotal,
    this.cajasLlenas,
    this.cajasVacias,
    this.tipoProducto,
    this.pesador,
    this.tipo,
    this.cuadrilla,
    this.chofer,
    this.numeroChofer,
    this.plantaDestino,
    this.nombreBahia,
    this.compras = const [],
    this.gastos = const [],
    this.ventas = const [],
  });

  /// Construye desde un [Map] de Supabase (sin relaciones).
  factory CuadreWebModelo.desdeJson(Map<String, dynamic> json) {
    return CuadreWebModelo(
      id: json['id'] as String? ?? '',
      usuarioId: json['usuario_id'] as String? ?? '',
      placa: json['placa'] as String? ?? '',
      fechaZarpe: json['fecha_zarpe'] as String?,
      fechaCuadre: json['fecha_cuadre'] as String?,
      estado: json['estado'] as String? ?? 'borrador',
      urlPdfCloud: json['url_pdf_cloud'] as String?,
      urlExcelCloud: json['url_excel_cloud'] as String?,
      fotoZarpeUrl: json['foto_zarpe_url'] as String?,
      pesoTotal: (json['peso_total'] as num?)?.toDouble(),
      cajasLlenas: json['cajas_llenas'] as int?,
      cajasVacias: json['cajas_vacias'] as int?,
      tipoProducto: json['tipo_producto'] as int?,
      pesador: json['pesador'] as String?,
      tipo: json['tipo'] as String?,
      cuadrilla: json['cuadrilla'] as String?,
      chofer: json['chofer'] as String?,
      numeroChofer: json['numero_chofer'] as String?,
      plantaDestino: json['planta_destino'] as String?,
      nombreBahia: (json['usuarios'] as Map<String, dynamic>?)?['nombre_real'] as String?,
    );
  }

  /// Total de ventas calculado dinámicamente.
  double get totalVentas => ventas.fold(0.0, (s, v) => s + v.total);

  /// Total de gastos calculado dinámicamente.
  double get totalGastos => gastos.fold(0.0, (s, g) => s + g.total);

  /// Total de compras calculado dinámicamente.
  double get totalCompras => compras.fold(0.0, (s, c) => s + c.total);

  /// Utilidad neta: ventas − compras − gastos.
  double get utilidadNeta => totalVentas - totalCompras - totalGastos;

  /// Retorna `true` si el cuadre tiene estado de borrador.
  bool get esBorrador => estado.toLowerCase() == 'borrador';

  /// Crea una copia inmutable con listas de relaciones reemplazadas.
  CuadreWebModelo conRelaciones({
    List<CompraWebModelo>? compras,
    List<GastoWebModelo>? gastos,
    List<VentaWebModelo>? ventas,
  }) {
    return CuadreWebModelo(
      id: id,
      usuarioId: usuarioId,
      placa: placa,
      fechaZarpe: fechaZarpe,
      fechaCuadre: fechaCuadre,
      estado: estado,
      urlPdfCloud: urlPdfCloud,
      urlExcelCloud: urlExcelCloud,
      fotoZarpeUrl: fotoZarpeUrl,
      pesoTotal: pesoTotal,
      cajasLlenas: cajasLlenas,
      cajasVacias: cajasVacias,
      tipoProducto: tipoProducto,
      pesador: pesador,
      tipo: tipo,
      cuadrilla: cuadrilla,
      chofer: chofer,
      numeroChofer: numeroChofer,
      plantaDestino: plantaDestino,
      nombreBahia: nombreBahia,
      compras: compras ?? this.compras,
      gastos: gastos ?? this.gastos,
      ventas: ventas ?? this.ventas,
    );
  }

  /// Crea una copia inmutable con el [nombre] del bahía registrador sobrescrito.
  /// Útil como fallback cuando el JOIN con usuarios no retornó datos
  /// (e.g., cuadres históricos anteriores al JOIN).
  CuadreWebModelo conNombreBahia(String? nombre) {
    return CuadreWebModelo(
      id: id,
      usuarioId: usuarioId,
      placa: placa,
      fechaZarpe: fechaZarpe,
      fechaCuadre: fechaCuadre,
      estado: estado,
      urlPdfCloud: urlPdfCloud,
      urlExcelCloud: urlExcelCloud,
      fotoZarpeUrl: fotoZarpeUrl,
      pesoTotal: pesoTotal,
      cajasLlenas: cajasLlenas,
      cajasVacias: cajasVacias,
      tipoProducto: tipoProducto,
      pesador: pesador,
      plantaDestino: plantaDestino,
      nombreBahia: nombre,
      compras: compras,
      gastos: gastos,
      ventas: ventas,
    );
  }
}

// ─────────────────────────────────────────────────────────────

/// Modelo de Compra de la Web Admin.
///
/// Representa una entrada de compra de pescado asociada a un cuadre.
class CompraWebModelo {
  final String id;
  final String cuadreId;
  final String embarcacion;
  final String producto;
  final double kilos;
  final double precioUnitario;
  final double total;
  final double? adelanto;

  const CompraWebModelo({
    required this.id,
    required this.cuadreId,
    required this.embarcacion,
    required this.producto,
    required this.kilos,
    required this.precioUnitario,
    required this.total,
    this.adelanto,
  });

  /// Construye desde un [Map] de Supabase.
  factory CompraWebModelo.desdeJson(Map<String, dynamic> json) {
    return CompraWebModelo(
      id: json['id'] as String? ?? '',
      cuadreId: json['cuadre_id'] as String? ?? '',
      embarcacion: json['embarcacion'] as String? ?? '',
      producto: json['producto'] as String? ?? '',
      kilos: (json['kilos'] as num?)?.toDouble() ?? 0,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      adelanto: (json['adelanto'] as num?)?.toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────

/// Modelo de Gasto de la Web Admin.
///
/// Representa un gasto operativo (hielo, muelle, combustible, etc.)
/// asociado a un cuadre de pesca.
class GastoWebModelo {
  final String id;
  final String cuadreId;
  final String tipo;
  final String concepto;
  final double cantidad;
  final double costoUnitario;
  final double total;

  const GastoWebModelo({
    required this.id,
    required this.cuadreId,
    required this.tipo,
    required this.concepto,
    required this.cantidad,
    required this.costoUnitario,
    required this.total,
  });

  /// Construye desde un [Map] de Supabase.
  factory GastoWebModelo.desdeJson(Map<String, dynamic> json) {
    return GastoWebModelo(
      id: json['id'] as String? ?? '',
      cuadreId: json['cuadre_id'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      concepto: json['concepto'] as String? ?? '',
      cantidad: (json['cantidad'] as num?)?.toDouble() ?? 0,
      costoUnitario: (json['costo_unitario'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────

/// Modelo de Venta de la Web Admin.
///
/// Representa la venta del pescado a una planta de procesamiento.
class VentaWebModelo {
  final String id;
  final String cuadreId;
  final String lugar;
  final String producto;
  final double kilos;
  final double precioUnitario;
  final double total;

  const VentaWebModelo({
    required this.id,
    required this.cuadreId,
    required this.lugar,
    required this.producto,
    required this.kilos,
    required this.precioUnitario,
    required this.total,
  });

  /// Construye desde un [Map] de Supabase.
  factory VentaWebModelo.desdeJson(Map<String, dynamic> json) {
    return VentaWebModelo(
      id: json['id'] as String? ?? '',
      cuadreId: json['cuadre_id'] as String? ?? '',
      lugar: json['lugar'] as String? ?? '',
      producto: json['producto'] as String? ?? '',
      kilos: (json['kilos'] as num?)?.toDouble() ?? 0,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}
