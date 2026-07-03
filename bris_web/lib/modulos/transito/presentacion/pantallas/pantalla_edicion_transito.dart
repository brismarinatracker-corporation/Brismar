import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controladores/controlador_transito.dart';
import '../../datos/repositorio_edicion_zarpe.dart';
import '../../dominio/modelos/zarpe_modelo.dart';
import '../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

import 'widgets/seccion_datos_zarpe.dart';
import 'widgets/seccion_embarcaciones.dart';
import 'widgets/seccion_gastos.dart';

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
  
  ZarpeModelo? _zarpeInfo;
  
  // Controladores Zarpe
  final _placaCtrl = TextEditingController();
  final _choferCtrl = TextEditingController();
  final _muelleCtrl = TextEditingController();

  // Variables locales para Compras, Gastos
  List<CompraWebModelo> _compras = [];
  List<GastoWebModelo> _gastos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _choferCtrl.dispose();
    _muelleCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final repo = ref.read(proveedorRepositorioEdicionZarpe);

      final resultados = await Future.wait([
        repo.cargarZarpe(widget.id),
        repo.cargarCompras(widget.id),
        repo.cargarGastos(widget.id),
      ]);

      final zarpe = resultados[0] as ZarpeModelo?;
      final compras = resultados[1] as List<CompraWebModelo>;
      final gastos = resultados[2] as List<GastoWebModelo>;

      if (zarpe == null) throw Exception('No se encontró el zarpe con ID ${widget.id}');
      
      setState(() {
        _zarpeInfo = zarpe;
        _placaCtrl.text = zarpe.placaCamara;
        _choferCtrl.text = zarpe.chofer;
        _muelleCtrl.text = zarpe.muellePartida;
        _compras = List.from(compras);
        _gastos = List.from(gastos);
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
      final repo = ref.read(proveedorRepositorioEdicionZarpe);
      
      final params = EdicionZarpeParams(
        id: widget.id,
        placa: _placaCtrl.text.trim(),
        chofer: _choferCtrl.text.trim(),
        muellePartida: _muelleCtrl.text.trim(),
        compras: _compras,
        gastos: _gastos,
      );

      await repo.guardarEdicion(params);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios guardados con éxito'), backgroundColor: Colors.green));
        ref.read(proveedorTransito.notifier).recargar();
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _cargando = false);
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

    final fotosString = _zarpeInfo?.fotoUrlEvidencia ?? '';
    final urlsFotos = fotosString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.startsWith('http'))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _cargando 
          ? const Center(child: CargaOrbital(tamano: 80))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirEncabezado(context),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final esPantallaPequena = constraints.maxWidth <= 1200;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: esPantallaPequena
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: _construirSecciones(urlsFotos),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _construirSeccionesRow(urlsFotos),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _construirEncabezado(BuildContext context) {
    return Container(
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
    );
  }

  List<Widget> _construirSecciones(List<String> urlsFotos) {
    return [
      SeccionDatosZarpe(urlsFotos: urlsFotos, placaCtrl: _placaCtrl, choferCtrl: _choferCtrl, muelleCtrl: _muelleCtrl),
      const SizedBox(height: 24),
      SeccionEmbarcaciones(
        compras: _compras, 
        onGuardar: (c) {
          setState(() {
            final idx = _compras.indexWhere((item) => item.id == c.id);
            if (idx >= 0) {
              _compras[idx] = c;
            } else {
              _compras.add(c);
            }
          });
        },
        onEliminar: (id) => setState(() => _compras.removeWhere((item) => item.id == id)),
      ),
      const SizedBox(height: 24),
      SeccionGastos(
        gastos: _gastos,
        onGuardar: (g) {
          setState(() {
            final idx = _gastos.indexWhere((item) => item.id == g.id);
            if (idx >= 0) {
              _gastos[idx] = g;
            } else {
              _gastos.add(g);
            }
          });
        },
        onEliminar: (id) => setState(() => _gastos.removeWhere((item) => item.id == id)),
      ),
    ];
  }

  List<Widget> _construirSeccionesRow(List<String> urlsFotos) {
    return [
      Expanded(flex: 1, child: SeccionDatosZarpe(urlsFotos: urlsFotos, placaCtrl: _placaCtrl, choferCtrl: _choferCtrl, muelleCtrl: _muelleCtrl)),
      const SizedBox(width: 32),
      Expanded(flex: 1, child: SeccionEmbarcaciones(
        compras: _compras, 
        onGuardar: (c) {
          setState(() {
            final idx = _compras.indexWhere((item) => item.id == c.id);
            if (idx >= 0) {
              _compras[idx] = c;
            } else {
              _compras.add(c);
            }
          });
        },
        onEliminar: (id) => setState(() => _compras.removeWhere((item) => item.id == id)),
      )),
      const SizedBox(width: 32),
      Expanded(flex: 1, child: SeccionGastos(
        gastos: _gastos,
        onGuardar: (g) {
          setState(() {
            final idx = _gastos.indexWhere((item) => item.id == g.id);
            if (idx >= 0) {
              _gastos[idx] = g;
            } else {
              _gastos.add(g);
            }
          });
        },
        onEliminar: (id) => setState(() => _gastos.removeWhere((item) => item.id == id)),
      )),
    ];
  }
}
