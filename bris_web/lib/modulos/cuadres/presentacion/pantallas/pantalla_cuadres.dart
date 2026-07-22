import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bris_web/compartido/widgets/cabecera_pagina_web.dart';

import '../controladores/controlador_cuadres.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';
import '../widgets/panel_detalle_cuadre.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabeceraPaginaWeb(
              titulo: 'Cuadres de Pesca',
              subtitulo:
                  'Monitoreo centralizado de utilidades, liquidaciones y conciliación contable por zarpe',
              widgetAccion: ElevatedButton.icon(
                onPressed: () {
                  ref.read(controladorCuadresWebProvider.notifier).cargarCuadres();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _tarjetasMetricas(estado, fmt),
            const SizedBox(height: 20),
            _barraFiltros(context, ref, estado),
            const SizedBox(height: 16),
            Expanded(
              child: _contenidoPrincipal(context, ref, estado, fmt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetasMetricas(EstadoCuadresWeb estado, NumberFormat fmt) {
    return Row(
      children: [
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Total Cuadres',
            valor: '${estado.totalCuadres}',
            icono: Icons.analytics_outlined,
            colorIcono: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Utilidad Total',
            valor: 'S/ ${fmt.format(estado.utilidadTotalGlobal)}',
            icono: Icons.monetization_on_outlined,
            colorIcono: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TarjetaMetrica(
            titulo: 'Zarpes Pendientes',
            valor: '${estado.cuadresPendientes}',
            icono: Icons.pending_actions_outlined,
            colorIcono: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _barraFiltros(
    BuildContext context,
    WidgetRef ref,
    EstadoCuadresWeb estado,
  ) {
    final ctrl = ref.read(controladorCuadresWebProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por placa, chofer o embarcación...',
                prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (val) => ctrl.filtrarPorTexto(val),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: estado.filtroEstado,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'TODOS', child: Text('Todos los estados')),
              DropdownMenuItem(value: 'PENDIENTE', child: Text('Pendientes')),
              DropdownMenuItem(value: 'COMPLETADO', child: Text('Completados')),
              DropdownMenuItem(value: 'OBSERVADO', child: Text('Observados')),
            ],
            onChanged: (val) {
              if (val != null) ctrl.filtrarPorEstado(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _contenidoPrincipal(
    BuildContext context,
    WidgetRef ref,
    EstadoCuadresWeb estado,
    NumberFormat fmt,
  ) {
    if (estado.cargando) {
      return const Center(child: CargaOrbital());
    }

    if (estado.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error: ${estado.error}', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(controladorCuadresWebProvider.notifier).cargarCuadres(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
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
                child: PanelDetalleCuadre(
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
            child: PanelDetalleCuadre(cuadre: estado.cuadreSeleccionado!, fmt: fmt),
          ),
        ],
      ],
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color colorIcono;

  const _TarjetaMetrica({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: colorIcono, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}

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
    if (cuadres.isEmpty) {
      return const Center(
        child: Text('No hay cuadres registrados', style: TextStyle(color: Color(0xFF64748B))),
      );
    }

    return ListView.separated(
      itemCount: cuadres.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cuadres[index];
        final isSelected = item.id == seleccionadoId;

        return Card(
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            onTap: () {
              ref.read(controladorCuadresWebProvider.notifier).seleccionarCuadre(item.id);
            },
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF1F5F9),
              child: Icon(Icons.local_shipping, color: const Color(0xFF0F172A)),
            ),
            title: Text(
              'Placa: ${item.placa}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Chofer: ${item.chofer ?? "Sin asignar"} | Muelle: ${item.plantaDestino ?? "-"}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Utilidad: S/ ${fmt.format(item.utilidadNeta)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.utilidadNeta >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  item.estado,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
