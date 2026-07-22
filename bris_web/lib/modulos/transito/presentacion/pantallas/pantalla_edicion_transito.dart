import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
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
  ConsumerState<PantallaEdicionTransito> createState() =>
      _PantallaEdicionTransitoState();
}

class _PantallaEdicionTransitoState
    extends ConsumerState<PantallaEdicionTransito> {
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
  final _otroProductoCtrl = TextEditingController();
  String? _tipoProductoSeleccionado;

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
    setState(() {
      _cargando = true;
      _error = null;
    });
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

      if (zarpe == null) {
        throw Exception('No se encontró el zarpe con ID ${widget.id}');
      }

      setState(() {
        _zarpeInfo = zarpe;
        _placaCtrl.text = zarpe.placaCamara;
        _choferCtrl.text = zarpe.chofer;
        _numeroChoferCtrl.text = zarpe.numeroChofer;
        _muelleCtrl.text = zarpe.muellePartida;
        final obsGasto = gastos.where((g) => g.concepto.toUpperCase().trim() == 'OBSERVACIONES').firstOrNull;
        _observacionesCtrl.text = (zarpe.observaciones != null && zarpe.observaciones!.isNotEmpty) 
            ? zarpe.observaciones! 
            : (obsGasto?.tipo ?? '');

        if (cuadre != null) {
          _pesoTotalCtrl.text = cuadre.pesoTotal?.toString() ?? '';
          _cajasLlenasCtrl.text = cuadre.cajasLlenas?.toString() ?? '';
          _cajasVaciasCtrl.text = cuadre.cajasVacias?.toString() ?? '';
          _pesadorCtrl.text = cuadre.pesador ?? '';
          _tipoCtrl.text = cuadre.tipo ?? '';
          _cuadrillaCtrl.text = cuadre.cuadrilla ?? '';
          _tipoProductoSeleccionado = cuadre.tipoProducto;
          if (_tipoProductoSeleccionado != null &&
              ![
                'CATANA',
                'POTA',
                '1a',
                '2a',
                'Destare',
                'Caballa',
                'BONITO',
                'JUREL',
                'OTROS',
              ].contains(_tipoProductoSeleccionado)) {
            _otroProductoCtrl.text = _tipoProductoSeleccionado!;
            _tipoProductoSeleccionado = 'OTROS';
          }
        } else {
          // If cuadre doesn't exist, we fall back to zarpe fields if any.
          _pesoTotalCtrl.text =
              zarpe.pesoTotal?.toString() ??
              zarpe.pesoAproximado?.toString() ??
              '';
          _cajasLlenasCtrl.text =
              zarpe.cajasLlenas?.toString() ??
              zarpe.numeroCajas?.toString() ??
              '';
        }

        _compras = List.from(compras);
        _gastos = List.from(gastos)..removeWhere((g) => g.concepto.toUpperCase().trim() == 'OBSERVACIONES');
        _ventas = List.from(ventas);
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _recalcularGastosAdministrativos() {
    double totalKilos = 0;
    double totalVenta = 0;
    for (var v in _ventas) {
      totalKilos += v.kilos;
      totalVenta += v.total;
    }

    // Crear una nueva referencia para que el widget hijo detecte el cambio
    _gastos = List.from(_gastos);

    // 1. FACTURACION_PLANTA = totalKilos * 0.1
    _actualizarGastoFijo('FACTURACION_PLANTA', totalKilos * 0.1);
    
    // 2. IMPUESTO DE RENTA = totalVenta * 0.03
    _actualizarGastoFijo('IMPUESTO DE RENTA', totalVenta * 0.03);
  }

  void _actualizarGastoFijo(String concepto, double totalCalculado) {
    final idx = _gastos.indexWhere((g) => g.concepto.toUpperCase().trim() == concepto);
    if (totalCalculado > 0) {
      if (idx >= 0) {
        _gastos[idx] = GastoWebModelo(
          id: _gastos[idx].id,
          cuadreId: _gastos[idx].cuadreId,
          tipo: 'Administrativo',
          concepto: concepto,
          cantidad: 1,
          costoUnitario: totalCalculado,
          total: totalCalculado,
        );
      } else {
        _gastos.add(GastoWebModelo(
          id: const Uuid().v4(),
          cuadreId: widget.id,
          tipo: 'Administrativo',
          concepto: concepto,
          cantidad: 1,
          costoUnitario: totalCalculado,
          total: totalCalculado,
        ));
      }
    } else {
      if (idx >= 0) {
        _gastos.removeAt(idx);
      }
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
        cajasVacias: int.tryParse(_cajasVaciasCtrl.text) ?? 0,
        tipoProducto: _tipoProductoSeleccionado == 'OTROS'
            ? _otroProductoCtrl.text.trim().toUpperCase()
            : _tipoProductoSeleccionado,
        pesador: _pesadorCtrl.text.trim().isEmpty
            ? null
            : _pesadorCtrl.text.trim().toUpperCase(),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarParcial(String mensaje) async {
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
        cajasVacias: int.tryParse(_cajasVaciasCtrl.text) ?? 0,
        tipoProducto: _tipoProductoSeleccionado == 'OTROS'
            ? _otroProductoCtrl.text.trim().toUpperCase()
            : _tipoProductoSeleccionado,
        pesador: _pesadorCtrl.text.trim().isEmpty
            ? null
            : _pesadorCtrl.text.trim().toUpperCase(),
        tipo: _tipoCtrl.text.trim(),
        cuadrilla: _cuadrillaCtrl.text.trim(),
        compras: _compras,
        gastos: _gastos,
        ventas: _ventas,
      );
      await repo.guardarEdicion(params);
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  '¡Guardado!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _finalizarViaje() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Finalizar Viaje'),
        content: const Text('¿Estás seguro que deseas finalizar este viaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text(
              'Sí, Finalizar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

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
        cajasVacias: int.tryParse(_cajasVaciasCtrl.text) ?? 0,
        tipoProducto: _tipoProductoSeleccionado == 'OTROS'
            ? _otroProductoCtrl.text.trim().toUpperCase()
            : _tipoProductoSeleccionado,
        pesador: _pesadorCtrl.text.trim().isEmpty
            ? null
            : _pesadorCtrl.text.trim().toUpperCase(),
        tipo: _tipoCtrl.text.trim(),
        cuadrilla: _cuadrillaCtrl.text.trim(),
        compras: _compras,
        gastos: _gastos,
        ventas: _ventas,
      );
      await repo.guardarEdicion(params);
      await repo.finalizarViaje(widget.id);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  '¡Finalizado!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text('El viaje se ha finalizado correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
        ref.read(proveedorTransito.notifier).recargar();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo finalizar: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Aceptar'),
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
    final estaFinalizado = _zarpeInfo?.estado.estaFinalizado ?? false;
    final esSoloLectura =
        authState.rol == 'administrador' ||
        authState.rol == 'supervisor' ||
        estaFinalizado;
    final esMovil = MediaQuery.of(context).size.width < 800;

    if (_cargando && _zarpeInfo == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CargaOrbital(tamano: 80)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
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
                    child: esMovil
                        ? Column(
                            children: [
                              _construirNavegacionPasos(context, esSoloLectura),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: AbsorbPointer(
                                    absorbing: esSoloLectura,
                                    child: _construirContenidoPasoActual(
                                      urlsFotos,
                                      esSoloLectura,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _construirNavegacionPasos(context, esSoloLectura),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(32),
                                  child: AbsorbPointer(
                                    absorbing: esSoloLectura,
                                    child: _construirContenidoPasoActual(
                                      urlsFotos,
                                      esSoloLectura,
                                    ),
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
      padding: EdgeInsets.symmetric(
        horizontal: esMovil ? 20 : 32,
        vertical: esMovil ? 16 : 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: esMovil
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF15181A),
                        size: 24,
                      ),
                      onPressed: () => context.pop(),
                      tooltip: 'Volver',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        esSoloLectura
                            ? 'Detalles de Viaje (Finalizado)'
                            : 'Editor de Viaje / Cuadre',
                        style: GoogleFonts.sora(
                          color: const Color(0xFF15181A),
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
                    child: ElevatedButton.icon(
                      onPressed: _guardarCambios,
                      icon: const Icon(
                        Icons.save_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Guardar',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E3E2C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF15181A),
                        size: 24,
                      ),
                      onPressed: () => context.pop(),
                      tooltip: 'Volver',
                    ),
                    const SizedBox(width: 16),
                    Text(
                      esSoloLectura
                          ? 'Detalles de Viaje (Finalizado)'
                          : 'Editor de Viaje / Cuadre',
                      style: GoogleFonts.sora(
                        color: const Color(0xFF15181A),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!esSoloLectura)
                  ElevatedButton.icon(
                    onPressed: _guardarCambios,
                    icon: const Icon(
                      Icons.save_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'Guardar',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E3E2C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _construirNavegacionPasos(BuildContext context, bool esSoloLectura) {
    final esMovil = MediaQuery.of(context).size.width < 800;

    if (esMovil) {
      return Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _construirItemPaso(esMovil, 0, 'Zarpe Inicial', 'Partida', Icons.directions_boat_outlined, esSoloLectura),
            _construirItemPaso(esMovil, 1, 'Cuadre Muelle', 'Compras', Icons.receipt_long_outlined, esSoloLectura),
            _construirItemPaso(esMovil, 2, 'Recepción', 'Destino', Icons.storefront_outlined, esSoloLectura),
            _construirItemPaso(esMovil, 3, 'Gastos Admin', 'Fletes', Icons.account_balance_wallet_outlined, esSoloLectura),
          ],
        ),
      );
    }

    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          _construirItemPaso(esMovil, 0, 'Zarpe Inicial', 'Datos de partida', Icons.directions_boat_outlined, esSoloLectura),
          _construirItemPaso(esMovil, 1, 'Cuadre de Muelle', 'Gastos operativos y compras', Icons.receipt_long_outlined, esSoloLectura),
          _construirItemPaso(esMovil, 2, 'Recepción y Venta', 'Destino, kilos y precio final', Icons.storefront_outlined, esSoloLectura),
          _construirItemPaso(esMovil, 3, 'Gastos Administrativos', 'Fletes y comisiones', Icons.account_balance_wallet_outlined, esSoloLectura),
        ],
      ),
    );
  }

  Widget _construirItemPaso(
    bool esMovil,
    int indice,
    String titulo,
    String subtitulo,
    IconData icono,
    bool esSoloLectura,
  ) {
    final seleccionado = _pasoActual == indice;
    return InkWell(
      onTap: () => setState(() => _pasoActual = indice),
      child: Container(
        padding: esMovil 
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFFF0FDF4) : Colors.transparent,
          border: esMovil 
              ? Border(
                  bottom: BorderSide(
                    color: seleccionado ? const Color(0xFF00C853) : Colors.transparent,
                    width: 3,
                  ),
                )
              : Border(
                  left: BorderSide(
                    color: seleccionado ? const Color(0xFF00C853) : Colors.transparent,
                    width: 4,
                  ),
                  bottom: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
        ),
        child: Row(
          mainAxisSize: esMovil ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: seleccionado ? const Color(0xFF00C853) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                color: seleccionado ? Colors.white : const Color(0xFF64748B),
                size: esMovil ? 18 : 22,
              ),
            ),
            const SizedBox(width: 12),
            if (!esMovil)
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
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: seleccionado ? const Color(0xFF15181A) : const Color(0xFF475569),
                      fontWeight: seleccionado ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirContenidoPasoActual(
    List<String> urlsFotos,
    bool esSoloLectura,
  ) {
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
              tipoProductoActual: _tipoProductoSeleccionado == 'OTROS'
                  ? _otroProductoCtrl.text
                  : _tipoProductoSeleccionado,
              onTipoProductoCambiado: (v) =>
                  setState(() => _tipoProductoSeleccionado = v),
            ),
            _botonGuardarSeccion(
              'Guardar Datos Iniciales',
              '¡Datos iniciales de Zarpe guardados con éxito!',
              esSoloLectura,
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
              esSoloLectura: esSoloLectura,
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
              onEliminar: (id) =>
                  setState(() => _compras.removeWhere((item) => item.id == id)),
            ),
            const SizedBox(height: 24),
            SeccionGastos(
              gastos: _gastos,
              esSoloLectura: esSoloLectura,
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
              onEliminar: (id) =>
                  setState(() => _gastos.removeWhere((item) => item.id == id)),
            ),
            _botonGuardarSeccion(
              'Guardar Compras y Gastos Muelle',
              '¡Compras y Gastos de Muelle guardados con éxito!',
              esSoloLectura,
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
              esSoloLectura: esSoloLectura,
              onGuardar: (v) {
                setState(() {
                  final idx = _ventas.indexWhere((item) => item.id == v.id);
                  if (idx >= 0) {
                    _ventas[idx] = v;
                  } else {
                    _ventas.add(v);
                  }
                  _recalcularGastosAdministrativos();
                });
              },
              onEliminar: (id) {
                setState(() {
                  _ventas.removeWhere((item) => item.id == id);
                  _recalcularGastosAdministrativos();
                });
              },
            ),
            _botonGuardarSeccion(
              'Guardar Ventas',
              '¡Ventas guardadas con éxito!',
              esSoloLectura,
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
              esSoloLectura: esSoloLectura,
              onGuardarSeccion: esSoloLectura
                  ? null
                  : () => _guardarParcial(
                      '¡Gastos Administrativos guardados con éxito!',
                    ),
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
              onEliminar: (id) =>
                  setState(() => _gastos.removeWhere((item) => item.id == id)),
            ),
            _botonFinalizarViajeBtn(esSoloLectura),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _botonGuardarSeccion(
    String titulo,
    String mensaje,
    bool esSoloLectura,
  ) {
    if (esSoloLectura) return const SizedBox();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save, size: 18, color: Colors.white),
        label: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00796B),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: () => _guardarParcial(mensaje),
      ),
    );
  }

  Widget _botonFinalizarViajeBtn(bool esSoloLectura) {
    if (esSoloLectura) return const SizedBox();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.lock, size: 18, color: Colors.white),
        label: const Text(
          'Finalizar Viaje (Cerrar Cuadre)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: _finalizarViaje,
      ),
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        titulo,
        style: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF15181A),
        ),
      ),
    );
  }
}
