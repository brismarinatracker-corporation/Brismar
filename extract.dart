import 'dart:io';

void main() async {
  final files = [
    'bris_tracker/lib/modulos/perfil/presentacion/pantallas/pantalla_perfil.dart',
    'bris_tracker/lib/modulos/registro_pesca/datos/modelos/cuadre_modelo.dart',
    'bris_tracker/lib/modulos/registro_pesca/datos/repositorios/zarpe_repositorio_imp.dart',
    'bris_tracker/lib/modulos/registro_pesca/presentacion/pantallas/dashboard_cuadres.dart',
    'bris_tracker/lib/modulos/registro_pesca/presentacion/pantallas/formulario_registro_pesca.dart',
    'bris_tracker/lib/modulos/registro_pesca/presentacion/widgets/panel_calculo_vivo.dart',
    'bris_web/lib/modulos/cuadres/datos/fuente_datos_cuadres_web.dart',
    'bris_web/lib/modulos/cuadres/presentacion/pantallas/pantalla_cuadres.dart',
    'bris_web/lib/modulos/cuadres/servicios/servicio_exportacion.dart',
    'bris_web/lib/modulos/transito/datos/repositorio_edicion_zarpe.dart',
    'bris_web/lib/modulos/transito/presentacion/pantallas/pantalla_edicion_transito.dart',
    'bris_web/lib/modulos/transito/presentacion/pantallas/widgets/seccion_datos_zarpe.dart',
    'bris_web/lib/nucleo/enrutador/enrutador.dart'
  ];

  final out = File('conflicts.md');
  await out.writeAsString('');

  for (final file in files) {
    final content = await File(file).readAsString();
    final regex = RegExp(r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> origin/DEV-JJGS\n', dotAll: true);
    final matches = regex.allMatches(content);
    if (matches.isEmpty) continue;
    
    await out.writeAsString('# $file\n', mode: FileMode.append);
    for (int i = 0; i < matches.length; i++) {
      await out.writeAsString('## Conflict ${i+1}\n', mode: FileMode.append);
      await out.writeAsString('### HEAD (Your changes)\n```dart\n${matches.elementAt(i).group(1)}\n```\n', mode: FileMode.append);
      await out.writeAsString('### DEV-JJGS (Incoming changes)\n```dart\n${matches.elementAt(i).group(2)}\n```\n', mode: FileMode.append);
    }
    await out.writeAsString('\n', mode: FileMode.append);
  }
  print('Conflicts extracted.');
}
