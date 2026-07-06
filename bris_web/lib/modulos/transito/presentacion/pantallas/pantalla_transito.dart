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
    final esMovil = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFFF2F6F3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark Blue Header Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: esMovil ? 20 : 32, vertical: esMovil ? 20 : 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF0E3E2C), Color(0xFF0E3E2C)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: esMovil
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Radar de tránsito (cámaras entrantes)', style: GoogleFonts.sora(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Vista en tiempo real de las cámaras despachadas desde Piura.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 16),
                      _BotonActualizarTransito(ref: ref),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Radar de tránsito (cámaras entrantes)', style: GoogleFonts.sora(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Vista en tiempo real de las cámaras despachadas desde Piura.', style: TextStyle(color: Colors.white70, fontSize: 15)),
                        ],
                      ),
                      _BotonActualizarTransito(ref: ref),
                    ],
                  ),
          ),
        
        // Filter bar
        Padding(
          padding: EdgeInsets.only(left: esMovil ? 20 : 32, right: esMovil ? 20 : 32, top: esMovil ? 16 : 24),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt_outlined, color: Color(0xFF64748B), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Filtrar por fecha:',
                    style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(width: esMovil ? 0 : 8),
                ],
              ),
              _FiltroChip(
                label: 'Todos',
                activo: filtro == 'todos',
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('todos');
                  setState(() => _paginaActual = 0);
                },
              ),
              _FiltroChip(
                label: 'Ayer',
                activo: filtro == 'ayer',
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('ayer');
                  setState(() => _paginaActual = 0);
                },
              ),
              _FiltroChip(
                label: 'Esta Semana',
                activo: filtro == 'semana',
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('semana');
                  setState(() => _paginaActual = 0);
                },
              ),
              _FiltroChip(
                label: 'Este Mes',
                activo: filtro == 'mes',
                onTap: () {
                  ref.read(proveedorFiltroTransito.notifier).establecerFiltro('mes');
                  setState(() => _paginaActual = 0);
                },
              ),
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
            padding: EdgeInsets.symmetric(horizontal: esMovil ? 20.0 : 32.0, vertical: 16.0),
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
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Left Status Stripe
                                    Container(
                                      width: 6,
                                      color: estaRecibido ? const Color(0xFF16A34A) : const Color(0xFF1E88E5), // Green if received, Blue if in transit
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Image/Photo placeholder
                                                if (urlFoto.toString().isNotEmpty)
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(urlFoto, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 64, height: 64, color: const Color(0xFFE6F0FA), child: const Icon(Icons.broken_image, color: Color(0xFF1E88E5), size: 24))),
                                                  )
                                                else
                                                  Container(
                                                    width: 64, height: 64,
                                                    decoration: BoxDecoration(color: const Color(0xFFE6F0FA), borderRadius: BorderRadius.circular(8)),
                                                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF1E88E5), size: 24),
                                                  ),
                                                const SizedBox(width: 16),
                                                // Main texts column
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Wrap(
                                                        spacing: 8,
                                                        runSpacing: 4,
                                                        crossAxisAlignment: WrapCrossAlignment.center,
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                            decoration: BoxDecoration(color: estaRecibido ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20)),
                                                            child: Text(estaRecibido ? 'Recibido' : 'En tránsito', style: TextStyle(color: estaRecibido ? const Color(0xFF1B5E20) : const Color(0xFFE65100), fontSize: 11, fontWeight: FontWeight.bold)),
                                                          ),
                                                          Text('Placa: ${z.placaCamara}', style: const TextStyle(color: Color(0xFF15181A), fontSize: 16, fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text('Chofer: ${z.chofer}  ·  Muelle: ${z.muellePartida}', style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500)),
                                                      const SizedBox(height: 4),
                                                      Text('Carga: ${z.pesoTotal ?? 0} kg  ·  Cajas: ${z.cajasLlenas ?? 0}  ·  Lanchas: ${(z.embarcacionesAsociadas ?? 'ninguna').toLowerCase()}', style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500)),
                                                      const SizedBox(height: 6),
                                                      Wrap(
                                                        spacing: 16,
                                                        runSpacing: 4,
                                                        children: [
                                                          Text('Flete total: S/. ${z.costoFlete ?? '0'}', style: const TextStyle(color: Color(0xFF065F46), fontSize: 13, fontWeight: FontWeight.bold)),
                                                          Text('Despacho: ${fechaFormateada.replaceAll('AM', 'a.m.').replaceAll('PM', 'p.m.')}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (esMovil) ...[
                                              const SizedBox(height: 16),
                                              _BotonesAccionTransito(z: z, estaRecibido: estaRecibido, onMarcarRecibido: (zId, emb, peso) => _mostrarDialogoRecepcion(context, ref, zId, emb, peso)),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (!esMovil)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 20, top: 16, bottom: 16),
                                        child: SizedBox(
                                          width: 170,
                                          child: _BotonesAccionTransito(z: z, estaRecibido: estaRecibido, onMarcarRecibido: (zId, emb, peso) => _mostrarDialogoRecepcion(context, ref, zId, emb, peso)),
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
    bool guardando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (contextDialog, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Recepción en Planta',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15181A), fontSize: 22),
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
                  dropdownColor: Colors.white,
                  iconEnabledColor: const Color(0xFF64748B),
                  style: const TextStyle(color: Color(0xFF15181A), fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona planta'),
                  items: ['DEXIM', 'SEAFROST', 'ALTAMAR', 'PERUPEZ', 'TRANSMARINA', 'OTROS'].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Color(0xFF15181A), fontSize: 14)),
                      )).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return ['DEXIM', 'SEAFROST', 'ALTAMAR', 'PERUPEZ', 'TRANSMARINA', 'OTROS'].map<Widget>((String value) {
                      return Text(value, style: const TextStyle(color: Color(0xFF15181A), fontSize: 14));
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
                    style: const TextStyle(color: Color(0xFF15181A), fontSize: 14),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: _decoracionDialogo('Nombre de la planta procesadora'),
                  ),
                ],
                _construirEtiquetaDialogo('Especie comercializada'),
                DropdownButtonFormField<String>(
                  value: especieSeleccionada,
                  dropdownColor: Colors.white,
                  iconEnabledColor: const Color(0xFF64748B),
                  style: const TextStyle(color: Color(0xFF15181A), fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona especie'),
                  items: ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Color(0xFF15181A), fontSize: 14)),
                      )).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"].map<Widget>((String value) {
                      return Text(value, style: const TextStyle(color: Color(0xFF15181A), fontSize: 14));
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
                            style: const TextStyle(color: Color(0xFF15181A), fontSize: 14),
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
                            style: const TextStyle(color: Color(0xFF15181A), fontSize: 14),
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
                  onPressed: guardando ? null : () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF64748B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF15181A), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: guardando ? null : () async {
                    final kilos = double.tryParse(kilosCtrl.text) ?? 0.0;
                    final precio = double.tryParse(precioCtrl.text) ?? 0.0;
                    final planta = plantaSeleccionada == 'OTROS' ? otraPlantaCtrl.text.trim().toUpperCase() : plantaSeleccionada;
                    
                    if (planta.isEmpty || kilos <= 0) {
                      showDialog(
                        context: ctx,
                        builder: (c) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                              SizedBox(width: 12),
                              Text('Datos incompletos', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: const Text('Por favor, selecciona una planta destino e ingresa una cantidad de kilos mayor a 0.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('Entendido', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    setStateDialog(() => guardando = true);

                    try {
                      await ref.read(proveedorTransito.notifier).registrarRecepcionEnPlanta(
                        id: id,
                        planta: planta,
                        especie: especieSeleccionada,
                        kilos: kilos,
                        precio: precio,
                      );
                      
                      if (contextDialog.mounted) {
                        Navigator.pop(ctx); // Cierra el formulario principal
                        
                        // Muestra el mensaje de éxito usando el contexto principal
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 28),
                                SizedBox(width: 12),
                                Text('¡Recepción Exitosa!', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: Text('La recepción se registró correctamente en la planta $planta.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Aceptar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      if (contextDialog.mounted) {
                        setStateDialog(() => guardando = false);
                        showDialog(
                          context: ctx,
                          builder: (c) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 28),
                                SizedBox(width: 12),
                                Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: Text('No se pudo registrar la recepción:\n$e'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Aceptar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  icon: guardando 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF15181A)))
                      : const Icon(Icons.check, size: 18, color: Color(0xFF15181A)),
                  label: Text(guardando ? 'Guardando...' : 'Confirmar Recepción', style: const TextStyle(color: Color(0xFF15181A), fontWeight: FontWeight.bold)),
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
        child: Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  InputDecoration _decoracionDialogo(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF64748B))),
    );
  }
}

class _BotonActualizarTransito extends StatelessWidget {
  const _BotonActualizarTransito({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => ref.read(proveedorTransito.notifier).recargar(),
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Actualizar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _BotonesAccionTransito extends StatelessWidget {
  final dynamic z;
  final bool estaRecibido;
  final Function(String, String, double) onMarcarRecibido;

  const _BotonesAccionTransito({required this.z, required this.estaRecibido, required this.onMarcarRecibido});

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 800;
    return Flex(
      direction: esMovil ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: esMovil ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      mainAxisAlignment: esMovil ? MainAxisAlignment.end : MainAxisAlignment.center,
      children: [
        if (esMovil) Expanded(child: _botonVerEditar(context)),
        if (!esMovil) _botonVerEditar(context),
        if (!estaRecibido) ...[
          SizedBox(height: esMovil ? 0 : 8, width: esMovil ? 8 : 0),
          if (esMovil) Expanded(child: _botonRecibir(context)),
          if (!esMovil) _botonRecibir(context),
        ]
      ],
    );
  }

  Widget _botonVerEditar(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.go('/transito/editar/${z.id}'),
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: const Text('Ver / editar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF374151),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _botonRecibir(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onMarcarRecibido(z.id, z.embarcacionesAsociadas ?? '', z.pesoTotal ?? 0.0),
      icon: const Icon(Icons.check_rounded, size: 16),
      label: const Text('Marcar recibido'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D5C75),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
