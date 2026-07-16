import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bris_web/compartido/widgets/cabecera_pagina_web.dart';

import '../componentes/hoja_liquidacion_excel.dart';
import '../controladores/controlador_cuadres.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

/// Pantalla de Cuadres de Pesca — Web Admin.
///
/// Muestra la lista completa de cuadres con filtros y un panel lateral
/// de detalle cuando se selecciona una fila.
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
          widgetAccion: OutlinedButton.icon(
            onPressed: estado.cargando
                ? null
                : () => ref
                      .read(controladorCuadresWebProvider.notifier)
                      .cargarCuadres(),
            icon: estado.cargando
                ? const CargaOrbital(tamano: 16)
                : const Icon(Icons.refresh_rounded, size: 18),
            label: esMovil ? const SizedBox() : const Text('Actualizar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0E3E2C),
              disabledForegroundColor: Colors.black38,
              side: const BorderSide(color: Colors.black12),
              padding: EdgeInsets.symmetric(
                horizontal: esMovil ? 12 : 20,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
                const SizedBox(height: 16),
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            controller: _busquedaCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar cámara (placa)',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: Colors.grey,
              ),
              suffixIcon: widget.estado.filtroPlaca != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        _busquedaCtrl.clear();
                        ctrl.aplicarFiltroPlaca(null);
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0E3E2C)),
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
            icon: const Icon(Icons.clear, size: 16, color: Colors.orangeAccent),
            label: const Text(
              'Limpiar filtros',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
      ],
    );
  }
}

class _BotoFiltroFecha extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final texto = fecha != null
        ? DateFormat('dd/MM/yyyy').format(fecha!)
        : label;
    return OutlinedButton.icon(
      onPressed: () async {
        final seleccionada = await showDatePicker(
          context: context,
          initialDate: fecha ?? DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          locale: const Locale('es', 'ES'),
          builder: (ctx, child) =>
              Theme(data: ThemeData.light(), child: child!),
        );
        if (seleccionada != null) onSeleccionar(seleccionada);
      },
      icon: Icon(
        fecha != null ? Icons.event_available : Icons.calendar_today,
        size: 16,
        color: fecha != null
            ? const Color(0xFF00838F)
            : const Color(0xFF64748B),
      ),
      label: Text(
        texto,
        style: TextStyle(
          color: fecha != null
              ? const Color(0xFF00838F)
              : const Color(0xFF475569),
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: fecha != null ? const Color(0xFFE0F7FA) : Colors.white,
        side: BorderSide(
          color: fecha != null
              ? const Color(0xFF00838F)
              : const Color(0xFF94A3B8),
          width: 1.2,
        ),
        foregroundColor: fecha != null
            ? const Color(0xFF00838F)
            : const Color(0xFF475569),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                color: Colors.white.withValues(alpha: 0.9),
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
          flex: 3,
          child: _TablaCuadres(
            cuadres: estado.cuadres,
            fmt: fmt,
            seleccionadoId: estado.cuadreSeleccionadoId,
          ),
        ),
        if (estado.cuadreSeleccionado != null) ...[
          const SizedBox(width: 24),
          SizedBox(
            width: 380,
            child: _PanelDetalle(cuadre: estado.cuadreSeleccionado!, fmt: fmt),
          ),
        ],
      ],
    );
  }
}

// ─── Tabla de Cuadres ─────────────────────────────────────────────────────────

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

    if (esMovil) {
      return ListView.separated(
        itemCount: cuadres.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final c = cuadres[i];
          final color = _colorEstado(c.estado);
          final utilColor = c.utilidadNeta >= 0
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828);
          final esSel = c.id == seleccionadoId;

          return InkWell(
            onTap: () => ctrl.seleccionarCuadre(c.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: esSel
                    ? const Color(0xFF00838F).withValues(alpha: 0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: esSel
                      ? const Color(0xFF00838F)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
                      Text(
                        c.placa,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15181A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c.estado.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Zarpe: ${c.fechaZarpe != null ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(c.fechaZarpe!)!) : '-'}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ventas',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'S/ ${fmt.format(c.totalVentas)}',
                            style: const TextStyle(
                              color: Color(0xFF15181A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Utilidad',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'S/ ${fmt.format(c.utilidadNeta)}',
                            style: TextStyle(
                              color: utilColor,
                              fontSize: 14,
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
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: Table(
              border: const TableBorder(
                horizontalInside: BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1.2),
                5: FlexColumnWidth(1),
              },
              children: [
                _filaTitulo([
                  'Placa',
                  'Fecha Zarpe',
                  'Estado',
                  'Ventas',
                  'Utilidad',
                  '',
                ]),
                ...cuadres.map((c) => _filaData(c, ctrl)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _filaTitulo(List<String> titulos) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
      children: titulos
          .map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                t,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _filaData(CuadreWebModelo c, ControladorCuadresWeb ctrl) {
    final esSeleccionado = c.id == seleccionadoId;
    final color = _colorEstado(c.estado);
    return TableRow(
      decoration: BoxDecoration(
        color: esSeleccionado
            ? const Color(0xFF00838F).withValues(alpha: 0.06)
            : Colors.transparent,
      ),
      children: [
        _celda(c.placa, bold: true),
        _celda(
          c.fechaZarpe != null
              ? DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.tryParse(c.fechaZarpe!)!)
              : '-',
        ),
        _celdaEstado(c.estado, color),
        _celda('S/ ${fmt.format(c.totalVentas)}'),
        _celda(
          'S/ ${fmt.format(c.utilidadNeta)}',
          color: c.utilidadNeta >= 0
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
        ),
        _celdaAccion(c, ctrl),
      ],
    );
  }

  Widget _celda(String texto, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        texto,
        style: TextStyle(
          color:
              color ??
              (bold ? const Color(0xFF15181A) : const Color(0xFF475569)),
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _celdaEstado(String estado, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          estado.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _celdaAccion(CuadreWebModelo c, ControladorCuadresWeb ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Consumer(
        builder: (ctx, ref, _) => IconButton(
          icon: Icon(
            c.id == seleccionadoId
                ? Icons.close_rounded
                : Icons.chevron_right_rounded,
            color: const Color(0xFF00838F),
          ),
          onPressed: () => ctrl.seleccionarCuadre(c.id),
          tooltip: c.id == seleccionadoId ? 'Cerrar detalle' : 'Ver detalle',
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completo':
        return const Color(0xFF2E7D32);
      case 'borrador':
        return const Color(0xFFE65100);
      default:
        return Colors.blueAccent;
    }
  }
}

// ─── Panel de Detalle ─────────────────────────────────────────────────────────

class _PanelDetalle extends ConsumerWidget {
  const _PanelDetalle({required this.cuadre, required this.fmt});
  final CuadreWebModelo cuadre;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(controladorCuadresWebProvider.notifier);
    final estado = ref.watch(controladorCuadresWebProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _encabezadoDetalle(context, ctrl, estado),
            const SizedBox(height: 20),
            _seccionResumen(),
            const SizedBox(height: 16),
            _seccionRelacion(
              icono: Icons.sailing_outlined,
              colorIcono: const Color(0xFF00796B),
              titulo: 'Compras (Embarcaciones)',
              items: cuadre.compras
                  .map(
                    (c) =>
                        '${c.embarcacion} — ${c.producto}: ${c.kilos}kg @ S/${fmt.format(c.precioUnitario)} = S/${fmt.format(c.total)}',
                  )
                  .toList(),
              total: cuadre.totalCompras,
              fmt: fmt,
            ),
            const SizedBox(height: 12),
            _seccionRelacion(
              icono: Icons.trending_down_rounded,
              colorIcono: const Color(0xFFEA580C),
              titulo: 'Gastos',
              items: cuadre.gastos
                  .map(
                    (g) =>
                        '${g.tipo} — ${g.concepto}: ${g.cantidad} @ S/${fmt.format(g.costoUnitario)} = S/${fmt.format(g.total)}',
                  )
                  .toList(),
              total: cuadre.totalGastos,
              fmt: fmt,
            ),
            const SizedBox(height: 12),
            _seccionRelacion(
              icono: Icons.trending_up_rounded,
              colorIcono: const Color(0xFF16A34A),
              titulo: 'Ventas (Planta)',
              items: cuadre.ventas
                  .map(
                    (v) =>
                        '${v.lugar} — ${v.producto}: ${v.kilos}kg @ S/${fmt.format(v.precioUnitario)} = S/${fmt.format(v.total)}',
                  )
                  .toList(),
              total: cuadre.totalVentas,
              fmt: fmt,
            ),
            const SizedBox(height: 16),
            _utilidadNeta(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
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
                              backgroundColor: const Color(0xFF203764),
                              title: Text(
                                'Liquidación - Placa: ${cuadre.placa}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              iconTheme: const IconThemeData(
                                color: Colors.white,
                              ),
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
                icon: const Icon(Icons.table_view_rounded, size: 20),
                label: const Text(
                  'Generar Hoja de Liquidación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezadoDetalle(
    BuildContext ctx,
    ControladorCuadresWeb ctrl,
    EstadoCuadresWeb estado,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Placa: ${cuadre.placa}',
              style: const TextStyle(
                color: Color(0xFF15181A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              cuadre.estado.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF00838F),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: estado.exportando
                  ? const CargaOrbital(tamano: 20)
                  : const Icon(
                      Icons.download_rounded,
                      color: Color(0xFF00838F),
                    ),
              tooltip: 'Exportar a Excel',
              onPressed: estado.exportando
                  ? null
                  : () => ctrl.exportarCuadreAExcel(cuadre),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF64748B)),
              onPressed: () => ctrl.seleccionarCuadre(null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _seccionResumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen',
          style: TextStyle(
            color: Color(0xFF15181A),
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(color: Color(0xFFE2E8F0)),
        _itemInfo('Chofer', cuadre.chofer ?? '-'),
        _itemInfo('Número de Chofer', cuadre.numeroChofer ?? '-'),
        _itemInfo(
          'Fecha Zarpe',
          cuadre.fechaZarpe != null
              ? DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.tryParse(cuadre.fechaZarpe!)!)
              : '-',
        ),
        _itemInfo('Muelle de Partida', cuadre.plantaDestino ?? '-'),
        _itemInfo(
          'Peso Total',
          cuadre.pesoTotal != null ? '${cuadre.pesoTotal} kg' : '-',
        ),
        _itemInfo(
          'Cajas (Llenas/Vacías)',
          '${cuadre.cajasLlenas ?? 0} / ${cuadre.cajasVacias ?? 0}',
        ),
        _itemInfo('Tipo Producto', _nombreTipoProducto(cuadre.tipoProducto)),
        _itemInfo('Pesador de Muelle', cuadre.pesador ?? '-'),
        _itemInfo('Tipo', cuadre.tipo ?? '-'),
        _itemInfo('Cuadrilla', cuadre.cuadrilla ?? '-'),
      ],
    );
  }

  String _nombreTipoProducto(String? tipo) {
    if (tipo == null || tipo.trim().isEmpty) return 'No definido';
    return tipo;
  }

  Widget _itemInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: Color(0xFF15181A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionRelacion({
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required List<String> items,
    required double total,
    required NumberFormat fmt,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: colorIcono, size: 16),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF15181A),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const Divider(color: Color(0xFFE2E8F0)),
        if (items.isEmpty)
          const Text(
            'Sin registros',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          )
        else
          ...items.map(
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                i,
                style: const TextStyle(color: Color(0xFF475569), fontSize: 11),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Total: S/ ${fmt.format(total)}',
            style: const TextStyle(
              color: Color(0xFF00838F),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _utilidadNeta() {
    final color = cuadre.utilidadNeta >= 0
        ? const Color(0xFF1B5E20)
        : const Color(0xFFB71C1C);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Text(
            'UTILIDAD NETA',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'S/ ${NumberFormat('#,##0.00', 'es_PE').format(cuadre.utilidadNeta)}',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
