import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controladores/controlador_transito.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../compartido/widgets/shimmer_carga.dart';

// Esta pantalla es FRONTEND PURO. Solo dibuja. No sabe de Supabase.
// El filtro y los datos vienen del ControladorTransito (capa de lógica).
class PantallaTransito extends ConsumerStatefulWidget {
  const PantallaTransito({super.key});

  @override
  ConsumerState<PantallaTransito> createState() => _PantallaTransitoState();
}

class _PantallaTransitoState extends ConsumerState<PantallaTransito> {
  int _paginaActual = 0;
  static const int _elementosPorPagina = 6;

  @override
  Widget build(BuildContext context) {
    // Escucha el estado del controlador y del filtro
    final estadoZarpes = ref.watch(proveedorTransito);
    final filtro = ref.watch(proveedorFiltroTransito);

    return Container(
      color: const Color(0xFFEEF3F1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark Blue Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF0A2440),
                  Color(0xFF123A5C),
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      'Radar de tránsito (cámaras entrantes)',
                      style: GoogleFonts.fraunces(
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
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('todos');
                  setState(() => _paginaActual = 0);
                },
              ),
              const SizedBox(width: 8),
              _FiltroChip(
                label: 'Esta Semana',
                activo: filtro == 'semana',
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('semana');
                  setState(() => _paginaActual = 0);
                },
              ),
              const SizedBox(width: 8),
              _FiltroChip(
                label: 'Este Mes',
                activo: filtro == 'mes',
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('mes');
                  setState(() => _paginaActual = 0);
                },
              ),
              const SizedBox(width: 8),
              _FiltroChip(
                label: 'Este Año',
                activo: filtro == 'anio',
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('anio');
                  setState(() => _paginaActual = 0);
                },
              ),
            ],
          ),
        ),

        // Main list container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: (() {
              final hasData = estadoZarpes.hasValue && estadoZarpes.value!.isNotEmpty;
              if (estadoZarpes.isLoading && !hasData) {
                return const ShimmerTablaCarga(oscuro: false, filas: 5);
              }
              if (estadoZarpes.hasError && !hasData) {
                return Center(child: Text('Error: ${estadoZarpes.error}', style: const TextStyle(color: Colors.redAccent)));
              }
              final zarpesFiltrados = estadoZarpes.value ?? [];

                if (zarpesFiltrados.isEmpty) {
                  return const Center(
                    child: Text('No hay tránsitos que coincidan con el filtro seleccionado.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                  );
                }

                final startIndex = _paginaActual * _elementosPorPagina;
                final endIndex = (startIndex + _elementosPorPagina > zarpesFiltrados.length)
                    ? zarpesFiltrados.length
                    : startIndex + _elementosPorPagina;
                
                final zarpesPaginados = zarpesFiltrados.sublist(startIndex, endIndex);
                final totalPaginas = (zarpesFiltrados.length / _elementosPorPagina).ceil();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: zarpesPaginados.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                        itemBuilder: (ctx, i) {
                          final z = zarpesPaginados[i];
                          final fecha = z.fechaZarpe;
                          final fechaFormateada = fecha != null ? DateFormat('dd/MM/yyyy hh:mm a').format(fecha) : 'Fecha Desconocida';
                          final urlFoto = z.fotoUrlEvidencia ?? '';
                          final estaRecibido = z.estado.estaFinalizado;

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
                                                  'Placa: ${z.placaCamara}',
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
                                              'Chofer: ${z.chofer}  ·  Muelle: ${z.muellePartida}',
                                              style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Carga: ${z.pesoTotal ?? 0} kg  ·  Cajas: ${z.cajasLlenas ?? 0}  ·  Lanchas: ${(z.embarcacionesAsociadas ?? 'ninguna').toLowerCase()}',
                                              style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  'Flete total: S/. ${z.costoFlete ?? '0'}',
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
                                                context.go('/transito/editar/${z.id}');
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
                                                   z.id,
                                                   z.embarcacionesAsociadas ?? '',
                                                   z.pesoTotal ?? 0.0,
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
                      ),
                    ),
                    // Controles de paginación
                    if (totalPaginas > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _paginaActual > 0
                                  ? () => setState(() => _paginaActual--)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Página ${_paginaActual + 1} de $totalPaginas',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _paginaActual < totalPaginas - 1
                                  ? () => setState(() => _paginaActual++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              })(),
          ),
        ),
      ],
    ),
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
                  initialValue: plantaSeleccionada,
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
                  initialValue: especieSeleccionada,
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

class _FiltroChip extends StatefulWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  State<_FiltroChip> createState() => _FiltroChipState();
}

class _FiltroChipState extends State<_FiltroChip> {
  bool _estaCerniendo = false;

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF0F766E); // Sea green
    
    final colorFondo = widget.activo
        ? colorPrimario
        : (_estaCerniendo ? const Color(0xFFE2E8F0) : Colors.white);

    final colorBorde = widget.activo
        ? colorPrimario
        : (_estaCerniendo ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1));

    return MouseRegion(
      onEnter: (_) => setState(() => _estaCerniendo = true),
      onExit: (_) => setState(() => _estaCerniendo = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorBorde,
              width: 1.5,
            ),
            boxShadow: widget.activo ? [
              BoxShadow(
                color: colorPrimario.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: widget.activo ? Colors.white : const Color(0xFF475569),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
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
