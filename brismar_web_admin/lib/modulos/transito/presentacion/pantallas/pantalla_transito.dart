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
                style: TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => ref.read(proveedorTransito.notifier).recargar(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ACC1).withOpacity(0.08),
                  foregroundColor: const Color(0xFF00838F),
                  elevation: 0,
                  side: BorderSide(color: const Color(0xFF00ACC1).withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Vista en tiempo real de las cámaras despachadas desde Piura. Marca como recibida al llegar.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 16),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: estadoZarpes.when(
              loading: () => const Center(child: CargaOrbital(tamano: 80)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (zarpes) {
                if (zarpes.isEmpty) {
                  return const Center(
                    child: Text('No hay tránsitos activos desde Piura.', style: TextStyle(color: Color(0xFF64748B))),
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
                    final estaRecibido = z['estado'] == 'RECIBIDO_LAMBAYEQUE';

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/transito/editar/${z['id']}'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              if (urlFoto.toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    urlFoto,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 80, height: 80, color: const Color(0xFFF1F5F9),
                                      child: const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 80, height: 80, 
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.camera_alt, color: Color(0xFF94A3B8)),
                                ),
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
                                            color: estaRecibido ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            estaRecibido ? 'RECIBIDO' : 'EN TRÁNSITO', 
                                            style: TextStyle(
                                              color: estaRecibido ? const Color(0xFF1B5E20) : const Color(0xFFE65100), 
                                              fontSize: 10, 
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('Placa: ${z['placa_camara']}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Chofer: ${z['chofer']}  |  Muelle: ${z['muelle_partida']}', style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('Carga: ${z['peso_total'] ?? 0} Kg  |  Cajas: ${z['cajas_llenas'] ?? 0}', style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('Lanchas: ${z['embarcaciones_asociadas'] ?? 'Ninguna'}', style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('Flete Total: S/. ${z['costo_flete'] ?? '0.00'}', style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Despacho: $fechaFormateada', style: const TextStyle(color: Color(0xFF00838F), fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        context.go('/transito/editar/${z['id']}');
                                      },
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      label: const Text('Ver / editar'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF374151),
                                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                        icon: const Icon(Icons.check_rounded, size: 18),
                                        label: const Text('Marcar recibido'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00796B),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
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
}
