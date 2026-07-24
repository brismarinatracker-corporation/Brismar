import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

import 'modulos/registro_pesca/presentacion/controladores/controlador_cuadres.dart';
import 'modulos/registro_pesca/presentacion/controladores/controlador_zarpes.dart';
import 'nucleo/componentes/visor_error_app.dart';
import 'nucleo/red/cliente_supabase.dart';
import 'nucleo/rutas/enrutador.dart';
import 'nucleo/tema/controlador_tema.dart';
import 'nucleo/tema/fabrica_tema_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configurarSeguridadYEntorno();
  await ConfiguracionSupabase.inicializar();
  _configurarManejoDeErrores();

  runApp(const ProviderScope(child: MyApp()));
}

/// Configura la protección contra capturas de pantalla y carga el entorno.
Future<void> _configurarSeguridadYEntorno() async {
  if (!kIsWeb) {
    await ScreenProtector.preventScreenshotOn();
  }
  await dotenv.load(fileName: ".env");
}

/// Registra los capturadores globales de errores runtime.
void _configurarManejoDeErrores() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return VisorErrorAppTracker(detalles: details);
  };
}

/// Widget raíz de la aplicación móvil BRISMAR Tracker.
class MyApp extends ConsumerStatefulWidget {
  /// Constructor del widget raíz.
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _iniciarAutoSincronizacion();
  }

  void _iniciarAutoSincronizacion() {
    _subscription = Connectivity().onConnectivityChanged.listen(
      _procesarCambioConectividad,
    );
  }

  void _procesarCambioConectividad(List<ConnectivityResult> resultados) {
    if (resultados.contains(ConnectivityResult.none)) return;
    Future.delayed(const Duration(seconds: 1), _ejecutarSincronizaciones);
  }

  void _ejecutarSincronizaciones() {
    try {
      ref.read(cuadresProvider.notifier).cargarHistorial();
      ref.read(proveedorZarpes.notifier).sincronizarZarpesPendientes();
      ref.read(proveedorZarpes.notifier).sincronizarZarpesDownstream();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoSync] Error silencioso reintentable: $e');
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrutador = ref.watch(enrutadorProvider);
    final modoTema = ref.watch(proveedorControladorTemaTracker);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BRISMAR APP',
      theme: FabricaTemaApp.crearTemaClaro(),
      darkTheme: FabricaTemaApp.crearTemaOscuro(),
      themeMode: modoTema,
      routerConfig: enrutador,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
    );
  }
}
