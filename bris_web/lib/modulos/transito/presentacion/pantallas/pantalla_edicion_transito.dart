import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controladores/controlador_transito.dart';
import '../../datos/repositorio_edicion_zarpe.dart';
import '../../dominio/modelos/zarpe_modelo.dart';
import '../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

import 'widgets/seccion_datos_zarpe.dart';
import 'widgets/seccion_embarcaciones.dart';
import 'widgets/seccion_gastos.dart';
import 'widgets/seccion_gastos_administrativos.dart';
import 'widgets/seccion_recepcion_venta.dart';


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
  final _numeroChoferCtrl = TextEditingController();
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

  // Variables locales para Compras, Gastos, Ventas
  List<CompraWebModelo> _compras = [];
  List<GastoWebModelo> _gastos = [];
  List<VentaWebModelo> _ventas = [];
  
  // Paso actual
  int _pasoActual = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _choferCtrl.dispose();
    _numeroChoferCtrl.dispose();
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
        repo.cargarVentas(widget.id),
      ]);

      final zarpe = resultados[0] as ZarpeModelo?;
      final cuadre = resultados[1] as CuadreWebModelo?;
      final compras = resultados[2] as List<CompraWebModelo>;
      final gastos = resultados[3] as List<GastoWebModelo>;
      final ventas = resultados[4] as List<VentaWebModelo>;

      if (zarpe == null) throw Exception('No se encontró el zarpe con ID ${widget.id}');
      
      setState(() {
        _zarpeInfo = zarpe;
        _placaCtrl.text = zarpe.placaCamara;
        _choferCtrl.text = zarpe.chofer;
        _numeroChoferCtrl.text = zarpe.numeroChofer;
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
        _ventas = List.from(ventas);
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
        ventas: _ventas,
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
    final authState = ref.watch(proveedorAutenticacion);
    final esSoloLectura = authState.rol == 'administrador' || authState.rol == 'supervisor';

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
                _construirEncabezado(context, esSoloLectura),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Navegación Lateral (Pasos)
                        _construirNavegacionPasos(esSoloLectura),
                        // Contenido del Paso Actual
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32),
                            child: AbsorbPointer(
                              absorbing: esSoloLectura,
                              child: _construirContenidoPasoActual(urlsFotos),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _construirEncabezado(BuildContext context, bool esSoloLectura) {
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
                if (!esSoloLectura)
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
                if (!esSoloLectura)
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

  Widget _construirNavegacionPasos(bool esSoloLectura) {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          _construirItemPaso(0, 'Zarpe Inicial', 'Datos de partida', Icons.directions_boat_outlined, esSoloLectura),
          _construirItemPaso(1, 'Cuadre de Muelle', 'Gastos operativos y compras', Icons.receipt_long_outlined, esSoloLectura),
          _construirItemPaso(2, 'Recepción y Venta', 'Destino, kilos y precio final', Icons.storefront_outlined, esSoloLectura),
          _construirItemPaso(3, 'Gastos Administrativos', 'Fletes y comisiones', Icons.account_balance_wallet_outlined, esSoloLectura),
        ],
      ),
    );
  }

  Widget _construirItemPaso(int indice, String titulo, String subtitulo, IconData icono, bool esSoloLectura) {
    final seleccionado = _pasoActual == indice;
    return InkWell(
      onTap: () => setState(() => _pasoActual = indice),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFFF0FDF4) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: seleccionado ? const Color(0xFF00C853) : Colors.transparent,
              width: 4,
            ),
            bottom: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: seleccionado ? const Color(0xFF00C853) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: seleccionado ? Colors.white : const Color(0xFF64748B), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: seleccionado ? const Color(0xFF15181A) : const Color(0xFF475569),
                      fontWeight: seleccionado ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirContenidoPasoActual(List<String> urlsFotos) {
    switch (_pasoActual) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloSeccion('Paso 1: Zarpe Inicial (Bahía)'),
            SeccionDatosZarpe(
              urlsFotos: urlsFotos,
              placaCtrl: _placaCtrl,
              choferCtrl: _choferCtrl,
              numeroChoferCtrl: _numeroChoferCtrl,
              muelleCtrl: _muelleCtrl,
              pesoTotalCtrl: _pesoTotalCtrl,
              cajasLlenasCtrl: _cajasLlenasCtrl,
              cajasVaciasCtrl: _cajasVaciasCtrl,
              pesadorCtrl: _pesadorCtrl,
              tipoCtrl: _tipoCtrl,
              cuadrillaCtrl: _cuadrillaCtrl,
              observacionesCtrl: _observacionesCtrl,
              tipoProductoActual: _tipoProductoSeleccionado,
              onTipoProductoCambiado: (v) => setState(() => _tipoProductoSeleccionado = v),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloSeccion('Paso 2: Cuadre de Muelle (Bahía)'),
            SeccionEmbarcaciones(
              compras: _compras, 
              onGuardar: (c) {
                setState(() {
                  final idx = _compras.indexWhere((item) => item.id == c.id);
                  if (idx >= 0) _compras[idx] = c;
                  else _compras.add(c);
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
                  if (idx >= 0) _gastos[idx] = g;
                  else _gastos.add(g);
                });
              },
              onEliminar: (id) => setState(() => _gastos.removeWhere((item) => item.id == id)),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloSeccion('Paso 3: Recepción y Venta (Trabajador de Planta)'),
            SeccionRecepcionVenta(
              ventas: _ventas,
              onGuardar: (v) {
                setState(() {
                  final idx = _ventas.indexWhere((item) => item.id == v.id);
                  if (idx >= 0) _ventas[idx] = v;
                  else _ventas.add(v);
                });
              },
              onEliminar: (id) => setState(() => _ventas.removeWhere((item) => item.id == id)),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloSeccion('Paso 4: Gastos Administrativos (Trabajador/Admin)'),
            SeccionGastosAdministrativos(
              gastos: _gastos,
              onGuardar: (g) {
                setState(() {
                  final idx = _gastos.indexWhere((item) => item.id == g.id);
                  if (idx >= 0) _gastos[idx] = g;
                  else _gastos.add(g);
                });
              },
              onEliminar: (id) => setState(() => _gastos.removeWhere((item) => item.id == id)),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _tituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        titulo,
        style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF15181A)),
      ),
    );
  }
}
