import 'package:drift/drift.dart';

@DataClassName('Cuadre')
class Cuadres extends Table {
  TextColumn get id => text()();
  TextColumn get usuarioId => text()();
  TextColumn get placa => text()();
  TextColumn get fechaZarpe => text().nullable()();
  TextColumn get fechaCuadre => text().nullable()();
  TextColumn get estado => text().withDefault(const Constant('borrador'))();
  TextColumn get urlPdfCloud => text().nullable()();
  TextColumn get urlExcelCloud => text().nullable()();
  IntColumn get sincronizado => integer().withDefault(const Constant(0))();
  TextColumn get fotoZarpeUrl => text().nullable()();
  RealColumn get pesoTotal => real().nullable()();
  IntColumn get cajasLlenas => integer().nullable()();
  IntColumn get cajasVacias => integer().nullable()();
  IntColumn get tipoProducto => integer().nullable()();
  TextColumn get plantaDestino => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Compra')
class Compras extends Table {
  TextColumn get id => text()();
  TextColumn get cuadreId => text().references(Cuadres, #id, onDelete: KeyAction.cascade)();
  TextColumn get embarcacion => text()();
  TextColumn get producto => text()();
  RealColumn get kilos => real().withDefault(const Constant(0.0))();
  RealColumn get precioUnitario => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Gasto')
class Gastos extends Table {
  TextColumn get id => text()();
  TextColumn get cuadreId => text().references(Cuadres, #id, onDelete: KeyAction.cascade)();
  TextColumn get tipo => text()();
  TextColumn get concepto => text()();
  RealColumn get cantidad => real().withDefault(const Constant(0.0))();
  RealColumn get costoUnitario => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Venta')
class Ventas extends Table {
  TextColumn get id => text()();
  TextColumn get cuadreId => text().references(Cuadres, #id, onDelete: KeyAction.cascade)();
  TextColumn get lugar => text()();
  TextColumn get producto => text()();
  RealColumn get kilos => real().withDefault(const Constant(0.0))();
  RealColumn get precioUnitario => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Zarpe')
class Zarpes extends Table {
  TextColumn get id => text()();
  TextColumn get placaCamara => text()();
  TextColumn get chofer => text()();
  TextColumn get muellePartida => text()();
  TextColumn get fotoUrlEvidencia => text().nullable()();
  TextColumn get fotoLocalPath => text().nullable()();
  TextColumn get fechaZarpe => text()();
  TextColumn get estado => text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}
