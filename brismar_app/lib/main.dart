import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'nucleo/red/cliente_supabase.dart';
import 'nucleo/rutas/enrutador.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'modulos/registro_pesca/presentacion/controladores/controlador_cuadres.dart';
import 'modulos/registro_pesca/presentacion/controladores/controlador_zarpes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevención contra captura de pantalla/grabación (solo móvil)
  if (!kIsWeb) {
    await ScreenProtector.preventScreenshotOn();
  }

  // Cargamos las variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializamos Supabase
  await ConfiguracionSupabase.inicializar();

  runApp(const ProviderScope(child: MyApp()));
}

/// Widget raíz de BRISMAR APP.
class MyApp extends ConsumerStatefulWidget {
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
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> resultados) {
      if (!resultados.contains(ConnectivityResult.none)) {
        // Retrasamos un segundo para asegurar que el SO ya estableció la red
        Future.delayed(const Duration(seconds: 2), () {
          try {
            // Se ejecuta la sincronización silenciosa (ignora si están listos)
            ref.read(cuadresProvider.notifier).cargarHistorial();
            ref.read(proveedorZarpes.notifier).sincronizarZarpesPendientes();
          } catch (e) {
            debugPrint("Auto-Sync falló, se reintentará luego: $e");
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrutador = ref.watch(enrutadorProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BRISMAR APP',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D255F),
        primaryColor: const Color(0xFF0D255F),
      ),
      routerConfig: enrutador,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
    );
  }
}
