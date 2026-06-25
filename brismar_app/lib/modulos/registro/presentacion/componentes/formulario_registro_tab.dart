import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/registro_entidad.dart';
import '../controladores/registro_controlador.dart';
import '../controladores/registro_formulario_controlador.dart';
import 'seccion_embarcacion_form.dart';
import 'seccion_venta_form.dart';
import 'seccion_gastos_form.dart';
import 'seccion_totales.dart';
import 'encabezado_usuario.dart';

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Helper class to group text controllers and local state for each boat input form.
class EntradaEmbarcacion {
  final nombreNaveController = TextEditingController();
  final kilosController = TextEditingController();
  final precioVentaController = TextEditingController();

  void dispose() {
    nombreNaveController.dispose();
    kilosController.dispose();
    precioVentaController.dispose();
  }
}

/// Pestaña que encapsula el formulario de registro de pescas y sus inputs.
/// Controla el ciclo de vida de los TextEditingControllers.
class FormularioRegistroTab extends ConsumerStatefulWidget {
  final String nombreUsuario;
  final String usuarioId;
  final VoidCallback onRegistroExitoso;

  const FormularioRegistroTab({
    super.key,
    required this.nombreUsuario,
    required this.usuarioId,
    required this.onRegistroExitoso,
  });

  @override
  ConsumerState<FormularioRegistroTab> createState() =>
      _FormularioRegistroTabState();
}

class _FormularioRegistroTabState extends ConsumerState<FormularioRegistroTab> {
  final _formKey = GlobalKey<FormState>();

  // --- FECHA EDITABLE ---
  DateTime _fechaSeleccionada = DateTime.now();

  // --- DATOS GLOBALES DE LA CÁMARA ---
  String? _productoSeleccionado;
  final _placaController = TextEditingController();
  final _muelleController = TextEditingController();
  final _cajasController = TextEditingController();

  // --- LISTA DINÁMICA DE EMBARCACIONES (MÁX 5) ---
  final List<EntradaEmbarcacion> _embarcaciones = [];
  int _indiceEmbarcacionActiva = 0;

  // Gastos (Desglose de los 9 tipos)
  final _facturacionController = TextEditingController();
  final _personalController = TextEditingController();
  final _apoyoController = TextEditingController();
  final _aguaController = TextEditingController();
  final _cloroxController = TextEditingController();
  final _fleteController = TextEditingController();
  final _hieloController = TextEditingController();
  final _pesadorController = TextEditingController();
  final _otrosController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar la primera embarcación obligatoria
    _agregarEmbarcacion(notificar: false);

    // Suscribir los controladores globales para disparar el cálculo matemático en Riverpod
    _facturacionController.addListener(_notificarCalculo);
    _personalController.addListener(_notificarCalculo);
    _apoyoController.addListener(_notificarCalculo);
    _aguaController.addListener(_notificarCalculo);
    _cloroxController.addListener(_notificarCalculo);
    _fleteController.addListener(_notificarCalculo);
    _hieloController.addListener(_notificarCalculo);
    _pesadorController.addListener(_notificarCalculo);
    _otrosController.addListener(_notificarCalculo);
  }

  @override
  void dispose() {
    for (var emb in _embarcaciones) {
      emb.dispose();
    }
    _placaController.dispose();
    _muelleController.dispose();
    _cajasController.dispose();
    _facturacionController.dispose();
    _personalController.dispose();
    _apoyoController.dispose();
    _aguaController.dispose();
    _cloroxController.dispose();
    _fleteController.dispose();
    _hieloController.dispose();
    _pesadorController.dispose();
    _otrosController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _actualizarEstadoNombres() {
    setState(() {});
  }

  void _agregarEmbarcacion({bool notificar = true}) {
    if (_embarcaciones.length >= 5) return;

    final nueva = EntradaEmbarcacion();
    nueva.kilosController.addListener(_notificarCalculo);
    nueva.precioVentaController.addListener(_notificarCalculo);
    nueva.nombreNaveController.addListener(_actualizarEstadoNombres);

    setState(() {
      _embarcaciones.add(nueva);
      _indiceEmbarcacionActiva = _embarcaciones.length - 1; // Foco automático en la nueva pestaña
    });

    if (notificar) {
      _notificarCalculo();
    }
  }

  void _eliminarEmbarcacion(int index) {
    if (_embarcaciones.length <= 1) return;

    final eliminada = _embarcaciones.removeAt(index);
    eliminada.kilosController.removeListener(_notificarCalculo);
    eliminada.precioVentaController.removeListener(_notificarCalculo);
    eliminada.nombreNaveController.removeListener(_actualizarEstadoNombres);
    eliminada.dispose();

    setState(() {
      if (_indiceEmbarcacionActiva >= _embarcaciones.length) {
        _indiceEmbarcacionActiva = _embarcaciones.length - 1;
      }
    });
    _notificarCalculo();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E5FF),
              onPrimary: Color(0xFF040B1E),
              surface: Color(0xFF0F224A),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF040B1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  /// Lee los valores de los inputs y los envía al controlador matemático
  void _notificarCalculo() {
    double totalKilos = 0.0;
    double totalVenta = 0.0;
    for (var emb in _embarcaciones) {
      final kilos = double.tryParse(emb.kilosController.text.replaceAll(',', '')) ?? 0.0;
      final precio = double.tryParse(emb.precioVentaController.text.replaceAll(',', '')) ?? 0.0;
      totalKilos += kilos;
      totalVenta += kilos * precio;
    }

    final precioVentaConsolidado = totalKilos > 0 ? totalVenta / totalKilos : 0.0;

    ref
        .read(proveedorRegistroFormController.notifier)
        .calcularTotales(
          kilos: totalKilos,
          precioVenta: precioVentaConsolidado,
          gFacturacion: double.tryParse(_facturacionController.text.replaceAll(',', '')) ?? 0.0,
          gPersonal: double.tryParse(_personalController.text.replaceAll(',', '')) ?? 0.0,
          gApoyo: double.tryParse(_apoyoController.text.replaceAll(',', '')) ?? 0.0,
          gAgua: double.tryParse(_aguaController.text.replaceAll(',', '')) ?? 0.0,
          gClorox: double.tryParse(_cloroxController.text.replaceAll(',', '')) ?? 0.0,
          gFlete: double.tryParse(_fleteController.text.replaceAll(',', '')) ?? 0.0,
          gHielo: double.tryParse(_hieloController.text.replaceAll(',', '')) ?? 0.0,
          gPesador: double.tryParse(_pesadorController.text.replaceAll(',', '')) ?? 0.0,
          gOtros: double.tryParse(_otrosController.text.replaceAll(',', '')) ?? 0.0,
        );
  }

  Future<void> _guardarRegistro() async {

    if (!_formKey.currentState!.validate() || _productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rellene todos los campos obligatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final fecha =
        '${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}';
    final hora =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final totalNaves = _embarcaciones.length;

    // Distribuir los gastos equitativamente entre las embarcaciones registradas
    final gFacturacion = (double.tryParse(_facturacionController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gPersonal = (double.tryParse(_personalController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gApoyo = (double.tryParse(_apoyoController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gAgua = (double.tryParse(_aguaController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gClorox = (double.tryParse(_cloroxController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gFlete = (double.tryParse(_fleteController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gHielo = (double.tryParse(_hieloController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gPesador = (double.tryParse(_pesadorController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;
    final gOtros = (double.tryParse(_otrosController.text.replaceAll(',', '')) ?? 0.0) / totalNaves;

    final cajasTotales = int.tryParse(_cajasController.text) ?? 0;

    try {
      for (var emb in _embarcaciones) {
        final kilos = double.tryParse(emb.kilosController.text.replaceAll(',', '')) ?? 0.0;
        final precioVenta = double.tryParse(emb.precioVentaController.text.replaceAll(',', '')) ?? 0.0;
        final reg = RegistroEntidad(
          id: const Uuid().v4(),
          usuarioId: widget.usuarioId,
          nombreEmbarcacion: emb.nombreNaveController.text.trim(),
          producto: _productoSeleccionado!,
          placaCarro: _placaController.text.trim(),
          kilos: kilos,
          precioPorKilo: precioVenta,
          fecha: fecha,
          hora: hora,
          muelleInicio: _muelleController.text.trim(),
          cajas: cajasTotales,
          gastoFacturacion: gFacturacion,
          gastoPersonal: gPersonal,
          gastoApoyo: gApoyo,
          gastoAgua: gAgua,
          gastoClorox: gClorox,
          gastoFlete: gFlete,
          gastoHielo: gHielo,
          gastoPesador: gPesador, //se implementoel nuevo campo del pesador en gastos del muelle
          gastoOtros: gOtros,
          observaciones: _observacionesController.text.trim().isEmpty //se integro este nuevo campo, para el registro de la captura de gastos 
              ? null 
              : _observacionesController.text.trim(),
        );

        await ref
            .read(proveedorHistorialController.notifier)
            .registrarNuevaEmbarcacion(reg);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(totalNaves > 1 
                ? 'Registros guardados exitosamente ($totalNaves embarcaciones)' 
                : 'Registro guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _limpiarCampos();
      widget.onRegistroExitoso();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _limpiarCampos() {
    for (var emb in _embarcaciones) {
      emb.dispose();
    }
    _embarcaciones.clear();
    _agregarEmbarcacion(notificar: false);

    _placaController.clear();
    _muelleController.clear();
    _cajasController.clear();
    _facturacionController.clear();
    _personalController.clear();
    _apoyoController.clear();
    _aguaController.clear();
    _cloroxController.clear();
    _fleteController.clear();
    _hieloController.clear();
    _pesadorController.clear();
    _otrosController.clear();
    _observacionesController.clear();
    
    setState(() {
      _productoSeleccionado = null;
      _fechaSeleccionada = DateTime.now();
    });

    ref.read(proveedorRegistroFormController.notifier).limpiar();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(proveedorRegistroFormController);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TÍTULO SECCIÓN CON SUBRAYADO AMARILLO ---
            const Text(
              'REGISTRO DE RUTA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 50,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(height: 20),

            // --- FECHA Y HORA EN PARALELO ---
            EncabezadoUsuario(
              nombreUsuario: widget.nombreUsuario,
              fechaSeleccionada: _fechaSeleccionada,
              onTapFecha: _seleccionarFecha,
            ),
            const SizedBox(height: 20),

            // --- SECCIÓN: DATOS DE LA CÁMARA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1938),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1C2A54),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_shipping_rounded, color: Color(0xFFFFD54F), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'DATOS DE LA CÁMARA',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Row 1: Producto y Placa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🐟 PRODUCTO *',
                              style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _productoSeleccionado,
                              dropdownColor: const Color(0xFF0E1938),
                              iconEnabledColor: const Color(0xFF00E5FF),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00E5FF)),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              hint: const Text(
                                "Seleccionar..",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              decoration: _inputDecoration(""),
                              items: ["POTA", "JUREL", "BONITO", "CABALLA"]
                                  .map(
                                    (e) {
                                      final Map<String, Color> coloresProductos = {
                                        "POTA": const Color(0xFFE040FB),
                                        "JUREL": const Color(0xFF29B6F6),
                                        "BONITO": const Color(0xFF00E676),
                                        "CABALLA": const Color(0xFFFFB74D),
                                      };
                                      final colorTag = coloresProductos[e] ?? const Color(0xFF00E5FF);
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: colorTag,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              e,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _productoSeleccionado = val;
                                });
                              },
                              validator: (v) => v == null ? 'Obligatorio' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          "Placa de Cámara *",
                          "Ej: ABC123",
                          _placaController,
                          esObligatorio: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                            LengthLimitingTextInputFormatter(6),
                            _UpperCaseTextFormatter(),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Requerido';
                            }
                            if (v.trim().length != 6) {
                              return 'Exactamente 6 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2: Cajas y Muelle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Cajas totales *",
                          "Ej: 150",
                          _cajasController,
                          isNumeric: true,
                          esObligatorio: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          "Muelle de Partida *",
                          "Ej: Muelle A",
                          _muelleController,
                          esObligatorio: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // --- SECCIÓN DEDICADA DE EMBARCACIONES CON HEADER Y BOTÓN AGREGAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.anchor_rounded, color: Color(0xFFFFD54F), size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'EMBARCACIONES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${_embarcaciones.length}/5)',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (_embarcaciones.length < 5)
                  ElevatedButton(
                    onPressed: () => _agregarEmbarcacion(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      '+ Agregar',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // --- CAROUSEL DE PESTAÑAS HORIZONTALES ---
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _embarcaciones.length,
                itemBuilder: (context, index) {
                  final emb = _embarcaciones[index];
                  final esActiva = index == _indiceEmbarcacionActiva;
                  final nombre = emb.nombreNaveController.text.trim();
                  final label = nombre.isNotEmpty
                      ? (nombre.length > 12 ? '${nombre.substring(0, 10)}..' : nombre)
                      : 'Emb ${index + 1}';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _indiceEmbarcacionActiva = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: esActiva
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                            : const Color(0xFF0F224A).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: esActiva
                              ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.08),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_boat_rounded,
                            size: 14,
                            color: esActiva ? const Color(0xFF00E5FF) : Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: esActiva ? const Color(0xFF00E5FF) : Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- FORMULARIO DE LA EMBARCACIÓN ACTIVA CON ANIMACIÓN ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey('form_emb_$_indiceEmbarcacionActiva'),
                child: SeccionEmbarcacionForm(
                  index: _indiceEmbarcacionActiva,
                  mostrarBotonEliminar: _embarcaciones.length > 1,
                  onEliminar: () => _eliminarEmbarcacion(_indiceEmbarcacionActiva),
                  nombreNaveController: _embarcaciones[_indiceEmbarcacionActiva].nombreNaveController,
                  kilosController: _embarcaciones[_indiceEmbarcacionActiva].kilosController,
                  precioVentaController: _embarcaciones[_indiceEmbarcacionActiva].precioVentaController,
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Muestra el total consolidado de venta estimado de forma informativa
            SeccionVentaForm(
              precioKiloVentaController: TextEditingController(), // Dummy, no se edita aquí
              totalVenta: estado.totalVenta,
              esSoloVisual: true,
            ),
            const SizedBox(height: 15),
            SeccionGastosForm(
              facturacionController: _facturacionController,
              personalController: _personalController,
              apoyoController: _apoyoController,
              aguaController: _aguaController,
              cloroxController: _cloroxController,
              fleteController: _fleteController,
              hieloController: _hieloController,
              otrosController: _otrosController,
              pesadorController: _pesadorController,
              observacionesController: _observacionesController,
            ),
            const SizedBox(height: 15),
            SeccionTotales(
              totalVenta: estado.totalVenta,
              totalGastos: estado.totalGastos,
              totalNeto: estado.totalNeto,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0077C2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _guardarRegistro,
                  splashColor: Colors.white24,
                  child: const Center(
                    child: Text(
                      'REGISTRAR CÁMARA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumeric = false,
    bool esObligatorio = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: _inputDecoration(hint),
          inputFormatters: [
            if (isNumeric) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ...?inputFormatters,
          ],
          validator: validator ?? (v) {
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
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF070E22), // Fondo oscuro uniforme
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)), // Borde azul oscuro uniforme
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
    );
  }
}
