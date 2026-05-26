import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../autenticacion/presentacion/controladores/auth_controlador.dart';
import '../../dominio/entidades/registro_entidad.dart';
import '../controladores/registro_controlador.dart';
import '../componentes/user_header.dart';
import '../componentes/tab_selector.dart';
import '../componentes/seccion_totales.dart';
import '../componentes/historial_lista.dart';
import '../../../../nucleo/utilidades/pdf_helper.dart';

/// Pantalla principal para registrar capturas pesqueras y gastos en BRISMAR APP.
class RegistroPantalla extends ConsumerStatefulWidget {
  const RegistroPantalla({super.key});

  @override
  ConsumerState<RegistroPantalla> createState() => _RegistroPantallaState();
}

class _RegistroPantallaState extends ConsumerState<RegistroPantalla> {
  int _activeTabIndex = 0;
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLADORES DE LOS CAMPOS ---
  final _nombreNaveController = TextEditingController();
  final _kilosController = TextEditingController();
  final _catanaKilosController = TextEditingController(text: '0');
  final _catanaPrecioController = TextEditingController(text: '0');
  final _placaController = TextEditingController();
  final _cajasController = TextEditingController(text: '0');
  final _muelleController = TextEditingController();
  final _precioKiloVentaController = TextEditingController();

  // Gastos (Desglose de los 8 tipos)
  final _facturacionController = TextEditingController(text: '0');
  final _personalController = TextEditingController(text: '0');
  final _apoyoController = TextEditingController(text: '0');
  final _aguaController = TextEditingController(text: '0');
  final _cloroxController = TextEditingController(text: '0');
  final _fleteController = TextEditingController(text: '0');
  final _hieloController = TextEditingController(text: '0');
  final _otrosController = TextEditingController(text: '0');

  // --- VARIABLES DE ESTADO LOCAL ---
  String? productoSeleccionado;
  double kilosTotales = 0.0;
  double totalVenta = 0.0;
  double totalGastos = 0.0;
  double totalNeto = 0.0;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de controladores para auto-calcular
    _kilosController.addListener(_calcularTodo);
    _precioKiloVentaController.addListener(_calcularTodo);
    _facturacionController.addListener(_calcularTodo);
    _personalController.addListener(_calcularTodo);
    _apoyoController.addListener(_calcularTodo);
    _aguaController.addListener(_calcularTodo);
    _cloroxController.addListener(_calcularTodo);
    _fleteController.addListener(_calcularTodo);
    _hieloController.addListener(_calcularTodo);
    _otrosController.addListener(_calcularTodo);
  }

  @override
  void dispose() {
    _nombreNaveController.dispose();
    _kilosController.dispose();
    _catanaKilosController.dispose();
    _catanaPrecioController.dispose();
    _placaController.dispose();
    _cajasController.dispose();
    _muelleController.dispose();
    _precioKiloVentaController.dispose();
    _facturacionController.dispose();
    _personalController.dispose();
    _apoyoController.dispose();
    _aguaController.dispose();
    _cloroxController.dispose();
    _fleteController.dispose();
    _hieloController.dispose();
    _otrosController.dispose();
    super.dispose();
  }

  void _calcularTodo() {
    setState(() {
      kilosTotales = double.tryParse(_kilosController.text) ?? 0.0;
      final precioVenta = double.tryParse(_precioKiloVentaController.text) ?? 0.0;
      totalVenta = kilosTotales * precioVenta;

      final g1 = double.tryParse(_facturacionController.text) ?? 0.0;
      final g2 = double.tryParse(_personalController.text) ?? 0.0;
      final g3 = double.tryParse(_apoyoController.text) ?? 0.0;
      final g4 = double.tryParse(_aguaController.text) ?? 0.0;
      final g5 = double.tryParse(_cloroxController.text) ?? 0.0;
      final g6 = double.tryParse(_fleteController.text) ?? 0.0;
      final g7 = double.tryParse(_hieloController.text) ?? 0.0;
      final g8 = double.tryParse(_otrosController.text) ?? 0.0;

      totalGastos = g1 + g2 + g3 + g4 + g5 + g6 + g7 + g8;
      totalNeto = totalVenta - totalGastos;
    });
  }

  Future<void> _guardarRegistroFormulario(String nombreUsuario) async {
    if (!_formKey.currentState!.validate() || productoSeleccionado == null) {
      _mostrarMensaje('Rellene todos los campos obligatorios', Colors.orange);
      return;
    }

    final now = DateTime.now();
    final fecha = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hora = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final reg = RegistroEntidad(
      id: const Uuid().v4(),
      nombreEmbarcacion: _nombreNaveController.text,
      producto: productoSeleccionado!,
      placaCarro: _placaController.text,
      kilos: kilosTotales,
      precioPorKilo: double.tryParse(_precioKiloVentaController.text) ?? 0.0,
      fecha: fecha,
      hora: hora,
      muelleInicio: _muelleController.text,
      gastoFacturacion: double.tryParse(_facturacionController.text) ?? 0.0,
      gastoPersonal: double.tryParse(_personalController.text) ?? 0.0,
      gastoApoyo: double.tryParse(_apoyoController.text) ?? 0.0,
      gastoAgua: double.tryParse(_aguaController.text) ?? 0.0,
      gastoClorox: double.tryParse(_cloroxController.text) ?? 0.0,
      gastoFlete: double.tryParse(_fleteController.text) ?? 0.0,
      gastoHielo: double.tryParse(_hieloController.text) ?? 0.0,
      gastoOtros: double.tryParse(_otrosController.text) ?? 0.0,
    );

    try {
      await ref.read(proveedorHistorialController.notifier).registrarNuevaEmbarcacion(reg);
      _mostrarMensaje('Registro guardado exitosamente (SQLite)', Colors.green);
      _limpiarCampos();
      setState(() => _activeTabIndex = 1); // Cambia a lista
    } catch (e) {
      _mostrarMensaje('Error al guardar: $e', Colors.red);
    }
  }

  void _limpiarCampos() {
    _nombreNaveController.clear();
    _kilosController.clear();
    _catanaKilosController.text = '0';
    _catanaPrecioController.text = '0';
    _placaController.clear();
    _cajasController.text = '0';
    _muelleController.clear();
    _precioKiloVentaController.clear();
    _facturacionController.text = '0';
    _personalController.text = '0';
    _apoyoController.text = '0';
    _aguaController.text = '0';
    _cloroxController.text = '0';
    _fleteController.text = '0';
    _hieloController.text = '0';
    _otrosController.text = '0';
    setState(() => productoSeleccionado = null);
  }

  void _mostrarMensaje(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _exportarPDF(RegistroEntidad reg, String nombreUsuario) async {
    try {
      final file = await PdfHelper.generarReportePesca(reg, nombreUsuario);
      _mostrarMensaje('Reporte PDF guardado en: ${file.path}', Colors.teal);
    } catch (e) {
      _mostrarMensaje('Error al generar PDF: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historialState = ref.watch(proveedorHistorialController);
    final authState = ref.watch(proveedorAuthController);
    final nombreUsuario = authState is EstadoAutenticacionAutenticado
        ? authState.usuario.nombreReal
        : 'Daniel';

    // Escuchamos la sincronización para alertar
    ref.listen(proveedorSyncController, (previous, next) {
      if (next is AsyncError) {
        _mostrarMensaje('Error al sincronizar con Supabase: ${next.error}', Colors.orange);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D255F),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          TabSelector(
            indiceActivo: _activeTabIndex,
            totalRegistros: historialState.maybeWhen(
              data: (list) => list.length,
              orElse: () => 0,
            ),
            onTabChanged: (index) => setState(() => _activeTabIndex = index),
          ),
          Expanded(
            child: _buildBodyContent(historialState, nombreUsuario),
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                child: const Text('BRISMAR', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEGOCIOS', style: TextStyle(fontSize: 9, color: Colors.white70)),
                  Text('BRISMAR S.R.L.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(proveedorAuthController.notifier).cerrarSesion();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B1F31), shape: const StadiumBorder()),
            child: const Text('Salir', style: TextStyle(color: Colors.white, fontSize: 11)),
          )
        ],
      ),
    );
  }

  Widget _buildBodyContent(AsyncValue<List<RegistroEntidad>> state, String nombreUsuario) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F4F9),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: _activeTabIndex == 0
          ? _buildFormularioRegistro(nombreUsuario)
          : _buildListaHistorial(state, nombreUsuario),
    );
  }

  Widget _buildListaHistorial(AsyncValue<List<RegistroEntidad>> state, String nombreUsuario) {
    return state.when(
      data: (list) => RefreshIndicator(
        onRefresh: () async {
          await ref.read(proveedorSyncController.notifier).ejecutarSincronizacion();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              UserHeader(nombreUsuario: nombreUsuario),
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

  Widget _buildFormularioRegistro(String nombreUsuario) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            UserHeader(nombreUsuario: nombreUsuario),
            const SizedBox(height: 15),
            _buildSeccionEmbarcaciones(),
            const SizedBox(height: 15),
            _buildSeccionVenta(),
            const SizedBox(height: 15),
            _buildSeccionGastos(),
            const SizedBox(height: 15),
            SeccionTotales(
              totalVenta: totalVenta,
              totalGastos: totalGastos,
              totalNeto: totalNeto,
            ),
            const SizedBox(height: 20),
            _buildBotonRegistrar(nombreUsuario),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWrapper({required Color colorHeader, required String title, required Widget child}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorHeader,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildSeccionEmbarcaciones() {
    return _buildCardWrapper(
      colorHeader: const Color(0xFF0D255F),
      title: '⚓ DATOS DE LA EMBARCACIÓN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Nombre de la Embarcación *", "Ej: Don José I", _nombreNaveController, esObligatorio: true),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField("Kilos capturados *", "0.0", _kilosController, isNumeric: true, esObligatorio: true)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🐟 PRODUCTO *', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: productoSeleccionado,
                      decoration: _inputDecoration("Seleccionar.."),
                      items: ["POTA", "JUREL", "BONITO", "CABALLA"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 11))))
                          .toList(),
                      onChanged: (v) => setState(() => productoSeleccionado = v),
                      validator: (v) => v == null ? 'Obligatorio' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField("Placa de Cámara", "Ej: ABC-123", _placaController)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("Muelle de Partida *", "Ej: Muelle A", _muelleController, esObligatorio: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionVenta() {
    return _buildCardWrapper(
      colorHeader: const Color(0xFF006B3D),
      title: '\$ PRECIO Y VENTA',
      child: Column(
        children: [
          _buildTextField("PRECIO DE VENTA POR KILO *", "0.00", _precioKiloVentaController, isNumeric: true, esObligatorio: true),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL DE VENTA ESTIMADO', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
              Text('S/ ${totalVenta.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSeccionGastos() {
    return _buildCardWrapper(
      colorHeader: const Color(0xFF8B3A0F),
      title: '💵 DESGLOSE DE GASTOS DEL MUELLE',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField("FACTURACIÓN", "0.0", _facturacionController, isNumeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("PERSONAL/ESTIBAS", "0.0", _personalController, isNumeric: true)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField("APOYO OPERATIVO", "0.0", _apoyoController, isNumeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("AGUA potable", "0.0", _aguaController, isNumeric: true)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField("CLOROX / LIMPIEZA", "0.0", _cloroxController, isNumeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("FLETE / TRANSPORTE", "0.0", _fleteController, isNumeric: true)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField("HIELO DE CONSERVACIÓN", "0.0", _hieloController, isNumeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("OTROS GASTOS", "0.0", _otrosController, isNumeric: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonRegistrar(String nombreUsuario) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077B6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _guardarRegistroFormulario(nombreUsuario),
        child: const Text('REGISTRAR EMBARCACIÓN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumeric = false, bool esObligatorio = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(fontSize: 12),
          decoration: _inputDecoration(hint),
          validator: (v) {
            if (esObligatorio && (v == null || v.trim().isEmpty)) {
              return 'Requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade100)),
    );
  }
}
