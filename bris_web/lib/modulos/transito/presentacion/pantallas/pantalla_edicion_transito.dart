import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controladores/controlador_transito.dart';
import '../../datos/repositorio_edicion_zarpe.dart';
import '../../dominio/modelos/zarpe_modelo.dart';
import '../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _observacionesCtrl = TextEditingController();

  // Controladores Extra (Cuadre)
  final _pesoTotalCtrl = TextEditingController();
  final _cajasLlenasCtrl = TextEditingController();
  final _cajasVaciasCtrl = TextEditingController();
  final _pesadorCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _cuadrillaCtrl = TextEditingController();
  int _tipoProductoSeleccionado = 1;

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
    _observacionesCtrl.dispose();
    _pesoTotalCtrl.dispose();
    _cajasLlenasCtrl.dispose();
    _cajasVaciasCtrl.dispose();
    _pesadorCtrl.dispose();
    _tipoCtrl.dispose();
    _cuadrillaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final repo = ref.read(proveedorRepositorioEdicionZarpe);

      final resultados = await Future.wait([
        repo.cargarZarpe(widget.id),
        repo.cargarCuadre(widget.id),
        repo.cargarCompras(widget.id),
        repo.cargarGastos(widget.id),
      ]);

      final zarpe = resultados[0] as ZarpeModelo?;
      final cuadre = resultados[1] as CuadreWebModelo?;
      final compras = resultados[2] as List<CompraWebModelo>;
      final gastos = resultados[3] as List<GastoWebModelo>;

      if (zarpe == null) throw Exception('No se encontró el zarpe con ID ${widget.id}');
      
      setState(() {
        _zarpeInfo = zarpe;
        _placaCtrl.text = zarpe.placaCamara;
        _choferCtrl.text = zarpe.chofer;
        _muelleCtrl.text = zarpe.muellePartida;
        _observacionesCtrl.text = zarpe.observaciones ?? '';
        
        if (cuadre != null) {
          _pesoTotalCtrl.text = cuadre.pesoTotal?.toString() ?? '';
          _cajasLlenasCtrl.text = cuadre.cajasLlenas?.toString() ?? '';
          _cajasVaciasCtrl.text = cuadre.cajasVacias?.toString() ?? '';
          _pesadorCtrl.text = cuadre.pesador ?? '';
          _tipoCtrl.text = cuadre.tipo ?? '';
          _cuadrillaCtrl.text = cuadre.cuadrilla ?? '';
          _tipoProductoSeleccionado = cuadre.tipoProducto ?? 1;
        } else {
          // If cuadre doesn't exist, we fall back to zarpe fields if any.
          _pesoTotalCtrl.text = zarpe.pesoTotal?.toString() ?? zarpe.pesoAproximado?.toString() ?? '';
          _cajasLlenasCtrl.text = zarpe.cajasLlenas?.toString() ?? zarpe.numeroCajas?.toString() ?? '';
        }

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
        observaciones: _observacionesCtrl.text.trim(),
        pesoTotal: double.tryParse(_pesoTotalCtrl.text.trim()),
        cajasLlenas: int.tryParse(_cajasLlenasCtrl.text.trim()),
        cajasVacias: int.tryParse(_cajasVaciasCtrl.text.trim()),
        tipoProducto: _tipoProductoSeleccionado,
        pesador: _pesadorCtrl.text.trim(),
        tipo: _tipoCtrl.text.trim(),
        cuadrilla: _cuadrillaCtrl.text.trim(),
        compras: _compras,
        gastos: _gastos,
      );

      await repo.guardarEdicion(params);
      
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('¡Éxito!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text('Los cambios se guardaron correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Aceptar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        ref.read(proveedorTransito.notifier).recargar();
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text('No se pudo guardar: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Aceptar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
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
    final esMovil = MediaQuery.of(context).size.width < 800;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: esMovil ? 20 : 32, vertical: esMovil ? 16 : 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0E3E2C), // Dark green matching mockup
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: esMovil
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                      onPressed: () => context.pop(),
                      tooltip: 'Volver',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Editor de Viaje / Cuadre',
                        style: GoogleFonts.sora(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                    label: Text('Guardar', style: GoogleFonts.inter(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )
          : Row(
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
                    Text(
                      'Editor de Viaje / Cuadre',
                      style: GoogleFonts.sora(
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
                  label: Text('Guardar', style: GoogleFonts.inter(color: Colors.white)),
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
      SeccionDatosZarpe(
        urlsFotos: urlsFotos,
        placaCtrl: _placaCtrl,
        choferCtrl: _choferCtrl,
        muelleCtrl: _muelleCtrl,
        pesoTotalCtrl: _pesoTotalCtrl,
        cajasLlenasCtrl: _cajasLlenasCtrl,
        cajasVaciasCtrl: _cajasVaciasCtrl,
        pesadorCtrl: _pesadorCtrl,
        tipoCtrl: _tipoCtrl,
        cuadrillaCtrl: _cuadrillaCtrl,
        tipoProductoActual: _tipoProductoSeleccionado,
        onTipoProductoCambiado: (v) => setState(() => _tipoProductoSeleccionado = v),
      ),
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
      Expanded(
        flex: 1,
        child: SeccionDatosZarpe(
          urlsFotos: urlsFotos,
          placaCtrl: _placaCtrl,
          choferCtrl: _choferCtrl,
          muelleCtrl: _muelleCtrl,
          pesoTotalCtrl: _pesoTotalCtrl,
          cajasLlenasCtrl: _cajasLlenasCtrl,
          cajasVaciasCtrl: _cajasVaciasCtrl,
          pesadorCtrl: _pesadorCtrl,
          tipoCtrl: _tipoCtrl,
          cuadrillaCtrl: _cuadrillaCtrl,
          tipoProductoActual: _tipoProductoSeleccionado,
          onTipoProductoCambiado: (v) => setState(() => _tipoProductoSeleccionado = v),
        ),
      ),
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
