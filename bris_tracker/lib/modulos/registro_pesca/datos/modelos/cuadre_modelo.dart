import '../../dominio/entidades/cuadre_entidad.dart';

/// Modelo de datos para la entidad de compras, adaptado para serialización y persistencia.
class CompraModelo extends CompraEntidad {
  /// Constructor de [CompraModelo].
  const CompraModelo({
    required super.id,
    required super.cuadreId,
    required super.embarcacion,
    required super.producto,
    required super.kilos,
    required super.precioUnitario,
    super.adelanto = 0.0,
    required super.total,
  });

  /// Crea un [CompraModelo] a partir de una [CompraEntidad].
  factory CompraModelo.fromEntidad(CompraEntidad e) => CompraModelo(
    id: e.id,
    cuadreId: e.cuadreId,
    embarcacion: e.embarcacion,
    producto: e.producto,
    kilos: e.kilos,
    precioUnitario: e.precioUnitario,
    adelanto: e.adelanto,
    total: e.total,
  );

  /// Crea un [CompraModelo] a partir de un mapa de SQLite.
  factory CompraModelo.fromSqlite(Map<String, dynamic> map) => CompraModelo(
    id: map['id'] as String,
    cuadreId: map['cuadre_id'] as String,
    embarcacion: map['embarcacion'] as String,
    producto: map['producto'] as String,
    kilos: (map['kilos'] as num).toDouble(),
    precioUnitario: (map['precio_unitario'] as num).toDouble(),
    adelanto: map['adelanto'] != null
        ? (map['adelanto'] as num).toDouble()
        : 0.0,
    total: (map['total'] as num).toDouble(),
  );

  /// Convierte este modelo a un mapa compatible con SQLite.
  Map<String, dynamic> toSqlite() => {
    'id': id,
    'cuadre_id': cuadreId,
    'embarcacion': embarcacion,
    'producto': producto,
    'kilos': kilos,
    'precio_unitario': precioUnitario,
    'adelanto': adelanto,
    'total': total,
  };

  /// Crea un [CompraModelo] a partir de un mapa JSON de Supabase.
  factory CompraModelo.fromJson(Map<String, dynamic> map) => CompraModelo(
    id: map['id'] as String,
    cuadreId: map['cuadre_id'] as String,
    embarcacion: map['embarcacion'] as String,
    producto: map['producto'] as String,
    kilos: (map['kilos'] as num).toDouble(),
    precioUnitario: (map['precio_unitario'] as num).toDouble(),
    adelanto: map['adelanto'] != null
        ? (map['adelanto'] as num).toDouble()
        : 0.0,
    total: (map['total'] as num).toDouble(),
  );

  /// Convierte este modelo a un mapa JSON para Supabase.
  Map<String, dynamic> toJson() => {
    'id': id,
    'cuadre_id': cuadreId,
    'embarcacion': embarcacion,
    'producto': producto,
    'kilos': kilos,
    'precio_unitario': precioUnitario,
    'adelanto': adelanto,
    'total': total,
  };
}

/// Modelo de datos para la entidad de gastos, adaptado para serialización y persistencia.
class GastoModelo extends GastoEntidad {
  /// Constructor de [GastoModelo].
  const GastoModelo({
    required super.id,
    required super.cuadreId,
    required super.tipo,
    required super.concepto,
    required super.cantidad,
    required super.costoUnitario,
    required super.total,
  });

  /// Crea un [GastoModelo] a partir de una [GastoEntidad].
  factory GastoModelo.fromEntidad(GastoEntidad e) => GastoModelo(
    id: e.id,
    cuadreId: e.cuadreId,
    tipo: e.tipo,
    concepto: e.concepto,
    cantidad: e.cantidad,
    costoUnitario: e.costoUnitario,
    total: e.total,
  );

  /// Crea un [GastoModelo] a partir de un mapa de SQLite.
  factory GastoModelo.fromSqlite(Map<String, dynamic> map) => GastoModelo(
    id: map['id'] as String,
    cuadreId: map['cuadre_id'] as String,
    tipo: map['tipo'] as String,
    concepto: map['concepto'] as String,
    cantidad: (map['cantidad'] as num).toDouble(),
    costoUnitario: (map['costo_unitario'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
  );

  /// Convierte este modelo a un mapa compatible con SQLite.
  Map<String, dynamic> toSqlite() => {
    'id': id,
    'cuadre_id': cuadreId,
    'tipo': tipo,
    'concepto': concepto,
    'cantidad': cantidad,
    'costo_unitario': costoUnitario,
    'total': total,
  };

  /// Crea un [GastoModelo] a partir de un mapa JSON de Supabase.
  factory GastoModelo.fromJson(Map<String, dynamic> map) => GastoModelo(
    id: map['id'] as String,
    cuadreId: map['cuadre_id'] as String,
    tipo: map['tipo'] as String,
    concepto: map['concepto'] as String,
    cantidad: (map['cantidad'] as num).toDouble(),
    costoUnitario: (map['costo_unitario'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
  );

  /// Convierte este modelo a un mapa JSON para Supabase.
  Map<String, dynamic> toJson() => {
    'id': id,
    'cuadre_id': cuadreId,
    'tipo': tipo,
    'concepto': concepto,
    'cantidad': cantidad,
    'costo_unitario': costoUnitario,
    'total': total,
  };
}

/// Modelo de datos para la entidad de ventas, adaptado para serialización y persistencia.
class VentaModelo extends VentaEntidad {
  /// Constructor de [VentaModelo].
  const VentaModelo({
    required super.id,
    required super.cuadreId,
    required super.lugar,
    required super.producto,
    required super.kilos,
    required super.precioUnitario,
    required super.total,
  });

  /// Crea un [VentaModelo] a partir de una [VentaEntidad].
  factory VentaModelo.fromEntidad(VentaEntidad e) => VentaModelo(
    id: e.id,
    cuadreId: e.cuadreId,
    lugar: e.lugar,
    producto: e.producto,
    kilos: e.kilos,
    precioUnitario: e.precioUnitario,
    total: e.total,
  );

  /// Crea un [VentaModelo] a partir de un mapa de SQLite.
  factory VentaModelo.fromSqlite(Map<String, dynamic> map) => VentaModelo(
    id: map['id'] as String,
    cuadreId: map['cuadre_id'] as String,
    lugar: map['lugar'] as String,
    producto: map['producto'] as String,
    kilos: (map['kilos'] as num).toDouble(),
    precioUnitario: (map['precio_unitario'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
  );

  /// Convierte este modelo a un mapa compatible con SQLite.
  Map<String, dynamic> toSqlite() => {
    'id': id,
    'cuadre_id': cuadreId,
    'lugar': lugar,
    'producto': producto,
    'kilos': kilos,
    'precio_unitario': precioUnitario,
    'total': total,
  };

  /// Crea un [VentaModelo] a partir de un mapa JSON de Supabase.
  factory VentaModelo.fromJson(Map<String, dynamic> map) => VentaModelo(
    id: map['id'] as String,
    cuadreId: map['cuadre_id'] as String,
    lugar: map['lugar'] as String,
    producto: map['producto'] as String,
    kilos: (map['kilos'] as num).toDouble(),
    precioUnitario: (map['precio_unitario'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
  );

  /// Convierte este modelo a un mapa JSON para Supabase.
  Map<String, dynamic> toJson() => {
    'id': id,
    'cuadre_id': cuadreId,
    'lugar': lugar,
    'producto': producto,
    'kilos': kilos,
    'precio_unitario': precioUnitario,
    'total': total,
  };
}

/// Modelo de datos para la entidad de cuadres, adaptado para serialización y persistencia.
class CuadreModelo extends CuadreEntidad {
  /// Constructor de [CuadreModelo].
  const CuadreModelo({
    required super.id,
    required super.usuarioId,
    required super.placa,
    super.fechaZarpe,
    super.fechaCuadre,
    super.estado,
    super.urlPdfCloud,
    super.urlExcelCloud,
    super.sincronizado,
    super.fotoZarpeUrl,
    super.pesoTotal,
    super.cajasLlenas,
    super.cajasVacias,
    super.tipoProducto,
    super.muellePartida,
    super.pesador,
    super.tipo,
    super.cuadrilla,
    super.compras = const [],
    super.gastos,
    super.ventas,
  });

  /// Crea un [CuadreModelo] a partir de una [CuadreEntidad].
  factory CuadreModelo.fromEntidad(CuadreEntidad e) => CuadreModelo(
    id: e.id,
    usuarioId: e.usuarioId,
    placa: e.placa,
    fechaZarpe: e.fechaZarpe,
    fechaCuadre: e.fechaCuadre,
    estado: e.estado,
    urlPdfCloud: e.urlPdfCloud,
    urlExcelCloud: e.urlExcelCloud,
    sincronizado: e.sincronizado,
    fotoZarpeUrl: e.fotoZarpeUrl,
    pesoTotal: e.pesoTotal,
    cajasLlenas: e.cajasLlenas,
    cajasVacias: e.cajasVacias,
    tipoProducto: e.tipoProducto,
    muellePartida: e.muellePartida,
    pesador: e.pesador,
    tipo: e.tipo,
    cuadrilla: e.cuadrilla,
    compras: e.compras.map((c) => CompraModelo.fromEntidad(c)).toList(),
    gastos: e.gastos.map((g) => GastoModelo.fromEntidad(g)).toList(),
    ventas: e.ventas.map((v) => VentaModelo.fromEntidad(v)).toList(),
  );

  /// Crea un [CuadreModelo] a partir de un mapa de SQLite.
  factory CuadreModelo.fromSqlite(Map<String, dynamic> map) => CuadreModelo(
    id: map['id'] as String,
    usuarioId: map['usuario_id'] as String,
    placa: map['placa'] as String,
    fechaZarpe: map['fecha_zarpe'] as String?,
    fechaCuadre: map['fecha_cuadre'] as String?,
    estado: map['estado'] as String? ?? 'borrador',
    urlPdfCloud: map['url_pdf_cloud'] as String?,
    urlExcelCloud: map['url_excel_cloud'] as String?,
    sincronizado: (map['sincronizado'] as int) == 1,
    fotoZarpeUrl: map['foto_zarpe_url'] as String?,
    pesoTotal: map['peso_total'] != null
        ? (map['peso_total'] as num).toDouble()
        : null,
    cajasLlenas: map['cajas_llenas'] as int?,
    cajasVacias: map['cajas_vacias'] as int?,
    tipoProducto: map['tipo_producto']?.toString(),
    muellePartida: map['planta_destino'] as String?,
    pesador: map['pesador'] as String?,
    tipo: map['tipo'] as String?,
    cuadrilla: map['cuadrilla'] as String?,
  );

  /// Convierte este modelo a un mapa compatible con SQLite.
  Map<String, dynamic> toSqlite() => {
    'id': id,
    'usuario_id': usuarioId,
    'placa': placa,
    'fecha_zarpe': fechaZarpe,
    'fecha_cuadre': fechaCuadre,
    'estado': estado,
    'url_pdf_cloud': urlPdfCloud,
    'url_excel_cloud': urlExcelCloud,
    'sincronizado': sincronizado ? 1 : 0,
    'foto_zarpe_url': fotoZarpeUrl,
    'peso_total': pesoTotal,
    'cajas_llenas': cajasLlenas,
    'cajas_vacias': cajasVacias,
    'tipo_producto': tipoProducto,
    'planta_destino': muellePartida,
    'pesador': pesador,
    'tipo': tipo,
    'cuadrilla': cuadrilla,
  };

  /// Crea un [CuadreModelo] a partir de un mapa JSON de Supabase.
  factory CuadreModelo.fromJson(Map<String, dynamic> map) => CuadreModelo(
    id: map['id'] as String,
    usuarioId: map['usuario_id'] as String,
    placa: map['placa'] as String,
    fechaZarpe: map['fecha_zarpe'] as String?,
    fechaCuadre: map['fecha_cuadre'] as String?,
    estado: map['estado'] as String? ?? 'borrador',
    urlPdfCloud: map['url_pdf_cloud'] as String?,
    urlExcelCloud: map['url_excel_cloud'] as String?,
    sincronizado: map['sincronizado'] as bool? ?? false,
    fotoZarpeUrl: map['foto_zarpe_url'] as String?,
    pesoTotal: map['peso_total'] != null
        ? (map['peso_total'] as num).toDouble()
        : null,
    cajasLlenas: map['cajas_llenas'] as int?,
    cajasVacias: map['cajas_vacias'] as int?,
    tipoProducto: map['tipo_producto']?.toString(),
    muellePartida: map['planta_destino'] as String?,
    pesador: map['pesador'] as String?,
    tipo: map['tipo'] as String?,
    cuadrilla: map['cuadrilla'] as String?,
  );

  /// Convierte este modelo a un mapa JSON para Supabase.
  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'placa': placa,
    'fecha_zarpe': fechaZarpe,
    'fecha_cuadre': fechaCuadre,
    'estado': estado,
    'url_pdf_cloud': urlPdfCloud,
    'url_excel_cloud': urlExcelCloud,
    'foto_zarpe_url': fotoZarpeUrl,
    'peso_total': pesoTotal,
    'cajas_llenas': cajasLlenas,
    'cajas_vacias': cajasVacias,
    'tipo_producto': tipoProducto,
    'planta_destino': muellePartida,
    'pesador': pesador,
    'tipo': tipo,
    'cuadrilla': cuadrilla,
  };
}
