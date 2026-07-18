import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dominio/entidades/cuadre_entidad.dart';
import '../../dominio/entidades/estado_cuadre.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../controladores/controlador_cuadres.dart';
import '../controladores/controlador_zarpes.dart';
import '../../datos/repositorios/camaras_repositorio_local.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';

class DashboardCuadresPantalla extends ConsumerStatefulWidget {
  const DashboardCuadresPantalla({super.key});

  @override
  ConsumerState<DashboardCuadresPantalla> createState() =>
      _DashboardCuadresPantallaState();
}

class _DashboardCuadresPantallaState
    extends ConsumerState<DashboardCuadresPantalla> {
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
      context.push('/perfil');
    } else {
      setState(() {
        _pestanaSeleccionada = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estadoCuadres = ref.watch(cuadresProvider);
    final authState = ref.watch(proveedorControladorAutenticacion);

    String userName = 'operador';
    if (authState is EstadoAutenticacionAutenticado) {
      userName = authState.usuario.nombreReal.split(' ').first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: _buildAppBar(context),
      body: SafeArea(child: _buildBodyContent(estadoCuadres, userName)),
      floatingActionButton: _pestanaSeleccionada == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF006B54),
              onPressed: () {
                context.push('/nuevo-cuadre');
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pestanaSeleccionada,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF006B54),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Registrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final textColor = Colors.black87;
    final subTextColor = Colors.black54;
    final iconColor = Colors.black87;
    final primaryIconColor = const Color(0xFF006B54);
    final primaryIconBg = const Color(0xFFE8F5E9);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: iconColor),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryIconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.anchor_rounded,
              color: primaryIconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bris group',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'Cuadres jerárquicos',
                style: TextStyle(fontSize: 11, color: subTextColor),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.sync_rounded, color: iconColor),
          onPressed: () {
            ref.read(cuadresProvider.notifier).cargarHistorial();
            ref.read(proveedorZarpes.notifier).sincronizarZarpesPendientes();
            CamarasRepositorioLocal().sincronizarCamaras();
          },
        ),
      ],
    );
  }

  Widget _buildBodyContent(
    AsyncValue<List<CuadreEntidad>> estadoCuadres,
    String userName,
  ) {
    if (_pestanaSeleccionada == 0) {
      // Registrar
      return _buildVistaRegistrar(userName);
    } else {
      // Historial
      return _buildVistaHistorial(estadoCuadres);
    }
  }

  Widget _buildVistaRegistrar(String userName) {
    final capitalizedName = userName.isNotEmpty
        ? '${userName[0].toUpperCase()}${userName.substring(1).toLowerCase()}'
        : 'Operador';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Saludo y Bienvenida
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $capitalizedName',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Qué operación vamos a registrar hoy en el muelle?',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Opción 1: Zarpe
            _buildTarjetaOperacion(
              title: 'Despacho de cámara (zarpe)',
              description:
                  'Registra la salida rápida hacia la planta. Solo foto de evidencia y guía.',
              icon: Icons.local_shipping_outlined,
              bgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF00695C),
              onTap: () => context.push('/nuevo-zarpe'),
            ),

            const SizedBox(height: 24),

            // Opción 2: Cuadre
            _buildTarjetaOperacion(
              title: 'Cuadre de pesca',
              description:
                  'Reporte detallado del viaje: kilos, embarcaciones y gastos operativos.',
              icon: Icons.assignment_outlined,
              bgColor: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE65100),
              onTap: () => context.push('/nuevo-cuadre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaOperacion({
    required String title,
    required String description,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black26,
              size: 18,
            ),
          ],
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Buscar por cámara...',
                  hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF006B54),
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF006B54),
                      width: 1.5,
                    ),
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
                      child: Text(
                        'No se encontraron resultados.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredCuadres.length,
                      itemBuilder: (context, index) {
                        final cuadre = filteredCuadres[index];

                        // Personalización visual del estado
                        Color badgeBg;
                        Color badgeText;
                        String labelEstado;

                        if (cuadre.estado == EstadoCuadre.completo) {
                          badgeBg = Colors.green.withValues(alpha: 0.15);
                          badgeText = Colors.green;
                          labelEstado = 'COMPLETO';
                        } else if (cuadre.estado == EstadoCuadre.zarpe) {
                          badgeBg = const Color(
                            0xFF006B54,
                          ).withValues(alpha: 0.15);
                          badgeText = const Color(0xFF006B54);
                          labelEstado = 'EN CAMINO';
                        } else {
                          badgeBg = Colors.orange.withValues(alpha: 0.15);
                          badgeText = Colors.orange;
                          labelEstado = 'BORRADOR';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.local_shipping_rounded,
                                  color: cuadre.estado == EstadoCuadre.zarpe
                                      ? const Color(0xFF006B54)
                                      : const Color(0xFFD97706),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CÁMARA: ${cuadre.placa.toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.date_range_rounded,
                                      color: Colors.black54,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      cuadre.fechaZarpe ?? 'Pendiente',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
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
                                      Icon(
                                        Icons.photo_camera_rounded,
                                        color: const Color(
                                          0xFF006B54,
                                        ).withValues(alpha: 0.8),
                                        size: 14,
                                      ),
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
                                    const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                  if (cuadre.urlExcelCloud != null)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.table_chart,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                  if (cuadre.estado == EstadoCuadre.zarpe &&
                                      cuadre.fotoZarpeUrl != null &&
                                      cuadre.fotoZarpeUrl!.startsWith('http'))
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.cloud_done_rounded,
                                        color: Color(0xFF006B54),
                                        size: 20,
                                      ),
                                    ),
                                ] else ...[
                                  const Icon(
                                    Icons.cloud_off,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
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
      loading: () => const Center(child: CargaOrbital(tamano: 80)),
      error: (err, _) => Center(
        child: Text(
          'Error: $err',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
