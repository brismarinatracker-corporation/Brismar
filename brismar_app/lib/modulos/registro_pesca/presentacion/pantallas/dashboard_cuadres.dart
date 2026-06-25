import 'formulario_cuadre_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controladores/controlador_cuadres.dart';

class DashboardCuadresPantalla extends ConsumerWidget {
  const DashboardCuadresPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoCuadres = ref.watch(cuadresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuadres de Pesca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(cuadresProvider.notifier).cargarHistorial(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: estadoCuadres.when(
        data: (cuadres) {
          if (cuadres.isEmpty) {
            return const Center(
              child: Text('No tienes cuadres registrados.\\nPresiona + para crear uno.', textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            itemCount: cuadres.length,
            itemBuilder: (context, index) {
              final cuadre = cuadres[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Placa: ${cuadre.placa}'),
                  subtitle: Text('Zarpe: ${cuadre.fechaZarpe ?? 'Pendiente'} - Estado: ${cuadre.estado}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cuadre.sincronizado) ...[
                        if (cuadre.urlPdfCloud != null)
                          IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.red), onPressed: () {}),
                        if (cuadre.urlExcelCloud != null)
                          IconButton(icon: const Icon(Icons.table_chart, color: Colors.green), onPressed: () {}),
                      ] else ...[
                        const Icon(Icons.cloud_off, color: Colors.grey),
                      ]
                    ],
                  ),
                  onTap: () {
                    // TODO: Navegar a FormularioCuadrePantalla para editar/ver
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => const FormularioCuadreTabs(),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
