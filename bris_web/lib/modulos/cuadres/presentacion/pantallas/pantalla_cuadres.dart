import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bris_web/compartido/widgets/cabecera_pagina_web.dart';

import '../componentes/hoja_liquidacion_excel.dart';
import '../../servicios/servicio_exportacion_pdf.dart';
import '../controladores/controlador_cuadres.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

/// Pantalla de Cuadres de Pesca — Web Admin.
///
/// Muestra la lista completa de cuadres con filtros y un panel lateral
/// de detalle cuando se selecciona una fila. (Rediseño Premium)
class PantallaCuadres extends ConsumerWidget {
  const PantallaCuadres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorCuadresWebProvider);
    final fmt = NumberFormat('#,##0.00', 'es_PE');

    final esMovil = MediaQuery.of(context).size.width < 800;

    if (estado.cargando) {
      return const Center(child: CargaOrbital(tamano: 80));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabeceraPaginaWeb(
          titulo: 'Cuadres de Pesca',
          subtitulo: '${estado.cuadres.length} cuadres cargados',
          widgetAccion: ElevatedButton.icon(
            onPressed: estado.cargando
                ? null
                : () => ref
                      .read(controladorCuadresWebProvider.notifier)
                      .cargarCuadres(),
            icon: estado.cargando
                ? const CargaOrbital(tamano: 16)
                : const Icon(Icons.refresh_rounded, size: 18),
            label: esMovil ? const SizedBox() : const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B54),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: esMovil ? 12 : 20,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
          ),
        ),
        // Rest of the screen
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(esMovil ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BarraFiltros(estado: estado),
                const SizedBox(height: 24),
                Expanded(
                  child: _CuerpoConDetalle(estado: estado, fmt: fmt),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Barra de Filtros ─────────────────────────────────────────────────────────

class _BarraFiltros extends ConsumerStatefulWidget {
  const _BarraFiltros({required this.estado});
  final EstadoCuadresWeb estado;

  @override
  ConsumerState<_BarraFiltros> createState() => _BarraFiltrosState();
}

class _BarraFiltrosState extends ConsumerState<_BarraFiltros> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _busquedaCtrl.text = widget.estado.filtroPlaca ?? '';
  }

  @override
  void didUpdateWidget(covariant _BarraFiltros oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.estado.filtroPlaca != oldWidget.estado.filtroPlaca) {
      _busquedaCtrl.text = widget.estado.filtroPlaca ?? '';
    }
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(controladorCuadresWebProvider.notifier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                hintText: 'Buscar cámara (placa)',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: widget.estado.filtroPlaca != null
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          ctrl.aplicarFiltroPlaca(null);
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF006B54), width: 1.5),
                ),
              ),
              onSubmitted: (val) => ctrl.aplicarFiltroPlaca(val),
            ),
          ),
          _BotoFiltroFecha(
            label: 'Desde',
            fecha: widget.estado.filtroDesde,
            onSeleccionar: (d) => ctrl.aplicarFiltroDesde(d),
            onLimpiar: () => ctrl.aplicarFiltroDesde(null),
          ),
          _BotoFiltroFecha(
            label: 'Hasta',
            fecha: widget.estado.filtroHasta,
            onSeleccionar: (d) => ctrl.aplicarFiltroHasta(d),
            onLimpiar: () => ctrl.aplicarFiltroHasta(null),
          ),
          if (widget.estado.filtroDesde != null ||
              widget.estado.filtroHasta != null ||
              widget.estado.filtroPlaca != null)
            TextButton.icon(
              onPressed: () async {
                _busquedaCtrl.clear();
                await ctrl.aplicarFiltroPlaca(null);
                await ctrl.aplicarFiltroDesde(null);
                await ctrl.aplicarFiltroHasta(null);
              },
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18, color: Color(0xFFEA580C)),
              label: const Text(
                'Limpiar filtros',
                style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotoFiltroFecha extends StatefulWidget {
  const _BotoFiltroFecha({
    required this.label,
    required this.fecha,
    required this.onSeleccionar,
    required this.onLimpiar,
  });

  final String label;
  final DateTime? fecha;
  final ValueChanged<DateTime> onSeleccionar;
  final VoidCallback onLimpiar;

  @override
  State<_BotoFiltroFecha> createState() => _BotoFiltroFechaState();
}

class _BotoFiltroFechaState extends State<_BotoFiltroFecha> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final texto = widget.fecha != null
        ? DateFormat('dd/MM/yyyy').format(widget.fecha!)
        : widget.label;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () async {
          final seleccionada = await showDatePicker(
            context: context,
            initialDate: widget.fecha ?? DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime.now().add(const Duration(days: 1)),
            locale: const Locale('es', 'ES'),
            builder: (ctx, child) =>
                Theme(data: ThemeData.light(), child: child!),
          );
          if (seleccionada != null) widget.onSeleccionar(seleccionada);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.fecha != null 
                ? const Color(0xFF006B54).withValues(alpha: 0.1) 
                : _isHovering ? const Color(0xFFF1F5F9) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.fecha != null
                  ? const Color(0xFF006B54)
                  : _isHovering
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.fecha != null ? Icons.event_available_rounded : Icons.calendar_today_rounded,
                size: 18,
                color: widget.fecha != null
                    ? const Color(0xFF006B54)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                texto,
                style: TextStyle(
                  color: widget.fecha != null
                      ? const Color(0xFF006B54)
                      : const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cuerpo con Detalle ───────────────────────────────────────────────────────

class _CuerpoConDetalle extends StatelessWidget {
  const _CuerpoConDetalle({required this.estado, required this.fmt});
  final EstadoCuadresWeb estado;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    if (estado.cargando) {
      return const Center(child: CargaOrbital(tamano: 80));
    }
    if (estado.error != null) {
      return Center(
        child: Text(
          'Error: ${estado.error}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }
    if (estado.cuadres.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text(
              'No hay cuadres registrados.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
          ],
        ),
      );
    }

    final esMovil = MediaQuery.of(context).size.width < 800;

    if (esMovil) {
      return Stack(
        children: [
          _TablaCuadres(
            cuadres: estado.cuadres,
            fmt: fmt,
            seleccionadoId: estado.cuadreSeleccionadoId,
          ),
          if (estado.cuadreSeleccionado != null)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.95),
                child: _PanelDetalle(
                  cuadre: estado.cuadreSeleccionado!,
                  fmt: fmt,
                ),
              ),
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _TablaCuadres(
            cuadres: estado.cuadres,
            fmt: fmt,
            seleccionadoId: estado.cuadreSeleccionadoId,
          ),
        ),
        if (estado.cuadreSeleccionado != null) ...[
          const SizedBox(width: 24),
          SizedBox(
            width: 440,
            child: _PanelDetalle(cuadre: estado.cuadreSeleccionado!, fmt: fmt),
          ),
        ],
      ],
    );
  }
}

// ─── Tabla de Cuadres (Rediseño Estilo Lista de Tarjetas) ──────────────────────

class _TablaCuadres extends ConsumerWidget {
  const _TablaCuadres({
    required this.cuadres,
    required this.fmt,
    required this.seleccionadoId,
  });
  final List<CuadreWebModelo> cuadres;
  final NumberFormat fmt;
  final String? seleccionadoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(controladorCuadresWebProvider.notifier);
    final esMovil = MediaQuery.of(context).size.width < 800;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          if (!esMovil)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _HeaderTitle('Placa')),
                  Expanded(flex: 2, child: _HeaderTitle('Fecha Zarpe')),
                  Expanded(flex: 2, child: _HeaderTitle('Estado')),
                  Expanded(flex: 2, child: _HeaderTitle('Ventas')),
                  Expanded(flex: 2, child: _HeaderTitle('Utilidad Neta')),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cuadres.length,
              itemBuilder: (ctx, i) {
                final c = cuadres[i];
                if (esMovil) {
                  return _HoverableRowMobile(
                    cuadre: c,
                    isSelected: c.id == seleccionadoId,
                    fmt: fmt,
                    onTap: () => ctrl.seleccionarCuadre(c.id),
                  );
                }
                return _HoverableRowDesktop(
                  cuadre: c,
                  isSelected: c.id == seleccionadoId,
                  fmt: fmt,
                  onTap: () => ctrl.seleccionarCuadre(c.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  final String text;
  const _HeaderTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}

Color _colorEstado(String estado) {
  switch (estado.toLowerCase()) {
    case 'completo':
      return const Color(0xFF16A34A);
    case 'borrador':
      return const Color(0xFFF59E0B);
    default:
      return const Color(0xFF3B82F6);
  }
}

Widget _celdaEstado(String estado, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Text(
      estado.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _HoverableRowDesktop extends StatefulWidget {
  final CuadreWebModelo cuadre;
  final bool isSelected;
  final NumberFormat fmt;
  final VoidCallback onTap;

  const _HoverableRowDesktop({
    required this.cuadre,
    required this.isSelected,
    required this.fmt,
    required this.onTap,
  });

  @override
  State<_HoverableRowDesktop> createState() => _HoverableRowDesktopState();
}

class _HoverableRowDesktopState extends State<_HoverableRowDesktop> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cuadre;
    final color = _colorEstado(c.estado);
    final isPositiva = c.utilidadNeta >= 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF006B54).withValues(alpha: 0.05)
                : _isHovering
                    ? const Color(0xFFF8FAFC)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF006B54).withValues(alpha: 0.5)
                  : _isHovering
                      ? const Color(0xFFE2E8F0)
                      : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        c.placa,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    c.fechaZarpe != null
                        ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(c.fechaZarpe!)!)
                        : '-',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _celdaEstado(c.estado, color),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'S/ ${widget.fmt.format(c.totalVentas)}',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'S/ ${widget.fmt.format(c.utilidadNeta)}',
                    style: TextStyle(
                      color: isPositiva ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: AnimatedOpacity(
                    opacity: _isHovering || widget.isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.isSelected ? Icons.chevron_right_rounded : Icons.arrow_forward_rounded,
                      color: const Color(0xFF006B54),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverableRowMobile extends StatelessWidget {
  final CuadreWebModelo cuadre;
  final bool isSelected;
  final NumberFormat fmt;
  final VoidCallback onTap;

  const _HoverableRowMobile({
    required this.cuadre,
    required this.isSelected,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorEstado(cuadre.estado);
    final isPositiva = cuadre.utilidadNeta >= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF006B54).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF006B54) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cuadre.placa,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                _celdaEstado(cuadre.estado, color),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Zarpe: ${cuadre.fechaZarpe != null ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(cuadre.fechaZarpe!)!) : '-'}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ventas', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    Text('S/ ${fmt.format(cuadre.totalVentas)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Utilidad', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    Text(
                      'S/ ${fmt.format(cuadre.utilidadNeta)}',
                      style: TextStyle(
                        color: isPositiva ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Panel de Detalle (Rediseño Premium) ──────────────────────────────────────

class _PanelDetalle extends ConsumerWidget {
  const _PanelDetalle({required this.cuadre, required this.fmt});
  final CuadreWebModelo cuadre;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(controladorCuadresWebProvider.notifier);
    final estado = ref.watch(controladorCuadresWebProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _encabezadoDetalle(context, ctrl, estado),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _seccionResumen(),
                  const SizedBox(height: 24),
                  _seccionRelacion(
                    icono: Icons.directions_boat_rounded,
                    colorIcono: const Color(0xFF0891B2),
                    titulo: 'Compras (Embarcaciones)',
                    items: cuadre.compras.map((c) => _ItemRelacionData(
                          titulo: '${c.embarcacion} — ${c.producto}',
                          subtitulo: '${c.kilos}kg x S/${fmt.format(c.precioUnitario)}',
                          monto: c.total,
                        )).toList(),
                    total: cuadre.totalCompras,
                    fmt: fmt,
                  ),
                  const SizedBox(height: 16),
                  _seccionRelacion(
                    icono: Icons.payments_rounded,
                    colorIcono: const Color(0xFFEA580C),
                    titulo: 'Gastos',
                    items: cuadre.gastos.map((g) => _ItemRelacionData(
                          titulo: '${g.tipo} — ${g.concepto}',
                          subtitulo: '${g.cantidad} uds x S/${fmt.format(g.costoUnitario)}',
                          monto: g.total,
                        )).toList(),
                    total: cuadre.totalGastos,
                    fmt: fmt,
                  ),
                  const SizedBox(height: 16),
                  _seccionRelacion(
                    icono: Icons.storefront_rounded,
                    colorIcono: const Color(0xFF16A34A),
                    titulo: 'Ventas (Planta)',
                    items: cuadre.ventas.map((v) => _ItemRelacionData(
                          titulo: '${v.lugar} — ${v.producto}',
                          subtitulo: '${v.kilos}kg x S/${fmt.format(v.precioUnitario)}',
                          monto: v.total,
                        )).toList(),
                    total: cuadre.totalVentas,
                    fmt: fmt,
                  ),
                  const SizedBox(height: 24),
                  _utilidadNeta(),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 1200,
                            maxHeight: 800,
                          ),
                          child: Scaffold(
                            appBar: AppBar(
                              backgroundColor: const Color(0xFF0F172A),
                              title: Text(
                                'Liquidación - Placa: ${cuadre.placa}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              iconTheme: const IconThemeData(color: Colors.white),
                              actions: [
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                                  tooltip: 'Descargar PDF',
                                  onPressed: () async {
                                    await ServicioExportacionPdf.exportar(cuadre);
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            body: HojaLiquidacionExcel(
                              cuadre: cuadre,
                              fmt: fmt,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.description_rounded, size: 22),
                label: const Text(
                  'Generar Liquidación',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezadoDetalle(
    BuildContext ctx,
    ControladorCuadresWeb ctrl,
    EstadoCuadresWeb estado,
  ) {
    final color = _colorEstado(cuadre.estado);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_shipping_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cuadre.placa,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _celdaEstado(cuadre.estado, color),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: estado.exportando
                      ? const CargaOrbital(tamano: 20)
                      : const Icon(Icons.download_rounded, color: Color(0xFF0F172A), size: 20),
                  tooltip: 'Exportar a Excel',
                  onPressed: estado.exportando ? null : () => ctrl.exportarCuadreAExcel(cuadre),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFFDC2626), size: 20),
                  onPressed: () => ctrl.seleccionarCuadre(null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seccionResumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información General',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 300 ? 1 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _itemGrid(Icons.person_rounded, 'Chofer', cuadre.chofer ?? '-'),
                  _itemGrid(Icons.pin_rounded, 'Nº Chofer', cuadre.numeroChofer ?? '-'),
                  _itemGrid(Icons.event_rounded, 'Fecha Zarpe', cuadre.fechaZarpe != null ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(cuadre.fechaZarpe!)!) : '-'),
                  _itemGrid(Icons.anchor_rounded, 'Muelle', cuadre.plantaDestino ?? '-'),
                  _itemGrid(Icons.scale_rounded, 'Peso Total', cuadre.pesoTotal != null ? '${cuadre.pesoTotal} kg' : '-'),
                  _itemGrid(Icons.inventory_2_rounded, 'Cajas (L/V)', '${cuadre.cajasLlenas ?? 0} / ${cuadre.cajasVacias ?? 0}'),
                  _itemGrid(Icons.set_meal_rounded, 'Producto', _nombreTipoProducto(cuadre.tipoProducto)),
                  _itemGrid(Icons.group_rounded, 'Cuadrilla', cuadre.cuadrilla ?? '-'),
                ],
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _itemGrid(IconData icono, String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icono, size: 16, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  String _nombreTipoProducto(String? tipo) {
    if (tipo == null || tipo.trim().isEmpty) return 'No definido';
    return tipo;
  }

  Widget _seccionRelacion({
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required List<_ItemRelacionData> items,
    required double total,
    required NumberFormat fmt,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icono, color: colorIcono, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Sin registros', style: TextStyle(color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
              itemBuilder: (ctx, i) {
                final item = items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.titulo, style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(item.subtitulo, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        'S/ ${fmt.format(item.monto)}',
                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 11)),
                Text(
                  'S/ ${fmt.format(total)}',
                  style: TextStyle(
                    color: colorIcono,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _utilidadNeta() {
    final isPositiva = cuadre.utilidadNeta >= 0;
    final colorBase = isPositiva ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final colorFondo = isPositiva ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorFondo, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorBase.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorBase.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isPositiva ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: colorBase, size: 24),
              const SizedBox(width: 8),
              Text(
                'UTILIDAD NETA FINAL',
                style: TextStyle(
                  color: colorBase,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'S/ ${NumberFormat('#,##0.00', 'es_PE').format(cuadre.utilidadNeta)}',
            style: TextStyle(
              color: colorBase,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: colorBase.withValues(alpha: 0.2), offset: const Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRelacionData {
  final String titulo;
  final String subtitulo;
  final double monto;
  _ItemRelacionData({required this.titulo, required this.subtitulo, required this.monto});
}
