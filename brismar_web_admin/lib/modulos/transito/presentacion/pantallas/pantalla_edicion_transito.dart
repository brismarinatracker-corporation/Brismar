import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      // Si existe Cuadre, actualizarlo
      if (_cuadreInfo != null) {
        await cliente.from('cuadres').update({
          'placa': _placaCtrl.text.trim(), // mantener sincronizados
        }).eq('id', widget.id);
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
    final urlFoto = _zarpeInfo?['foto_url_evidencia'] ?? '';

    return _tarjeta(
      titulo: 'Datos del Zarpe (Cámara)',
      hijos: [
        if (urlFoto.toString().isNotEmpty) ...[
          const Text(
            'Evidencia Fotográfica / Guía',
            style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(40),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(urlFoto),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  color: const Color(0xFFF1F5F9),
                  constraints: const BoxConstraints(maxHeight: 220),
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          urlFoto,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const SizedBox(
                            height: 120,
                            child: Center(
                              child: Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 40),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ),
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
            trailing: Text('S/ ${c.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Lógica para añadir nueva embarcación
          },
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
            trailing: Text('S/ ${g.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Lógica para añadir nuevo gasto
          },
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
}
