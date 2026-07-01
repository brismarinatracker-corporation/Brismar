import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../controladores/controlador_dashboard.dart';
import 'package:brismar_web_admin/nucleo/componentes/carga_orbital.dart';

/// Pantalla de KPIs del Dashboard — Web Admin.
class PantallaDashboard extends ConsumerWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorDashboardProvider);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: estado.cargando
          ? const Center(
              child: CargaOrbital(tamano: 80),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _encabezado(ref, estado),
                      const SizedBox(height: 40),
                      if (estado.error != null) _bannerError(estado.error!),
                      _gridKpis(context, estado),
                      const SizedBox(height: 40),
                      _seccionRentabilidadGlobal(),
                    ]),
                  ),
                ),
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
          const Text(
            'Dashboard General',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resumen operativo — ${mesActual.toUpperCase()}',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ]),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF00ACC1).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00ACC1).withOpacity(0.2)),
          ),
          child: IconButton(
            onPressed: () => ref.read(controladorDashboardProvider.notifier).cargarKpis(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00ACC1)),
            tooltip: 'Actualizar KPIs',
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _bannerError(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Text('Error de conexión: $error', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _gridKpis(BuildContext context, EstadoDashboard estado) {
    final fmt = NumberFormat('#,##0.0', 'es_PE');
    final kpis = estado.kpis;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        int columnas = 4;
        if (availableWidth < 1200) columnas = 3;
        if (availableWidth < 800) columnas = 2;
        if (availableWidth < 500) columnas = 1;

        // Calcula el aspect ratio dinámicamente para fijar la altura de las tarjetas a 165px
        double anchoTarjeta = (availableWidth - (columnas - 1) * 24) / columnas;
        double childAspectRatio = anchoTarjeta / 165;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columnas,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: childAspectRatio,
          children: [
            _TarjetaKpiPremium(
              icono: Icons.local_shipping_outlined,
              titulo: 'Zarpes del mes',
              valor: kpis.totalZarpesMes.toString(),
              colorIcono: const Color(0xFF00796B),
              subtitulo: '',
            ),
            _TarjetaKpiPremium(
              icono: Icons.balance_outlined,
              titulo: 'Volumen total',
              valor: '${fmt.format(kpis.totalKilosMes)} kg',
              colorIcono: const Color(0xFF2E7D32),
              subtitulo: '',
            ),
            _TarjetaKpiPremium(
              icono: Icons.access_time_rounded,
              titulo: 'En tránsito',
              valor: kpis.zarpesPendientes.toString(),
              colorIcono: const Color(0xFFB45309),
              subtitulo: '',
            ),
            _TarjetaKpiPremium(
              icono: Icons.check_circle_outline_rounded,
              titulo: 'Recibidos',
              valor: kpis.zarpesRecibidos.toString(),
              colorIcono: const Color(0xFF16A34A),
              subtitulo: '',
            ),
            _TarjetaKpiPremium(
              icono: Icons.person_outline_rounded,
              titulo: 'Cuentas activas',
              valor: kpis.usuariosActivos.toString(),
              colorIcono: const Color(0xFF475569),
              subtitulo: '',
            ),
          ],
        );
      },
    );
  }

  Widget _seccionRentabilidadGlobal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas Financieras (Próximamente)',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí se integrarán las gráficas de rentabilidad y flujos de caja a nivel nacional.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Icon(Icons.bar_chart_rounded, size: 64, color: Color(0xFFCBD5E1)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta KPI Premium ──────────────────────────────────────────────────────────────

class _TarjetaKpiPremium extends StatelessWidget {
  const _TarjetaKpiPremium({
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

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorIcono.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: colorIcono, size: 20),
          ),
          const Spacer(),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
