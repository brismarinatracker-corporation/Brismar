import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../controladores/controlador_transito.dart';
import '../../../cuadres/presentacion/controladores/controlador_cuadres.dart';
import '../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'package:brismar_web_admin/nucleo/componentes/carga_orbital.dart';

class PantallaEdicionTransito extends ConsumerStatefulWidget {
  final String id;
  const PantallaEdicionTransito({super.key, required this.id});

  @override
  ConsumerState<PantallaEdicionTransito> createState() => _PantallaEdicionTransitoState();
}

class _PantallaEdicionTransitoState extends ConsumerState<PantallaEdicionTransito> {
  final _formKey = GlobalKey<FormState>();
  
  bool _cargando = true;
  String? _error;
  
  Map<String, dynamic>? _zarpeInfo;
  CuadreWebModelo? _cuadreInfo;
  
  int _indiceFotoActiva = 0;
  
  // Controladores Zarpe
  final _placaCtrl = TextEditingController();
  final _choferCtrl = TextEditingController();
  final _muelleCtrl = TextEditingController();

  // Variables locales para Compras, Gastos, Ventas
  List<CompraWebModelo> _compras = [];
  List<GastoWebModelo> _gastos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final ctrlTransito = ref.read(proveedorTransito.notifier);
      final fuenteCuadres = ref.read(fuenteCuadresWebProvider);

      final zarpe = await ctrlTransito.obtenerZarpePorId(widget.id);
      final cuadre = await fuenteCuadres.obtenerPorId(widget.id);

      if (zarpe == null) throw Exception('No se encontró el zarpe con ID ${widget.id}');
      
      setState(() {
        _zarpeInfo = zarpe;
        _cuadreInfo = cuadre;
        _placaCtrl.text = zarpe['placa_camara'] ?? '';
        _choferCtrl.text = zarpe['chofer'] ?? '';
        _muelleCtrl.text = zarpe['muelle_partida'] ?? '';
        
        if (cuadre != null) {
          _compras = List.from(cuadre.compras);
          _gastos = List.from(cuadre.gastos);
        }
        _cargando = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _cargando = false; });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _cargando = true);
    try {
      final cliente = Supabase.instance.client;
      
      // Actualizar Zarpe
      await cliente.from('zarpes').update({
        'placa_camara': _placaCtrl.text.trim(),
        'chofer': _choferCtrl.text.trim(),
        'muelle_partida': _muelleCtrl.text.trim(),
      }).eq('id', widget.id);

      // Si existe Cuadre, actualizarlo; si no, crear uno básico
      if (_cuadreInfo != null) {
        await cliente.from('cuadres').update({
          'placa': _placaCtrl.text.trim(), // mantener sincronizados
        }).eq('id', widget.id);
      } else {
        await cliente.from('cuadres').insert({
          'id': widget.id,
          'usuario_id': cliente.auth.currentUser?.id ?? '',
          'placa': _placaCtrl.text.trim(),
          'fecha_zarpe': DateTime.now().toIso8601String().substring(0, 10),
          'estado': 'borrador',
        });
      }

      // Guardar Relaciones: Compras (Embarcaciones)
      await cliente.from('compras').delete().eq('cuadre_id', widget.id);
      if (_compras.isNotEmpty) {
        final comprasJson = _compras.map((c) => {
          'id': c.id,
          'cuadre_id': widget.id,
          'embarcacion': c.embarcacion,
          'producto': c.producto,
          'kilos': c.kilos,
          'precio_unitario': c.precioUnitario,
          'total': c.total,
          'adelanto': c.adelanto ?? 0.0,
        }).toList();
        await cliente.from('compras').insert(comprasJson);
      }

      // Guardar Relaciones: Gastos
      await cliente.from('gastos').delete().eq('cuadre_id', widget.id);
      if (_gastos.isNotEmpty) {
        final gastosJson = _gastos.map((g) => {
          'id': g.id,
          'cuadre_id': widget.id,
          'tipo': g.tipo,
          'concepto': g.concepto,
          'cantidad': g.cantidad,
          'costo_unitario': g.costoUnitario,
          'total': g.total,
        }).toList();
        await cliente.from('gastos').insert(gastosJson);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios guardados con éxito'), backgroundColor: Colors.green));
        ref.read(proveedorTransito.notifier).recargar();
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _zarpeInfo == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CargaOrbital(tamano: 80)),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.redAccent))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _cargando 
          ? const Center(child: CargaOrbital(tamano: 80))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dark Blue Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F2D4A), // Deep navy blue
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                            onPressed: () => context.pop(),
                            tooltip: 'Volver',
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Editor de Viaje / Cuadre',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: _guardarCambios,
                        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                        label: const Text('Guardar', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Form body
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _construirSeccionZarpe()),
                          const SizedBox(width: 32),
                          Expanded(flex: 1, child: _construirSeccionEmbarcaciones()),
                          const SizedBox(width: 32),
                          Expanded(flex: 1, child: _construirSeccionFlete()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _construirSeccionZarpe() {
    final String fotosString = _zarpeInfo?['foto_url_evidencia'] ?? '';
    final List<String> urlsFotos = fotosString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.startsWith('http'))
        .toList();

    return _tarjeta(
      titulo: 'Datos del Zarpe (Cámara)',
      hijos: [
        if (urlsFotos.isNotEmpty) ...[
          const Text(
            'Evidencia Fotográfica / Guía',
            style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Carousel container
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Active Image
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _abrirGaleriaLightbox(urlsFotos, _indiceFotoActiva),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Image.network(
                          urlsFotos[_indiceFotoActiva],
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Center(
                            child: Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Left Arrow Button
                  if (urlsFotos.length > 1)
                    Positioned(
                      left: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        radius: 18,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              _indiceFotoActiva = (_indiceFotoActiva - 1 + urlsFotos.length) % urlsFotos.length;
                            });
                          },
                        ),
                      ),
                    ),

                  // Right Arrow Button
                  if (urlsFotos.length > 1)
                    Positioned(
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        radius: 18,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              _indiceFotoActiva = (_indiceFotoActiva + 1) % urlsFotos.length;
                            });
                          },
                        ),
                      ),
                    ),

                  // Image indicator badge (e.g. 1/3)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_indiceFotoActiva + 1} / ${urlsFotos.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  // Zoom icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        TextFormField(
          controller: _placaCtrl,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: _decoracion('Placa Cámara'),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _choferCtrl,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: _decoracion('Chofer'),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _muelleCtrl,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: _decoracion('Muelle Partida'),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 20),
        const Text(
          'Nota: Estos datos actualizan tanto el Zarpe como el Cuadre.', 
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
        ),
      ],
    );
  }

  void _abrirGaleriaLightbox(List<String> urls, int indiceInicial) {
    showDialog(
      context: context,
      builder: (ctx) {
        int indiceLocal = indiceInicial;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The Interactive Image View
                  InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        urls[indiceLocal],
                        loadingBuilder: (c, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CargaOrbital(tamano: 60));
                        },
                      ),
                    ),
                  ),

                  // Left Lightbox Arrow
                  if (urls.length > 1)
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        radius: 28,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                          onPressed: () {
                            setStateDialog(() {
                              indiceLocal = (indiceLocal - 1 + urls.length) % urls.length;
                            });
                          },
                        ),
                      ),
                    ),

                  // Right Lightbox Arrow
                  if (urls.length > 1)
                    Positioned(
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        radius: 28,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 24),
                          onPressed: () {
                            setStateDialog(() {
                              indiceLocal = (indiceLocal + 1) % urls.length;
                            });
                          },
                        ),
                      ),
                    ),

                  // Close button
                  Positioned(
                    top: 20,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      radius: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ),

                  // Image indicator text at the bottom
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Foto ${indiceLocal + 1} de ${urls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _construirSeccionEmbarcaciones() {
    return _tarjeta(
      titulo: 'Embarcaciones Asociadas (Compras)',
      hijos: [
        if (_compras.isEmpty) 
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No hay embarcaciones registradas.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ),
        ..._compras.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text('${c.embarcacion} - ${c.producto}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
            subtitle: Text('${c.kilos}kg @ S/ ${c.precioUnitario}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('S/ ${c.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF00796B), size: 20),
                  onPressed: () => _mostrarDialogoCompra(c),
                  tooltip: 'Editar embarcación',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () => setState(() => _compras.removeWhere((item) => item.id == c.id)),
                  tooltip: 'Eliminar embarcación',
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _mostrarDialogoCompra(),
          icon: const Icon(Icons.add_rounded, color: Color(0xFF00796B), size: 18),
          label: const Text('Añadir embarcación', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF00796B)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        )
      ]
    );
  }

  Widget _construirSeccionFlete() {
    return _tarjeta(
      titulo: 'Gastos (Flete y Otros)',
      hijos: [
        if (_gastos.isEmpty) 
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No hay gastos registrados.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ),
        ..._gastos.map((g) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text('${g.tipo} - ${g.concepto}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
            subtitle: Text('Cant: ${g.cantidad} @ S/ ${g.costoUnitario}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('S/ ${g.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFFEA580C), size: 20),
                  onPressed: () => _mostrarDialogoGasto(g),
                  tooltip: 'Editar gasto',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () => setState(() => _gastos.removeWhere((item) => item.id == g.id)),
                  tooltip: 'Eliminar gasto',
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _mostrarDialogoGasto(),
          icon: const Icon(Icons.add_rounded, color: Color(0xFFEA580C), size: 18),
          label: const Text('Añadir gasto', style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFEA580C)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        )
      ]
    );
  }

  Widget _tarjeta({required String titulo, required List<Widget> hijos}) {
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
          Text(titulo, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Color(0xFFF1F5F9), height: 32),
          ...hijos,
        ],
      ),
    );
  }

  InputDecoration _decoracion(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00796B), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );
  }

  Widget _construirEtiquetaDialogo(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  InputDecoration _decoracionDialogo(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF2D302D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white38)),
    );
  }

  void _mostrarDialogoCompra([CompraWebModelo? compra]) {
    final esNuevo = compra == null;
    final embarcacionCtrl = TextEditingController(text: compra?.embarcacion ?? '');
    String productoSeleccionado = compra?.producto ?? 'POTA';
    final kilosCtrl = TextEditingController(text: compra?.kilos.toString() ?? '');
    final precioCtrl = TextEditingController(text: compra?.precioUnitario.toString() ?? '');
    final adelantoCtrl = TextEditingController(text: compra?.adelanto?.toString() ?? '0.00');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1E201E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esNuevo ? 'Añadir embarcación' : 'Editar embarcación',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los datos de la compra registrada.',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _construirEtiquetaDialogo('Nombre de la embarcación'),
                TextField(
                  controller: embarcacionCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseTextFormatter()],
                  decoration: _decoracionDialogo('Ej. DON LUCHO II'),
                ),
                _construirEtiquetaDialogo('Especie'),
                DropdownButtonFormField<String>(
                  value: productoSeleccionado,
                  dropdownColor: const Color(0xFF1E201E),
                  iconEnabledColor: Colors.white70,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona especie'),
                  items: ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"].map<Widget>((String value) {
                      return Text(
                        value,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      );
                    }).toList();
                  },
                  onChanged: (val) { if (val != null) setStateDialog(() => productoSeleccionado = val); },
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Kilos'),
                          TextField(
                            controller: kilosCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Precio unitario'),
                          TextField(
                            controller: precioCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('S/ 0.00'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _construirEtiquetaDialogo('Adelanto en efectivo'),
                TextField(
                  controller: adelantoCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                  decoration: _decoracionDialogo('S/ 0.00'),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final kilos = double.tryParse(kilosCtrl.text) ?? 0.0;
                    final precio = double.tryParse(precioCtrl.text) ?? 0.0;
                    final adelanto = double.tryParse(adelantoCtrl.text) ?? 0.0;
                    if (embarcacionCtrl.text.trim().isEmpty) return;

                    setState(() {
                      if (esNuevo) {
                        _compras.add(CompraWebModelo(
                          id: const Uuid().v4(),
                          cuadreId: widget.id,
                          embarcacion: embarcacionCtrl.text.trim().toUpperCase(),
                          producto: productoSeleccionado,
                          kilos: kilos,
                          precioUnitario: precio,
                          total: kilos * precio,
                          adelanto: adelanto,
                        ));
                      } else {
                        final index = _compras.indexWhere((c) => c.id == compra.id);
                        if (index != -1) {
                          _compras[index] = CompraWebModelo(
                            id: compra.id,
                            cuadreId: widget.id,
                            embarcacion: embarcacionCtrl.text.trim().toUpperCase(),
                            producto: productoSeleccionado,
                            kilos: kilos,
                            precioUnitario: precio,
                            total: kilos * precio,
                            adelanto: adelanto,
                          );
                        }
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853), // Green
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoGasto([GastoWebModelo? gasto]) {
    final esNuevo = gasto == null;
    String tipoSeleccionado = ['MUELLE', 'FLETE', 'OTROS'].contains(gasto?.tipo) ? gasto!.tipo : 'MUELLE';
    String conceptoSeleccionado = ['FACTURACION', 'PERSONAL', 'APOYO', 'AGUA', 'PESADOR', 'CLOROX', 'HIELO', 'FLETE', 'OTROS'].contains(gasto?.concepto) ? gasto!.concepto : 'HIELO';
    final cantidadCtrl = TextEditingController(text: gasto?.cantidad.toString() ?? '1');
    final precioCtrl = TextEditingController(text: gasto?.costoUnitario.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1E201E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esNuevo ? 'Añadir gasto' : 'Editar gasto',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los datos del gasto registrado.',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _construirEtiquetaDialogo('Tipo de gasto'),
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  dropdownColor: const Color(0xFF1E201E),
                  iconEnabledColor: Colors.white70,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona tipo'),
                  items: ['MUELLE', 'FLETE', 'OTROS'].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return ['MUELLE', 'FLETE', 'OTROS'].map<Widget>((String value) {
                      return Text(
                        value,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      );
                    }).toList();
                  },
                  onChanged: (val) { if (val != null) setStateDialog(() => tipoSeleccionado = val); },
                ),
                _construirEtiquetaDialogo('Concepto / Detalle'),
                DropdownButtonFormField<String>(
                  value: conceptoSeleccionado,
                  dropdownColor: const Color(0xFF1E201E),
                  iconEnabledColor: Colors.white70,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona concepto'),
                  items: ['FACTURACION', 'PERSONAL', 'APOYO', 'AGUA', 'PESADOR', 'CLOROX', 'HIELO', 'FLETE', 'OTROS'].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return ['FACTURACION', 'PERSONAL', 'APOYO', 'AGUA', 'PESADOR', 'CLOROX', 'HIELO', 'FLETE', 'OTROS'].map<Widget>((String value) {
                      return Text(
                        value,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      );
                    }).toList();
                  },
                  onChanged: (val) { if (val != null) setStateDialog(() => conceptoSeleccionado = val); },
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Cantidad'),
                          TextField(
                            controller: cantidadCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('1'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Costo unitario'),
                          TextField(
                            controller: precioCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('S/ 0.00'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final cant = double.tryParse(cantidadCtrl.text) ?? 1.0;
                    final precio = double.tryParse(precioCtrl.text) ?? 0.0;

                    setState(() {
                      if (esNuevo) {
                        _gastos.add(GastoWebModelo(
                          id: const Uuid().v4(),
                          cuadreId: widget.id,
                          tipo: tipoSeleccionado,
                          concepto: conceptoSeleccionado,
                          cantidad: cant,
                          costoUnitario: precio,
                          total: cant * precio,
                        ));
                      } else {
                        final index = _gastos.indexWhere((g) => g.id == gasto.id);
                        if (index != -1) {
                          _gastos[index] = GastoWebModelo(
                            id: gasto.id,
                            cuadreId: widget.id,
                            tipo: tipoSeleccionado,
                            concepto: conceptoSeleccionado,
                            cantidad: cant,
                            costoUnitario: precio,
                            total: cant * precio,
                          );
                        }
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853), // Green
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
