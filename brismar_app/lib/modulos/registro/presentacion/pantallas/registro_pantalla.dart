import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../../dominio/entidades/registro_entidad.dart';
import '../controladores/registro_controlador.dart';
import '../componentes/encabezado_usuario.dart';
import '../componentes/historial_lista.dart';
import '../componentes/formulario_registro_tab.dart';
import '../../../../nucleo/utilidades/gestor_pdf.dart';

/// Pantalla principal para registrar capturas pesqueras y gastos en BRISMAR APP.
class RegistroPantalla extends ConsumerStatefulWidget {
  const RegistroPantalla({super.key});

  @override
  ConsumerState<RegistroPantalla> createState() => _RegistroPantallaState();
}

class _RegistroPantallaState extends ConsumerState<RegistroPantalla> {
  int _indicePestanaActiva = 0;

  void _mostrarMensaje(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _exportarPDF(RegistroEntidad reg, String nombreUsuario) async {
    try {
      final file = await GestorPdf.generarReportePesca(reg, nombreUsuario);
      _mostrarMensaje('Reporte PDF guardado en: ${file.path}', Colors.teal);
    } catch (e) {
      _mostrarMensaje('Error al generar PDF: $e', Colors.red);
    }
  }

  String _formatearNumero(double valor, {int decimales = 2}) {
    String str = valor.toStringAsFixed(decimales);
    List<String> partes = str.split('.');
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    partes[0] = partes[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
    return partes.join('.');
  }

  @override
  Widget build(BuildContext context) {
    final historialState = ref.watch(proveedorHistorialController);
    final estadoAutenticacion = ref.watch(proveedorControladorAutenticacion);
    final nombreUsuario = estadoAutenticacion is EstadoAutenticacionAutenticado
        ? estadoAutenticacion.usuario.nombreReal
        : 'Daniel';

    // Escuchamos la sincronización para alertar de errores remotos
    ref.listen(proveedorSyncController, (previous, next) {
      if (next is AsyncError) {
        _mostrarMensaje(
          'Error al sincronizar con Supabase: ${next.error}',
          Colors.orange,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _construirFondoGradiente(),
          _construirEsferaBrillo(top: -100, left: -50, color: const Color(0x2200E5FF)),
          _construirEsferaBrillo(bottom: -150, right: -100, color: const Color(0x1B0D47A1)),
          SafeArea(
            child: _buildBodyContent(historialState, nombreUsuario),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0077C2)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'BRISMAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEGOCIOS',
                    style: TextStyle(fontSize: 9, color: Colors.white60, letterSpacing: 0.5),
                  ),
                  Text(
                    'BRISMAR S.R.L.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.assignment_turned_in_rounded, "Registrar"),
          _buildNavItem(1, Icons.history_rounded, "Historial"),
          _buildNavItem(2, Icons.sync_rounded, "Sincronizar"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _indicePestanaActiva == index;
    return InkWell(
      onTap: () => setState(() => _indicePestanaActiva = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFFFD54F) : Colors.white54, // Color activo amarillo
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFFFD54F) : Colors.white54,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    AsyncValue<List<RegistroEntidad>> state,
    String nombreUsuario,
  ) {
    if (_indicePestanaActiva == 0) {
      return FormularioRegistroTab(
        nombreUsuario: nombreUsuario,
        onRegistroExitoso: () => setState(() => _indicePestanaActiva = 1),
      );
    } else if (_indicePestanaActiva == 1) {
      return _buildListaHistorial(state, nombreUsuario);
    } else {
      return _buildPerfilTab(state, nombreUsuario);
    }
  }

  Widget _buildListaHistorial(
    AsyncValue<List<RegistroEntidad>> state,
    String nombreUsuario,
  ) {
    return state.when(
      data: (list) => RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(proveedorSyncController.notifier)
              .ejecutarSincronizacion();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              EncabezadoUsuario(nombreUsuario: nombreUsuario),
              const SizedBox(height: 15),
              HistorialLista(
                registros: list,
                onGenerarPDF: (reg) => _exportarPDF(reg, nombreUsuario),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white70))),
    );
  }

  Widget _buildPerfilTab(AsyncValue<List<RegistroEntidad>> state, String nombreUsuario) {
    final totalKilos = state.maybeWhen(
      data: (list) => list.fold<double>(0.0, (sum, item) => sum + item.kilos),
      orElse: () => 0.0,
    );
    final totalViajes = state.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          EncabezadoUsuario(nombreUsuario: nombreUsuario),
          const SizedBox(height: 20),
          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F224A).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  nombreUsuario,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'BAHÍA ACTIVA',
                  style: TextStyle(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Kilos Registrados',
                  '${_formatearNumero(totalKilos, decimales: 0)} kg',
                  Icons.scale_rounded,
                  const Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildMetricCard(
                  'Total Registros',
                  '$totalViajes',
                  Icons.anchor_rounded,
                  const Color(0xFF00E676),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Sincronizar Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F224A).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.sync_rounded, color: Color(0xFF00E5FF)),
              title: const Text('Sincronizar Datos', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Enviar registros pendientes a la nube', style: TextStyle(color: Colors.white54, fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              onTap: () async {
                _mostrarMensaje('Sincronizando...', Colors.teal);
                await ref.read(proveedorSyncController.notifier).ejecutarSincronizacion();
                _mostrarMensaje('Sincronización finalizada', Colors.teal);
              },
            ),
          ),
          const SizedBox(height: 15),
          // Logout Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Salir de la cuenta actual', style: TextStyle(color: Colors.white54, fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              onTap: () {
                ref.read(proveedorControladorAutenticacion.notifier).cerrarSesion();
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el fondo degradado principal de la pantalla.
  Widget _construirFondoGradiente() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF040B1E),
            Color(0xFF0C1D3F),
            Color(0xFF143068),
          ],
        ),
      ),
    );
  }

  /// Genera una esfera decorativa de brillo de fondo para la interfaz premium.
  Widget _construirEsferaBrillo({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 120,
              spreadRadius: 60,
            ),
          ],
        ),
      ),
    );
  }
}
