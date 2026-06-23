import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_protector/screen_protector.dart';
import 'nucleo/red/cliente_supabase.dart';
import 'nucleo/rutas/enrutador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevención contra captura de pantalla/grabación
  await ScreenProtector.preventScreenshotOn();

  // Cargamos las variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializamos Supabase
  await ConfiguracionSupabase.inicializar();

  runApp(const ProviderScope(child: MyApp()));
}

/// Widget raíz de BRISMAR APP.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BRISMAR APP',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D255F),
        primaryColor: const Color(0xFF0D255F),
      ),
      routerConfig: enrutador,
    );
  }
}
