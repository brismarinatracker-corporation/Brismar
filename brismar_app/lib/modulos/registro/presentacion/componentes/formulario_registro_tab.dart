import 'package:flutter/material.dart';
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

/// Helper class to group text controllers and local state for each boat input form.
class EntradaEmbarcacion {
  final nombreNaveController = TextEditingController();
  final kilosController = TextEditingController();
  final placaController = TextEditingController();
  final muelleController = TextEditingController();
  String? productoSeleccionado;

  void dispose() {
    nombreNaveController.dispose();
    kilosController.dispose();
    placaController.dispose();
    muelleController.dispose();
  }
}

/// Pestaña que encapsula el formulario de registro de pescas y sus inputs.
/// Controla el ciclo de vida de los TextEditingControllers.
class FormularioRegistroTab extends ConsumerStatefulWidget {
  final String nombreUsuario;
  final VoidCallback onRegistroExitoso;

  const FormularioRegistroTab({
    super.key,
    required this.nombreUsuario,
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

  // --- LISTA DINÁMICA DE EMBARCACIONES (MÁX 5) ---
  final List<EntradaEmbarcacion> _embarcaciones = [];

  // --- CONTROLADORES GLOBALES DE VENTAS Y GASTOS ---
  final _precioKiloVentaController = TextEditingController();

  // Gastos (Desglose de los 8 tipos)
  final _facturacionController = TextEditingController();
  final _personalController = TextEditingController();
  final _apoyoController = TextEditingController();
  final _aguaController = TextEditingController();
  final _cloroxController = TextEditingController();
  final _fleteController = TextEditingController();
  final _hieloController = TextEditingController();
  final _otrosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar la primera embarcación obligatoria
    _agregarEmbarcacion(notificar: false);

    // Suscribir los controladores globales para disparar el cálculo matemático en Riverpod
    _precioKiloVentaController.addListener(_notificarCalculo);
    _facturacionController.addListener(_notificarCalculo);
    _personalController.addListener(_notificarCalculo);
    _apoyoController.addListener(_notificarCalculo);
    _aguaController.addListener(_notificarCalculo);
    _cloroxController.addListener(_notificarCalculo);
    _fleteController.addListener(_notificarCalculo);
    _hieloController.addListener(_notificarCalculo);
    _otrosController.addListener(_notificarCalculo);
  }

  @override
  void dispose() {
    for (var emb in _embarcaciones) {
      emb.dispose();
    }
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

  void _agregarEmbarcacion({bool notificar = true}) {
    if (_embarcaciones.length >= 5) return;

    final nueva = EntradaEmbarcacion();
    nueva.kilosController.addListener(_notificarCalculo);

    setState(() {
      _embarcaciones.add(nueva);
    });

    if (notificar) {
      _notificarCalculo();
    }
  }

  void _eliminarEmbarcacion(int index) {
    if (_embarcaciones.length <= 1) return;

    final eliminada = _embarcaciones.removeAt(index);
    eliminada.kilosController.removeListener(_notificarCalculo);
    eliminada.dispose();

    setState(() {});
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
    for (var emb in _embarcaciones) {
      totalKilos += double.tryParse(emb.kilosController.text) ?? 0.0;
    }

    ref
        .read(proveedorRegistroFormController.notifier)
        .calcularTotales(
          kilos: totalKilos,
          precioVenta: double.tryParse(_precioKiloVentaController.text) ?? 0.0,
          gFacturacion: double.tryParse(_facturacionController.text) ?? 0.0,
          gPersonal: double.tryParse(_personalController.text) ?? 0.0,
          gApoyo: double.tryParse(_apoyoController.text) ?? 0.0,
          gAgua: double.tryParse(_aguaController.text) ?? 0.0,
          gClorox: double.tryParse(_cloroxController.text) ?? 0.0,
          gFlete: double.tryParse(_fleteController.text) ?? 0.0,
          gHielo: double.tryParse(_hieloController.text) ?? 0.0,
          gOtros: double.tryParse(_otrosController.text) ?? 0.0,
        );
  }

  Future<void> _guardarRegistro() async {
    final estadoForm = ref.read(proveedorRegistroFormController);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rellene todos los campos obligatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que todas las embarcaciones tengan un producto seleccionado
    for (int i = 0; i < _embarcaciones.length; i++) {
      if (_embarcaciones[i].productoSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seleccione el producto para la Embarcación #${i + 1}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final now = DateTime.now();
    final fecha =
        '${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}';
    final hora =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final totalNaves = _embarcaciones.length;

    // Distribuir los gastos equitativamente entre las embarcaciones registradas
    final gFacturacion = (double.tryParse(_facturacionController.text) ?? 0.0) / totalNaves;
    final gPersonal = (double.tryParse(_personalController.text) ?? 0.0) / totalNaves;
    final gApoyo = (double.tryParse(_apoyoController.text) ?? 0.0) / totalNaves;
    final gAgua = (double.tryParse(_aguaController.text) ?? 0.0) / totalNaves;
    final gClorox = (double.tryParse(_cloroxController.text) ?? 0.0) / totalNaves;
    final gFlete = (double.tryParse(_fleteController.text) ?? 0.0) / totalNaves;
    final gHielo = (double.tryParse(_hieloController.text) ?? 0.0) / totalNaves;
    final gOtros = (double.tryParse(_otrosController.text) ?? 0.0) / totalNaves;

    try {
      for (var emb in _embarcaciones) {
        final kilos = double.tryParse(emb.kilosController.text) ?? 0.0;
        final reg = RegistroEntidad(
          id: const Uuid().v4(),
          nombreEmbarcacion: emb.nombreNaveController.text.trim(),
          producto: emb.productoSeleccionado!,
          placaCarro: emb.placaController.text.trim(),
          kilos: kilos,
          precioPorKilo: estadoForm.precioVenta,
          fecha: fecha,
          hora: hora,
          muelleInicio: emb.muelleController.text.trim(),
          gastoFacturacion: gFacturacion,
          gastoPersonal: gPersonal,
          gastoApoyo: gApoyo,
          gastoAgua: gAgua,
          gastoClorox: gClorox,
          gastoFlete: gFlete,
          gastoHielo: gHielo,
          gastoOtros: gOtros,
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

    _precioKiloVentaController.clear();
    _facturacionController.clear();
    _personalController.clear();
    _apoyoController.clear();
    _aguaController.clear();
    _cloroxController.clear();
    _fleteController.clear();
    _hieloController.clear();
    _otrosController.clear();
    
    setState(() {
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
                      backgroundColor: const Color(0xFF1565C0), // Azul sólido de la imagen
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
            
            // --- SECCIÓN DINÁMICA DE EMBARCACIONES ---
            Column(
              children: List.generate(_embarcaciones.length, (index) {
                final emb = _embarcaciones[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SeccionEmbarcacionForm(
                    index: index,
                    mostrarBotonEliminar: _embarcaciones.length > 1,
                    onEliminar: () => _eliminarEmbarcacion(index),
                    nombreNaveController: emb.nombreNaveController,
                    kilosController: emb.kilosController,
                    placaController: emb.placaController,
                    muelleController: emb.muelleController,
                    productoSeleccionado: emb.productoSeleccionado,
                    onProductoChanged: (val) {
                      setState(() {
                        emb.productoSeleccionado = val;
                      });
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),
            SeccionVentaForm(
              precioKiloVentaController: _precioKiloVentaController,
              totalVenta: estado.totalVenta,
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
                      'REGISTRAR EMBARCACIÓN(ES)',
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
}
