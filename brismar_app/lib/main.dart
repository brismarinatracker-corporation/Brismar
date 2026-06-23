import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'nucleo/red/cliente_supabase.dart';
import 'nucleo/rutas/enrutador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('es'),
      ],
      locale: const Locale('es', 'ES'),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF040B1E),
        primaryColor: const Color(0xFF040B1E),
      ),
      routerConfig: enrutador,
    );
  }
}
