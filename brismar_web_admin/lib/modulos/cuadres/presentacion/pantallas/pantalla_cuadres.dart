import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controladores/controlador_cuadres.dart';

// Frontend puro, sin Supabase ni Excel
class PantallaCuadres extends ConsumerWidget {
  const PantallaCuadres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoExportacion = ref.watch(proveedorCuadres);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Exportación de Cuadres',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: estadoExportacion.isLoading 
                  ? null 
                  : () async {
                      await ref.read(proveedorCuadres.notifier).exportarAExcel();
                      if (ref.read(proveedorCuadres).hasError) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Error: ${ref.read(proveedorCuadres).error}'), backgroundColor: Colors.red),
                           );
                         }
                      } else {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Excel exportado exitosamente!'), backgroundColor: Colors.green),
                          );
                         }
                      }
                    },
                icon: estadoExportacion.isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF070E22), strokeWidth: 2))
                  : const Icon(Icons.download_rounded),
                label: const Text('Exportar a Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF070E22),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Exporta los registros generados en Piura a formato Excel para el área de contabilidad.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(Icons.table_view_rounded, size: 120, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 24),
                const Text(
                  'Haz clic en "Exportar a Excel" para descargar los últimos registros de la nube.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
