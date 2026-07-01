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
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            Color(0xFF0F224A),
            Color(0xFF070E22),
          ],
        ),
      ),
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
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resumen operativo — ${mesActual.toUpperCase()}',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ]),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
          ),
          child: IconButton(
            onPressed: () => ref.read(controladorDashboardProvider.notifier).cargarKpis(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E5FF)),
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
    final width = MediaQuery.of(context).size.width;
    
    int columnas = 4;
    if (width < 1400) columnas = 3;
    if (width < 1000) columnas = 2;
    if (width < 600) columnas = 1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columnas,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.8,
      children: [
        _TarjetaKpiPremium(
          icono: Icons.local_shipping_rounded,
          titulo: 'Zarpes del Mes',
          valor: kpis.totalZarpesMes.toString(),
          colorIcono: const Color(0xFF3B82F6),
          subtitulo: 'Cámaras despachadas',
        ),
        _TarjetaKpiPremium(
          icono: Icons.scale_rounded,
          titulo: 'Volumen Total',
          valor: '${fmt.format(kpis.totalKilosMes)} kg',
          colorIcono: const Color(0xFF00E5FF),
          subtitulo: 'Peso registrado',
        ),
        _TarjetaKpiPremium(
          icono: Icons.hourglass_top_rounded,
          titulo: 'En Tránsito',
          valor: kpis.zarpesPendientes.toString(),
          colorIcono: const Color(0xFFF59E0B),
          subtitulo: 'Pendientes de recibir',
        ),
        _TarjetaKpiPremium(
          icono: Icons.check_circle_rounded,
          titulo: 'Recibidos',
          valor: kpis.zarpesRecibidos.toString(),
          colorIcono: const Color(0xFF10B981),
          subtitulo: 'Confirmados en Lambayeque',
        ),
        if (columnas > 2)
          _TarjetaKpiPremium(
            icono: Icons.people_alt_rounded,
            titulo: 'Cuentas Activas',
            valor: kpis.usuariosActivos.toString(),
            colorIcono: const Color(0xFF8B5CF6),
            subtitulo: 'Bahías y Operadores',
          ),
      ],
    );
  }

  Widget _seccionRentabilidadGlobal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas Financieras (Próximamente)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí se integrarán las gráficas de rentabilidad y flujos de caja a nivel nacional.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: const Center(
              child: Icon(Icons.bar_chart_rounded, size: 64, color: Color(0xFF334155)),
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorIcono.withOpacity(0.2),
                      colorIcono.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorIcono.withOpacity(0.3)),
                ),
                child: Icon(icono, color: colorIcono, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        valor,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorIcono.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
