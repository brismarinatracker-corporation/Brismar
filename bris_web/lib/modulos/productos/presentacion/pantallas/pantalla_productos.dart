import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dominio/modelos/producto_modelo.dart';
import '../controladores/controlador_productos.dart';
import '../widgets/dialogo_formulario_producto.dart';
import 'package:bris_web/compartido/widgets/cabecera_pagina_web.dart';

import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

class PantallaProductos extends ConsumerStatefulWidget {
  const PantallaProductos({super.key});

  @override
  ConsumerState<PantallaProductos> createState() => _PantallaProductosState();
}

class _PantallaProductosState extends ConsumerState<PantallaProductos> {
  final TextEditingController _busquedaCtrl = TextEditingController();
  String _terminoBusqueda = '';

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _abrirFormulario({Producto? producto}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      pageBuilder: (context, _, _) =>
          DialogoFormularioProducto(productoAEditar: producto),
    );
  }

  void _confirmarAlternarEstado(Producto p) {
    final accion = p.estadoActivo ? 'desactivar' : 'activar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Confirmar',
          style: GoogleFonts.sora(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro que deseas $accion el producto "${p.nombre}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E3E2C),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(controladorProductosProvider.notifier).alternarEstado(p);
            },
            child: Text(
              accion.toUpperCase(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(controladorProductosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // Header y Buscador
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: CabeceraPaginaWeb(
              titulo: 'Productos',
              subtitulo: 'Gestión de catálogo de pesca',
              widgetAccion: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width < 800 ? 200 : 300,
                    child: TextField(
                      controller: _busquedaCtrl,
                      onChanged: (v) => setState(
                        () => _terminoBusqueda = v.trim().toLowerCase(),
                      ),
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF7EBFC9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Color(0xFF070E22)),
                    label: Text(
                      'NUEVO',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF070E22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7EBFC9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _abrirFormulario(),
                  ),
                ],
              ),
            ),
          ),

          // Tabla
          Expanded(
            child: estado.when(
              loading: () => const Center(child: CargaOrbital()),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: GoogleFonts.inter(color: Colors.red),
                ),
              ),
              data: (productos) {
                final filtrados = productos
                    .where(
                      (p) => p.nombre.toLowerCase().contains(_terminoBusqueda),
                    )
                    .toList();

                if (filtrados.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron productos.',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: const Color(0xFFF1F5F9),
                            width: 1,
                          ),
                        ),
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                            ),
                            children: [
                              _celdaHeader('NOMBRE'),
                              _celdaHeader('DESCRIPCIÓN'),
                              _celdaHeader('ESTADO'),
                              _celdaHeader('ACCIONES', centro: true),
                            ],
                          ),
                          ...filtrados.map((p) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    p.nombre,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    p.descripcion ?? '-',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.estadoActivo
                                            ? const Color(
                                                0xFF14B8A6,
                                              ).withValues(alpha: 0.1)
                                            : Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        p.estadoActivo ? 'ACTIVO' : 'INACTIVO',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: p.estadoActivo
                                              ? const Color(0xFF14B8A6)
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Color(0xFF94A3B8),
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _abrirFormulario(producto: p),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          p.estadoActivo
                                              ? Icons.block
                                              : Icons.check_circle_outline,
                                          color: p.estadoActivo
                                              ? Colors.red[300]
                                              : Colors.green[300],
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _confirmarAlternarEstado(p),
                                        tooltip: p.estadoActivo
                                            ? 'Desactivar'
                                            : 'Activar',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _celdaHeader(String texto, {bool centro = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        texto,
        textAlign: centro ? TextAlign.center : TextAlign.left,
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
