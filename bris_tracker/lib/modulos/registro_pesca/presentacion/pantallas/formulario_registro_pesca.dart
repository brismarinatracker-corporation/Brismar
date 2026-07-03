import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/cuadre_entidad.dart';
import '../controladores/controlador_cuadres.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../widgets/panel_calculo_vivo.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (text.length > 6) {
      return oldValue;
    }
    String formatted = text;
    if (text.length > 3) {
      formatted = '${text.substring(0, 3)}-${text.substring(3)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class FormularioRegistroPesca extends ConsumerStatefulWidget {
  final CuadreEntidad? cuadreInicial;
  
  const FormularioRegistroPesca({super.key, this.cuadreInicial});

  @override
  ConsumerState<FormularioRegistroPesca> createState() => _FormularioRegistroPescaState();
}

class _FormularioRegistroPescaState extends ConsumerState<FormularioRegistroPesca> {
  final _formKey = GlobalKey<FormState>();
  late String _cuadreId;
  bool _guardando = false;
  Map<String, dynamic>? _zarpeSeleccionado;

  // Controladores Generales
  final _placaCtrl = TextEditingController();
  final _fechaZarpeCtrl = TextEditingController();
  final _muellePartidaCtrl = TextEditingController();

  // Controladores de Observaciones
  final _observacionesCtrl = TextEditingController();

  // Listas de items en memoria antes de guardar
  final List<CompraEntidad> _compras = [];
  final List<GastoEntidad> _gastos = [];

  // Constante de Negocio
  final double taraOficialCaja = 3.0;

  @override
  void initState() {
    super.initState();
    if (widget.cuadreInicial != null) {
      _cuadreId = widget.cuadreInicial!.id;
      _placaCtrl.text = widget.cuadreInicial!.placa;
      _fechaZarpeCtrl.text = widget.cuadreInicial!.fechaZarpe ?? '';
      _muellePartidaCtrl.text = widget.cuadreInicial!.muellePartida ?? '';
      _compras.addAll(widget.cuadreInicial!.compras);
      _gastos.addAll(widget.cuadreInicial!.gastos);
      _cargarZarpeAsociado(widget.cuadreInicial!.id);

      for (final g in widget.cuadreInicial!.gastos) {
        if (g.concepto == 'OBSERVACIONES') {
          _observacionesCtrl.text = g.tipo;
        }
      }
    } else {
      _cuadreId = const Uuid().v4();
      final now = DateTime.now();
      _fechaZarpeCtrl.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _fechaZarpeCtrl.dispose();
    _muellePartidaCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  double get totalKilosCompras => _compras.fold(0.0, (sum, c) => sum + c.kilos);
  double get totalCostoCompras => _compras.fold(0.0, (sum, c) => sum + c.total);
  double get totalAdelantos => _compras.fold(0.0, (sum, c) => sum + c.adelanto);
  
  double get totalGastosOperativos {
    double sum = _gastos.where((g) => g.concepto != 'OBSERVACIONES').fold(0.0, (acc, g) => acc + g.total);
    return sum;
  }

  Future<void> _guardarCuadre() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_compras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos una Embarcación'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Remover observación previa si existe antes de agregar la nueva
    _gastos.removeWhere((g) => g.concepto == 'OBSERVACIONES');
    if (_observacionesCtrl.text.trim().isNotEmpty) {
      _gastos.add(GastoEntidad(
        id: const Uuid().v4(), cuadreId: _cuadreId, tipo: _observacionesCtrl.text.trim(), concepto: 'OBSERVACIONES', cantidad: 1, costoUnitario: 0, total: 0,
      ));
    }

    final authState = ref.read(proveedorControladorAutenticacion);
    if (authState is! EstadoAutenticacionAutenticado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de sesión: Usuario no autenticado.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    final String usuarioActualId = authState.usuario.id;

    setState(() => _guardando = true);

    final nuevoCuadre = CuadreEntidad(
      id: _cuadreId,
      usuarioId: usuarioActualId,
      placa: _placaCtrl.text,
      fechaZarpe: _fechaZarpeCtrl.text,
      estado: 'borrador', // En móvil siempre es borrador porque la venta se cierra en planta.
      fotoZarpeUrl: widget.cuadreInicial?.fotoZarpeUrl,
      pesoTotal: widget.cuadreInicial?.pesoTotal,
      cajasLlenas: widget.cuadreInicial?.cajasLlenas,
      cajasVacias: widget.cuadreInicial?.cajasVacias,
      tipoProducto: widget.cuadreInicial?.tipoProducto,
      muellePartida: _muellePartidaCtrl.text.trim().isEmpty ? null : _muellePartidaCtrl.text.trim(),
      compras: _compras,
      gastos: _gastos,
      ventas: [],
    );

    await ref.read(cuadresProvider.notifier).guardarCuadre(nuevoCuadre);
    if (mounted) {
      setState(() => _guardando = false);
      Navigator.of(context).pop();
    }
  }

  // UI Helpers
  String _formatearNumero(double valor, {int decimales = 2}) {
    String str = valor.toStringAsFixed(decimales);
    List<String> partes = str.split('.');
    String entera = partes[0];
    String decimal = partes.length > 1 ? partes[1] : '';

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String enteraFormateada = entera.replaceAllMapped(reg, (Match m) => '${m[1]},');

    if (decimales > 0 && decimal.isNotEmpty) return '$enteraFormateada.$decimal';
    return enteraFormateada;
  }

  InputDecoration _construirInputDecoration({required String labelText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0F224A).withValues(alpha: 0.6),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );
  }

  void _agregarGastoDialog({GastoEntidad? gastoAEditar, int? indiceAEditar}) {
    final formKeyDialog = GlobalKey<FormState>();
    String tipoSeleccionado = gastoAEditar?.tipo ?? 'Petróleo';
    final conceptoCtrl = TextEditingController(text: gastoAEditar?.concepto ?? '');
    final cantidadCtrl = TextEditingController(text: gastoAEditar != null ? gastoAEditar.cantidad.toString() : '1');
    final costoUnitarioCtrl = TextEditingController(text: gastoAEditar != null ? gastoAEditar.costoUnitario.toString() : '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: const Color(0xFF0F224A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.2)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKeyDialog,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_money_rounded, color: Colors.orangeAccent, size: 32),
                            const SizedBox(width: 12),
                            Text(gastoAEditar != null ? 'EDITAR GASTO' : 'REGISTRAR GASTO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 32),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: tipoSeleccionado,
                          dropdownColor: const Color(0xFF0F224A),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: _construirInputDecoration(labelText: 'Categoría').copyWith(contentPadding: const EdgeInsets.all(16)),
                          items: ['Petróleo', 'Hielo', 'Víveres', 'Muelle', 'Mantenimiento', 'Otros'].map((String tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) setStateDialog(() => tipoSeleccionado = newValue);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: conceptoCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: _construirInputDecoration(labelText: 'Concepto / Detalle').copyWith(contentPadding: const EdgeInsets.all(16)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: cantidadCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                decoration: _construirInputDecoration(labelText: 'Cantidad').copyWith(contentPadding: const EdgeInsets.all(16)),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Inválido' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: costoUnitarioCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                decoration: _construirInputDecoration(labelText: 'Costo Unit. (S/)').copyWith(contentPadding: const EdgeInsets.all(16)),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Inválido' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: const Color(0xFF040B1E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.check, size: 28),
                            label: const Text('GUARDAR GASTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            onPressed: () {
                              if (!formKeyDialog.currentState!.validate()) return;
                              final c = double.parse(cantidadCtrl.text.replaceAll(',', ''));
                              final cu = double.parse(costoUnitarioCtrl.text.replaceAll(',', ''));
                              
                              setState(() {
                                final item = GastoEntidad(
                                  id: gastoAEditar?.id ?? const Uuid().v4(),
                                  cuadreId: _cuadreId,
                                  tipo: tipoSeleccionado,
                                  concepto: conceptoCtrl.text.trim(),
                                  cantidad: c,
                                  costoUnitario: cu,
                                  total: c * cu,
                                );
                                if (gastoAEditar != null && indiceAEditar != null) {
                                  _gastos[indiceAEditar] = item;
                                } else {
                                  _gastos.add(item);
                                }
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  void _agregarCompraDialog({CompraEntidad? compraAEditar, int? indiceAEditar}) {
    final formKeyDialog = GlobalKey<FormState>();
    final embCtrl = TextEditingController(text: compraAEditar?.embarcacion ?? '');
    String productoSeleccionado = compraAEditar?.producto ?? 'POTA';
    final cajasCtrl = TextEditingController();
    final kilosBrutosCtrl = TextEditingController();
    final kilosNetosCtrl = TextEditingController(text: compraAEditar != null ? compraAEditar.kilos.toString() : '');
    final precioCtrl = TextEditingController(text: compraAEditar != null ? compraAEditar.precioUnitario.toString() : '');
    final adelantoCtrl = TextEditingController(text: compraAEditar != null && compraAEditar.adelanto > 0 ? compraAEditar.adelanto.toString() : '');

    void calcularNeto() {
      final cajas = int.tryParse(cajasCtrl.text) ?? 0;
      final bruto = double.tryParse(kilosBrutosCtrl.text.replaceAll(',', '')) ?? 0.0;
      if (bruto > 0) {
        final tara = cajas * taraOficialCaja;
        final neto = bruto - tara;
        kilosNetosCtrl.text = neto > 0 ? neto.toStringAsFixed(2) : '0.00';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: const Color(0xFF0F224A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.2)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // Ancho POS tablet
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKeyDialog,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_boat, color: Color(0xFF00E5FF), size: 32),
                            const SizedBox(width: 12),
                            Text(compraAEditar != null ? 'EDITAR LOTE' : 'NUEVO LOTE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 32),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: embCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [_UpperCaseTextFormatter()],
                                decoration: _construirInputDecoration(labelText: 'Embarcación').copyWith(contentPadding: const EdgeInsets.all(20)),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: productoSeleccionado,
                                dropdownColor: const Color(0xFF0F224A),
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                decoration: _construirInputDecoration(labelText: 'Especie').copyWith(contentPadding: const EdgeInsets.all(20)),
                                items: ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"].map((String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    )).toList(),
                                onChanged: (val) { if (val != null) setStateDialog(() => productoSeleccionado = val); },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cálculo de Pesaje (Tara Oficial: 3kg/caja)', style: TextStyle(color: Colors.white54, fontSize: 14)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: cajasCtrl,
                                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                      decoration: _construirInputDecoration(labelText: 'Cant. Cajas').copyWith(contentPadding: const EdgeInsets.all(20)),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onChanged: (v) => calcularNeto(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: kilosBrutosCtrl,
                                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                      decoration: _construirInputDecoration(labelText: 'Kilos Brutos (Balanza)').copyWith(contentPadding: const EdgeInsets.all(20)),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                      onChanged: (v) => calcularNeto(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('Ajuste rápido de Kilos Brutos:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [100, 500, 1000, 5000].map((kg) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: const BorderSide(color: Colors.white10),
                                          ),
                                        ),
                                        onPressed: () {
                                          final actual = double.tryParse(kilosBrutosCtrl.text.replaceAll(',', '')) ?? 0.0;
                                          kilosBrutosCtrl.text = (actual + kg).toStringAsFixed(0);
                                          calcularNeto();
                                          setStateDialog(() {});
                                        },
                                        child: Text('+$kg kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: kilosNetosCtrl,
                                style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w900, fontSize: 32),
                                decoration: _construirInputDecoration(labelText: 'KILOS NETOS (REALES)').copyWith(contentPadding: const EdgeInsets.all(24)),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Requerido';
                                  final k = double.tryParse(v.replaceAll(',', ''));
                                  if (k == null || k <= 0) return 'Mayor a 0';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: precioCtrl,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                                decoration: _construirInputDecoration(labelText: 'S/ Precio x Kg').copyWith(contentPadding: const EdgeInsets.all(24)),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Requerido';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: adelantoCtrl,
                                style: const TextStyle(color: Color(0xFFFFB74D), fontWeight: FontWeight.bold, fontSize: 28),
                                decoration: _construirInputDecoration(labelText: 'S/ Adelanto Efectivo').copyWith(contentPadding: const EdgeInsets.all(24)),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 64, // Botón super gigante POS
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: const Color(0xFF040B1E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.check, size: 32),
                            label: const Text('CONFIRMAR LOTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            onPressed: () {
                              if (!formKeyDialog.currentState!.validate()) return;
                              final k = double.parse(kilosNetosCtrl.text.replaceAll(',', ''));
                              final p = double.parse(precioCtrl.text.replaceAll(',', ''));
                              final a = double.tryParse(adelantoCtrl.text.replaceAll(',', '')) ?? 0.0;
                              
                              setState(() {
                                final item = CompraEntidad(
                                  id: compraAEditar?.id ?? const Uuid().v4(),
                                  cuadreId: _cuadreId,
                                  embarcacion: embCtrl.text.trim(),
                                  producto: productoSeleccionado,
                                  kilos: k,
                                  precioUnitario: p,
                                  adelanto: a,
                                  total: k * p,
                                );
                                if (compraAEditar != null && indiceAEditar != null) {
                                  _compras[indiceAEditar] = item;
                                } else {
                                  _compras.add(item);
                                }
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    DateTime initial = DateTime.now();
    if (_fechaZarpeCtrl.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_fechaZarpeCtrl.text);
      if (parsed != null && parsed.isAfter(DateTime(2000)) && parsed.isBefore(DateTime(2101))) {
        initial = parsed;
      }
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
    );
    if (selected != null) {
      setState(() {
        _fechaZarpeCtrl.text = "${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<List<Map<String, dynamic>>> _obtenerZarpesDisponibles() async {
    final db = await GestorBaseDatos.instance.database;
    return await db.query(
      'zarpes',
      where: "estado != 'RECIBIDO_LAMBAYEQUE'",
      orderBy: 'fecha_zarpe DESC',
    );
  }

  Future<void> _mostrarSelectorZarpes() async {
    final zarpes = await _obtenerZarpesDisponibles();
    if (!mounted) return;
    if (zarpes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay zarpes registrados para seleccionar.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    _mostrarModalZarpes(zarpes);
  }

  void _mostrarModalZarpes(List<Map<String, dynamic>> zarpes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F224A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildModalSheetContent(zarpes),
    );
  }

  Widget _buildModalSheetContent(List<Map<String, dynamic>> zarpes) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModalHeader(),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: zarpes.length,
              itemBuilder: (context, idx) => _buildZarpeItem(zarpes[idx]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader() {
    return const Text(
      'SELECCIONAR ZARPE ACTIVO',
      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }

  Widget _buildZarpeItem(Map<String, dynamic> z) {
    final placa = z['placa_camara'] ?? '';
    final info = 'Chofer: ${z['chofer'] ?? ''}\nMuelle: ${z['muelle_partida'] ?? ''}\nFecha: ${z['fecha_zarpe'] ?? ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: _buildZarpeLeading(),
        title: Text('Placa: $placa', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(info, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF00E5FF)),
        onTap: () => _onZarpeSelected(z),
      ),
    );
  }

  Widget _buildZarpeLeading() {
    return const CircleAvatar(
      backgroundColor: Color(0xFF00E5FF),
      child: Icon(Icons.local_shipping, color: Color(0xFF040B1E)),
    );
  }

  void _onZarpeSelected(Map<String, dynamic> z) {
    setState(() {
      _zarpeSeleccionado = z;
      _cuadreId = z['id'] ?? '';
      _placaCtrl.text = z['placa_camara'] ?? '';
      _fechaZarpeCtrl.text = z['fecha_zarpe'] ?? '';
    });
    Navigator.pop(context);
  }

  // Vistas Parciales
  Widget _buildSeccionGeneral() {
    return Card(
      color: const Color(0xFF0F224A).withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información de Cámara', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _placaCtrl,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [_PlacaInputFormatter()],
                    decoration: _construirInputDecoration(
                      labelText: 'Placa (Ej: AAA-123)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search_rounded, color: Color(0xFF00E5FF)),
                        onPressed: _mostrarSelectorZarpes,
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fechaZarpeCtrl,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _construirInputDecoration(labelText: 'Fecha', suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00E5FF), size: 18)),
                    onTap: _seleccionarFecha,
                  ),
                ),
              ],
            ),
            _buildFotosZarpeEvidencia(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionEmbarcaciones() {
    return Card(
      color: const Color(0xFF0F224A).withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Lotes / Embarcaciones', 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF040B1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => _agregarCompraDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ingreso Rápido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_compras.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No hay embarcaciones registradas.', style: TextStyle(color: Colors.white54))))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _compras.length,
                itemBuilder: (ctx, i) {
                  final c = _compras[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      title: Text(c.embarcacion, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.producto} • ${_formatearNumero(c.kilos)} kg a S/ ${_formatearNumero(c.precioUnitario)}', style: const TextStyle(color: Colors.white70)),
                          if (c.adelanto > 0)
                            Text('Adelanto Entregado: S/ ${_formatearNumero(c.adelanto)}', style: const TextStyle(color: Color(0xFFFFB74D), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('S/ ${_formatearNumero(c.total)}', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 15)),
                          IconButton(icon: const Icon(Icons.edit, color: Colors.white54, size: 20), onPressed: () => _agregarCompraDialog(compraAEditar: c, indiceAEditar: i)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _compras.removeAt(i))),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionGastos() {
    final gastosVisibles = _gastos.where((g) => g.concepto != 'OBSERVACIONES').toList();
    
    return Card(
      color: const Color(0xFF0F224A).withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Gastos Operativos', 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: const Color(0xFF040B1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => _agregarGastoDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Registrar Gasto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (gastosVisibles.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No hay gastos registrados.', style: TextStyle(color: Colors.white54))))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gastosVisibles.length,
                itemBuilder: (ctx, i) {
                  final g = gastosVisibles[i];
                  final indexGlobal = _gastos.indexOf(g);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.attach_money, color: Colors.white, size: 20)),
                      title: Text(g.concepto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${g.tipo} • ${g.cantidad} x S/ ${_formatearNumero(g.costoUnitario)}', style: const TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('S/ ${_formatearNumero(g.total)}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                          IconButton(icon: const Icon(Icons.edit, color: Colors.white54, size: 20), onPressed: () => _agregarGastoDialog(gastoAEditar: g, indiceAEditar: indexGlobal)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _gastos.removeAt(indexGlobal))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _construirInputDecoration(labelText: 'Observaciones / Notas (Opcional)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSeccionGeneral(),
                const SizedBox(height: 16),
                _buildSeccionEmbarcaciones(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSeccionGastos(),
                const SizedBox(height: 16),
                _buildPanelCalculo(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSeccionGeneral(),
          const SizedBox(height: 16),
          _buildSeccionEmbarcaciones(),
          const SizedBox(height: 16),
          _buildSeccionGastos(),
          const SizedBox(height: 16),
          _buildPanelCalculo(),
        ],
      ),
    );
  }

  Widget _buildPanelCalculo() {
    return PanelCalculoVivo(
      totalKilosCompras: totalKilosCompras,
      totalCostoCompras: totalCostoCompras,
      totalGastosOperativos: totalGastosOperativos,
      totalAdelantos: totalAdelantos,
      guardando: _guardando,
      onGuardar: _guardarCuadre,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040B1E),
      appBar: AppBar(
        title: const Text('Punto de Venta - Muelle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF040B1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return _buildTabletLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  Future<void> _cargarZarpeAsociado(String id) async {
    final db = await GestorBaseDatos.instance.database;
    final zarpes = await db.query('zarpes', where: 'id = ?', whereArgs: [id]);
    if (zarpes.isNotEmpty && mounted) {
      setState(() {
        _zarpeSeleccionado = zarpes.first;
      });
    }
  }

  void _verFotoGrande(String path, bool esUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: esUrl ? Image.network(path) : Image.file(File(path)),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotosZarpeEvidencia() {
    if (_zarpeSeleccionado == null) return const SizedBox.shrink();

    final localPath = _zarpeSeleccionado!['foto_local_path'] as String?;
    final urlEvidencia = _zarpeSeleccionado!['foto_url_evidencia'] as String?;

    final List<String> fotos = [];
    if (localPath != null && localPath.isNotEmpty) {
      fotos.addAll(localPath.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
    if (urlEvidencia != null && urlEvidencia.isNotEmpty) {
      fotos.addAll(urlEvidencia.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }

    if (fotos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Fotos de Evidencia del Zarpe:',
          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fotos.length,
            itemBuilder: (context, index) {
              final path = fotos[index];
              final esUrl = path.startsWith('http');
              return GestureDetector(
                onTap: () => _verFotoGrande(path, esUrl),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: esUrl
                        ? Image.network(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24),
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
