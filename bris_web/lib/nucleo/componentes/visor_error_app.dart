import 'package:flutter/material.dart';

/// Componente visual reutilizable para renderizar errores runtime no controlados.
///
/// Muestra un mensaje amigable y seguro sin comprometer la estabilidad del sistema.
class VisorErrorApp extends StatelessWidget {
  /// Detalles del error ocurrido en Flutter.
  final FlutterErrorDetails detalles;

  /// Crea una instancia del visor de errores.
  const VisorErrorApp({super.key, required this.detalles});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Material(
      color: tema.colorScheme.surface,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(16),
          decoration: _construirDecoracion(tema),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, color: tema.colorScheme.error, size: 64),
              const SizedBox(height: 24),
              Text(
                'Ups, algo inesperado ocurrió',
                style: tema.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                detalles.exceptionAsString(),
                style: tema.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la decoración del contenedor con sombras y bordes defensivos.
  BoxDecoration _construirDecoracion(ThemeData tema) {
    return BoxDecoration(
      color: tema.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: tema.colorScheme.error.withValues(alpha: 0.3),
        width: 2,
      ),
    );
  }
}
