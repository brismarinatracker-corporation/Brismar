import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../dominio/modelos/cuadre_web_modelo.dart';
import '../controladores/controlador_cuadres.dart';
import '../componentes/hoja_liquidacion_excel.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

/// Panel lateral que despliega la información detallada de un cuadre seleccionado.
///
/// Muestra resumen, fotografías de evidencia, compras, gastos, ventas y utilidad neta.
class PanelDetalleCuadre extends ConsumerWidget {
  final CuadreWebModelo cuadre;
  final NumberFormat fmt;

  const PanelDetalleCuadre({
    super.key,
    required this.cuadre,
    required this.fmt,
  });

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
