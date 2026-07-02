import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controladores/controlador_transito.dart';
import 'package:brismar_web_admin/nucleo/componentes/carga_orbital.dart';

class FiltroTransitoNotifier extends Notifier<String> {
  @override
  String build() => 'todos';

  void establecerFiltro(String nuevoFiltro) {
    state = nuevoFiltro;
  }
}

final proveedorFiltroTransito = NotifierProvider<FiltroTransitoNotifier, String>(() {
  return FiltroTransitoNotifier();
});

// Esta pantalla ahora es FRONTEND PURO. Solo Dibuja. No sabe de Supabase.
class PantallaTransito extends ConsumerWidget {
  const PantallaTransito({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el estado del controlador y del filtro
    final estadoZarpes = ref.watch(proveedorTransito);
    final filtro = ref.watch(proveedorFiltroTransito);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dark Blue Header Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F2D4A), // Deep navy blue
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Radar de tránsito (cámaras entrantes)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vista en tiempo real de las cámaras despachadas desde Piura.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => ref.read(proveedorTransito.notifier).recargar(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Actualizar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        
        // Filter bar
        Padding(
          padding: const EdgeInsets.only(left: 32, right: 32, top: 24),
          child: Row(
            children: [
              const Icon(Icons.filter_alt_outlined, color: Color(0xFF64748B), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filtrar por fecha:',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              _FiltroChip(
                label: 'Todos',
                activo: filtro == 'todos',
                onTap: () => ref.read(proveedorFiltroTransito.notifier).establecerFiltro('todos'),
              ),
              const SizedBox(width: 8),
              _FiltroChip(
                label: 'Esta Semana',
                activo: filtro == 'semana',
                onTap: () => ref.read(proveedorFiltroTransito.notifier).establecerFiltro('semana'),
              ),
              const SizedBox(width: 8),
              _FiltroChip(
                label: 'Este Mes',
                activo: filtro == 'mes',
                onTap: () => ref.read(proveedorFiltroTransito.notifier).establecerFiltro('mes'),
              ),
              const SizedBox(width: 8),
              _FiltroChip(
                label: 'Este Año',
                activo: filtro == 'anio',
                onTap: () => ref.read(proveedorFiltroTransito.notifier).establecerFiltro('anio'),
              ),
            ],
          ),
        ),

        // Main list container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: estadoZarpes.when(
              loading: () => const Center(child: CargaOrbital(tamano: 80)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (zarpes) {
                // Filter the zarpes in-memory
                final zarpesFiltrados = zarpes.where((z) {
                  if (filtro == 'todos') return true;
                  final fechaStr = z['fecha_zarpe'];
                  if (fechaStr == null) return false;
                  final fecha = DateTime.tryParse(fechaStr);
                  if (fecha == null) return false;

                  final ahora = DateTime.now();
                  if (filtro == 'semana') {
                    final haceUnaSemana = ahora.subtract(const Duration(days: 7));
                    return fecha.isAfter(haceUnaSemana);
                  } else if (filtro == 'mes') {
                    final haceUnMes = ahora.subtract(const Duration(days: 30));
                    return fecha.isAfter(haceUnMes);
                  } else if (filtro == 'anio') {
                    return fecha.year == ahora.year;
                  }
                  return true;
                }).toList();

                if (zarpesFiltrados.isEmpty) {
                  return const Center(
                    child: Text('No hay tránsitos que coincidan con el filtro seleccionado.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                  );
                }

                return ListView.separated(
                  itemCount: zarpesFiltrados.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final z = zarpesFiltrados[i];
                    final fechaStr = z['fecha_zarpe'];
                    final fecha = fechaStr != null ? DateTime.tryParse(fechaStr) : null;
                    final fechaFormateada = fecha != null ? DateFormat('dd/MM/yyyy hh:mm a').format(fecha) : 'Fecha Desconocida';
                    final urlFoto = z['foto_url_evidencia'] ?? '';
                    final estaRecibido = z['estado_transito'] == 'RECIBIDO_LAMBAYEQUE';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Left Status Stripe
                              Container(
                                width: 6,
                                color: estaRecibido ? const Color(0xFF16A34A) : const Color(0xFF1E88E5), // Green if received, Blue if in transit
                              ),
                              const SizedBox(width: 20),
                              // Image/Photo placeholder
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: urlFoto.toString().isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        urlFoto,
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 72, height: 72, color: const Color(0xFFE6F0FA),
                                          child: const Icon(Icons.broken_image, color: Color(0xFF1E88E5), size: 24),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F0FA),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF1E88E5), size: 24),
                                    ),
                              ),
                              const SizedBox(width: 20),
                              // Main texts column
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: estaRecibido ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              estaRecibido ? 'Recibido' : 'En tránsito',
                                              style: TextStyle(
                                                color: estaRecibido ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Placa: ${z['placa_camara']}',
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Chofer: ${z['chofer']}  ·  Muelle: ${z['muelle_partida']}',
                                        style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Carga: ${z['peso_total'] ?? 0} kg  ·  Cajas: ${z['cajas_llenas'] ?? 0}  ·  Lanchas: ${(z['embarcaciones_asociadas'] ?? 'ninguna').toString().toLowerCase()}',
                                        style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            'Flete total: S/. ${z['costo_flete'] ?? '0'}',
                                            style: const TextStyle(color: Color(0xFF065F46), fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Despacho: ${fechaFormateada.replaceAll('AM', 'a.m.').replaceAll('PM', 'p.m.')}',
                                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Action buttons
                              Padding(
                                padding: const EdgeInsets.only(right: 20, top: 16, bottom: 16),
                                child: SizedBox(
                                  width: 170,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          context.go('/transito/editar/${z['id']}');
                                        },
                                        icon: const Icon(Icons.edit_outlined, size: 16),
                                        label: const Text('Ver / editar'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF374151),
                                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                      if (!estaRecibido) ...[
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                           onPressed: () => _mostrarDialogoRecepcion(
                                             context,
                                             ref,
                                             z['id'],
                                             (z['embarcaciones_asociadas'] ?? '').toString(),
                                             (z['peso_total'] as num?)?.toDouble() ?? 0.0,
                                           ),
                                           icon: const Icon(Icons.check_rounded, size: 16),
                                           label: const Text('Marcar recibido'),
                                           style: ElevatedButton.styleFrom(
                                             backgroundColor: const Color(0xFF0D5C75), // Dark teal green/blue matching mockup
                                             foregroundColor: Colors.white,
                                             elevation: 0,
                                             padding: const EdgeInsets.symmetric(vertical: 10),
                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                           ),
                                         ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
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
        ),
      ],
    );
  }

  void _mostrarDialogoRecepcion(BuildContext context, WidgetRef ref, String id, String embarcaciones, double pesoInicial) {
    String plantaSeleccionada = 'DEXIM';
    String especieSeleccionada = 'POTA';
    final kilosCtrl = TextEditingController(text: pesoInicial > 0 ? pesoInicial.toString() : '');
    final precioCtrl = TextEditingController();
    final otraPlantaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1E201E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Recepción en Planta',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
              ),
              SizedBox(height: 4),
              Text(
                'Completa los datos de venta finales de esta cámara.',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _construirEtiquetaDialogo('Planta de Destino (Procesadora)'),
                DropdownButtonFormField<String>(
                  value: plantaSeleccionada,
                  dropdownColor: const Color(0xFF1E201E),
                  iconEnabledColor: Colors.white70,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona planta'),
                  items: ['DEXIM', 'SEAFROST', 'ALTAMAR', 'PERUPEZ', 'TRANSMARINA', 'OTROS'].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return ['DEXIM', 'SEAFROST', 'ALTAMAR', 'PERUPEZ', 'TRANSMARINA', 'OTROS'].map<Widget>((String value) {
                      return Text(value, style: const TextStyle(color: Colors.white, fontSize: 14));
                    }).toList();
                  },
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => plantaSeleccionada = val);
                  },
                ),
                if (plantaSeleccionada == 'OTROS') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: otraPlantaCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: _decoracionDialogo('Nombre de la planta procesadora'),
                  ),
                ],
                _construirEtiquetaDialogo('Especie comercializada'),
                DropdownButtonFormField<String>(
                  value: especieSeleccionada,
                  dropdownColor: const Color(0xFF1E201E),
                  iconEnabledColor: Colors.white70,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona especie'),
                  items: ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"].map<Widget>((String value) {
                      return Text(value, style: const TextStyle(color: Colors.white, fontSize: 14));
                    }).toList();
                  },
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => especieSeleccionada = val);
                  },
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Kilos Finales'),
                          TextField(
                            controller: kilosCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Precio Venta (x Kg)'),
                          TextField(
                            controller: precioCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('S/ 0.00'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final kilos = double.tryParse(kilosCtrl.text) ?? 0.0;
                    final precio = double.tryParse(precioCtrl.text) ?? 0.0;
                    final planta = plantaSeleccionada == 'OTROS' ? otraPlantaCtrl.text.trim().toUpperCase() : plantaSeleccionada;
                    if (planta.isEmpty || kilos <= 0 || precio <= 0) return;

                    Navigator.pop(ctx);

                    try {
                      await ref.read(proveedorTransito.notifier).registrarRecepcionEnPlanta(
                        id: id,
                        planta: planta,
                        especie: especieSeleccionada,
                        kilos: kilos,
                        precio: precio,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recepción registrada con éxito en planta $planta.'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: const Text('Confirmar Recepción', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirEtiquetaDialogo(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  InputDecoration _decoracionDialogo(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF2D302D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white38)),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorPrimario = const Color(0xFF0D5C75);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? colorPrimario : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? colorPrimario : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          boxShadow: activo ? [
            BoxShadow(
              color: colorPrimario.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: activo ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
