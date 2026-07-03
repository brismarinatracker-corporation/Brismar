import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controladores/controlador_dashboard.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

/// Pantalla de KPIs del Dashboard — Web Admin.
class PantallaDashboard extends ConsumerWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorDashboardProvider);
    final mesActual = DateFormat('MMMM yyyy', 'es').format(DateTime.now());

    return Container(
      color: const Color(0xFFEEF3F1),
      child: estado.cargando
          ? const Center(
              child: CargaOrbital(tamano: 80),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topbar Premium (Look técnico/marítimo)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
                            'Dashboard general',
                            style: GoogleFonts.fraunces(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Indicador "en vivo" (pulso verde marino)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF14B8A6), // Sea Green
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF14B8A6),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'RESUMEN OPERATIVO — ${mesActual.toUpperCase()} — ACTUALIZADO HACE 3 MIN',
                                style: GoogleFonts.ibmPlexMono(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Botón Actualizar (Borde Ámbar)
                      OutlinedButton.icon(
                        onPressed: () => ref.read(controladorDashboardProvider.notifier).cargarKpis(),
                        icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFFF59E0B)),
                        label: Text(
                          'Actualizar',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid y contenido principal
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(40),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (estado.error != null) _bannerError(estado.error!),
                            _gridKpis(context, estado),
                            const SizedBox(height: 40),
                            _seccionRentabilidadGlobal(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _bannerError(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Text(
            'Error de conexión: $error',
            style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontWeight: FontWeight.w500),
          ),
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
        int columnas = 5; // Cambiado a 5 columnas para alojar todas las tarjetas en una sola línea si hay espacio
        if (availableWidth < 1400) columnas = 4;
        if (availableWidth < 1100) columnas = 3;
        if (availableWidth < 800) columnas = 2;
        if (availableWidth < 500) columnas = 1;

        double anchoTarjeta = (availableWidth - (columnas - 1) * 20) / columnas;
        double childAspectRatio = anchoTarjeta / 165;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columnas,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: childAspectRatio,
          children: [
            _TarjetaKpiPremium(
              icono: Icons.local_shipping_outlined,
              titulo: 'Zarpes del mes',
              valor: kpis.totalZarpesMes.toString(),
              colorTema: const Color(0xFFF59E0B), // Amber = Acción / Zarpes
              subtitulo: 'faenas registradas',
            ),
            _TarjetaKpiPremium(
              icono: Icons.balance_outlined,
              titulo: 'Volumen total',
              valor: '${fmt.format(kpis.totalKilosMes)} kg',
              colorTema: const Color(0xFF0F2D4A), // Navy = Medición / Kilos
              subtitulo: '↑ 12% vs. mes anterior',
            ),
            _TarjetaKpiPremium(
              icono: Icons.access_time_rounded,
              titulo: 'En tránsito',
              valor: kpis.zarpesPendientes.toString(),
              colorTema: const Color(0xFF475569), // Slate Blue = Tránsito
              subtitulo: 'pendientes de recepción',
            ),
            _TarjetaKpiPremium(
              icono: Icons.check_circle_outline_rounded,
              titulo: 'Recibidos',
              valor: kpis.zarpesRecibidos.toString(),
              colorTema: const Color(0xFF0D9488), // Sea Green = Recibidos
              subtitulo: 'al día',
            ),
            _TarjetaKpiPremium(
              icono: Icons.person_outline_rounded,
              titulo: 'Cuentas activas',
              colorTema: const Color(0xFF0F2D4A),
              valor: kpis.usuariosActivos.toString(),
              subtitulo: 'usuarios del sistema',
            ),
          ],
        );
      },
    );
  }

  // Bloque Financiero Rediseñado con batimetría y CTA claro
  Widget _seccionRentabilidadGlobal() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF051329), // Deep Navy matching brand
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Líneas batimétricas tipo "ver bajo la superficie"
            Positioned.fill(
              child: CustomPaint(
                painter: DibujadorOndasDashboard(),
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge "En Construcción"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'EN CONSTRUCCIÓN',
                      style: GoogleFonts.ibmPlexMono(
                        color: const Color(0xFFF59E0B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Métricas financieras',
                    style: GoogleFonts.fraunces(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'Rentabilidad por faena, flujo de caja y comparativos mensuales a nivel nacional.\nEsta sección se activa en cuanto conectemos el módulo de cuadres con el motor de reportes.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // CTA Button
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver cronograma de la integración',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFF59E0B)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta KPI Premium con colores semánticos y tipografías Fraunces/IBM Plex Mono ───

class _TarjetaKpiPremium extends StatelessWidget {
  const _TarjetaKpiPremium({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.colorTema,
    required this.subtitulo,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final Color colorTema;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono destacado con fondo opaco según el color semántico
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorTema.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: colorTema, size: 18),
          ),
          const Spacer(),
          
          // Título del KPI
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          
          // Valor numérico (Fraunces)
          Text(
            valor,
            style: GoogleFonts.fraunces(
              color: const Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          
          // Subtítulo / Delta (IBM Plex Mono)
          Text(
            subtitulo,
            style: GoogleFonts.ibmPlexMono(
              color: colorTema, // Resalta con el color semántico correspondiente
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dibuja curvas batimétricas sutiles para la sección financiera
class DibujadorOndasDashboard extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = const Color(0xFF14B8A6).withValues(alpha: 0.03) // Sea green sutil
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pincelFuerte = Paint()
      ..color = const Color(0xFF14B8A6).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centroX = size.width * 0.85;
    final centroY = size.height * 0.95;

    for (int i = 1; i <= 6; i++) {
      final radio = i * 65.0;
      final pincelActivo = (i % 3 == 0) ? pincelFuerte : pincel;
      canvas.drawCircle(Offset(centroX, centroY), radio, pincelActivo);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
