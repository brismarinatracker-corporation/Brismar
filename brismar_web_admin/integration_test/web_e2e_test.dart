import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:brismar_web_admin/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas E2E Web Admin:', () {
    testWidgets('Debe cargar la pantalla principal de login de administrador', (tester) async {
      // 1. Iniciar la aplicación web
      app.main();
      
      // Esperar a que la animación de inicio y la carga finalicen
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 2. Verificar que se monta la estructura de la aplicación
      expect(find.byType(MaterialApp), findsWidgets);
      
      // Asegurarse de que el Scaffold (pantalla) se está renderizando
      expect(find.byType(Scaffold), findsWidgets);
      
      // TODO: Agregar pruebas reales de llenado de usuario y contraseña cuando se proporcione entorno Staging
    });
  });
}
