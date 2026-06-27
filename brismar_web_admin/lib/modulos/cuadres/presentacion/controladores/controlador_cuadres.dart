import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';

final proveedorCuadres = AsyncNotifierProvider<ControladorCuadres, void>(() {
  return ControladorCuadres();
});

class ControladorCuadres extends AsyncNotifier<void> {
  final _cliente = Supabase.instance.client;

  @override
  Future<void> build() async {}

  Future<void> exportarAExcel() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final datos = await _cliente.from('zarpes').select().order('fecha_zarpe', ascending: false);
      
      var excel = Excel.createExcel();
      Sheet hoja = excel['Cuadres_Piura'];
      excel.setDefaultSheet('Cuadres_Piura');

      hoja.appendRow([
        TextCellValue('ID ZARPE'),
        TextCellValue('PLACA CÁMARA'),
        TextCellValue('CHOFER'),
        TextCellValue('MUELLE PARTIDA'),
        TextCellValue('FECHA ZARPE'),
        TextCellValue('ESTADO'),
      ]);

      for (var fila in datos) {
        hoja.appendRow([
          TextCellValue(fila['id'].toString()),
          TextCellValue(fila['placa_camara'] ?? ''),
          TextCellValue(fila['chofer'] ?? ''),
          TextCellValue(fila['muelle_partida'] ?? ''),
          TextCellValue(fila['fecha_zarpe']?.toString() ?? ''),
          TextCellValue(fila['estado'] ?? ''),
        ]);
      }

      List<int>? bytesArchivo = excel.save();
      if (bytesArchivo != null) {
        Uint8List bytes = Uint8List.fromList(bytesArchivo);
        await FileSaver.instance.saveFile(
          name: 'Cuadres_Brismar_${DateTime.now().millisecondsSinceEpoch}.xlsx',
          bytes: bytes,
          mimeType: MimeType.microsoftExcel,
        );
      }
    });
  }
}
