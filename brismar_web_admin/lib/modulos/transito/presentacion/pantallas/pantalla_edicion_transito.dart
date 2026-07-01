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
        
        // Aquí idealmente sincronizaríamos las listas de compras y gastos con Supabase.
        // Por simplicidad de esta demostración asíncrona, si _compras o _gastos cambiaran, 
        // haríamos un upsert o delete+insert.
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
      return const Scaffold(backgroundColor: Color(0xFF070E22), body: Center(child: CargaOrbital(tamano: 80)));
    }
    
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF070E22),
        body: Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.redAccent))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070E22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D255F),
        title: const Text('Editor de Viaje / Cuadre', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        actions: [
          if (!_cargando)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: const Color(0xFF070E22)),
              ),
            )
        ],
      ),
      body: _cargando 
          ? const Center(child: CargaOrbital(tamano: 80))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _construirSeccionZarpe()),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _construirSeccionLanchas()),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _construirSeccionFlete()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _construirSeccionZarpe() {
    return _tarjeta(
      titulo: 'Datos del Zarpe (Cámara)',
      hijos: [
        TextFormField(
          controller: _placaCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: _decoracion('Placa Cámara'),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _choferCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: _decoracion('Chofer'),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _muelleCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: _decoracion('Muelle Partida'),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        const Text('Nota: Estos datos actualizan tanto el Zarpe como el Cuadre.', style: TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _construirSeccionLanchas() {
    return _tarjeta(
      titulo: 'Lanchas Asociadas (Compras)',
      hijos: [
        if (_compras.isEmpty) const Text('No hay lanchas registradas.', style: TextStyle(color: Colors.white54)),
        ..._compras.map((c) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${c.embarcacion} - ${c.producto}', style: const TextStyle(color: Colors.white)),
          subtitle: Text('${c.kilos}kg @ S/ ${c.precioUnitario}', style: const TextStyle(color: Colors.white70)),
          trailing: Text('S/ ${c.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Lógica para añadir nueva lancha
          },
          icon: const Icon(Icons.add, color: Color(0xFF00E5FF)),
          label: const Text('Añadir Lancha', style: TextStyle(color: Color(0xFF00E5FF))),
        )
      ]
    );
  }

  Widget _construirSeccionFlete() {
    return _tarjeta(
      titulo: 'Gastos (Flete y Otros)',
      hijos: [
        if (_gastos.isEmpty) const Text('No hay gastos registrados.', style: TextStyle(color: Colors.white54)),
        ..._gastos.map((g) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${g.tipo} - ${g.concepto}', style: const TextStyle(color: Colors.white)),
          subtitle: Text('Cant: ${g.cantidad} @ S/ ${g.costoUnitario}', style: const TextStyle(color: Colors.white70)),
          trailing: Text('S/ ${g.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Lógica para añadir nuevo gasto
          },
          icon: const Icon(Icons.add, color: Colors.orangeAccent),
          label: const Text('Añadir Gasto', style: TextStyle(color: Colors.orangeAccent)),
        )
      ]
    );
  }

  Widget _tarjeta({required String titulo, required List<Widget> hijos}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12, height: 32),
          ...hijos,
        ],
      ),
    );
  }

  InputDecoration _decoracion(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00E5FF))),
    );
  }
}
