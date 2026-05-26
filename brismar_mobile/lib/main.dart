import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nucleo/red/supabase_client.dart';
import 'nucleo/rutas/enrutador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Supabase (con simulación interna si es la URL de plantilla)
  await SupabaseConfig.inicializar();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
