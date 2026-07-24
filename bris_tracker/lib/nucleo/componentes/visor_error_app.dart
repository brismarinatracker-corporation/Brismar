import 'package:flutter/material.dart';

/// Visor visual de errores runtime para BRISMAR Tracker.
///
/// Previene pantallas rojas en dispositivos móviles capturando excepciones de renderizado.
class VisorErrorAppTracker extends StatelessWidget {
  /// Detalles del error reportado por el motor de Flutter.
  final FlutterErrorDetails detalles;

  /// Crea la instancia del visor de errores para móvil.
  const VisorErrorAppTracker({super.key, required this.detalles});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Material(
      color: tema.scaffoldBackgroundColor,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: _construirDecoracion(tema),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: tema.colorScheme.error, size: 56),
              const SizedBox(height: 16),
              Text(
                'Ocurrió un inconveniente temporal',
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                detalles.exceptionAsString(),
                style: tema.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Genera el estilo del contenedor de error adaptado al tema.
  BoxDecoration _construirDecoracion(ThemeData tema) {
    return BoxDecoration(
      color: tema.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: tema.colorScheme.error.withValues(alpha: 0.4),
        width: 1.5,
      ),
    );
  }
}
