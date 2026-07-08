import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bris_web/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flujo completo de login a cuadres (E2E)', skip: true, (WidgetTester tester) async {
    // Mock de path_provider para evitar MissingPluginException en google_fonts
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });

    // Mock de SharedPreferences para evitar MissingPluginException
    SharedPreferences.setMockInitialValues({});

    // 1. Iniciar la aplicación
    app.main();
    await tester.pumpAndSettle();

    // 2. Verificar que estamos en la pantalla de login
    expect(find.text('ACCESO AL PANEL'), findsWidgets);
    
    // Ingresar credenciales mock (asumiendo que las pruebas apuntan a ambiente de pruebas)
    await tester.enterText(find.byType(TextFormField).at(0), 'admin@brismar.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    // 3. Verificar navegación al Dashboard / Cuadres
    expect(find.text('Cuadres de Pesca'), findsWidgets);
    
    // 4. Verificar presencia del botón "Actualizar"
    expect(find.text('Actualizar'), findsOneWidget);

    // 5. Interactuar con la tabla (abrir detalle del primer cuadre si existe)
    final primerDetalleBoton = find.byIcon(Icons.chevron_right_rounded).first;
    if (tester.any(primerDetalleBoton)) {
      await tester.tap(primerDetalleBoton);
      await tester.pumpAndSettle();
      
      // Verificar que se haya abierto el panel de detalle
      expect(find.text('Resumen'), findsWidgets);
      expect(find.text('UTILIDAD NETA'), findsWidgets);
    }
  });
}
