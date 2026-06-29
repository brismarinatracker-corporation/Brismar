import '../../dominio/entidades/cuadre_entidad.dart';

class CompraModelo extends CompraEntidad {
  const CompraModelo({
    required super.id,
    required super.cuadreId,
    required super.embarcacion,
    required super.producto,
    required super.kilos,
    required super.precioUnitario,
    required super.total,
  });

  factory CompraModelo.fromEntidad(CompraEntidad e) => CompraModelo(
        id: e.id,
        cuadreId: e.cuadreId,
        embarcacion: e.embarcacion,
        producto: e.producto,
        kilos: e.kilos,
        precioUnitario: e.precioUnitario,
        total: e.total,
      );

  factory CompraModelo.fromSqlite(Map<String, dynamic> map) => CompraModelo(
        id: map['id'] as String,
        cuadreId: map['cuadre_id'] as String,
        embarcacion: map['embarcacion'] as String,
        producto: map['producto'] as String,
        kilos: (map['kilos'] as num).toDouble(),
        precioUnitario: (map['precio_unitario'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
      );

  Map<String, dynamic> toSqlite() => {
        'id': id,
        'cuadre_id': cuadreId,
        'embarcacion': embarcacion,
        'producto': producto,
        'kilos': kilos,
        'precio_unitario': precioUnitario,
        'total': total,
      };

  factory CompraModelo.fromJson(Map<String, dynamic> map) => CompraModelo(
        id: map['id'] as String,
        cuadreId: map['cuadre_id'] as String,
        embarcacion: map['embarcacion'] as String,
        producto: map['producto'] as String,
        kilos: (map['kilos'] as num).toDouble(),
        precioUnitario: (map['precio_unitario'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cuadre_id': cuadreId,
        'embarcacion': embarcacion,
        'producto': producto,
        'kilos': kilos,
        'precio_unitario': precioUnitario,
        'total': total,
      };
}

class GastoModelo extends GastoEntidad {
  const GastoModelo({
    required super.id,
    required super.cuadreId,
    required super.tipo,
    required super.concepto,
    required super.cantidad,
    required super.costoUnitario,
    required super.total,
  });

  factory GastoModelo.fromEntidad(GastoEntidad e) => GastoModelo(
        id: e.id,
        cuadreId: e.cuadreId,
        tipo: e.tipo,
        concepto: e.concepto,
        cantidad: e.cantidad,
        costoUnitario: e.costoUnitario,
        total: e.total,
      );

  factory GastoModelo.fromSqlite(Map<String, dynamic> map) => GastoModelo(
        id: map['id'] as String,
        cuadreId: map['cuadre_id'] as String,
        tipo: map['tipo'] as String,
        concepto: map['concepto'] as String,
        cantidad: (map['cantidad'] as num).toDouble(),
        costoUnitario: (map['costo_unitario'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
      );

  Map<String, dynamic> toSqlite() => {
        'id': id,
        'cuadre_id': cuadreId,
        'tipo': tipo,
        'concepto': concepto,
        'cantidad': cantidad,
        'costo_unitario': costoUnitario,
        'total': total,
      };

  factory GastoModelo.fromJson(Map<String, dynamic> map) => GastoModelo(
        id: map['id'] as String,
        cuadreId: map['cuadre_id'] as String,
        tipo: map['tipo'] as String,
        concepto: map['concepto'] as String,
        cantidad: (map['cantidad'] as num).toDouble(),
        costoUnitario: (map['costo_unitario'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
      );

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

class VentaModelo extends VentaEntidad {
  const VentaModelo({
    required super.id,
    required super.cuadreId,
    required super.lugar,
    required super.producto,
    required super.kilos,
    required super.precioUnitario,
    required super.total,
  });

  factory VentaModelo.fromEntidad(VentaEntidad e) => VentaModelo(
        id: e.id,
        cuadreId: e.cuadreId,
        lugar: e.lugar,
        producto: e.producto,
        kilos: e.kilos,
        precioUnitario: e.precioUnitario,
        total: e.total,
      );

  factory VentaModelo.fromSqlite(Map<String, dynamic> map) => VentaModelo(
        id: map['id'] as String,
        cuadreId: map['cuadre_id'] as String,
        lugar: map['lugar'] as String,
        producto: map['producto'] as String,
        kilos: (map['kilos'] as num).toDouble(),
        precioUnitario: (map['precio_unitario'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
      );

  Map<String, dynamic> toSqlite() => {
        'id': id,
        'cuadre_id': cuadreId,
        'lugar': lugar,
        'producto': producto,
        'kilos': kilos,
        'precio_unitario': precioUnitario,
        'total': total,
      };

  factory VentaModelo.fromJson(Map<String, dynamic> map) => VentaModelo(
        id: map['id'] as String,
        cuadreId: map['cuadre_id'] as String,
        lugar: map['lugar'] as String,
        producto: map['producto'] as String,
        kilos: (map['kilos'] as num).toDouble(),
        precioUnitario: (map['precio_unitario'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
      );

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

class CuadreModelo extends CuadreEntidad {
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
    super.compras,
    super.gastos,
    super.ventas,
  });

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
        compras: e.compras.map((c) => CompraModelo.fromEntidad(c)).toList(),
        gastos: e.gastos.map((g) => GastoModelo.fromEntidad(g)).toList(),
        ventas: e.ventas.map((v) => VentaModelo.fromEntidad(v)).toList(),
      );

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
        pesoTotal: map['peso_total'] != null ? (map['peso_total'] as num).toDouble() : null,
        cajasLlenas: map['cajas_llenas'] as int?,
        cajasVacias: map['cajas_vacias'] as int?,
        tipoProducto: map['tipo_producto'] as int?,
        muellePartida: map['planta_destino'] as String?,
        pesador: map['pesador'] as String?,
      );

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
      };

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
        pesoTotal: map['peso_total'] != null ? (map['peso_total'] as num).toDouble() : null,
        cajasLlenas: map['cajas_llenas'] as int?,
        cajasVacias: map['cajas_vacias'] as int?,
        tipoProducto: map['tipo_producto'] as int?,
        muellePartida: map['planta_destino'] as String?,
        pesador: map['pesador'] as String?,
      );

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
      };
}
