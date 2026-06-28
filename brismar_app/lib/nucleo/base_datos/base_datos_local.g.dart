// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_datos_local.dart';

// ignore_for_file: type=lint
class $CuadresTable extends Cuadres with TableInfo<$CuadresTable, Cuadre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuadresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placaMeta = const VerificationMeta('placa');
  @override
  late final GeneratedColumn<String> placa = GeneratedColumn<String>(
    'placa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaZarpeMeta = const VerificationMeta(
    'fechaZarpe',
  );
  @override
  late final GeneratedColumn<String> fechaZarpe = GeneratedColumn<String>(
    'fecha_zarpe',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaCuadreMeta = const VerificationMeta(
    'fechaCuadre',
  );
  @override
  late final GeneratedColumn<String> fechaCuadre = GeneratedColumn<String>(
    'fecha_cuadre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('borrador'),
  );
  static const VerificationMeta _urlPdfCloudMeta = const VerificationMeta(
    'urlPdfCloud',
  );
  @override
  late final GeneratedColumn<String> urlPdfCloud = GeneratedColumn<String>(
    'url_pdf_cloud',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlExcelCloudMeta = const VerificationMeta(
    'urlExcelCloud',
  );
  @override
  late final GeneratedColumn<String> urlExcelCloud = GeneratedColumn<String>(
    'url_excel_cloud',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sincronizadoMeta = const VerificationMeta(
    'sincronizado',
  );
  @override
  late final GeneratedColumn<int> sincronizado = GeneratedColumn<int>(
    'sincronizado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fotoZarpeUrlMeta = const VerificationMeta(
    'fotoZarpeUrl',
  );
  @override
  late final GeneratedColumn<String> fotoZarpeUrl = GeneratedColumn<String>(
    'foto_zarpe_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pesoTotalMeta = const VerificationMeta(
    'pesoTotal',
  );
  @override
  late final GeneratedColumn<double> pesoTotal = GeneratedColumn<double>(
    'peso_total',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cajasLlenasMeta = const VerificationMeta(
    'cajasLlenas',
  );
  @override
  late final GeneratedColumn<int> cajasLlenas = GeneratedColumn<int>(
    'cajas_llenas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cajasVaciasMeta = const VerificationMeta(
    'cajasVacias',
  );
  @override
  late final GeneratedColumn<int> cajasVacias = GeneratedColumn<int>(
    'cajas_vacias',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoProductoMeta = const VerificationMeta(
    'tipoProducto',
  );
  @override
  late final GeneratedColumn<int> tipoProducto = GeneratedColumn<int>(
    'tipo_producto',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plantaDestinoMeta = const VerificationMeta(
    'plantaDestino',
  );
  @override
  late final GeneratedColumn<String> plantaDestino = GeneratedColumn<String>(
    'planta_destino',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    usuarioId,
    placa,
    fechaZarpe,
    fechaCuadre,
    estado,
    urlPdfCloud,
    urlExcelCloud,
    sincronizado,
    fotoZarpeUrl,
    pesoTotal,
    cajasLlenas,
    cajasVacias,
    tipoProducto,
    plantaDestino,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cuadres';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cuadre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('placa')) {
      context.handle(
        _placaMeta,
        placa.isAcceptableOrUnknown(data['placa']!, _placaMeta),
      );
    } else if (isInserting) {
      context.missing(_placaMeta);
    }
    if (data.containsKey('fecha_zarpe')) {
      context.handle(
        _fechaZarpeMeta,
        fechaZarpe.isAcceptableOrUnknown(data['fecha_zarpe']!, _fechaZarpeMeta),
      );
    }
    if (data.containsKey('fecha_cuadre')) {
      context.handle(
        _fechaCuadreMeta,
        fechaCuadre.isAcceptableOrUnknown(
          data['fecha_cuadre']!,
          _fechaCuadreMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('url_pdf_cloud')) {
      context.handle(
        _urlPdfCloudMeta,
        urlPdfCloud.isAcceptableOrUnknown(
          data['url_pdf_cloud']!,
          _urlPdfCloudMeta,
        ),
      );
    }
    if (data.containsKey('url_excel_cloud')) {
      context.handle(
        _urlExcelCloudMeta,
        urlExcelCloud.isAcceptableOrUnknown(
          data['url_excel_cloud']!,
          _urlExcelCloudMeta,
        ),
      );
    }
    if (data.containsKey('sincronizado')) {
      context.handle(
        _sincronizadoMeta,
        sincronizado.isAcceptableOrUnknown(
          data['sincronizado']!,
          _sincronizadoMeta,
        ),
      );
    }
    if (data.containsKey('foto_zarpe_url')) {
      context.handle(
        _fotoZarpeUrlMeta,
        fotoZarpeUrl.isAcceptableOrUnknown(
          data['foto_zarpe_url']!,
          _fotoZarpeUrlMeta,
        ),
      );
    }
    if (data.containsKey('peso_total')) {
      context.handle(
        _pesoTotalMeta,
        pesoTotal.isAcceptableOrUnknown(data['peso_total']!, _pesoTotalMeta),
      );
    }
    if (data.containsKey('cajas_llenas')) {
      context.handle(
        _cajasLlenasMeta,
        cajasLlenas.isAcceptableOrUnknown(
          data['cajas_llenas']!,
          _cajasLlenasMeta,
        ),
      );
    }
    if (data.containsKey('cajas_vacias')) {
      context.handle(
        _cajasVaciasMeta,
        cajasVacias.isAcceptableOrUnknown(
          data['cajas_vacias']!,
          _cajasVaciasMeta,
        ),
      );
    }
    if (data.containsKey('tipo_producto')) {
      context.handle(
        _tipoProductoMeta,
        tipoProducto.isAcceptableOrUnknown(
          data['tipo_producto']!,
          _tipoProductoMeta,
        ),
      );
    }
    if (data.containsKey('planta_destino')) {
      context.handle(
        _plantaDestinoMeta,
        plantaDestino.isAcceptableOrUnknown(
          data['planta_destino']!,
          _plantaDestinoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cuadre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cuadre(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      placa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}placa'],
      )!,
      fechaZarpe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_zarpe'],
      ),
      fechaCuadre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_cuadre'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      urlPdfCloud: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_pdf_cloud'],
      ),
      urlExcelCloud: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_excel_cloud'],
      ),
      sincronizado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sincronizado'],
      )!,
      fotoZarpeUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_zarpe_url'],
      ),
      pesoTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_total'],
      ),
      cajasLlenas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cajas_llenas'],
      ),
      cajasVacias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cajas_vacias'],
      ),
      tipoProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tipo_producto'],
      ),
      plantaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planta_destino'],
      ),
    );
  }

  @override
  $CuadresTable createAlias(String alias) {
    return $CuadresTable(attachedDatabase, alias);
  }
}

class Cuadre extends DataClass implements Insertable<Cuadre> {
  final String id;
  final String usuarioId;
  final String placa;
  final String? fechaZarpe;
  final String? fechaCuadre;
  final String estado;
  final String? urlPdfCloud;
  final String? urlExcelCloud;
  final int sincronizado;
  final String? fotoZarpeUrl;
  final double? pesoTotal;
  final int? cajasLlenas;
  final int? cajasVacias;
  final int? tipoProducto;
  final String? plantaDestino;
  const Cuadre({
    required this.id,
    required this.usuarioId,
    required this.placa,
    this.fechaZarpe,
    this.fechaCuadre,
    required this.estado,
    this.urlPdfCloud,
    this.urlExcelCloud,
    required this.sincronizado,
    this.fotoZarpeUrl,
    this.pesoTotal,
    this.cajasLlenas,
    this.cajasVacias,
    this.tipoProducto,
    this.plantaDestino,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['placa'] = Variable<String>(placa);
    if (!nullToAbsent || fechaZarpe != null) {
      map['fecha_zarpe'] = Variable<String>(fechaZarpe);
    }
    if (!nullToAbsent || fechaCuadre != null) {
      map['fecha_cuadre'] = Variable<String>(fechaCuadre);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || urlPdfCloud != null) {
      map['url_pdf_cloud'] = Variable<String>(urlPdfCloud);
    }
    if (!nullToAbsent || urlExcelCloud != null) {
      map['url_excel_cloud'] = Variable<String>(urlExcelCloud);
    }
    map['sincronizado'] = Variable<int>(sincronizado);
    if (!nullToAbsent || fotoZarpeUrl != null) {
      map['foto_zarpe_url'] = Variable<String>(fotoZarpeUrl);
    }
    if (!nullToAbsent || pesoTotal != null) {
      map['peso_total'] = Variable<double>(pesoTotal);
    }
    if (!nullToAbsent || cajasLlenas != null) {
      map['cajas_llenas'] = Variable<int>(cajasLlenas);
    }
    if (!nullToAbsent || cajasVacias != null) {
      map['cajas_vacias'] = Variable<int>(cajasVacias);
    }
    if (!nullToAbsent || tipoProducto != null) {
      map['tipo_producto'] = Variable<int>(tipoProducto);
    }
    if (!nullToAbsent || plantaDestino != null) {
      map['planta_destino'] = Variable<String>(plantaDestino);
    }
    return map;
  }

  CuadresCompanion toCompanion(bool nullToAbsent) {
    return CuadresCompanion(
      id: Value(id),
      usuarioId: Value(usuarioId),
      placa: Value(placa),
      fechaZarpe: fechaZarpe == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaZarpe),
      fechaCuadre: fechaCuadre == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCuadre),
      estado: Value(estado),
      urlPdfCloud: urlPdfCloud == null && nullToAbsent
          ? const Value.absent()
          : Value(urlPdfCloud),
      urlExcelCloud: urlExcelCloud == null && nullToAbsent
          ? const Value.absent()
          : Value(urlExcelCloud),
      sincronizado: Value(sincronizado),
      fotoZarpeUrl: fotoZarpeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoZarpeUrl),
      pesoTotal: pesoTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(pesoTotal),
      cajasLlenas: cajasLlenas == null && nullToAbsent
          ? const Value.absent()
          : Value(cajasLlenas),
      cajasVacias: cajasVacias == null && nullToAbsent
          ? const Value.absent()
          : Value(cajasVacias),
      tipoProducto: tipoProducto == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoProducto),
      plantaDestino: plantaDestino == null && nullToAbsent
          ? const Value.absent()
          : Value(plantaDestino),
    );
  }

  factory Cuadre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cuadre(
      id: serializer.fromJson<String>(json['id']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      placa: serializer.fromJson<String>(json['placa']),
      fechaZarpe: serializer.fromJson<String?>(json['fechaZarpe']),
      fechaCuadre: serializer.fromJson<String?>(json['fechaCuadre']),
      estado: serializer.fromJson<String>(json['estado']),
      urlPdfCloud: serializer.fromJson<String?>(json['urlPdfCloud']),
      urlExcelCloud: serializer.fromJson<String?>(json['urlExcelCloud']),
      sincronizado: serializer.fromJson<int>(json['sincronizado']),
      fotoZarpeUrl: serializer.fromJson<String?>(json['fotoZarpeUrl']),
      pesoTotal: serializer.fromJson<double?>(json['pesoTotal']),
      cajasLlenas: serializer.fromJson<int?>(json['cajasLlenas']),
      cajasVacias: serializer.fromJson<int?>(json['cajasVacias']),
      tipoProducto: serializer.fromJson<int?>(json['tipoProducto']),
      plantaDestino: serializer.fromJson<String?>(json['plantaDestino']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'placa': serializer.toJson<String>(placa),
      'fechaZarpe': serializer.toJson<String?>(fechaZarpe),
      'fechaCuadre': serializer.toJson<String?>(fechaCuadre),
      'estado': serializer.toJson<String>(estado),
      'urlPdfCloud': serializer.toJson<String?>(urlPdfCloud),
      'urlExcelCloud': serializer.toJson<String?>(urlExcelCloud),
      'sincronizado': serializer.toJson<int>(sincronizado),
      'fotoZarpeUrl': serializer.toJson<String?>(fotoZarpeUrl),
      'pesoTotal': serializer.toJson<double?>(pesoTotal),
      'cajasLlenas': serializer.toJson<int?>(cajasLlenas),
      'cajasVacias': serializer.toJson<int?>(cajasVacias),
      'tipoProducto': serializer.toJson<int?>(tipoProducto),
      'plantaDestino': serializer.toJson<String?>(plantaDestino),
    };
  }

  Cuadre copyWith({
    String? id,
    String? usuarioId,
    String? placa,
    Value<String?> fechaZarpe = const Value.absent(),
    Value<String?> fechaCuadre = const Value.absent(),
    String? estado,
    Value<String?> urlPdfCloud = const Value.absent(),
    Value<String?> urlExcelCloud = const Value.absent(),
    int? sincronizado,
    Value<String?> fotoZarpeUrl = const Value.absent(),
    Value<double?> pesoTotal = const Value.absent(),
    Value<int?> cajasLlenas = const Value.absent(),
    Value<int?> cajasVacias = const Value.absent(),
    Value<int?> tipoProducto = const Value.absent(),
    Value<String?> plantaDestino = const Value.absent(),
  }) => Cuadre(
    id: id ?? this.id,
    usuarioId: usuarioId ?? this.usuarioId,
    placa: placa ?? this.placa,
    fechaZarpe: fechaZarpe.present ? fechaZarpe.value : this.fechaZarpe,
    fechaCuadre: fechaCuadre.present ? fechaCuadre.value : this.fechaCuadre,
    estado: estado ?? this.estado,
    urlPdfCloud: urlPdfCloud.present ? urlPdfCloud.value : this.urlPdfCloud,
    urlExcelCloud: urlExcelCloud.present
        ? urlExcelCloud.value
        : this.urlExcelCloud,
    sincronizado: sincronizado ?? this.sincronizado,
    fotoZarpeUrl: fotoZarpeUrl.present ? fotoZarpeUrl.value : this.fotoZarpeUrl,
    pesoTotal: pesoTotal.present ? pesoTotal.value : this.pesoTotal,
    cajasLlenas: cajasLlenas.present ? cajasLlenas.value : this.cajasLlenas,
    cajasVacias: cajasVacias.present ? cajasVacias.value : this.cajasVacias,
    tipoProducto: tipoProducto.present ? tipoProducto.value : this.tipoProducto,
    plantaDestino: plantaDestino.present
        ? plantaDestino.value
        : this.plantaDestino,
  );
  Cuadre copyWithCompanion(CuadresCompanion data) {
    return Cuadre(
      id: data.id.present ? data.id.value : this.id,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      placa: data.placa.present ? data.placa.value : this.placa,
      fechaZarpe: data.fechaZarpe.present
          ? data.fechaZarpe.value
          : this.fechaZarpe,
      fechaCuadre: data.fechaCuadre.present
          ? data.fechaCuadre.value
          : this.fechaCuadre,
      estado: data.estado.present ? data.estado.value : this.estado,
      urlPdfCloud: data.urlPdfCloud.present
          ? data.urlPdfCloud.value
          : this.urlPdfCloud,
      urlExcelCloud: data.urlExcelCloud.present
          ? data.urlExcelCloud.value
          : this.urlExcelCloud,
      sincronizado: data.sincronizado.present
          ? data.sincronizado.value
          : this.sincronizado,
      fotoZarpeUrl: data.fotoZarpeUrl.present
          ? data.fotoZarpeUrl.value
          : this.fotoZarpeUrl,
      pesoTotal: data.pesoTotal.present ? data.pesoTotal.value : this.pesoTotal,
      cajasLlenas: data.cajasLlenas.present
          ? data.cajasLlenas.value
          : this.cajasLlenas,
      cajasVacias: data.cajasVacias.present
          ? data.cajasVacias.value
          : this.cajasVacias,
      tipoProducto: data.tipoProducto.present
          ? data.tipoProducto.value
          : this.tipoProducto,
      plantaDestino: data.plantaDestino.present
          ? data.plantaDestino.value
          : this.plantaDestino,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cuadre(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('placa: $placa, ')
          ..write('fechaZarpe: $fechaZarpe, ')
          ..write('fechaCuadre: $fechaCuadre, ')
          ..write('estado: $estado, ')
          ..write('urlPdfCloud: $urlPdfCloud, ')
          ..write('urlExcelCloud: $urlExcelCloud, ')
          ..write('sincronizado: $sincronizado, ')
          ..write('fotoZarpeUrl: $fotoZarpeUrl, ')
          ..write('pesoTotal: $pesoTotal, ')
          ..write('cajasLlenas: $cajasLlenas, ')
          ..write('cajasVacias: $cajasVacias, ')
          ..write('tipoProducto: $tipoProducto, ')
          ..write('plantaDestino: $plantaDestino')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    usuarioId,
    placa,
    fechaZarpe,
    fechaCuadre,
    estado,
    urlPdfCloud,
    urlExcelCloud,
    sincronizado,
    fotoZarpeUrl,
    pesoTotal,
    cajasLlenas,
    cajasVacias,
    tipoProducto,
    plantaDestino,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cuadre &&
          other.id == this.id &&
          other.usuarioId == this.usuarioId &&
          other.placa == this.placa &&
          other.fechaZarpe == this.fechaZarpe &&
          other.fechaCuadre == this.fechaCuadre &&
          other.estado == this.estado &&
          other.urlPdfCloud == this.urlPdfCloud &&
          other.urlExcelCloud == this.urlExcelCloud &&
          other.sincronizado == this.sincronizado &&
          other.fotoZarpeUrl == this.fotoZarpeUrl &&
          other.pesoTotal == this.pesoTotal &&
          other.cajasLlenas == this.cajasLlenas &&
          other.cajasVacias == this.cajasVacias &&
          other.tipoProducto == this.tipoProducto &&
          other.plantaDestino == this.plantaDestino);
}

class CuadresCompanion extends UpdateCompanion<Cuadre> {
  final Value<String> id;
  final Value<String> usuarioId;
  final Value<String> placa;
  final Value<String?> fechaZarpe;
  final Value<String?> fechaCuadre;
  final Value<String> estado;
  final Value<String?> urlPdfCloud;
  final Value<String?> urlExcelCloud;
  final Value<int> sincronizado;
  final Value<String?> fotoZarpeUrl;
  final Value<double?> pesoTotal;
  final Value<int?> cajasLlenas;
  final Value<int?> cajasVacias;
  final Value<int?> tipoProducto;
  final Value<String?> plantaDestino;
  final Value<int> rowid;
  const CuadresCompanion({
    this.id = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.placa = const Value.absent(),
    this.fechaZarpe = const Value.absent(),
    this.fechaCuadre = const Value.absent(),
    this.estado = const Value.absent(),
    this.urlPdfCloud = const Value.absent(),
    this.urlExcelCloud = const Value.absent(),
    this.sincronizado = const Value.absent(),
    this.fotoZarpeUrl = const Value.absent(),
    this.pesoTotal = const Value.absent(),
    this.cajasLlenas = const Value.absent(),
    this.cajasVacias = const Value.absent(),
    this.tipoProducto = const Value.absent(),
    this.plantaDestino = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CuadresCompanion.insert({
    required String id,
    required String usuarioId,
    required String placa,
    this.fechaZarpe = const Value.absent(),
    this.fechaCuadre = const Value.absent(),
    this.estado = const Value.absent(),
    this.urlPdfCloud = const Value.absent(),
    this.urlExcelCloud = const Value.absent(),
    this.sincronizado = const Value.absent(),
    this.fotoZarpeUrl = const Value.absent(),
    this.pesoTotal = const Value.absent(),
    this.cajasLlenas = const Value.absent(),
    this.cajasVacias = const Value.absent(),
    this.tipoProducto = const Value.absent(),
    this.plantaDestino = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       usuarioId = Value(usuarioId),
       placa = Value(placa);
  static Insertable<Cuadre> custom({
    Expression<String>? id,
    Expression<String>? usuarioId,
    Expression<String>? placa,
    Expression<String>? fechaZarpe,
    Expression<String>? fechaCuadre,
    Expression<String>? estado,
    Expression<String>? urlPdfCloud,
    Expression<String>? urlExcelCloud,
    Expression<int>? sincronizado,
    Expression<String>? fotoZarpeUrl,
    Expression<double>? pesoTotal,
    Expression<int>? cajasLlenas,
    Expression<int>? cajasVacias,
    Expression<int>? tipoProducto,
    Expression<String>? plantaDestino,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (placa != null) 'placa': placa,
      if (fechaZarpe != null) 'fecha_zarpe': fechaZarpe,
      if (fechaCuadre != null) 'fecha_cuadre': fechaCuadre,
      if (estado != null) 'estado': estado,
      if (urlPdfCloud != null) 'url_pdf_cloud': urlPdfCloud,
      if (urlExcelCloud != null) 'url_excel_cloud': urlExcelCloud,
      if (sincronizado != null) 'sincronizado': sincronizado,
      if (fotoZarpeUrl != null) 'foto_zarpe_url': fotoZarpeUrl,
      if (pesoTotal != null) 'peso_total': pesoTotal,
      if (cajasLlenas != null) 'cajas_llenas': cajasLlenas,
      if (cajasVacias != null) 'cajas_vacias': cajasVacias,
      if (tipoProducto != null) 'tipo_producto': tipoProducto,
      if (plantaDestino != null) 'planta_destino': plantaDestino,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CuadresCompanion copyWith({
    Value<String>? id,
    Value<String>? usuarioId,
    Value<String>? placa,
    Value<String?>? fechaZarpe,
    Value<String?>? fechaCuadre,
    Value<String>? estado,
    Value<String?>? urlPdfCloud,
    Value<String?>? urlExcelCloud,
    Value<int>? sincronizado,
    Value<String?>? fotoZarpeUrl,
    Value<double?>? pesoTotal,
    Value<int?>? cajasLlenas,
    Value<int?>? cajasVacias,
    Value<int?>? tipoProducto,
    Value<String?>? plantaDestino,
    Value<int>? rowid,
  }) {
    return CuadresCompanion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      placa: placa ?? this.placa,
      fechaZarpe: fechaZarpe ?? this.fechaZarpe,
      fechaCuadre: fechaCuadre ?? this.fechaCuadre,
      estado: estado ?? this.estado,
      urlPdfCloud: urlPdfCloud ?? this.urlPdfCloud,
      urlExcelCloud: urlExcelCloud ?? this.urlExcelCloud,
      sincronizado: sincronizado ?? this.sincronizado,
      fotoZarpeUrl: fotoZarpeUrl ?? this.fotoZarpeUrl,
      pesoTotal: pesoTotal ?? this.pesoTotal,
      cajasLlenas: cajasLlenas ?? this.cajasLlenas,
      cajasVacias: cajasVacias ?? this.cajasVacias,
      tipoProducto: tipoProducto ?? this.tipoProducto,
      plantaDestino: plantaDestino ?? this.plantaDestino,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (placa.present) {
      map['placa'] = Variable<String>(placa.value);
    }
    if (fechaZarpe.present) {
      map['fecha_zarpe'] = Variable<String>(fechaZarpe.value);
    }
    if (fechaCuadre.present) {
      map['fecha_cuadre'] = Variable<String>(fechaCuadre.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (urlPdfCloud.present) {
      map['url_pdf_cloud'] = Variable<String>(urlPdfCloud.value);
    }
    if (urlExcelCloud.present) {
      map['url_excel_cloud'] = Variable<String>(urlExcelCloud.value);
    }
    if (sincronizado.present) {
      map['sincronizado'] = Variable<int>(sincronizado.value);
    }
    if (fotoZarpeUrl.present) {
      map['foto_zarpe_url'] = Variable<String>(fotoZarpeUrl.value);
    }
    if (pesoTotal.present) {
      map['peso_total'] = Variable<double>(pesoTotal.value);
    }
    if (cajasLlenas.present) {
      map['cajas_llenas'] = Variable<int>(cajasLlenas.value);
    }
    if (cajasVacias.present) {
      map['cajas_vacias'] = Variable<int>(cajasVacias.value);
    }
    if (tipoProducto.present) {
      map['tipo_producto'] = Variable<int>(tipoProducto.value);
    }
    if (plantaDestino.present) {
      map['planta_destino'] = Variable<String>(plantaDestino.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuadresCompanion(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('placa: $placa, ')
          ..write('fechaZarpe: $fechaZarpe, ')
          ..write('fechaCuadre: $fechaCuadre, ')
          ..write('estado: $estado, ')
          ..write('urlPdfCloud: $urlPdfCloud, ')
          ..write('urlExcelCloud: $urlExcelCloud, ')
          ..write('sincronizado: $sincronizado, ')
          ..write('fotoZarpeUrl: $fotoZarpeUrl, ')
          ..write('pesoTotal: $pesoTotal, ')
          ..write('cajasLlenas: $cajasLlenas, ')
          ..write('cajasVacias: $cajasVacias, ')
          ..write('tipoProducto: $tipoProducto, ')
          ..write('plantaDestino: $plantaDestino, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComprasTable extends Compras with TableInfo<$ComprasTable, Compra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuadreIdMeta = const VerificationMeta(
    'cuadreId',
  );
  @override
  late final GeneratedColumn<String> cuadreId = GeneratedColumn<String>(
    'cuadre_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cuadres (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _embarcacionMeta = const VerificationMeta(
    'embarcacion',
  );
  @override
  late final GeneratedColumn<String> embarcacion = GeneratedColumn<String>(
    'embarcacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kilosMeta = const VerificationMeta('kilos');
  @override
  late final GeneratedColumn<double> kilos = GeneratedColumn<double>(
    'kilos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cuadreId,
    embarcacion,
    producto,
    kilos,
    precioUnitario,
    total,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras';
  @override
  VerificationContext validateIntegrity(
    Insertable<Compra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cuadre_id')) {
      context.handle(
        _cuadreIdMeta,
        cuadreId.isAcceptableOrUnknown(data['cuadre_id']!, _cuadreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuadreIdMeta);
    }
    if (data.containsKey('embarcacion')) {
      context.handle(
        _embarcacionMeta,
        embarcacion.isAcceptableOrUnknown(
          data['embarcacion']!,
          _embarcacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_embarcacionMeta);
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    } else if (isInserting) {
      context.missing(_productoMeta);
    }
    if (data.containsKey('kilos')) {
      context.handle(
        _kilosMeta,
        kilos.isAcceptableOrUnknown(data['kilos']!, _kilosMeta),
      );
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Compra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Compra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cuadreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuadre_id'],
      )!,
      embarcacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embarcacion'],
      )!,
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      )!,
      kilos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kilos'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
    );
  }

  @override
  $ComprasTable createAlias(String alias) {
    return $ComprasTable(attachedDatabase, alias);
  }
}

class Compra extends DataClass implements Insertable<Compra> {
  final String id;
  final String cuadreId;
  final String embarcacion;
  final String producto;
  final double kilos;
  final double precioUnitario;
  final double total;
  const Compra({
    required this.id,
    required this.cuadreId,
    required this.embarcacion,
    required this.producto,
    required this.kilos,
    required this.precioUnitario,
    required this.total,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cuadre_id'] = Variable<String>(cuadreId);
    map['embarcacion'] = Variable<String>(embarcacion);
    map['producto'] = Variable<String>(producto);
    map['kilos'] = Variable<double>(kilos);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['total'] = Variable<double>(total);
    return map;
  }

  ComprasCompanion toCompanion(bool nullToAbsent) {
    return ComprasCompanion(
      id: Value(id),
      cuadreId: Value(cuadreId),
      embarcacion: Value(embarcacion),
      producto: Value(producto),
      kilos: Value(kilos),
      precioUnitario: Value(precioUnitario),
      total: Value(total),
    );
  }

  factory Compra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Compra(
      id: serializer.fromJson<String>(json['id']),
      cuadreId: serializer.fromJson<String>(json['cuadreId']),
      embarcacion: serializer.fromJson<String>(json['embarcacion']),
      producto: serializer.fromJson<String>(json['producto']),
      kilos: serializer.fromJson<double>(json['kilos']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cuadreId': serializer.toJson<String>(cuadreId),
      'embarcacion': serializer.toJson<String>(embarcacion),
      'producto': serializer.toJson<String>(producto),
      'kilos': serializer.toJson<double>(kilos),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'total': serializer.toJson<double>(total),
    };
  }

  Compra copyWith({
    String? id,
    String? cuadreId,
    String? embarcacion,
    String? producto,
    double? kilos,
    double? precioUnitario,
    double? total,
  }) => Compra(
    id: id ?? this.id,
    cuadreId: cuadreId ?? this.cuadreId,
    embarcacion: embarcacion ?? this.embarcacion,
    producto: producto ?? this.producto,
    kilos: kilos ?? this.kilos,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    total: total ?? this.total,
  );
  Compra copyWithCompanion(ComprasCompanion data) {
    return Compra(
      id: data.id.present ? data.id.value : this.id,
      cuadreId: data.cuadreId.present ? data.cuadreId.value : this.cuadreId,
      embarcacion: data.embarcacion.present
          ? data.embarcacion.value
          : this.embarcacion,
      producto: data.producto.present ? data.producto.value : this.producto,
      kilos: data.kilos.present ? data.kilos.value : this.kilos,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Compra(')
          ..write('id: $id, ')
          ..write('cuadreId: $cuadreId, ')
          ..write('embarcacion: $embarcacion, ')
          ..write('producto: $producto, ')
          ..write('kilos: $kilos, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cuadreId,
    embarcacion,
    producto,
    kilos,
    precioUnitario,
    total,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Compra &&
          other.id == this.id &&
          other.cuadreId == this.cuadreId &&
          other.embarcacion == this.embarcacion &&
          other.producto == this.producto &&
          other.kilos == this.kilos &&
          other.precioUnitario == this.precioUnitario &&
          other.total == this.total);
}

class ComprasCompanion extends UpdateCompanion<Compra> {
  final Value<String> id;
  final Value<String> cuadreId;
  final Value<String> embarcacion;
  final Value<String> producto;
  final Value<double> kilos;
  final Value<double> precioUnitario;
  final Value<double> total;
  final Value<int> rowid;
  const ComprasCompanion({
    this.id = const Value.absent(),
    this.cuadreId = const Value.absent(),
    this.embarcacion = const Value.absent(),
    this.producto = const Value.absent(),
    this.kilos = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComprasCompanion.insert({
    required String id,
    required String cuadreId,
    required String embarcacion,
    required String producto,
    this.kilos = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cuadreId = Value(cuadreId),
       embarcacion = Value(embarcacion),
       producto = Value(producto);
  static Insertable<Compra> custom({
    Expression<String>? id,
    Expression<String>? cuadreId,
    Expression<String>? embarcacion,
    Expression<String>? producto,
    Expression<double>? kilos,
    Expression<double>? precioUnitario,
    Expression<double>? total,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cuadreId != null) 'cuadre_id': cuadreId,
      if (embarcacion != null) 'embarcacion': embarcacion,
      if (producto != null) 'producto': producto,
      if (kilos != null) 'kilos': kilos,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (total != null) 'total': total,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComprasCompanion copyWith({
    Value<String>? id,
    Value<String>? cuadreId,
    Value<String>? embarcacion,
    Value<String>? producto,
    Value<double>? kilos,
    Value<double>? precioUnitario,
    Value<double>? total,
    Value<int>? rowid,
  }) {
    return ComprasCompanion(
      id: id ?? this.id,
      cuadreId: cuadreId ?? this.cuadreId,
      embarcacion: embarcacion ?? this.embarcacion,
      producto: producto ?? this.producto,
      kilos: kilos ?? this.kilos,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      total: total ?? this.total,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cuadreId.present) {
      map['cuadre_id'] = Variable<String>(cuadreId.value);
    }
    if (embarcacion.present) {
      map['embarcacion'] = Variable<String>(embarcacion.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (kilos.present) {
      map['kilos'] = Variable<double>(kilos.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasCompanion(')
          ..write('id: $id, ')
          ..write('cuadreId: $cuadreId, ')
          ..write('embarcacion: $embarcacion, ')
          ..write('producto: $producto, ')
          ..write('kilos: $kilos, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('total: $total, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GastosTable extends Gastos with TableInfo<$GastosTable, Gasto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuadreIdMeta = const VerificationMeta(
    'cuadreId',
  );
  @override
  late final GeneratedColumn<String> cuadreId = GeneratedColumn<String>(
    'cuadre_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cuadres (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _costoUnitarioMeta = const VerificationMeta(
    'costoUnitario',
  );
  @override
  late final GeneratedColumn<double> costoUnitario = GeneratedColumn<double>(
    'costo_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cuadreId,
    tipo,
    concepto,
    cantidad,
    costoUnitario,
    total,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gasto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cuadre_id')) {
      context.handle(
        _cuadreIdMeta,
        cuadreId.isAcceptableOrUnknown(data['cuadre_id']!, _cuadreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuadreIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
        _costoUnitarioMeta,
        costoUnitario.isAcceptableOrUnknown(
          data['costo_unitario']!,
          _costoUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gasto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gasto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cuadreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuadre_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      costoUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_unitario'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
    );
  }

  @override
  $GastosTable createAlias(String alias) {
    return $GastosTable(attachedDatabase, alias);
  }
}

class Gasto extends DataClass implements Insertable<Gasto> {
  final String id;
  final String cuadreId;
  final String tipo;
  final String concepto;
  final double cantidad;
  final double costoUnitario;
  final double total;
  const Gasto({
    required this.id,
    required this.cuadreId,
    required this.tipo,
    required this.concepto,
    required this.cantidad,
    required this.costoUnitario,
    required this.total,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cuadre_id'] = Variable<String>(cuadreId);
    map['tipo'] = Variable<String>(tipo);
    map['concepto'] = Variable<String>(concepto);
    map['cantidad'] = Variable<double>(cantidad);
    map['costo_unitario'] = Variable<double>(costoUnitario);
    map['total'] = Variable<double>(total);
    return map;
  }

  GastosCompanion toCompanion(bool nullToAbsent) {
    return GastosCompanion(
      id: Value(id),
      cuadreId: Value(cuadreId),
      tipo: Value(tipo),
      concepto: Value(concepto),
      cantidad: Value(cantidad),
      costoUnitario: Value(costoUnitario),
      total: Value(total),
    );
  }

  factory Gasto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gasto(
      id: serializer.fromJson<String>(json['id']),
      cuadreId: serializer.fromJson<String>(json['cuadreId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      concepto: serializer.fromJson<String>(json['concepto']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      costoUnitario: serializer.fromJson<double>(json['costoUnitario']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cuadreId': serializer.toJson<String>(cuadreId),
      'tipo': serializer.toJson<String>(tipo),
      'concepto': serializer.toJson<String>(concepto),
      'cantidad': serializer.toJson<double>(cantidad),
      'costoUnitario': serializer.toJson<double>(costoUnitario),
      'total': serializer.toJson<double>(total),
    };
  }

  Gasto copyWith({
    String? id,
    String? cuadreId,
    String? tipo,
    String? concepto,
    double? cantidad,
    double? costoUnitario,
    double? total,
  }) => Gasto(
    id: id ?? this.id,
    cuadreId: cuadreId ?? this.cuadreId,
    tipo: tipo ?? this.tipo,
    concepto: concepto ?? this.concepto,
    cantidad: cantidad ?? this.cantidad,
    costoUnitario: costoUnitario ?? this.costoUnitario,
    total: total ?? this.total,
  );
  Gasto copyWithCompanion(GastosCompanion data) {
    return Gasto(
      id: data.id.present ? data.id.value : this.id,
      cuadreId: data.cuadreId.present ? data.cuadreId.value : this.cuadreId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gasto(')
          ..write('id: $id, ')
          ..write('cuadreId: $cuadreId, ')
          ..write('tipo: $tipo, ')
          ..write('concepto: $concepto, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cuadreId, tipo, concepto, cantidad, costoUnitario, total);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gasto &&
          other.id == this.id &&
          other.cuadreId == this.cuadreId &&
          other.tipo == this.tipo &&
          other.concepto == this.concepto &&
          other.cantidad == this.cantidad &&
          other.costoUnitario == this.costoUnitario &&
          other.total == this.total);
}

class GastosCompanion extends UpdateCompanion<Gasto> {
  final Value<String> id;
  final Value<String> cuadreId;
  final Value<String> tipo;
  final Value<String> concepto;
  final Value<double> cantidad;
  final Value<double> costoUnitario;
  final Value<double> total;
  final Value<int> rowid;
  const GastosCompanion({
    this.id = const Value.absent(),
    this.cuadreId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.concepto = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GastosCompanion.insert({
    required String id,
    required String cuadreId,
    required String tipo,
    required String concepto,
    this.cantidad = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cuadreId = Value(cuadreId),
       tipo = Value(tipo),
       concepto = Value(concepto);
  static Insertable<Gasto> custom({
    Expression<String>? id,
    Expression<String>? cuadreId,
    Expression<String>? tipo,
    Expression<String>? concepto,
    Expression<double>? cantidad,
    Expression<double>? costoUnitario,
    Expression<double>? total,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cuadreId != null) 'cuadre_id': cuadreId,
      if (tipo != null) 'tipo': tipo,
      if (concepto != null) 'concepto': concepto,
      if (cantidad != null) 'cantidad': cantidad,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (total != null) 'total': total,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GastosCompanion copyWith({
    Value<String>? id,
    Value<String>? cuadreId,
    Value<String>? tipo,
    Value<String>? concepto,
    Value<double>? cantidad,
    Value<double>? costoUnitario,
    Value<double>? total,
    Value<int>? rowid,
  }) {
    return GastosCompanion(
      id: id ?? this.id,
      cuadreId: cuadreId ?? this.cuadreId,
      tipo: tipo ?? this.tipo,
      concepto: concepto ?? this.concepto,
      cantidad: cantidad ?? this.cantidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      total: total ?? this.total,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cuadreId.present) {
      map['cuadre_id'] = Variable<String>(cuadreId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<double>(costoUnitario.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosCompanion(')
          ..write('id: $id, ')
          ..write('cuadreId: $cuadreId, ')
          ..write('tipo: $tipo, ')
          ..write('concepto: $concepto, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('total: $total, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, Venta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuadreIdMeta = const VerificationMeta(
    'cuadreId',
  );
  @override
  late final GeneratedColumn<String> cuadreId = GeneratedColumn<String>(
    'cuadre_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cuadres (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lugarMeta = const VerificationMeta('lugar');
  @override
  late final GeneratedColumn<String> lugar = GeneratedColumn<String>(
    'lugar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kilosMeta = const VerificationMeta('kilos');
  @override
  late final GeneratedColumn<double> kilos = GeneratedColumn<double>(
    'kilos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cuadreId,
    lugar,
    producto,
    kilos,
    precioUnitario,
    total,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Venta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cuadre_id')) {
      context.handle(
        _cuadreIdMeta,
        cuadreId.isAcceptableOrUnknown(data['cuadre_id']!, _cuadreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuadreIdMeta);
    }
    if (data.containsKey('lugar')) {
      context.handle(
        _lugarMeta,
        lugar.isAcceptableOrUnknown(data['lugar']!, _lugarMeta),
      );
    } else if (isInserting) {
      context.missing(_lugarMeta);
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    } else if (isInserting) {
      context.missing(_productoMeta);
    }
    if (data.containsKey('kilos')) {
      context.handle(
        _kilosMeta,
        kilos.isAcceptableOrUnknown(data['kilos']!, _kilosMeta),
      );
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Venta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Venta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cuadreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuadre_id'],
      )!,
      lugar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lugar'],
      )!,
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      )!,
      kilos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kilos'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class Venta extends DataClass implements Insertable<Venta> {
  final String id;
  final String cuadreId;
  final String lugar;
  final String producto;
  final double kilos;
  final double precioUnitario;
  final double total;
  const Venta({
    required this.id,
    required this.cuadreId,
    required this.lugar,
    required this.producto,
    required this.kilos,
    required this.precioUnitario,
    required this.total,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cuadre_id'] = Variable<String>(cuadreId);
    map['lugar'] = Variable<String>(lugar);
    map['producto'] = Variable<String>(producto);
    map['kilos'] = Variable<double>(kilos);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['total'] = Variable<double>(total);
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      cuadreId: Value(cuadreId),
      lugar: Value(lugar),
      producto: Value(producto),
      kilos: Value(kilos),
      precioUnitario: Value(precioUnitario),
      total: Value(total),
    );
  }

  factory Venta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Venta(
      id: serializer.fromJson<String>(json['id']),
      cuadreId: serializer.fromJson<String>(json['cuadreId']),
      lugar: serializer.fromJson<String>(json['lugar']),
      producto: serializer.fromJson<String>(json['producto']),
      kilos: serializer.fromJson<double>(json['kilos']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cuadreId': serializer.toJson<String>(cuadreId),
      'lugar': serializer.toJson<String>(lugar),
      'producto': serializer.toJson<String>(producto),
      'kilos': serializer.toJson<double>(kilos),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'total': serializer.toJson<double>(total),
    };
  }

  Venta copyWith({
    String? id,
    String? cuadreId,
    String? lugar,
    String? producto,
    double? kilos,
    double? precioUnitario,
    double? total,
  }) => Venta(
    id: id ?? this.id,
    cuadreId: cuadreId ?? this.cuadreId,
    lugar: lugar ?? this.lugar,
    producto: producto ?? this.producto,
    kilos: kilos ?? this.kilos,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    total: total ?? this.total,
  );
  Venta copyWithCompanion(VentasCompanion data) {
    return Venta(
      id: data.id.present ? data.id.value : this.id,
      cuadreId: data.cuadreId.present ? data.cuadreId.value : this.cuadreId,
      lugar: data.lugar.present ? data.lugar.value : this.lugar,
      producto: data.producto.present ? data.producto.value : this.producto,
      kilos: data.kilos.present ? data.kilos.value : this.kilos,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Venta(')
          ..write('id: $id, ')
          ..write('cuadreId: $cuadreId, ')
          ..write('lugar: $lugar, ')
          ..write('producto: $producto, ')
          ..write('kilos: $kilos, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cuadreId, lugar, producto, kilos, precioUnitario, total);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Venta &&
          other.id == this.id &&
          other.cuadreId == this.cuadreId &&
          other.lugar == this.lugar &&
          other.producto == this.producto &&
          other.kilos == this.kilos &&
          other.precioUnitario == this.precioUnitario &&
          other.total == this.total);
}

class VentasCompanion extends UpdateCompanion<Venta> {
  final Value<String> id;
  final Value<String> cuadreId;
  final Value<String> lugar;
  final Value<String> producto;
  final Value<double> kilos;
  final Value<double> precioUnitario;
  final Value<double> total;
  final Value<int> rowid;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.cuadreId = const Value.absent(),
    this.lugar = const Value.absent(),
    this.producto = const Value.absent(),
    this.kilos = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentasCompanion.insert({
    required String id,
    required String cuadreId,
    required String lugar,
    required String producto,
    this.kilos = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.total = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cuadreId = Value(cuadreId),
       lugar = Value(lugar),
       producto = Value(producto);
  static Insertable<Venta> custom({
    Expression<String>? id,
    Expression<String>? cuadreId,
    Expression<String>? lugar,
    Expression<String>? producto,
    Expression<double>? kilos,
    Expression<double>? precioUnitario,
    Expression<double>? total,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cuadreId != null) 'cuadre_id': cuadreId,
      if (lugar != null) 'lugar': lugar,
      if (producto != null) 'producto': producto,
      if (kilos != null) 'kilos': kilos,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (total != null) 'total': total,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentasCompanion copyWith({
    Value<String>? id,
    Value<String>? cuadreId,
    Value<String>? lugar,
    Value<String>? producto,
    Value<double>? kilos,
    Value<double>? precioUnitario,
    Value<double>? total,
    Value<int>? rowid,
  }) {
    return VentasCompanion(
      id: id ?? this.id,
      cuadreId: cuadreId ?? this.cuadreId,
      lugar: lugar ?? this.lugar,
      producto: producto ?? this.producto,
      kilos: kilos ?? this.kilos,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      total: total ?? this.total,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cuadreId.present) {
      map['cuadre_id'] = Variable<String>(cuadreId.value);
    }
    if (lugar.present) {
      map['lugar'] = Variable<String>(lugar.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (kilos.present) {
      map['kilos'] = Variable<double>(kilos.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('cuadreId: $cuadreId, ')
          ..write('lugar: $lugar, ')
          ..write('producto: $producto, ')
          ..write('kilos: $kilos, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('total: $total, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZarpesTable extends Zarpes with TableInfo<$ZarpesTable, Zarpe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZarpesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placaCamaraMeta = const VerificationMeta(
    'placaCamara',
  );
  @override
  late final GeneratedColumn<String> placaCamara = GeneratedColumn<String>(
    'placa_camara',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _choferMeta = const VerificationMeta('chofer');
  @override
  late final GeneratedColumn<String> chofer = GeneratedColumn<String>(
    'chofer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muellePartidaMeta = const VerificationMeta(
    'muellePartida',
  );
  @override
  late final GeneratedColumn<String> muellePartida = GeneratedColumn<String>(
    'muelle_partida',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoUrlEvidenciaMeta = const VerificationMeta(
    'fotoUrlEvidencia',
  );
  @override
  late final GeneratedColumn<String> fotoUrlEvidencia = GeneratedColumn<String>(
    'foto_url_evidencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoLocalPathMeta = const VerificationMeta(
    'fotoLocalPath',
  );
  @override
  late final GeneratedColumn<String> fotoLocalPath = GeneratedColumn<String>(
    'foto_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaZarpeMeta = const VerificationMeta(
    'fechaZarpe',
  );
  @override
  late final GeneratedColumn<String> fechaZarpe = GeneratedColumn<String>(
    'fecha_zarpe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendiente'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    placaCamara,
    chofer,
    muellePartida,
    fotoUrlEvidencia,
    fotoLocalPath,
    fechaZarpe,
    estado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zarpes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Zarpe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('placa_camara')) {
      context.handle(
        _placaCamaraMeta,
        placaCamara.isAcceptableOrUnknown(
          data['placa_camara']!,
          _placaCamaraMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placaCamaraMeta);
    }
    if (data.containsKey('chofer')) {
      context.handle(
        _choferMeta,
        chofer.isAcceptableOrUnknown(data['chofer']!, _choferMeta),
      );
    } else if (isInserting) {
      context.missing(_choferMeta);
    }
    if (data.containsKey('muelle_partida')) {
      context.handle(
        _muellePartidaMeta,
        muellePartida.isAcceptableOrUnknown(
          data['muelle_partida']!,
          _muellePartidaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muellePartidaMeta);
    }
    if (data.containsKey('foto_url_evidencia')) {
      context.handle(
        _fotoUrlEvidenciaMeta,
        fotoUrlEvidencia.isAcceptableOrUnknown(
          data['foto_url_evidencia']!,
          _fotoUrlEvidenciaMeta,
        ),
      );
    }
    if (data.containsKey('foto_local_path')) {
      context.handle(
        _fotoLocalPathMeta,
        fotoLocalPath.isAcceptableOrUnknown(
          data['foto_local_path']!,
          _fotoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('fecha_zarpe')) {
      context.handle(
        _fechaZarpeMeta,
        fechaZarpe.isAcceptableOrUnknown(data['fecha_zarpe']!, _fechaZarpeMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaZarpeMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Zarpe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Zarpe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      placaCamara: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}placa_camara'],
      )!,
      chofer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chofer'],
      )!,
      muellePartida: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muelle_partida'],
      )!,
      fotoUrlEvidencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_url_evidencia'],
      ),
      fotoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_local_path'],
      ),
      fechaZarpe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_zarpe'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
    );
  }

  @override
  $ZarpesTable createAlias(String alias) {
    return $ZarpesTable(attachedDatabase, alias);
  }
}

class Zarpe extends DataClass implements Insertable<Zarpe> {
  final String id;
  final String placaCamara;
  final String chofer;
  final String muellePartida;
  final String? fotoUrlEvidencia;
  final String? fotoLocalPath;
  final String fechaZarpe;
  final String estado;
  const Zarpe({
    required this.id,
    required this.placaCamara,
    required this.chofer,
    required this.muellePartida,
    this.fotoUrlEvidencia,
    this.fotoLocalPath,
    required this.fechaZarpe,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['placa_camara'] = Variable<String>(placaCamara);
    map['chofer'] = Variable<String>(chofer);
    map['muelle_partida'] = Variable<String>(muellePartida);
    if (!nullToAbsent || fotoUrlEvidencia != null) {
      map['foto_url_evidencia'] = Variable<String>(fotoUrlEvidencia);
    }
    if (!nullToAbsent || fotoLocalPath != null) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath);
    }
    map['fecha_zarpe'] = Variable<String>(fechaZarpe);
    map['estado'] = Variable<String>(estado);
    return map;
  }

  ZarpesCompanion toCompanion(bool nullToAbsent) {
    return ZarpesCompanion(
      id: Value(id),
      placaCamara: Value(placaCamara),
      chofer: Value(chofer),
      muellePartida: Value(muellePartida),
      fotoUrlEvidencia: fotoUrlEvidencia == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrlEvidencia),
      fotoLocalPath: fotoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoLocalPath),
      fechaZarpe: Value(fechaZarpe),
      estado: Value(estado),
    );
  }

  factory Zarpe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Zarpe(
      id: serializer.fromJson<String>(json['id']),
      placaCamara: serializer.fromJson<String>(json['placaCamara']),
      chofer: serializer.fromJson<String>(json['chofer']),
      muellePartida: serializer.fromJson<String>(json['muellePartida']),
      fotoUrlEvidencia: serializer.fromJson<String?>(json['fotoUrlEvidencia']),
      fotoLocalPath: serializer.fromJson<String?>(json['fotoLocalPath']),
      fechaZarpe: serializer.fromJson<String>(json['fechaZarpe']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'placaCamara': serializer.toJson<String>(placaCamara),
      'chofer': serializer.toJson<String>(chofer),
      'muellePartida': serializer.toJson<String>(muellePartida),
      'fotoUrlEvidencia': serializer.toJson<String?>(fotoUrlEvidencia),
      'fotoLocalPath': serializer.toJson<String?>(fotoLocalPath),
      'fechaZarpe': serializer.toJson<String>(fechaZarpe),
      'estado': serializer.toJson<String>(estado),
    };
  }

  Zarpe copyWith({
    String? id,
    String? placaCamara,
    String? chofer,
    String? muellePartida,
    Value<String?> fotoUrlEvidencia = const Value.absent(),
    Value<String?> fotoLocalPath = const Value.absent(),
    String? fechaZarpe,
    String? estado,
  }) => Zarpe(
    id: id ?? this.id,
    placaCamara: placaCamara ?? this.placaCamara,
    chofer: chofer ?? this.chofer,
    muellePartida: muellePartida ?? this.muellePartida,
    fotoUrlEvidencia: fotoUrlEvidencia.present
        ? fotoUrlEvidencia.value
        : this.fotoUrlEvidencia,
    fotoLocalPath: fotoLocalPath.present
        ? fotoLocalPath.value
        : this.fotoLocalPath,
    fechaZarpe: fechaZarpe ?? this.fechaZarpe,
    estado: estado ?? this.estado,
  );
  Zarpe copyWithCompanion(ZarpesCompanion data) {
    return Zarpe(
      id: data.id.present ? data.id.value : this.id,
      placaCamara: data.placaCamara.present
          ? data.placaCamara.value
          : this.placaCamara,
      chofer: data.chofer.present ? data.chofer.value : this.chofer,
      muellePartida: data.muellePartida.present
          ? data.muellePartida.value
          : this.muellePartida,
      fotoUrlEvidencia: data.fotoUrlEvidencia.present
          ? data.fotoUrlEvidencia.value
          : this.fotoUrlEvidencia,
      fotoLocalPath: data.fotoLocalPath.present
          ? data.fotoLocalPath.value
          : this.fotoLocalPath,
      fechaZarpe: data.fechaZarpe.present
          ? data.fechaZarpe.value
          : this.fechaZarpe,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Zarpe(')
          ..write('id: $id, ')
          ..write('placaCamara: $placaCamara, ')
          ..write('chofer: $chofer, ')
          ..write('muellePartida: $muellePartida, ')
          ..write('fotoUrlEvidencia: $fotoUrlEvidencia, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('fechaZarpe: $fechaZarpe, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    placaCamara,
    chofer,
    muellePartida,
    fotoUrlEvidencia,
    fotoLocalPath,
    fechaZarpe,
    estado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Zarpe &&
          other.id == this.id &&
          other.placaCamara == this.placaCamara &&
          other.chofer == this.chofer &&
          other.muellePartida == this.muellePartida &&
          other.fotoUrlEvidencia == this.fotoUrlEvidencia &&
          other.fotoLocalPath == this.fotoLocalPath &&
          other.fechaZarpe == this.fechaZarpe &&
          other.estado == this.estado);
}

class ZarpesCompanion extends UpdateCompanion<Zarpe> {
  final Value<String> id;
  final Value<String> placaCamara;
  final Value<String> chofer;
  final Value<String> muellePartida;
  final Value<String?> fotoUrlEvidencia;
  final Value<String?> fotoLocalPath;
  final Value<String> fechaZarpe;
  final Value<String> estado;
  final Value<int> rowid;
  const ZarpesCompanion({
    this.id = const Value.absent(),
    this.placaCamara = const Value.absent(),
    this.chofer = const Value.absent(),
    this.muellePartida = const Value.absent(),
    this.fotoUrlEvidencia = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.fechaZarpe = const Value.absent(),
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZarpesCompanion.insert({
    required String id,
    required String placaCamara,
    required String chofer,
    required String muellePartida,
    this.fotoUrlEvidencia = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    required String fechaZarpe,
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       placaCamara = Value(placaCamara),
       chofer = Value(chofer),
       muellePartida = Value(muellePartida),
       fechaZarpe = Value(fechaZarpe);
  static Insertable<Zarpe> custom({
    Expression<String>? id,
    Expression<String>? placaCamara,
    Expression<String>? chofer,
    Expression<String>? muellePartida,
    Expression<String>? fotoUrlEvidencia,
    Expression<String>? fotoLocalPath,
    Expression<String>? fechaZarpe,
    Expression<String>? estado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (placaCamara != null) 'placa_camara': placaCamara,
      if (chofer != null) 'chofer': chofer,
      if (muellePartida != null) 'muelle_partida': muellePartida,
      if (fotoUrlEvidencia != null) 'foto_url_evidencia': fotoUrlEvidencia,
      if (fotoLocalPath != null) 'foto_local_path': fotoLocalPath,
      if (fechaZarpe != null) 'fecha_zarpe': fechaZarpe,
      if (estado != null) 'estado': estado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZarpesCompanion copyWith({
    Value<String>? id,
    Value<String>? placaCamara,
    Value<String>? chofer,
    Value<String>? muellePartida,
    Value<String?>? fotoUrlEvidencia,
    Value<String?>? fotoLocalPath,
    Value<String>? fechaZarpe,
    Value<String>? estado,
    Value<int>? rowid,
  }) {
    return ZarpesCompanion(
      id: id ?? this.id,
      placaCamara: placaCamara ?? this.placaCamara,
      chofer: chofer ?? this.chofer,
      muellePartida: muellePartida ?? this.muellePartida,
      fotoUrlEvidencia: fotoUrlEvidencia ?? this.fotoUrlEvidencia,
      fotoLocalPath: fotoLocalPath ?? this.fotoLocalPath,
      fechaZarpe: fechaZarpe ?? this.fechaZarpe,
      estado: estado ?? this.estado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (placaCamara.present) {
      map['placa_camara'] = Variable<String>(placaCamara.value);
    }
    if (chofer.present) {
      map['chofer'] = Variable<String>(chofer.value);
    }
    if (muellePartida.present) {
      map['muelle_partida'] = Variable<String>(muellePartida.value);
    }
    if (fotoUrlEvidencia.present) {
      map['foto_url_evidencia'] = Variable<String>(fotoUrlEvidencia.value);
    }
    if (fotoLocalPath.present) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath.value);
    }
    if (fechaZarpe.present) {
      map['fecha_zarpe'] = Variable<String>(fechaZarpe.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZarpesCompanion(')
          ..write('id: $id, ')
          ..write('placaCamara: $placaCamara, ')
          ..write('chofer: $chofer, ')
          ..write('muellePartida: $muellePartida, ')
          ..write('fotoUrlEvidencia: $fotoUrlEvidencia, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('fechaZarpe: $fechaZarpe, ')
          ..write('estado: $estado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDatosLocal extends GeneratedDatabase {
  _$BaseDatosLocal(QueryExecutor e) : super(e);
  $BaseDatosLocalManager get managers => $BaseDatosLocalManager(this);
  late final $CuadresTable cuadres = $CuadresTable(this);
  late final $ComprasTable compras = $ComprasTable(this);
  late final $GastosTable gastos = $GastosTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $ZarpesTable zarpes = $ZarpesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cuadres,
    compras,
    gastos,
    ventas,
    zarpes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cuadres',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('compras', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cuadres',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gastos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cuadres',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ventas', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CuadresTableCreateCompanionBuilder =
    CuadresCompanion Function({
      required String id,
      required String usuarioId,
      required String placa,
      Value<String?> fechaZarpe,
      Value<String?> fechaCuadre,
      Value<String> estado,
      Value<String?> urlPdfCloud,
      Value<String?> urlExcelCloud,
      Value<int> sincronizado,
      Value<String?> fotoZarpeUrl,
      Value<double?> pesoTotal,
      Value<int?> cajasLlenas,
      Value<int?> cajasVacias,
      Value<int?> tipoProducto,
      Value<String?> plantaDestino,
      Value<int> rowid,
    });
typedef $$CuadresTableUpdateCompanionBuilder =
    CuadresCompanion Function({
      Value<String> id,
      Value<String> usuarioId,
      Value<String> placa,
      Value<String?> fechaZarpe,
      Value<String?> fechaCuadre,
      Value<String> estado,
      Value<String?> urlPdfCloud,
      Value<String?> urlExcelCloud,
      Value<int> sincronizado,
      Value<String?> fotoZarpeUrl,
      Value<double?> pesoTotal,
      Value<int?> cajasLlenas,
      Value<int?> cajasVacias,
      Value<int?> tipoProducto,
      Value<String?> plantaDestino,
      Value<int> rowid,
    });

final class $$CuadresTableReferences
    extends BaseReferences<_$BaseDatosLocal, $CuadresTable, Cuadre> {
  $$CuadresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ComprasTable, List<Compra>> _comprasRefsTable(
    _$BaseDatosLocal db,
  ) => MultiTypedResultKey.fromTable(
    db.compras,
    aliasName: 'cuadres__id__compras__cuadre_id',
  );

  $$ComprasTableProcessedTableManager get comprasRefs {
    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.cuadreId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_comprasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GastosTable, List<Gasto>> _gastosRefsTable(
    _$BaseDatosLocal db,
  ) => MultiTypedResultKey.fromTable(
    db.gastos,
    aliasName: 'cuadres__id__gastos__cuadre_id',
  );

  $$GastosTableProcessedTableManager get gastosRefs {
    final manager = $$GastosTableTableManager(
      $_db,
      $_db.gastos,
    ).filter((f) => f.cuadreId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gastosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VentasTable, List<Venta>> _ventasRefsTable(
    _$BaseDatosLocal db,
  ) => MultiTypedResultKey.fromTable(
    db.ventas,
    aliasName: 'cuadres__id__ventas__cuadre_id',
  );

  $$VentasTableProcessedTableManager get ventasRefs {
    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.cuadreId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CuadresTableFilterComposer
    extends Composer<_$BaseDatosLocal, $CuadresTable> {
  $$CuadresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placa => $composableBuilder(
    column: $table.placa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaZarpe => $composableBuilder(
    column: $table.fechaZarpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaCuadre => $composableBuilder(
    column: $table.fechaCuadre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urlPdfCloud => $composableBuilder(
    column: $table.urlPdfCloud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urlExcelCloud => $composableBuilder(
    column: $table.urlExcelCloud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sincronizado => $composableBuilder(
    column: $table.sincronizado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoZarpeUrl => $composableBuilder(
    column: $table.fotoZarpeUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoTotal => $composableBuilder(
    column: $table.pesoTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cajasLlenas => $composableBuilder(
    column: $table.cajasLlenas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cajasVacias => $composableBuilder(
    column: $table.cajasVacias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tipoProducto => $composableBuilder(
    column: $table.tipoProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantaDestino => $composableBuilder(
    column: $table.plantaDestino,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> comprasRefs(
    Expression<bool> Function($$ComprasTableFilterComposer f) f,
  ) {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.cuadreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gastosRefs(
    Expression<bool> Function($$GastosTableFilterComposer f) f,
  ) {
    final $$GastosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.cuadreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableFilterComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ventasRefs(
    Expression<bool> Function($$VentasTableFilterComposer f) f,
  ) {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.cuadreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CuadresTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $CuadresTable> {
  $$CuadresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placa => $composableBuilder(
    column: $table.placa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaZarpe => $composableBuilder(
    column: $table.fechaZarpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaCuadre => $composableBuilder(
    column: $table.fechaCuadre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urlPdfCloud => $composableBuilder(
    column: $table.urlPdfCloud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urlExcelCloud => $composableBuilder(
    column: $table.urlExcelCloud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sincronizado => $composableBuilder(
    column: $table.sincronizado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoZarpeUrl => $composableBuilder(
    column: $table.fotoZarpeUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoTotal => $composableBuilder(
    column: $table.pesoTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cajasLlenas => $composableBuilder(
    column: $table.cajasLlenas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cajasVacias => $composableBuilder(
    column: $table.cajasVacias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipoProducto => $composableBuilder(
    column: $table.tipoProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantaDestino => $composableBuilder(
    column: $table.plantaDestino,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CuadresTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $CuadresTable> {
  $$CuadresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get placa =>
      $composableBuilder(column: $table.placa, builder: (column) => column);

  GeneratedColumn<String> get fechaZarpe => $composableBuilder(
    column: $table.fechaZarpe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fechaCuadre => $composableBuilder(
    column: $table.fechaCuadre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get urlPdfCloud => $composableBuilder(
    column: $table.urlPdfCloud,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urlExcelCloud => $composableBuilder(
    column: $table.urlExcelCloud,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sincronizado => $composableBuilder(
    column: $table.sincronizado,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoZarpeUrl => $composableBuilder(
    column: $table.fotoZarpeUrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pesoTotal =>
      $composableBuilder(column: $table.pesoTotal, builder: (column) => column);

  GeneratedColumn<int> get cajasLlenas => $composableBuilder(
    column: $table.cajasLlenas,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cajasVacias => $composableBuilder(
    column: $table.cajasVacias,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tipoProducto => $composableBuilder(
    column: $table.tipoProducto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plantaDestino => $composableBuilder(
    column: $table.plantaDestino,
    builder: (column) => column,
  );

  Expression<T> comprasRefs<T extends Object>(
    Expression<T> Function($$ComprasTableAnnotationComposer a) f,
  ) {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.cuadreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gastosRefs<T extends Object>(
    Expression<T> Function($$GastosTableAnnotationComposer a) f,
  ) {
    final $$GastosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.cuadreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableAnnotationComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ventasRefs<T extends Object>(
    Expression<T> Function($$VentasTableAnnotationComposer a) f,
  ) {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.cuadreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CuadresTableTableManager
    extends
        RootTableManager<
          _$BaseDatosLocal,
          $CuadresTable,
          Cuadre,
          $$CuadresTableFilterComposer,
          $$CuadresTableOrderingComposer,
          $$CuadresTableAnnotationComposer,
          $$CuadresTableCreateCompanionBuilder,
          $$CuadresTableUpdateCompanionBuilder,
          (Cuadre, $$CuadresTableReferences),
          Cuadre,
          PrefetchHooks Function({
            bool comprasRefs,
            bool gastosRefs,
            bool ventasRefs,
          })
        > {
  $$CuadresTableTableManager(_$BaseDatosLocal db, $CuadresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuadresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuadresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuadresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> placa = const Value.absent(),
                Value<String?> fechaZarpe = const Value.absent(),
                Value<String?> fechaCuadre = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> urlPdfCloud = const Value.absent(),
                Value<String?> urlExcelCloud = const Value.absent(),
                Value<int> sincronizado = const Value.absent(),
                Value<String?> fotoZarpeUrl = const Value.absent(),
                Value<double?> pesoTotal = const Value.absent(),
                Value<int?> cajasLlenas = const Value.absent(),
                Value<int?> cajasVacias = const Value.absent(),
                Value<int?> tipoProducto = const Value.absent(),
                Value<String?> plantaDestino = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuadresCompanion(
                id: id,
                usuarioId: usuarioId,
                placa: placa,
                fechaZarpe: fechaZarpe,
                fechaCuadre: fechaCuadre,
                estado: estado,
                urlPdfCloud: urlPdfCloud,
                urlExcelCloud: urlExcelCloud,
                sincronizado: sincronizado,
                fotoZarpeUrl: fotoZarpeUrl,
                pesoTotal: pesoTotal,
                cajasLlenas: cajasLlenas,
                cajasVacias: cajasVacias,
                tipoProducto: tipoProducto,
                plantaDestino: plantaDestino,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String usuarioId,
                required String placa,
                Value<String?> fechaZarpe = const Value.absent(),
                Value<String?> fechaCuadre = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> urlPdfCloud = const Value.absent(),
                Value<String?> urlExcelCloud = const Value.absent(),
                Value<int> sincronizado = const Value.absent(),
                Value<String?> fotoZarpeUrl = const Value.absent(),
                Value<double?> pesoTotal = const Value.absent(),
                Value<int?> cajasLlenas = const Value.absent(),
                Value<int?> cajasVacias = const Value.absent(),
                Value<int?> tipoProducto = const Value.absent(),
                Value<String?> plantaDestino = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuadresCompanion.insert(
                id: id,
                usuarioId: usuarioId,
                placa: placa,
                fechaZarpe: fechaZarpe,
                fechaCuadre: fechaCuadre,
                estado: estado,
                urlPdfCloud: urlPdfCloud,
                urlExcelCloud: urlExcelCloud,
                sincronizado: sincronizado,
                fotoZarpeUrl: fotoZarpeUrl,
                pesoTotal: pesoTotal,
                cajasLlenas: cajasLlenas,
                cajasVacias: cajasVacias,
                tipoProducto: tipoProducto,
                plantaDestino: plantaDestino,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CuadresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({comprasRefs = false, gastosRefs = false, ventasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (comprasRefs) db.compras,
                    if (gastosRefs) db.gastos,
                    if (ventasRefs) db.ventas,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (comprasRefs)
                        await $_getPrefetchedData<
                          Cuadre,
                          $CuadresTable,
                          Compra
                        >(
                          currentTable: table,
                          referencedTable: $$CuadresTableReferences
                              ._comprasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CuadresTableReferences(
                                db,
                                table,
                                p0,
                              ).comprasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cuadreId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gastosRefs)
                        await $_getPrefetchedData<Cuadre, $CuadresTable, Gasto>(
                          currentTable: table,
                          referencedTable: $$CuadresTableReferences
                              ._gastosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CuadresTableReferences(
                                db,
                                table,
                                p0,
                              ).gastosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cuadreId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ventasRefs)
                        await $_getPrefetchedData<Cuadre, $CuadresTable, Venta>(
                          currentTable: table,
                          referencedTable: $$CuadresTableReferences
                              ._ventasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CuadresTableReferences(
                                db,
                                table,
                                p0,
                              ).ventasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cuadreId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CuadresTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatosLocal,
      $CuadresTable,
      Cuadre,
      $$CuadresTableFilterComposer,
      $$CuadresTableOrderingComposer,
      $$CuadresTableAnnotationComposer,
      $$CuadresTableCreateCompanionBuilder,
      $$CuadresTableUpdateCompanionBuilder,
      (Cuadre, $$CuadresTableReferences),
      Cuadre,
      PrefetchHooks Function({
        bool comprasRefs,
        bool gastosRefs,
        bool ventasRefs,
      })
    >;
typedef $$ComprasTableCreateCompanionBuilder =
    ComprasCompanion Function({
      required String id,
      required String cuadreId,
      required String embarcacion,
      required String producto,
      Value<double> kilos,
      Value<double> precioUnitario,
      Value<double> total,
      Value<int> rowid,
    });
typedef $$ComprasTableUpdateCompanionBuilder =
    ComprasCompanion Function({
      Value<String> id,
      Value<String> cuadreId,
      Value<String> embarcacion,
      Value<String> producto,
      Value<double> kilos,
      Value<double> precioUnitario,
      Value<double> total,
      Value<int> rowid,
    });

final class $$ComprasTableReferences
    extends BaseReferences<_$BaseDatosLocal, $ComprasTable, Compra> {
  $$ComprasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CuadresTable _cuadreIdTable(_$BaseDatosLocal db) =>
      db.cuadres.createAlias('compras__cuadre_id__cuadres__id');

  $$CuadresTableProcessedTableManager get cuadreId {
    final $_column = $_itemColumn<String>('cuadre_id')!;

    final manager = $$CuadresTableTableManager(
      $_db,
      $_db.cuadres,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuadreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComprasTableFilterComposer
    extends Composer<_$BaseDatosLocal, $ComprasTable> {
  $$ComprasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embarcacion => $composableBuilder(
    column: $table.embarcacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kilos => $composableBuilder(
    column: $table.kilos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  $$CuadresTableFilterComposer get cuadreId {
    final $$CuadresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableFilterComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $ComprasTable> {
  $$ComprasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embarcacion => $composableBuilder(
    column: $table.embarcacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kilos => $composableBuilder(
    column: $table.kilos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuadresTableOrderingComposer get cuadreId {
    final $$CuadresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableOrderingComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $ComprasTable> {
  $$ComprasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get embarcacion => $composableBuilder(
    column: $table.embarcacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumn<double> get kilos =>
      $composableBuilder(column: $table.kilos, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  $$CuadresTableAnnotationComposer get cuadreId {
    final $$CuadresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableAnnotationComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableTableManager
    extends
        RootTableManager<
          _$BaseDatosLocal,
          $ComprasTable,
          Compra,
          $$ComprasTableFilterComposer,
          $$ComprasTableOrderingComposer,
          $$ComprasTableAnnotationComposer,
          $$ComprasTableCreateCompanionBuilder,
          $$ComprasTableUpdateCompanionBuilder,
          (Compra, $$ComprasTableReferences),
          Compra,
          PrefetchHooks Function({bool cuadreId})
        > {
  $$ComprasTableTableManager(_$BaseDatosLocal db, $ComprasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cuadreId = const Value.absent(),
                Value<String> embarcacion = const Value.absent(),
                Value<String> producto = const Value.absent(),
                Value<double> kilos = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComprasCompanion(
                id: id,
                cuadreId: cuadreId,
                embarcacion: embarcacion,
                producto: producto,
                kilos: kilos,
                precioUnitario: precioUnitario,
                total: total,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cuadreId,
                required String embarcacion,
                required String producto,
                Value<double> kilos = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComprasCompanion.insert(
                id: id,
                cuadreId: cuadreId,
                embarcacion: embarcacion,
                producto: producto,
                kilos: kilos,
                precioUnitario: precioUnitario,
                total: total,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComprasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cuadreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cuadreId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cuadreId,
                                referencedTable: $$ComprasTableReferences
                                    ._cuadreIdTable(db),
                                referencedColumn: $$ComprasTableReferences
                                    ._cuadreIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComprasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatosLocal,
      $ComprasTable,
      Compra,
      $$ComprasTableFilterComposer,
      $$ComprasTableOrderingComposer,
      $$ComprasTableAnnotationComposer,
      $$ComprasTableCreateCompanionBuilder,
      $$ComprasTableUpdateCompanionBuilder,
      (Compra, $$ComprasTableReferences),
      Compra,
      PrefetchHooks Function({bool cuadreId})
    >;
typedef $$GastosTableCreateCompanionBuilder =
    GastosCompanion Function({
      required String id,
      required String cuadreId,
      required String tipo,
      required String concepto,
      Value<double> cantidad,
      Value<double> costoUnitario,
      Value<double> total,
      Value<int> rowid,
    });
typedef $$GastosTableUpdateCompanionBuilder =
    GastosCompanion Function({
      Value<String> id,
      Value<String> cuadreId,
      Value<String> tipo,
      Value<String> concepto,
      Value<double> cantidad,
      Value<double> costoUnitario,
      Value<double> total,
      Value<int> rowid,
    });

final class $$GastosTableReferences
    extends BaseReferences<_$BaseDatosLocal, $GastosTable, Gasto> {
  $$GastosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CuadresTable _cuadreIdTable(_$BaseDatosLocal db) =>
      db.cuadres.createAlias('gastos__cuadre_id__cuadres__id');

  $$CuadresTableProcessedTableManager get cuadreId {
    final $_column = $_itemColumn<String>('cuadre_id')!;

    final manager = $$CuadresTableTableManager(
      $_db,
      $_db.cuadres,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuadreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GastosTableFilterComposer
    extends Composer<_$BaseDatosLocal, $GastosTable> {
  $$GastosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  $$CuadresTableFilterComposer get cuadreId {
    final $$CuadresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableFilterComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $GastosTable> {
  $$GastosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuadresTableOrderingComposer get cuadreId {
    final $$CuadresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableOrderingComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $GastosTable> {
  $$GastosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  $$CuadresTableAnnotationComposer get cuadreId {
    final $$CuadresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableAnnotationComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableTableManager
    extends
        RootTableManager<
          _$BaseDatosLocal,
          $GastosTable,
          Gasto,
          $$GastosTableFilterComposer,
          $$GastosTableOrderingComposer,
          $$GastosTableAnnotationComposer,
          $$GastosTableCreateCompanionBuilder,
          $$GastosTableUpdateCompanionBuilder,
          (Gasto, $$GastosTableReferences),
          Gasto,
          PrefetchHooks Function({bool cuadreId})
        > {
  $$GastosTableTableManager(_$BaseDatosLocal db, $GastosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GastosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GastosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GastosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cuadreId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<double> costoUnitario = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GastosCompanion(
                id: id,
                cuadreId: cuadreId,
                tipo: tipo,
                concepto: concepto,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                total: total,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cuadreId,
                required String tipo,
                required String concepto,
                Value<double> cantidad = const Value.absent(),
                Value<double> costoUnitario = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GastosCompanion.insert(
                id: id,
                cuadreId: cuadreId,
                tipo: tipo,
                concepto: concepto,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                total: total,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GastosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cuadreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cuadreId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cuadreId,
                                referencedTable: $$GastosTableReferences
                                    ._cuadreIdTable(db),
                                referencedColumn: $$GastosTableReferences
                                    ._cuadreIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GastosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatosLocal,
      $GastosTable,
      Gasto,
      $$GastosTableFilterComposer,
      $$GastosTableOrderingComposer,
      $$GastosTableAnnotationComposer,
      $$GastosTableCreateCompanionBuilder,
      $$GastosTableUpdateCompanionBuilder,
      (Gasto, $$GastosTableReferences),
      Gasto,
      PrefetchHooks Function({bool cuadreId})
    >;
typedef $$VentasTableCreateCompanionBuilder =
    VentasCompanion Function({
      required String id,
      required String cuadreId,
      required String lugar,
      required String producto,
      Value<double> kilos,
      Value<double> precioUnitario,
      Value<double> total,
      Value<int> rowid,
    });
typedef $$VentasTableUpdateCompanionBuilder =
    VentasCompanion Function({
      Value<String> id,
      Value<String> cuadreId,
      Value<String> lugar,
      Value<String> producto,
      Value<double> kilos,
      Value<double> precioUnitario,
      Value<double> total,
      Value<int> rowid,
    });

final class $$VentasTableReferences
    extends BaseReferences<_$BaseDatosLocal, $VentasTable, Venta> {
  $$VentasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CuadresTable _cuadreIdTable(_$BaseDatosLocal db) =>
      db.cuadres.createAlias('ventas__cuadre_id__cuadres__id');

  $$CuadresTableProcessedTableManager get cuadreId {
    final $_column = $_itemColumn<String>('cuadre_id')!;

    final manager = $$CuadresTableTableManager(
      $_db,
      $_db.cuadres,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuadreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VentasTableFilterComposer
    extends Composer<_$BaseDatosLocal, $VentasTable> {
  $$VentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lugar => $composableBuilder(
    column: $table.lugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kilos => $composableBuilder(
    column: $table.kilos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  $$CuadresTableFilterComposer get cuadreId {
    final $$CuadresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableFilterComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentasTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $VentasTable> {
  $$VentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lugar => $composableBuilder(
    column: $table.lugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kilos => $composableBuilder(
    column: $table.kilos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuadresTableOrderingComposer get cuadreId {
    final $$CuadresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableOrderingComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentasTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $VentasTable> {
  $$VentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lugar =>
      $composableBuilder(column: $table.lugar, builder: (column) => column);

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumn<double> get kilos =>
      $composableBuilder(column: $table.kilos, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  $$CuadresTableAnnotationComposer get cuadreId {
    final $$CuadresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuadreId,
      referencedTable: $db.cuadres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuadresTableAnnotationComposer(
            $db: $db,
            $table: $db.cuadres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentasTableTableManager
    extends
        RootTableManager<
          _$BaseDatosLocal,
          $VentasTable,
          Venta,
          $$VentasTableFilterComposer,
          $$VentasTableOrderingComposer,
          $$VentasTableAnnotationComposer,
          $$VentasTableCreateCompanionBuilder,
          $$VentasTableUpdateCompanionBuilder,
          (Venta, $$VentasTableReferences),
          Venta,
          PrefetchHooks Function({bool cuadreId})
        > {
  $$VentasTableTableManager(_$BaseDatosLocal db, $VentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cuadreId = const Value.absent(),
                Value<String> lugar = const Value.absent(),
                Value<String> producto = const Value.absent(),
                Value<double> kilos = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion(
                id: id,
                cuadreId: cuadreId,
                lugar: lugar,
                producto: producto,
                kilos: kilos,
                precioUnitario: precioUnitario,
                total: total,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cuadreId,
                required String lugar,
                required String producto,
                Value<double> kilos = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion.insert(
                id: id,
                cuadreId: cuadreId,
                lugar: lugar,
                producto: producto,
                kilos: kilos,
                precioUnitario: precioUnitario,
                total: total,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VentasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cuadreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cuadreId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cuadreId,
                                referencedTable: $$VentasTableReferences
                                    ._cuadreIdTable(db),
                                referencedColumn: $$VentasTableReferences
                                    ._cuadreIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VentasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatosLocal,
      $VentasTable,
      Venta,
      $$VentasTableFilterComposer,
      $$VentasTableOrderingComposer,
      $$VentasTableAnnotationComposer,
      $$VentasTableCreateCompanionBuilder,
      $$VentasTableUpdateCompanionBuilder,
      (Venta, $$VentasTableReferences),
      Venta,
      PrefetchHooks Function({bool cuadreId})
    >;
typedef $$ZarpesTableCreateCompanionBuilder =
    ZarpesCompanion Function({
      required String id,
      required String placaCamara,
      required String chofer,
      required String muellePartida,
      Value<String?> fotoUrlEvidencia,
      Value<String?> fotoLocalPath,
      required String fechaZarpe,
      Value<String> estado,
      Value<int> rowid,
    });
typedef $$ZarpesTableUpdateCompanionBuilder =
    ZarpesCompanion Function({
      Value<String> id,
      Value<String> placaCamara,
      Value<String> chofer,
      Value<String> muellePartida,
      Value<String?> fotoUrlEvidencia,
      Value<String?> fotoLocalPath,
      Value<String> fechaZarpe,
      Value<String> estado,
      Value<int> rowid,
    });

class $$ZarpesTableFilterComposer
    extends Composer<_$BaseDatosLocal, $ZarpesTable> {
  $$ZarpesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placaCamara => $composableBuilder(
    column: $table.placaCamara,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chofer => $composableBuilder(
    column: $table.chofer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muellePartida => $composableBuilder(
    column: $table.muellePartida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoUrlEvidencia => $composableBuilder(
    column: $table.fotoUrlEvidencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaZarpe => $composableBuilder(
    column: $table.fechaZarpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ZarpesTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $ZarpesTable> {
  $$ZarpesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placaCamara => $composableBuilder(
    column: $table.placaCamara,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chofer => $composableBuilder(
    column: $table.chofer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muellePartida => $composableBuilder(
    column: $table.muellePartida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoUrlEvidencia => $composableBuilder(
    column: $table.fotoUrlEvidencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaZarpe => $composableBuilder(
    column: $table.fechaZarpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZarpesTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $ZarpesTable> {
  $$ZarpesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get placaCamara => $composableBuilder(
    column: $table.placaCamara,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chofer =>
      $composableBuilder(column: $table.chofer, builder: (column) => column);

  GeneratedColumn<String> get muellePartida => $composableBuilder(
    column: $table.muellePartida,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoUrlEvidencia => $composableBuilder(
    column: $table.fotoUrlEvidencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fechaZarpe => $composableBuilder(
    column: $table.fechaZarpe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$ZarpesTableTableManager
    extends
        RootTableManager<
          _$BaseDatosLocal,
          $ZarpesTable,
          Zarpe,
          $$ZarpesTableFilterComposer,
          $$ZarpesTableOrderingComposer,
          $$ZarpesTableAnnotationComposer,
          $$ZarpesTableCreateCompanionBuilder,
          $$ZarpesTableUpdateCompanionBuilder,
          (Zarpe, BaseReferences<_$BaseDatosLocal, $ZarpesTable, Zarpe>),
          Zarpe,
          PrefetchHooks Function()
        > {
  $$ZarpesTableTableManager(_$BaseDatosLocal db, $ZarpesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZarpesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZarpesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZarpesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> placaCamara = const Value.absent(),
                Value<String> chofer = const Value.absent(),
                Value<String> muellePartida = const Value.absent(),
                Value<String?> fotoUrlEvidencia = const Value.absent(),
                Value<String?> fotoLocalPath = const Value.absent(),
                Value<String> fechaZarpe = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZarpesCompanion(
                id: id,
                placaCamara: placaCamara,
                chofer: chofer,
                muellePartida: muellePartida,
                fotoUrlEvidencia: fotoUrlEvidencia,
                fotoLocalPath: fotoLocalPath,
                fechaZarpe: fechaZarpe,
                estado: estado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String placaCamara,
                required String chofer,
                required String muellePartida,
                Value<String?> fotoUrlEvidencia = const Value.absent(),
                Value<String?> fotoLocalPath = const Value.absent(),
                required String fechaZarpe,
                Value<String> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZarpesCompanion.insert(
                id: id,
                placaCamara: placaCamara,
                chofer: chofer,
                muellePartida: muellePartida,
                fotoUrlEvidencia: fotoUrlEvidencia,
                fotoLocalPath: fotoLocalPath,
                fechaZarpe: fechaZarpe,
                estado: estado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ZarpesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatosLocal,
      $ZarpesTable,
      Zarpe,
      $$ZarpesTableFilterComposer,
      $$ZarpesTableOrderingComposer,
      $$ZarpesTableAnnotationComposer,
      $$ZarpesTableCreateCompanionBuilder,
      $$ZarpesTableUpdateCompanionBuilder,
      (Zarpe, BaseReferences<_$BaseDatosLocal, $ZarpesTable, Zarpe>),
      Zarpe,
      PrefetchHooks Function()
    >;

class $BaseDatosLocalManager {
  final _$BaseDatosLocal _db;
  $BaseDatosLocalManager(this._db);
  $$CuadresTableTableManager get cuadres =>
      $$CuadresTableTableManager(_db, _db.cuadres);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db, _db.compras);
  $$GastosTableTableManager get gastos =>
      $$GastosTableTableManager(_db, _db.gastos);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$ZarpesTableTableManager get zarpes =>
      $$ZarpesTableTableManager(_db, _db.zarpes);
}
