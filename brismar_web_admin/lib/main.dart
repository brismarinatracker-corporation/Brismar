import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'nucleo/red/constantes_supabase.dart';
import 'nucleo/enrutador/enrutador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ConstantesSupabase.urlSupabase,
    anonKey: ConstantesSupabase.llaveAnonima,
  );

  runApp(
    const ProviderScope(
      child: BrismarWebAdminApp(),
    ),
  );
}

class BrismarWebAdminApp extends StatelessWidget {
  const BrismarWebAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Brismar Web Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF070E22), 
      ),
      routerConfig: enrutadorApp,
    );
  }
}
