import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/cuadre_entidad.dart';
import '../controladores/controlador_cuadres.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';

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

class FormularioCuadreTabs extends ConsumerStatefulWidget {
  final CuadreEntidad? cuadreInicial;
  
  const FormularioCuadreTabs({super.key, this.cuadreInicial});

  @override
  ConsumerState<FormularioCuadreTabs> createState() => _FormularioCuadreTabsState();
}

class _FormularioCuadreTabsState extends ConsumerState<FormularioCuadreTabs> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  late String _cuadreId;
  bool _guardando = false;

  // Controladores Generales
  final _placaCtrl = TextEditingController();
  final _fechaZarpeCtrl = TextEditingController();
  final _muellePartidaCtrl = TextEditingController();

  // Controladores de Gastos Operativos Establecidos
  final _facturacionCtrl = TextEditingController();
  final _personalCtrl = TextEditingController();
  final _apoyoCtrl = TextEditingController();
  final _aguaCtrl = TextEditingController();
  final _pesadorCtrl = TextEditingController();
  final _cloroxCtrl = TextEditingController();
  final _hieloCtrl = TextEditingController();
  final _fleteCtrl = TextEditingController();
  final _otrosCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  // Listas de items en memoria antes de guardar
  final List<CompraEntidad> _compras = [];
  final List<GastoEntidad> _gastos = [];
  final List<VentaEntidad> _ventas = []; // Remains empty as Ventas step was removed

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
      _ventas.addAll(widget.cuadreInicial!.ventas);

      // Inicializar controladores de gastos a partir de la lista
      for (final g in widget.cuadreInicial!.gastos) {
        final valor = g.total > 0 ? _formatearNumero(g.total) : '';
        if (g.concepto == 'FACTURACION') {
          _facturacionCtrl.text = valor;
        } else if (g.concepto == 'PERSONAL') {
          _personalCtrl.text = valor;
        } else if (g.concepto == 'APOYO') {
          _apoyoCtrl.text = valor;
        } else if (g.concepto == 'AGUA') {
          _aguaCtrl.text = valor;
        } else if (g.concepto == 'PESADOR') {
          _pesadorCtrl.text = valor;
        } else if (g.concepto == 'CLOROX') {
          _cloroxCtrl.text = valor;
        } else if (g.concepto == 'HIELO') {
          _hieloCtrl.text = valor;
        } else if (g.concepto == 'FLETE') {
          _fleteCtrl.text = valor;
        } else if (g.concepto == 'OTROS') {
          _otrosCtrl.text = valor;
        } else if (g.concepto == 'OBSERVACIONES') {
          _observacionesCtrl.text = g.tipo;
        }
      }
    } else {
      _cuadreId = const Uuid().v4();
      // Initialize with today's date formatted as YYYY-MM-DD
      final now = DateTime.now();
      _fechaZarpeCtrl.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _fechaZarpeCtrl.dispose();
    _muellePartidaCtrl.dispose();
    _facturacionCtrl.dispose();
    _personalCtrl.dispose();
    _apoyoCtrl.dispose();
    _aguaCtrl.dispose();
    _pesadorCtrl.dispose();
    _cloroxCtrl.dispose();
    _hieloCtrl.dispose();
    _fleteCtrl.dispose();
    _otrosCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  double get totalKilosCompras {
    return _compras.fold(0.0, (sum, c) => sum + c.kilos);
  }

  double get totalCostoCompras {
    return _compras.fold(0.0, (sum, c) => sum + c.total);
  }

  Future<void> _guardarCuadre() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar al menos una compra
    if (_compras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos una Compra (Embarcación)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Reconstruir lista de gastos a partir de los controladores
    _gastos.clear();
    final Map<String, TextEditingController> mapeoGastos = {
      'FACTURACION': _facturacionCtrl,
      'PERSONAL': _personalCtrl,
      'APOYO': _apoyoCtrl,
      'AGUA': _aguaCtrl,
      'PESADOR': _pesadorCtrl,
      'CLOROX': _cloroxCtrl,
      'HIELO': _hieloCtrl,
      'FLETE': _fleteCtrl,
      'OTROS': _otrosCtrl,
    };

    mapeoGastos.forEach((concepto, ctrl) {
      final texto = ctrl.text.replaceAll(',', '').trim();
      if (texto.isNotEmpty) {
        final valor = double.tryParse(texto) ?? 0.0;
        if (valor > 0) {
          _gastos.add(GastoEntidad(
            id: const Uuid().v4(),
            cuadreId: _cuadreId,
            tipo: 'Muelle',
            concepto: concepto,
            cantidad: 1,
            costoUnitario: valor,
            total: valor,
          ));
        }
      }
    });

    if (_observacionesCtrl.text.trim().isNotEmpty) {
      _gastos.add(GastoEntidad(
        id: const Uuid().v4(),
        cuadreId: _cuadreId,
        tipo: _observacionesCtrl.text.trim(),
        concepto: 'OBSERVACIONES',
        cantidad: 1,
        costoUnitario: 0,
        total: 0,
      ));
    }

    // Calcular estado: si no hay ventas, es borrador. (Dado que quitamos el paso de ventas, siempre será borrador o completo según reglas)
    final estado = _ventas.isEmpty ? 'borrador' : 'completo';
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
      estado: estado,
      fotoZarpeUrl: widget.cuadreInicial?.fotoZarpeUrl,
      pesoTotal: widget.cuadreInicial?.pesoTotal,
      cajasLlenas: widget.cuadreInicial?.cajasLlenas,
      cajasVacias: widget.cuadreInicial?.cajasVacias,
      tipoProducto: widget.cuadreInicial?.tipoProducto,
      muellePartida: _muellePartidaCtrl.text.trim().isEmpty ? null : _muellePartidaCtrl.text.trim(),
      compras: _compras,
      gastos: _gastos,
      ventas: _ventas,
    );

    await ref.read(cuadresProvider.notifier).guardarCuadre(nuevoCuadre);
    if (mounted) {
      setState(() => _guardando = false);
      Navigator.of(context).pop();
    }
  }

  Widget _construirFondoGradiente() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF040B1E),
            Color(0xFF0C1D3F),
            Color(0xFF143068),
          ],
        ),
      ),
    );
  }

  Widget _construirEsferaBrillo({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 120,
              spreadRadius: 60,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _construirInputDecoration({required String labelText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0F224A).withValues(alpha: 0.6),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _construirCampoGasto({required String labelText, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: _construirInputDecoration(labelText: labelText).copyWith(
          prefixText: 'S/ ',
          prefixStyle: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        validator: (v) {
          if (v != null && v.isNotEmpty) {
            final cleanValue = v.replaceAll(',', '');
            final val = double.tryParse(cleanValue);
            if (val == null || val < 0) return 'Ingrese un valor válido';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.cuadreInicial != null ? 'Editar Cuadre' : 'Nuevo Cuadre',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _construirFondoGradiente(),
          _construirEsferaBrillo(top: -100, left: -50, color: const Color(0x2200E5FF)),
          _construirEsferaBrillo(bottom: -150, right: -100, color: const Color(0x1B0D47A1)),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: const Color(0xFF0F224A).withValues(alpha: 0.9),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF00E5FF),
                    onPrimary: Color(0xFF040B1E),
                    secondary: Color(0xFF00E5FF),
                    surface: Color(0xFF0F224A),
                    onSurface: Colors.white,
                  ),
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: const TextStyle(color: Colors.white),
                    bodyMedium: const TextStyle(color: Colors.white70),
                    titleMedium: const TextStyle(color: Colors.white),
                  ),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep += 1);
                    } else {
                      _guardarCuadre();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  controlsBuilder: (BuildContext context, ControlsDetails details) {
                    final isLastStep = _currentStep == 2;
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: const Color(0xFF040B1E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: details.onStepContinue,
                              child: Text(
                                isLastStep ? 'GUARDAR CUADRE' : 'CONTINUAR',
                                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: details.onStepCancel,
                              child: Text(_currentStep == 0 ? 'CANCELAR' : 'ATRÁS'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: Text(
                        'General',
                        style: TextStyle(
                          color: _currentStep == 0 ? const Color(0xFF00E5FF) : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.cuadreInicial?.fotoZarpeUrl != null) ...[
                            _construirResumenZarpe(),
                            const SizedBox(height: 16),
                          ],
                          const Text(
                            'Información de la Cámara',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _placaCtrl,
                            style: const TextStyle(color: Colors.white),
                            readOnly: widget.cuadreInicial?.fotoZarpeUrl != null,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              _PlacaInputFormatter(),
                            ],
                            decoration: _construirInputDecoration(
                              labelText: 'Placa Cámara (Ej: AAA-123)',
                              suffixIcon: widget.cuadreInicial?.fotoZarpeUrl != null
                                  ? const Icon(Icons.lock_rounded, color: Colors.white30, size: 20)
                                  : null,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'La placa es requerida';
                              final clean = v.replaceAll('-', '');
                              if (clean.length != 6) return 'La placa debe tener exactamente 6 caracteres (Ej: AAA-123)';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fechaZarpeCtrl,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: _construirInputDecoration(
                              labelText: 'Fecha de Zarpe',
                              suffixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF00E5FF), size: 20),
                            ),
                            onTap: widget.cuadreInicial?.fotoZarpeUrl != null ? null : () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                locale: const Locale('es', 'ES'),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF00E5FF),
                                        onPrimary: Color(0xFF040B1E),
                                        surface: Color(0xFF0F224A),
                                        onSurface: Colors.white,
                                      ),
                                      textTheme: Theme.of(context).textTheme.copyWith(
                                        bodyLarge: const TextStyle(color: Colors.white),
                                        bodyMedium: const TextStyle(color: Colors.white70),
                                        titleMedium: const TextStyle(color: Colors.white),
                                      ),
                                      // ignore: deprecated_member_use
                                      dialogBackgroundColor: const Color(0xFF0F224A),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  _fechaZarpeCtrl.text =
                                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: Text(
                        'Compras',
                        style: TextStyle(
                          color: _currentStep == 1 ? const Color(0xFF00E5FF) : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      isActive: _currentStep >= 1,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Compras (Embarcación)',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                  foregroundColor: const Color(0xFF00E5FF),
                                  side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _agregarCompraDialog(),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Añadir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_compras.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'No hay compras añadidas.',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _compras.length,
                              itemBuilder: (ctx, i) {
                                final c = _compras[i];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F224A).withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    title: Text(
                                      '${i + 1}. ${c.embarcacion}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      '${c.producto} • ${_formatearNumero(c.kilos)} kg a S/ ${_formatearNumero(c.precioUnitario)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'S/ ${_formatearNumero(c.total)}',
                                          style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF00E5FF), size: 20),
                                          onPressed: () => _agregarCompraDialog(compraAEditar: c, indiceAEditar: i),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () => setState(() => _compras.removeAt(i)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (_compras.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2), width: 1.2),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TOTAL PESO:',
                                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                      Text(
                                        '${_formatearNumero(totalKilosCompras)} kg',
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TOTAL COMPRA:',
                                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                      Text(
                                        'S/ ${_formatearNumero(totalCostoCompras)}',
                                        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Step(
                      title: Text(
                        'Gastos',
                        style: TextStyle(
                          color: _currentStep == 2 ? const Color(0xFF00E5FF) : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      isActive: _currentStep >= 2,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gastos Operativos',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                           if (isTablet) ...[
                             Row(
                               children: [
                                 Expanded(child: _construirCampoGasto(labelText: 'Facturación', controller: _facturacionCtrl)),
                                 const SizedBox(width: 12),
                                 Expanded(child: _construirCampoGasto(labelText: 'Personal', controller: _personalCtrl)),
                               ],
                             ),
                             Row(
                               children: [
                                 Expanded(child: _construirCampoGasto(labelText: 'Apoyo', controller: _apoyoCtrl)),
                                 const SizedBox(width: 12),
                                 Expanded(child: _construirCampoGasto(labelText: 'Agua', controller: _aguaCtrl)),
                               ],
                             ),
                             Row(
                               children: [
                                 Expanded(child: _construirCampoGasto(labelText: 'Pesador', controller: _pesadorCtrl)),
                                 const SizedBox(width: 12),
                                 Expanded(child: _construirCampoGasto(labelText: 'Clorox', controller: _cloroxCtrl)),
                               ],
                             ),
                             Row(
                               children: [
                                 Expanded(child: _construirCampoGasto(labelText: 'Hielo', controller: _hieloCtrl)),
                                 const SizedBox(width: 12),
                                 Expanded(child: _construirCampoGasto(labelText: 'Flete', controller: _fleteCtrl)),
                               ],
                             ),
                             Row(
                               children: [
                                 Expanded(child: _construirCampoGasto(labelText: 'Otros', controller: _otrosCtrl)),
                                 const SizedBox(width: 12),
                                 const Expanded(child: SizedBox.shrink()),
                               ],
                             ),
                           ] else ...[
                             _construirCampoGasto(labelText: 'Facturación', controller: _facturacionCtrl),
                             _construirCampoGasto(labelText: 'Personal', controller: _personalCtrl),
                             _construirCampoGasto(labelText: 'Apoyo', controller: _apoyoCtrl),
                             _construirCampoGasto(labelText: 'Agua', controller: _aguaCtrl),
                             _construirCampoGasto(labelText: 'Pesador', controller: _pesadorCtrl),
                             _construirCampoGasto(labelText: 'Clorox', controller: _cloroxCtrl),
                             _construirCampoGasto(labelText: 'Hielo', controller: _hieloCtrl),
                             _construirCampoGasto(labelText: 'Flete', controller: _fleteCtrl),
                             _construirCampoGasto(labelText: 'Otros', controller: _otrosCtrl),
                           ],
                          const SizedBox(height: 16),
                          const Text(
                            'Observaciones o Notas',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _observacionesCtrl,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            decoration: _construirInputDecoration(
                              labelText: 'Escriba observaciones o notas aquí...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _guardando 
          ? const LinearProgressIndicator(color: Color(0xFF00E5FF)) 
          : const SizedBox.shrink(),
    );
  }

  String _formatearNumero(double valor, {int decimales = 2}) {
    String str = valor.toStringAsFixed(decimales);
    List<String> partes = str.split('.');
    String entera = partes[0];
    String decimal = partes.length > 1 ? partes[1] : '';

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String enteraFormateada = entera.replaceAllMapped(reg, (Match m) => '${m[1]},');

    if (decimales > 0 && decimal.isNotEmpty) {
      return '$enteraFormateada.$decimal';
    }
    return enteraFormateada;
  }

  void _agregarCompraDialog({CompraEntidad? compraAEditar, int? indiceAEditar}) {
    final formKeyDialog = GlobalKey<FormState>();
    final embCtrl = TextEditingController(text: compraAEditar?.embarcacion ?? '');
    String productoSeleccionado = compraAEditar?.producto ?? 'POTA';
    final kilosCtrl = TextEditingController(text: compraAEditar != null ? compraAEditar.kilos.toString() : '');
    final precioCtrl = TextEditingController(text: compraAEditar != null ? compraAEditar.precioUnitario.toString() : '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final isEditing = compraAEditar != null;
          return AlertDialog(
            backgroundColor: const Color(0xFF0F224A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.2),
            ),
            title: Text(
              isEditing ? 'Editar Compra' : 'Nueva Compra',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: Form(
              key: formKeyDialog,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: embCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        _UpperCaseTextFormatter(),
                      ],
                      decoration: _construirInputDecoration(labelText: 'Embarcación'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese la embarcación' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: productoSeleccionado,
                      dropdownColor: const Color(0xFF0F224A),
                      style: const TextStyle(color: Colors.white),
                      decoration: _construirInputDecoration(labelText: 'Producto'),
                      items: ["POTA", "JUREL", "BONITO", "CABALLA"]
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(color: Colors.white)),
                            ),
                          )
                          .toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return ["POTA", "JUREL", "BONITO", "CABALLA"].map((String value) {
                          final Map<String, Color> coloresProductos = {
                            "POTA": const Color(0xFFE040FB),
                            "JUREL": const Color(0xFF29B6F6),
                            "BONITO": const Color(0xFF00E676),
                            "CABALLA": const Color(0xFFFFB74D),
                          };
                          final colorTag = coloresProductos[value] ?? const Color(0xFF00E5FF);
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorTag.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colorTag.withValues(alpha: 0.35), width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colorTag,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colorTag,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            productoSeleccionado = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: kilosCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _construirInputDecoration(labelText: 'Kilos'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese los kilos';
                        final cleanValue = v.replaceAll(',', '');
                        final k = double.tryParse(cleanValue);
                        if (k == null || k <= 0) return 'Ingrese un valor mayor a 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: precioCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _construirInputDecoration(labelText: 'Precio / Kg'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese el precio';
                        final cleanValue = v.replaceAll(',', '');
                        final p = double.tryParse(cleanValue);
                        if (p == null || p <= 0) return 'Ingrese un valor mayor a 0';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF040B1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (!formKeyDialog.currentState!.validate()) return;
                  final e = embCtrl.text.trim();
                  final k = double.parse(kilosCtrl.text.replaceAll(',', ''));
                  final p = double.parse(precioCtrl.text.replaceAll(',', ''));
                  setState(() {
                    final item = CompraEntidad(
                      id: compraAEditar?.id ?? const Uuid().v4(),
                      cuadreId: _cuadreId,
                      embarcacion: e,
                      producto: productoSeleccionado,
                      kilos: k,
                      precioUnitario: p,
                      total: k * p,
                    );
                    if (isEditing && indiceAEditar != null) {
                      _compras[indiceAEditar] = item;
                    } else {
                      _compras.add(item);
                    }
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      ),
    );
  }

  // Métodos auxiliares para la visualización del resumen de Zarpe
  String _obtenerNombreProducto(int? tipo) {
    switch (tipo) {
      case 1: return 'Pota';
      case 2: return 'Bonito';
      case 3: return 'Caballa';
      case 4: return 'Jurel';
      case 5: return 'Otros';
      default: return 'Desconocido';
    }
  }

  Widget _buildZarpeInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _construirFotoZarpe(String path) {
    if (path.startsWith('http') || path.startsWith('blob:') || kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image_rounded, color: Colors.white24, size: 40));
        },
      );
    } else {
      return kIsWeb ? Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image_rounded, color: Colors.white24, size: 40));
        },
      ) : Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image_rounded, color: Colors.white24, size: 40));
        },
      );
    }
  }

  Widget _construirResumenZarpe() {
    if (widget.cuadreInicial?.fotoZarpeUrl == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F224A).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo_camera_rounded, color: Color(0xFF00E5FF), size: 18),
              SizedBox(width: 8),
              Text(
                'Evidencia de Zarpe de Cámara',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: widget.cuadreInicial!.fotoZarpeUrl!
                .split(',')
                .where((path) => path.trim().isNotEmpty)
                .map((path) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 140,
                            child: _construirFotoZarpe(path.trim()),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          _buildZarpeInfoRow('Peso Total:', '${_formatearNumero(widget.cuadreInicial!.pesoTotal ?? 0)} Kg'),
          _buildZarpeInfoRow('Cajas Llenas:', '${widget.cuadreInicial!.cajasLlenas ?? 0}'),
          _buildZarpeInfoRow('Cajas Vacías:', '${widget.cuadreInicial!.cajasVacias ?? 0}'),
          _buildZarpeInfoRow('Tipo Producto:', _obtenerNombreProducto(widget.cuadreInicial!.tipoProducto)),
          if (widget.cuadreInicial!.muellePartida != null && widget.cuadreInicial!.muellePartida!.isNotEmpty)
            _buildZarpeInfoRow('Muelle de Partida:', widget.cuadreInicial!.muellePartida!),
          if (widget.cuadreInicial!.pesador != null && widget.cuadreInicial!.pesador!.isNotEmpty)
            _buildZarpeInfoRow('Pesador de Muelle:', widget.cuadreInicial!.pesador!),
        ],
      ),
    );
  }
}
