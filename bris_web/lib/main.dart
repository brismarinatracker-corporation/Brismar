import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'nucleo/red/constantes_supabase.dart';
import 'nucleo/enrutador/enrutador.dart';
import 'nucleo/tema/fabrica_tema_app.dart';
import 'nucleo/tema/controlador_tema.dart';
import 'nucleo/componentes/visor_error_app.dart';

/// Punto de entrada principal para la aplicación web de administración BRISMAR.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeDateFormatting('es', null);
  await _inicializarServicios();
  _configurarManejoDeErrores();

  runApp(const ProviderScope(child: BrismarWebAdminApp()));
}

/// Inicializa los servicios centrales de infraestructura (Supabase).
Future<void> _inicializarServicios() async {
  await Supabase.initialize(
    url: ConstantesSupabase.urlSupabase,
    publishableKey: ConstantesSupabase.llaveAnonima,
  );
}

/// Configura los manejadores globales para la captura de errores en runtime.
void _configurarManejoDeErrores() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return VisorErrorApp(detalles: details);
  };
}

/// Widget raíz de la aplicación Web de administración BRISMAR.
class BrismarWebAdminApp extends ConsumerWidget {
  /// Constructor del widget raíz.
  const BrismarWebAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrutador = ref.watch(proveedorEnrutador);
    final modoTema = ref.watch(proveedorControladorTema);

    return MaterialApp.router(
      title: 'BrisWeb',
      debugShowCheckedModeBanner: false,
      theme: FabricaTemaApp.crearTemaClaro(),
      darkTheme: FabricaTemaApp.crearTemaOscuro(),
      themeMode: modoTema,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('es')],
      routerConfig: enrutador,
    );
  }
}
