import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tablas.dart';

part 'base_datos_local.g.dart';

@DriftDatabase(tables: [Cuadres, Compras, Gastos, Ventas, Zarpes])
class BaseDatosLocal extends _$BaseDatosLocal {
  BaseDatosLocal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Repositorios y consultas específicas se agregarán aquí.
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'brismar_local.sqlite'));
    
    
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    
    return NativeDatabase.createInBackground(file);
  });
}
