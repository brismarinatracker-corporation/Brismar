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
import 'user_header.dart';

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
  ConsumerState<FormularioRegistroTab> createState() => _FormularioRegistroTabState();
}

class _FormularioRegistroTabState extends ConsumerState<FormularioRegistroTab> {
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLADORES DE LOS CAMPOS ---
  final _nombreNaveController = TextEditingController();
  final _kilosController = TextEditingController();
  final _placaController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    // Suscribir los controladores para disparar el cálculo matemático en Riverpod
    _kilosController.addListener(_notificarCalculo);
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
    _nombreNaveController.dispose();
    _kilosController.dispose();
    _placaController.dispose();
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

  /// Lee los valores de los inputs y los envía al controlador matemático
  void _notificarCalculo() {
    ref.read(proveedorRegistroFormController.notifier).calcularTotales(
          kilos: double.tryParse(_kilosController.text) ?? 0.0,
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

    if (!_formKey.currentState!.validate() || estadoForm.productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellene todos los campos obligatorios'), backgroundColor: Colors.orange),
      );
      return;
    }

    final now = DateTime.now();
    final fecha = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hora = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final reg = RegistroEntidad(
      id: const Uuid().v4(),
      nombreEmbarcacion: _nombreNaveController.text,
      producto: estadoForm.productoSeleccionado!,
      placaCarro: _placaController.text,
      kilos: estadoForm.kilosTotales,
      precioPorKilo: estadoForm.precioVenta,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro guardado exitosamente'), backgroundColor: Colors.green),
        );
      }
      _limpiarCampos();
      widget.onRegistroExitoso();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _limpiarCampos() {
    _nombreNaveController.clear();
    _kilosController.clear();
    _placaController.clear();
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
    ref.read(proveedorRegistroFormController.notifier).limpiar();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(proveedorRegistroFormController);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            UserHeader(nombreUsuario: widget.nombreUsuario),
            const SizedBox(height: 15),
            SeccionEmbarcacionForm(
              nombreNaveController: _nombreNaveController,
              kilosController: _kilosController,
              placaController: _placaController,
              muelleController: _muelleController,
              productoSeleccionado: estado.productoSeleccionado,
              onProductoChanged: (val) {
                ref.read(proveedorRegistroFormController.notifier).seleccionarProducto(val);
              },
            ),
            const SizedBox(height: 15),
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _guardarRegistro,
                child: const Text('REGISTRAR EMBARCACIÓN',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
