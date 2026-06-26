import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'nucleo/red/cliente_supabase.dart';
import 'nucleo/rutas/enrutador.dart';

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
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
