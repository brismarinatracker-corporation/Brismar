import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controladores/controlador_transito.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../compartido/widgets/shimmer_carga.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:bris_web/compartido/widgets/cabecera_pagina_web.dart';
import 'package:bris_web/nucleo/utils/optimizador_imagenes.dart';

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
    final authState = ref.watch(proveedorAutenticacion);
    final esSoloLectura =
        authState.rol == 'administrador' || authState.rol == 'supervisor';
    final esMovil = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFFF2F6F3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabeceraPaginaWeb(
            titulo: 'Radar de tránsito (cámaras entrantes)',
            subtitulo:
                'Vista en tiempo real de las cámaras despachadas desde Piura.',
            widgetAccion: _BotonActualizarTransito(ref: ref),
          ),

          // Filter bar
          Padding(
            padding: EdgeInsets.only(
              left: esMovil ? 16 : 32,
              right: esMovil ? 16 : 32,
              top: esMovil ? 12 : 24,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FiltroChip(
                    label: 'Todos',
                    activo: filtro == 'todos',
                    onTap: () {
                      ref
                          .read(proveedorFiltroTransito.notifier)
                          .establecerFiltro('todos');
                      setState(() => _paginaActual = 0);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Hoy',
                    activo: filtro == 'hoy',
                    onTap: () {
                      ref
                          .read(proveedorFiltroTransito.notifier)
                          .establecerFiltro('hoy');
                      setState(() => _paginaActual = 0);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Ayer',
                    activo: filtro == 'ayer',
                    onTap: () {
                      ref
                          .read(proveedorFiltroTransito.notifier)
                          .establecerFiltro('ayer');
                      setState(() => _paginaActual = 0);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Esta Semana',
                    activo: filtro == 'semana',
                    onTap: () {
                      ref
                          .read(proveedorFiltroTransito.notifier)
                          .establecerFiltro('semana');
                      setState(() => _paginaActual = 0);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Este Mes',
                    activo: filtro == 'mes',
                    onTap: () {
                      ref
                          .read(proveedorFiltroTransito.notifier)
                          .establecerFiltro('mes');
                      setState(() => _paginaActual = 0);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Main list container
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: esMovil ? 16.0 : 32.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: const Color(0xFF0E3E2C),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF64748B),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      dividerColor: Colors.transparent,
                      onTap: (_) => setState(() => _paginaActual = 0),
                      tabs: const [
                        Tab(text: 'Pendientes'),
                        Tab(text: 'Finalizados'),
                      ],
                    ),
                  ),

                  // Tab Bar View
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: esMovil ? 16.0 : 32.0,
                        vertical: 8.0,
                      ),
                      child: (() {
                        final hasData =
                            estadoZarpes.hasValue &&
                            estadoZarpes.value!.isNotEmpty;
                        if (estadoZarpes.isLoading && !hasData) {
                          return const ShimmerTablaCarga(
                            oscuro: false,
                            filas: 5,
                          );
                        }
                        if (estadoZarpes.hasError && !hasData) {
                          return Center(
                            child: Text(
                              'Error: ${estadoZarpes.error}',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }
                        final zarpesTotales = estadoZarpes.value ?? [];

                        Widget construirListaPaginada(bool finalizados) {
                          final zarpesFiltrados = zarpesTotales
                              .where(
                                (z) => z.estado.estaFinalizado == finalizados,
                              )
                              .toList();

                          if (zarpesFiltrados.isEmpty) {
                            return Center(
                              child: Text(
                                finalizados
                                    ? 'No hay cámaras recibidas para esta fecha.'
                                    : 'No hay cámaras en tránsito para esta fecha.',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          final startIndex =
                              _paginaActual * _elementosPorPagina;
                          final endIndex =
                              (startIndex + _elementosPorPagina >
                                  zarpesFiltrados.length)
                              ? zarpesFiltrados.length
                              : startIndex + _elementosPorPagina;

                          // Si la página actual es mayor a las páginas disponibles (por cambiar de tab)
                          if (startIndex >= zarpesFiltrados.length) {
                            Future.microtask(
                              () => setState(() => _paginaActual = 0),
                            );
                            return const SizedBox();
                          }

                          final zarpesPaginados = zarpesFiltrados.sublist(
                            startIndex,
                            endIndex,
                          );
                          final totalPaginas =
                              (zarpesFiltrados.length / _elementosPorPagina)
                                  .ceil();

                          return Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: esMovil ? 600 : 450,
                                        mainAxisExtent: esMovil ? 430 : 410,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  itemCount: zarpesPaginados.length,
                                  itemBuilder: (ctx, i) {
                                    final z = zarpesPaginados[i];
                                    final fecha = z.fechaZarpe;
                                    final fechaFormateada = fecha != null
                                        ? DateFormat(
                                            'dd/MM/yyyy hh:mm a',
                                          ).format(fecha)
                                        : 'Fecha Desconocida';
                                    final fotosList = (z.fotoUrlEvidencia ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                                    final urlFoto = fotosList.isNotEmpty ? fotosList.first : '';
                                    final estaRecibido =
                                        z.estado.estaFinalizado;

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Imagen Header o Placeholder
                                            Container(
                                              height: 130,
                                              decoration: BoxDecoration(
                                                color: estaRecibido
                                                    ? const Color(0xFFE8F5E9)
                                                    : const Color(0xFFE3F2FD),
                                                image: urlFoto.isNotEmpty
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                          OptimizadorImagenes.optimizarSupabaseUrl(
                                                            urlFoto,
                                                            width: 400,
                                                          ),
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: urlFoto.isEmpty
                                                  ? Icon(
                                                      Icons
                                                          .local_shipping_outlined,
                                                      size: 40,
                                                      color: estaRecibido
                                                          ? const Color(
                                                              0xFF1B5E20,
                                                            )
                                                          : const Color(
                                                              0xFF1E88E5,
                                                            ),
                                                    )
                                                  : null,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            z.placaCamara.isNotEmpty
                                                                ? z.placaCamara
                                                                : 'Sin Placa',
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF15181A,
                                                                  ),
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: estaRecibido
                                                                ? const Color(
                                                                    0xFFE8F5E9,
                                                                  )
                                                                : const Color(
                                                                    0xFFFFF3E0,
                                                                  ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            estaRecibido
                                                                ? 'Recibido'
                                                                : 'En tránsito',
                                                            style: TextStyle(
                                                              color:
                                                                  estaRecibido
                                                                  ? const Color(
                                                                      0xFF1B5E20,
                                                                    )
                                                                  : const Color(
                                                                      0xFFE65100,
                                                                    ),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.person_outline,
                                                          size: 16,
                                                          color: Color(
                                                            0xFF64748B,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'Chofer: ${z.chofer}',
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF475569,
                                                                  ),
                                                                  fontSize: 13,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 16,
                                                          color: Color(
                                                            0xFF64748B,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'Muelle: ${z.muellePartida}',
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF475569,
                                                                  ),
                                                                  fontSize: 13,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.scale_outlined,
                                                          size: 16,
                                                          color: Color(
                                                            0xFF64748B,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'Peso total: ${z.pesoTotal ?? 0} kg',
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF475569,
                                                                  ),
                                                                  fontSize: 13,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .calendar_today_outlined,
                                                          size: 16,
                                                          color: Color(
                                                            0xFF64748B,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'Fecha: ${fechaFormateada.replaceAll('AM', 'a.m.').replaceAll('PM', 'p.m.')}',
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF475569,
                                                                  ),
                                                                  fontSize: 13,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .admin_panel_settings_outlined,
                                                          size: 16,
                                                          color: Color(
                                                            0xFF0284C7,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'Registrado por: ${z.usuarioNombre != null && z.usuarioNombre!.isNotEmpty ? z.usuarioNombre : "Bahía"}',
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF0369A1,
                                                                  ),
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                    color: Color(0xFFE2E8F0),
                                                  ),
                                                ),
                                                color: Color(0xFFF8FAFC),
                                              ),
                                              child: _BotonesAccionTransito(
                                                z: z,
                                                estaRecibido: estaRecibido,
                                                esSoloLectura: esSoloLectura,
                                              ),
                                            ),
                                          ],
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
                                            ? () => setState(
                                                () => _paginaActual--,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Página ${_paginaActual + 1} de $totalPaginas',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed:
                                            _paginaActual < totalPaginas - 1
                                            ? () => setState(
                                                () => _paginaActual++,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }

                        return TabBarView(
                          children: [
                            construirListaPaginada(
                              false,
                            ), // Pendientes (En Tránsito)
                            construirListaPaginada(
                              true,
                            ), // Finalizados (Recibidos)
                          ],
                        );
                      })(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modal de recepción rápido eliminado en favor del nuevo flujo de 4 pasos.
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
        foregroundColor: const Color(0xFF0E3E2C),
        side: const BorderSide(color: Colors.black26, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _BotonesAccionTransito extends StatelessWidget {
  final dynamic z;
  final bool estaRecibido;
  final bool esSoloLectura;
  const _BotonesAccionTransito({
    required this.z,
    required this.estaRecibido,
    this.esSoloLectura = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [Expanded(child: _botonVerEditar(context))]);
  }

  Widget _botonVerEditar(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.go('/transito/editar/${z.id}'),
      icon: Icon(
        (esSoloLectura || estaRecibido)
            ? Icons.visibility_outlined
            : Icons.edit_note_rounded,
        size: 18,
      ),
      label: Text(
        (esSoloLectura || estaRecibido)
            ? 'Ver detalles'
            : 'Continuar / Gestionar',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D5C75),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            border: Border.all(color: colorBorde, width: 1.5),
            boxShadow: widget.activo
                ? [
                    BoxShadow(
                      color: colorPrimario.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
