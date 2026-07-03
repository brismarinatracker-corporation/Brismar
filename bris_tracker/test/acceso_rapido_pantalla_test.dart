import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bris_tracker/modulos/autenticacion/presentacion/pantallas/acceso_rapido_pantalla.dart';
import 'package:bris_tracker/modulos/autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:bris_tracker/modulos/autenticacion/dominio/entidades/preferencia_acceso.dart';
import 'package:bris_tracker/modulos/autenticacion/dominio/repositorios/repositorio_autenticacion.dart';
import 'package:bris_tracker/modulos/autenticacion/dominio/entidades/usuario.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';

// Fake Repositorio
class FakeRepositorio extends RepositorioAutenticacion {
  @override
  Future<Usuario> iniciarSesion({required String usuario, required String password}) async => throw UnimplementedError();
  @override
  Future<void> cerrarSesion() async {}
  @override
  Future<Usuario?> obtenerUsuarioActual() async => null;
  @override
  Future<void> configurarPin(String pin) async {}
  @override
  Future<bool> verificarPin(String pin) async => true;
  @override
  Future<void> guardarPreferenciaAcceso(String preferencia) async {}
  @override
  Future<void> invalidarPinYToken() async {}
  @override
  Future<Usuario> obtenerPerfilActualizado(String id) async => throw UnimplementedError();
  
  @override
  Future<bool> verificarBiometria() async {
    // Simulamos un retraso para atrapar el estado de "Cargando"
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}

void main() {
  testWidgets('AccesoRapidoPantalla no debe lanzar error visual al cargar (Biometría)', (WidgetTester tester) async {
    final fakeRepo = FakeRepositorio();
    final controlador = NotificadorAutenticacion(repositorio: fakeRepo);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proveedorControladorAutenticacion.overrideWith((ref) => controlador),
        ],
        child: const MaterialApp(
          home: AccesoRapidoPantalla(preferencia: PreferenciaAcceso.huella),
        ),
      ),
    );

    // Damos tiempo a que se resuelva `verificarSesionActiva()` (se va a NoAutenticado temporalmente, luego reasignamos el estado)
    await tester.pumpAndSettle();
    
    // Forzamos manualmente el estado para simular que sí estamos en Acceso Rápido
    controlador.state = const EstadoAccesoRapidoRequerido(PreferenciaAcceso.huella);
    await tester.pump();

    // Estado inicial visual: deberíamos ver el icono de la huella
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Simulamos el toque para iniciar biometría
    await tester.tap(find.byIcon(Icons.fingerprint));
    
    // Pump the frame to start the animation
    await tester.pump();
    // Pump animation ticks
    await tester.pump(const Duration(milliseconds: 200));

    // En estado de carga, el ícono sigue ahí, PERO AHORA TAMBIÉN debe haber un CargaOrbital 
    expect(find.byType(CargaOrbital), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsNothing);
    
    // Verificamos que no hubo ninguna excepción de Flutter (como overflow o errores de layout)
    expect(tester.takeException(), isNull);
    
    // Finalizamos la espera de los 2 segundos para limpiar los timers
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
