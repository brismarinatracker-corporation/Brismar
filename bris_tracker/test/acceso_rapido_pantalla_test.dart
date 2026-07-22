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

class FakeNotificadorAutenticacion extends NotificadorAutenticacion {
  final EstadoAutenticacion estadoInicial;
  FakeNotificadorAutenticacion(this.estadoInicial);

  @override
  EstadoAutenticacion build() {
    super.build();
    return estadoInicial;
  }

  @override
  Future<void> verificarSesionActiva() async {}
}

void main() {
  testWidgets('AccesoRapidoPantalla no debe lanzar error visual al cargar (Biometría)', (WidgetTester tester) async {
    final fakeRepo = FakeRepositorio();
    final fakeNotifier = FakeNotificadorAutenticacion(
      const EstadoAccesoRapidoRequerido(PreferenciaAcceso.huella),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proveedorRepositorioAutenticacion.overrideWithValue(fakeRepo),
          proveedorControladorAutenticacion.overrideWith(() => fakeNotifier),
        ],
        child: const MaterialApp(
          home: AccesoRapidoPantalla(preferencia: PreferenciaAcceso.huella),
        ),
      ),
    );

    // La pantalla de biometría inicia la biometría automáticamente en initState
    // vía post-frame callback, cambiando el estado a Cargando y mostrando CargaOrbital
    await tester.pump();
    expect(find.byType(CargaOrbital), findsOneWidget);
    
    // Verificamos que no hubo ninguna excepción de Flutter (como overflow o errores de layout)
    expect(tester.takeException(), isNull);
    
    // Finalizamos la espera de la biometría para limpiar los timers
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
