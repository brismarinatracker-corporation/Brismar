import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controladores/controlador_transito.dart';
import 'package:brismar_web_admin/nucleo/componentes/carga_orbital.dart';

// Esta pantalla ahora es FRONTEND PURO. Solo Dibuja. No sabe de Supabase.
class PantallaTransito extends ConsumerWidget {
  const PantallaTransito({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el estado del controlador
    final estadoZarpes = ref.watch(proveedorTransito);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Radar de Tránsito (Cámaras Entrantes)',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => ref.read(proveedorTransito.notifier).recargar(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF070E22),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Vista en tiempo real de las cámaras despachadas desde Piura. Marca como recibida al llegar.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: estadoZarpes.when(
              loading: () => const Center(child: CargaOrbital(tamano: 80)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (zarpes) {
                if (zarpes.isEmpty) {
                  return const Center(
                    child: Text('No hay tránsitos activos desde Piura.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.separated(
                  itemCount: zarpes.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final z = zarpes[i];
                    final fechaStr = z['fecha_zarpe'];
                    final fecha = fechaStr != null ? DateTime.tryParse(fechaStr) : null;
                    final fechaFormateada = fecha != null ? DateFormat('dd/MM/yyyy hh:mm a').format(fecha) : 'Fecha Desconocida';
                    final urlFoto = z['foto_url_evidencia'] ?? '';
                    final estaRecibido = z['estado_transito'] == 'RECIBIDO_LAMBAYEQUE';

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/transito/editar/${z['id']}'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F224A).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                      child: Row(
                        children: [
                          _construirEvidenciaFotos(context, urlFoto),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: estaRecibido ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.orangeAccent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        estaRecibido ? 'RECIBIDO' : 'EN TRÁNSITO', 
                                        style: TextStyle(
                                          color: estaRecibido ? Colors.greenAccent : Colors.orangeAccent, 
                                          fontSize: 10, 
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Placa: ${z['placa_camara']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Chofer: ${z['chofer']}  |  Muelle: ${z['muelle_partida']}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Carga: ${z['peso_total'] ?? 0} Kg  |  Cajas: ${z['cajas_llenas'] ?? 0}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Lanchas: ${z['embarcaciones_asociadas'] ?? 'Ninguna'}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Flete Total: S/. ${z['costo_flete'] ?? '0.00'}', style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Despacho: $fechaFormateada', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Navegar a la pantalla de edición
                                  context.go('/transito/editar/${z['id']}');
                                },
                                icon: const Icon(Icons.edit_document),
                                label: const Text('Ver / Editar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white12,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              if (!estaRecibido) ...[
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      await ref.read(proveedorTransito.notifier).marcarComoRecibido(z['id']);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Cámara recibida con éxito.'), backgroundColor: Colors.green),
                                        );
                                      }
                                    } catch(e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Marcar Recibido'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E5FF),
                                    foregroundColor: const Color(0xFF070E22),
                                  ),
                                ),
                              ]
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarLightbox(BuildContext context, List<String> urls) {
    showDialog(
      context: context,
      builder: (ctx) {
        int indexActual = 0;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
                decoration: BoxDecoration(
                  color: const Color(0xFF070E22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InteractiveViewer(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            urls[indexActual],
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    if (urls.length > 1 && indexActual > 0)
                      Positioned(
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: () {
                              setStateDialog(() => indexActual--);
                            },
                          ),
                        ),
                      ),
                    if (urls.length > 1 && indexActual < urls.length - 1)
                      Positioned(
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.white),
                            onPressed: () {
                              setStateDialog(() => indexActual++);
                            },
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${indexActual + 1} / ${urls.length}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _construirEvidenciaFotos(BuildContext context, String urlFoto) {
    final urls = urlFoto.split(',').map((u) => u.trim()).where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white54),
      );
    }

    return InkWell(
      onTap: () => _mostrarLightbox(context, urls),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              urls[0],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 80,
                height: 80,
                color: Colors.black26,
                child: const Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${urls.length - 1}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
