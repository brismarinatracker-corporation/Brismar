import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dominio/entidades/cuadre_entidad.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../controladores/controlador_cuadres.dart';
import '../controladores/controlador_zarpes.dart';

class DashboardCuadresPantalla extends ConsumerStatefulWidget {
  const DashboardCuadresPantalla({super.key});

  @override
  ConsumerState<DashboardCuadresPantalla> createState() => _DashboardCuadresPantallaState();
}

class _DashboardCuadresPantallaState extends ConsumerState<DashboardCuadresPantalla> {
  int _pestanaSeleccionada = 0;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cuadresProvider.notifier).cargarHistorial();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Sincronizar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronizando cuadres...')),
      );
      ref.read(cuadresProvider.notifier).cargarHistorial();
    } else {
      setState(() {
        _pestanaSeleccionada = index;
      });
    }
  }

  void _mostrarConfirmacionCerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F224A),
        title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de salir de tu cuenta?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              // El redirect del enrutadorProvider navega a /login automáticamente
              // cuando el estado cambia a EstadoAutenticacionNoAutenticado.
              await ref
                  .read(proveedorControladorAutenticacion.notifier)
                  .cerrarSesion();
            },
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esHorizontal = MediaQuery.of(context).orientation == Orientation.landscape;
    final estadoCuadres = ref.watch(cuadresProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: esHorizontal ? null : _buildAppBar(context),
      extendBodyBehindAppBar: true,
      body: esHorizontal
          ? Row(
              children: [
                _buildLateralNavigationRail(),
                Expanded(
                  child: Stack(
                    children: [
                      _construirFondoGradiente(),
                      _construirEsferaBrillo(top: -100, left: -50, color: const Color(0x2200E5FF)),
                      _construirEsferaBrillo(bottom: -150, right: -100, color: const Color(0x1B0D47A1)),
                      SafeArea(
                        child: _buildBodyContent(estadoCuadres),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                _construirFondoGradiente(),
                _construirEsferaBrillo(top: -100, left: -50, color: const Color(0x2200E5FF)),
                _construirEsferaBrillo(bottom: -150, right: -100, color: const Color(0x1B0D47A1)),
                SafeArea(
                  child: _buildBodyContent(estadoCuadres),
                ),
              ],
            ),
      bottomNavigationBar: esHorizontal ? null : _buildBottomNavigationBar(),
      floatingActionButton: _pestanaSeleccionada == 1 // Si estamos en historial, mostramos FAB para crear
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF00E5FF),
              onPressed: () {
                context.push('/nuevo-cuadre');
              },
              child: const Icon(Icons.add, color: Color(0xFF070E22)),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_boat_rounded, color: Color(0xFF00E5FF), size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BRIS GROUP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'CUADRES JERÁRQUICOS',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () {
            ref.read(cuadresProvider.notifier).cargarHistorial();
            ref.read(proveedorZarpes.notifier).sincronizarZarpesPendientes();
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: _mostrarConfirmacionCerrarSesion,
        ),
      ],
    );
  }

  Widget _buildBodyContent(AsyncValue<List<CuadreEntidad>> estadoCuadres) {
    if (_pestanaSeleccionada == 0) {
      // Registrar
      return _buildVistaRegistrar();
    } else {
      // Historial
      return _buildVistaHistorial(estadoCuadres);
    }
  }

  Widget _buildVistaRegistrar() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.dashboard_customize_rounded, size: 48, color: Color(0xFF00E5FF)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Operaciones de Bahía',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Selecciona una actividad para iniciar',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            const SizedBox(height: 32),

            // Opción 1: Zarpe de Cámara
            _buildActionCard(
              title: 'Registrar Zarpe de Cámara',
              description: 'Registra la salida del muelle con foto de evidencia y datos de carga básicos.',
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFF00E5FF),
              onTap: () {
                context.push('/nuevo-zarpe');
              },
            ),
            const SizedBox(height: 16),

            // Opción 2: Cuadre de Caja
            _buildActionCard(
              title: 'Iniciar Cuadre de Caja',
              description: 'Reporte completo detallando compras de pesca, gastos de muelle/chofer y ventas.',
              icon: Icons.assignment_rounded,
              color: const Color(0xFFFFD54F),
              onTap: () {
                context.push('/nuevo-cuadre');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 30, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(color: Colors.white54, fontSize: 11.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVistaHistorial(AsyncValue<List<CuadreEntidad>> estadoCuadres) {
    return estadoCuadres.when(
      data: (cuadres) {
        final query = _searchCtrl.text.toLowerCase().trim();
        final filteredCuadres = cuadres.where((cuadre) {
          final placa = cuadre.placa.toLowerCase();
          return placa.contains(query);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar por cámara...',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E5FF)),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF0F224A).withValues(alpha: 0.6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: filteredCuadres.isEmpty
                  ? const Center(
                      child: Text('No se encontraron resultados.', style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredCuadres.length,
                      itemBuilder: (context, index) {
                        final cuadre = filteredCuadres[index];
                        
                        // Personalización visual del estado
                        Color badgeBg;
                        Color badgeText;
                        String labelEstado;
                        
                        if (cuadre.estado == 'completo') {
                          badgeBg = Colors.green.withValues(alpha: 0.15);
                          badgeText = Colors.greenAccent;
                          labelEstado = 'COMPLETO';
                        } else if (cuadre.estado == 'zarpe') {
                          badgeBg = const Color(0xFF00E5FF).withValues(alpha: 0.15);
                          badgeText = const Color(0xFF00E5FF);
                          labelEstado = 'EN CAMINO';
                        } else {
                          badgeBg = Colors.orange.withValues(alpha: 0.15);
                          badgeText = Colors.orangeAccent;
                          labelEstado = 'BORRADOR';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F224A).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.local_shipping_rounded, 
                                  color: cuadre.estado == 'zarpe' ? const Color(0xFF00E5FF) : const Color(0xFFFFD54F), 
                                  size: 18
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CÁMARA: ${cuadre.placa.toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.date_range_rounded, color: Colors.white54, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      cuadre.fechaZarpe ?? 'Pendiente',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        labelEstado,
                                        style: TextStyle(
                                          color: badgeText,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (cuadre.fotoZarpeUrl != null) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.photo_camera_rounded, color: const Color(0xFF00E5FF).withValues(alpha: 0.8), size: 14),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (cuadre.sincronizado) ...[
                                  if (cuadre.urlPdfCloud != null)
                                    const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                                  if (cuadre.urlExcelCloud != null)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(Icons.table_chart, color: Colors.green, size: 20),
                                    ),
                                  if (cuadre.estado == 'zarpe' && cuadre.fotoZarpeUrl != null && cuadre.fotoZarpeUrl!.startsWith('http'))
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(Icons.cloud_done_rounded, color: Color(0xFF00E5FF), size: 20),
                                    ),
                                ] else ...[
                                  const Icon(Icons.cloud_off, color: Colors.grey, size: 20),
                                ]
                              ],
                            ),
                            onTap: () {
                              // Editar/Completar cuadre
                              context.push('/nuevo-cuadre', extra: cuadre);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF070E22),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(0, Icons.assignment_turned_in_rounded, "Registrar"),
          _buildBottomNavItem(1, Icons.history_rounded, "Historial"),
          _buildBottomNavItem(2, Icons.sync_rounded, "Sincronizar"),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _pestanaSeleccionada == index;
    final color = isSelected ? const Color(0xFF00E5FF) : Colors.white54;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLateralNavigationRail() {
    return Container(
      width: 96,
      padding: EdgeInsets.only(
        top: 20 + MediaQuery.of(context).padding.top,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF070E22),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.directions_boat_rounded,
              size: 24,
              color: Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'BRIS GROUP',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),
          // Nav Items
          Expanded(
            child: Column(
              children: [
                _buildNavItem(0, Icons.assignment_turned_in_rounded, "Registrar"),
                const SizedBox(height: 24),
                _buildNavItem(1, Icons.history_rounded, "Historial"),
                const SizedBox(height: 24),
                _buildNavItem(2, Icons.sync_rounded, "Sincronizar"),
              ],
            ),
          ),
          // Logout Item
          InkWell(
            onTap: _mostrarConfirmacionCerrarSesion,
            child: const Column(
              children: [
                Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
                SizedBox(height: 4),
                Text('Salir', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _pestanaSeleccionada == index;
    final color = isSelected ? const Color(0xFF00E5FF) : Colors.white54;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        width: 64,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
