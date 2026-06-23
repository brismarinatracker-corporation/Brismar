import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../../dominio/entidades/registro_entidad.dart';
import '../controladores/registro_controlador.dart';
import '../componentes/encabezado_usuario.dart';
import '../componentes/selector_pestanas.dart';
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
  int _activeTabIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final historialState = ref.watch(proveedorHistorialController);
    final authState = ref.watch(proveedorControladorAutenticacion);
    final nombreUsuario = authState is EstadoAutenticacionAutenticado
        ? authState.usuario.nombreReal
        : 'Daniel';
    final usuarioId = authState is EstadoAutenticacionAutenticado
        ? authState.usuario.id
        : null;

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
      backgroundColor: const Color(0xFF0D255F),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          SelectorPestanas(
            indiceActivo: _activeTabIndex,
            totalRegistros: historialState.maybeWhen(
              data: (list) => list.length,
              orElse: () => 0,
            ),
            onTabChanged: (index) => setState(() => _activeTabIndex = index),
          ),
          Expanded(
            child: _buildBodyContent(historialState, nombreUsuario, usuarioId),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0D255F),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'BRISMAR',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEGOCIOS',
                    style: TextStyle(fontSize: 9, color: Colors.white70),
                  ),
                  Text(
                    'BRISMAR S.R.L.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(proveedorControladorAutenticacion.notifier)
                  .cerrarSesion();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B1F31),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    AsyncValue<List<RegistroEntidad>> state,
    String nombreUsuario,
    String? usuarioId,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F4F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: _activeTabIndex == 0
          ? FormularioRegistroTab(
              nombreUsuario: nombreUsuario,
              usuarioId: usuarioId,
              onRegistroExitoso: () => setState(() => _activeTabIndex = 1),
            )
          : _buildListaHistorial(state, nombreUsuario),
    );
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
          padding: const EdgeInsets.all(16),
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
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
