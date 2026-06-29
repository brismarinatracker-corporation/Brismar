import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controladores/controlador_dashboard.dart';

/// Pantalla de KPIs del Dashboard — Web Admin.
class PantallaDashboard extends ConsumerWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorDashboardProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _encabezado(ref, estado),
          const SizedBox(height: 32),
          if (estado.error != null) _bannerError(estado.error!),
          if (estado.cargando)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))))
          else
            _gridKpis(estado),
        ],
      ),
    );
  }

  Widget _encabezado(WidgetRef ref, EstadoDashboard estado) {
    final mesActual = DateFormat('MMMM yyyy', 'es').format(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Resumen operativo — $mesActual',
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ]),
        IconButton(
          onPressed: () => ref.read(controladorDashboardProvider.notifier).cargarKpis(),
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E5FF)),
          tooltip: 'Actualizar KPIs',
        ),
      ],
    );
  }

  Widget _bannerError(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent)),
    );
  }

  Widget _gridKpis(EstadoDashboard estado) {
    final fmt = NumberFormat('#,##0.0', 'es_PE');
    final kpis = estado.kpis;
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
        children: [
          _TarjetaKpi(
            icono: Icons.local_shipping_rounded,
            titulo: 'Zarpes del Mes',
            valor: kpis.totalZarpesMes.toString(),
            colorIcono: const Color(0xFF00E5FF),
            subtitulo: 'cámaras despachadas',
          ),
          _TarjetaKpi(
            icono: Icons.hourglass_top_rounded,
            titulo: 'En Tránsito',
            valor: kpis.zarpesPendientes.toString(),
            colorIcono: Colors.orangeAccent,
            subtitulo: 'pendientes de recibir',
          ),
          _TarjetaKpi(
            icono: Icons.check_circle_rounded,
            titulo: 'Recibidos',
            valor: kpis.zarpesRecibidos.toString(),
            colorIcono: Colors.greenAccent,
            subtitulo: 'confirmados en Lambayeque',
          ),
          _TarjetaKpi(
            icono: Icons.people_alt_rounded,
            titulo: 'Usuarios Activos',
            valor: kpis.usuariosActivos.toString(),
            colorIcono: Colors.purpleAccent,
            subtitulo: 'cuentas habilitadas',
          ),
          _TarjetaKpi(
            icono: Icons.scale_rounded,
            titulo: 'Kilos del Mes',
            valor: '${fmt.format(kpis.totalKilosMes)} kg',
            colorIcono: const Color(0xFF00E5FF),
            subtitulo: 'peso total registrado',
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta KPI ──────────────────────────────────────────────────────────────

class _TarjetaKpi extends StatelessWidget {
  const _TarjetaKpi({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.colorIcono,
    required this.subtitulo,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final Color colorIcono;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F224A).withValues(alpha: 0.8),
            const Color(0xFF0C1D3F).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorIcono.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: colorIcono.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: colorIcono, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(titulo,
                    style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(valor,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitulo,
                    style: TextStyle(color: colorIcono.withValues(alpha: 0.7), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
