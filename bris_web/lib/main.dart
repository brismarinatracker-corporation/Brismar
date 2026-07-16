import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'nucleo/red/constantes_supabase.dart';
import 'nucleo/enrutador/enrutador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeDateFormatting('es', null);

  await Supabase.initialize(
    url: ConstantesSupabase.urlSupabase,
    publishableKey: ConstantesSupabase.llaveAnonima,
  );

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF070E22),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F224A).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFF00E5FF),
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ups, algo inesperado ocurrió',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(const ProviderScope(child: BrismarWebAdminApp()));
}

class BrismarWebAdminApp extends ConsumerWidget {
  const BrismarWebAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseTextTheme = ThemeData(brightness: Brightness.light).textTheme;

    return MaterialApp.router(
      title: 'BrisWeb',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('es')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E3E2C),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(baseTextTheme)
            .copyWith(
              displayLarge: GoogleFonts.sora(
                textStyle: baseTextTheme.displayLarge?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              displayMedium: GoogleFonts.sora(
                textStyle: baseTextTheme.displayMedium?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              displaySmall: GoogleFonts.sora(
                textStyle: baseTextTheme.displaySmall?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              headlineLarge: GoogleFonts.sora(
                textStyle: baseTextTheme.headlineLarge?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              headlineMedium: GoogleFonts.sora(
                textStyle: baseTextTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              headlineSmall: GoogleFonts.sora(
                textStyle: baseTextTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              titleLarge: GoogleFonts.sora(
                textStyle: baseTextTheme.titleLarge?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              titleMedium: GoogleFonts.sora(
                textStyle: baseTextTheme.titleMedium?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
              titleSmall: GoogleFonts.sora(
                textStyle: baseTextTheme.titleSmall?.copyWith(
                  color: const Color(0xFF15181A),
                ),
              ),
            )
            .apply(
              bodyColor: const Color(0xFF15181A),
              displayColor: const Color(0xFF15181A),
            ),
        scaffoldBackgroundColor: const Color(0xFFF2F6F3),
      ),
      routerConfig: ref.watch(proveedorEnrutador),
    );
  }
}
