import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/zarpe_entidad.dart';
import '../../datos/repositorios/zarpe_repositorio_imp.dart';
import '../../datos/repositorios/camaras_repositorio_local.dart';
import '../../dominio/entidades/cuadre_entidad.dart';
import '../controladores/controlador_cuadres.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import '../widgets/panel_calculo_vivo.dart';
import '../../registro_pesca_inyeccion.dart';

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();
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
  ConsumerState<FormularioRegistroPesca> createState() =>
      _FormularioRegistroPescaState();
}

class _FormularioRegistroPescaState
    extends ConsumerState<FormularioRegistroPesca> {
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

  // Controladores de Gastos Operativos Establecidos
  final _fleteCtrl = TextEditingController();
  final _facturacionCtrl = TextEditingController();
  final _personalCtrl = TextEditingController();
  final _apoyoCtrl = TextEditingController();
  final _aguaCtrl = TextEditingController();
  final _pesadorCtrl = TextEditingController();
  final _cloroxCtrl = TextEditingController();
  final _hieloCtrl = TextEditingController();
  final _otrosCtrl = TextEditingController();

  // Listas de items en memoria antes de guardar
  final List<CompraEntidad> _compras = [];
  final List<GastoEntidad> _gastos = [];

  // Constante de Negocio
  final double taraOficialCaja = 3.0;
  List<String> _placasGuardadas = [];

  @override
  void initState() {
    super.initState();
    _cargarPlacas();
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
        } else {
          final conceptoUpper = g.concepto.toUpperCase().trim();
          final totalStr = g.total > 0 ? g.total.toString() : '';
          switch (conceptoUpper) {
            case 'FLETE':
              _fleteCtrl.text = totalStr;
              break;
            case 'FACTURACION':
            case 'FACTURACIÓN':
              _facturacionCtrl.text = totalStr;
              break;
            case 'PERSONAL':
              _personalCtrl.text = totalStr;
              break;
            case 'APOYO':
              _apoyoCtrl.text = totalStr;
              break;
            case 'AGUA':
              _aguaCtrl.text = totalStr;
              break;
            case 'PESADOR':
              _pesadorCtrl.text = totalStr;
              break;
            case 'CLOROX':
              _cloroxCtrl.text = totalStr;
              break;
            case 'HIELO':
              _hieloCtrl.text = totalStr;
              break;
            case 'OTROS':
              _otrosCtrl.text = totalStr;
              break;
          }
        }
      }
    } else {
      _cuadreId = const Uuid().v4();
      final now = DateTime.now();
      _fechaZarpeCtrl.text =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _fechaZarpeCtrl.dispose();
    _muellePartidaCtrl.dispose();
    _observacionesCtrl.dispose();
    _fleteCtrl.dispose();
    _facturacionCtrl.dispose();
    _personalCtrl.dispose();
    _apoyoCtrl.dispose();
    _aguaCtrl.dispose();
    _pesadorCtrl.dispose();
    _cloroxCtrl.dispose();
    _hieloCtrl.dispose();
    _otrosCtrl.dispose();
    super.dispose();
  }

  double get totalKilosCompras => _compras.fold(0.0, (sum, c) => sum + c.kilos);
  double get totalCostoCompras => _compras.fold(0.0, (sum, c) => sum + c.total);

  double get totalGastosOperativos {
    double sum = 0.0;
    sum += double.tryParse(_fleteCtrl.text) ?? 0.0;
    sum += double.tryParse(_facturacionCtrl.text) ?? 0.0;
    sum += double.tryParse(_personalCtrl.text) ?? 0.0;
    sum += double.tryParse(_apoyoCtrl.text) ?? 0.0;
    sum += double.tryParse(_aguaCtrl.text) ?? 0.0;
    sum += double.tryParse(_pesadorCtrl.text) ?? 0.0;
    sum += double.tryParse(_cloroxCtrl.text) ?? 0.0;
    sum += double.tryParse(_hieloCtrl.text) ?? 0.0;
    sum += double.tryParse(_otrosCtrl.text) ?? 0.0;
    return sum;
  }

  void _guardarGastosEstablecidos() {
    _gastos.removeWhere((g) => g.concepto != 'OBSERVACIONES');

    final conceptosMap = {
      'FLETE': _fleteCtrl,
      'FACTURACION': _facturacionCtrl,
      'PERSONAL': _personalCtrl,
      'APOYO': _apoyoCtrl,
      'AGUA': _aguaCtrl,
      'PESADOR': _pesadorCtrl,
      'CLOROX': _cloroxCtrl,
      'HIELO': _hieloCtrl,
      'OTROS': _otrosCtrl,
    };

    conceptosMap.forEach((concepto, controller) {
      final valor = double.tryParse(controller.text) ?? 0.0;
      if (valor > 0) {
        _gastos.add(
          GastoEntidad(
            id: const Uuid().v4(),
            cuadreId: _cuadreId,
            tipo: 'Otros',
            concepto: concepto,
            cantidad: 1,
            costoUnitario: valor,
            total: valor,
          ),
        );
      }
    });
  }

  Future<void> _guardarCuadre() async {
    if (!_formKey.currentState!.validate()) return;

    await CamarasRepositorioLocal().guardarPlacaLocal(_placaCtrl.text);

    if (_compras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos una Embarcación'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _guardarGastosEstablecidos();

    // Remover observación previa si existe antes de agregar la nueva
    _gastos.removeWhere((g) => g.concepto == 'OBSERVACIONES');
    if (_observacionesCtrl.text.trim().isNotEmpty) {
      _gastos.add(
        GastoEntidad(
          id: const Uuid().v4(),
          cuadreId: _cuadreId,
          tipo: _observacionesCtrl.text.trim(),
          concepto: 'OBSERVACIONES',
          cantidad: 1,
          costoUnitario: 0,
          total: 0,
        ),
      );
    }

    final authState = ref.read(proveedorControladorAutenticacion);
    if (authState is! EstadoAutenticacionAutenticado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de sesión: Usuario no autenticado.'),
          backgroundColor: Colors.redAccent,
        ),
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
      estado:
          'borrador', // En móvil siempre es borrador porque la venta se cierra en planta.
      fotoZarpeUrl: widget.cuadreInicial?.fotoZarpeUrl,
      pesoTotal: totalKilosCompras > 0
          ? totalKilosCompras
          : (widget.cuadreInicial?.pesoTotal ?? 0),
      cajasLlenas: widget.cuadreInicial?.cajasLlenas ?? 0,
      cajasVacias: widget.cuadreInicial?.cajasVacias ?? 0,
      tipoProducto: widget.cuadreInicial?.tipoProducto ?? 0,
      muellePartida: _muellePartidaCtrl.text.trim().isEmpty
          ? null
          : _muellePartidaCtrl.text.trim(),
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
    String enteraFormateada = entera.replaceAllMapped(
      reg,
      (Match m) => '${m[1]},',
    );

    if (decimales > 0 && decimal.isNotEmpty) {
      return '$enteraFormateada.$decimal';
    }
    return enteraFormateada;
  }

  InputDecoration _construirInputDecoration({
    required String labelText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      floatingLabelStyle: const TextStyle(color: Color(0xFF006B54), fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF006B54), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  void _agregarCompraDialog({
    CompraEntidad? compraAEditar,
    int? indiceAEditar,
  }) {
    final formKeyDialog = GlobalKey<FormState>();
    final embCtrl = TextEditingController(
      text: compraAEditar?.embarcacion ?? '',
    );
    String productoSeleccionado = compraAEditar?.producto ?? 'POTA';
    final kilosNetosCtrl = TextEditingController(
      text: compraAEditar != null ? compraAEditar.kilos.toString() : '',
    );
    final precioCtrl = TextEditingController(
      text: compraAEditar != null
          ? compraAEditar.precioUnitario.toString()
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final isMobile = MediaQuery.of(context).size.width < 600;
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Color(0x1A1F2937),
                width: 1.2,
              ),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ), // Ancho POS tablet
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
                            const Icon(
                              Icons.directions_boat,
                              color: Color(0xFF006B54),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                compraAEditar != null
                                    ? 'EDITAR EMBARCACIÓN'
                                    : 'NUEVA EMBARCACIÓN',
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Color(0x8A1F2937),
                                size: 32,
                              ),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (isMobile) ...[
                          TextFormField(
                            controller: embCtrl,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [_UpperCaseTextFormatter()],
                            decoration:
                                _construirInputDecoration(
                                  labelText: 'Nombre de Embarcación',
                                ).copyWith(
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: productoSeleccionado,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration:
                                _construirInputDecoration(
                                  labelText: 'Especie (Producto)',
                                ).copyWith(
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                            items:
                                ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"]
                                    .map(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setStateDialog(
                                  () => productoSeleccionado = val,
                                );
                              }
                            },
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: embCtrl,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [_UpperCaseTextFormatter()],
                                  decoration:
                                      _construirInputDecoration(
                                        labelText: 'Nombre de Embarcación',
                                      ).copyWith(
                                        contentPadding: const EdgeInsets.all(
                                          20,
                                        ),
                                      ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Requerido'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  initialValue: productoSeleccionado,
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration:
                                      _construirInputDecoration(
                                        labelText: 'Especie (Producto)',
                                      ).copyWith(
                                        contentPadding: const EdgeInsets.all(
                                          20,
                                        ),
                                      ),
                                  items:
                                      [
                                            "POTA",
                                            "JUREL",
                                            "BONITO",
                                            "CABALLA",
                                            "PERICO",
                                          ]
                                          .map(
                                            (String value) =>
                                                DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setStateDialog(
                                        () => productoSeleccionado = val,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0x4D000000),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0x1F1F2937),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Datos de Pesaje',
                                style: TextStyle(
                                  color: Color(0x8A1F2937),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: kilosNetosCtrl,
                                style: const TextStyle(
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                ),
                                decoration:
                                    _construirInputDecoration(
                                      labelText: 'KILOS (PESO TOTAL)',
                                    ).copyWith(
                                      contentPadding: const EdgeInsets.all(24),
                                    ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Requerido';
                                  }
                                  final k = double.tryParse(
                                    v.replaceAll(',', ''),
                                  );
                                  if (k == null || k <= 0) return 'Mayor a 0';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (isMobile) ...[
                          TextFormField(
                            controller: precioCtrl,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            decoration:
                                _construirInputDecoration(
                                  labelText: 'S/ Precio x Kg',
                                ).copyWith(
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              return null;
                            },
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: precioCtrl,
                                  style: const TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                  decoration:
                                      _construirInputDecoration(
                                        labelText: 'S/ Precio x Kg',
                                      ).copyWith(
                                        contentPadding: const EdgeInsets.all(
                                          24,
                                        ),
                                      ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Requerido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 64, // Botón super gigante POS
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006B54),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.check, size: 32),
                            label: const Text(
                              'CONFIRMAR EMBARCACIÓN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              if (!formKeyDialog.currentState!.validate()) {
                                return;
                              }
                              final k = double.parse(
                                kilosNetosCtrl.text.replaceAll(',', ''),
                              );
                              final p = double.parse(
                                precioCtrl.text.replaceAll(',', ''),
                              );

                              setState(() {
                                final item = CompraEntidad(
                                  id: compraAEditar?.id ?? const Uuid().v4(),
                                  cuadreId: _cuadreId,
                                  embarcacion: embCtrl.text.trim(),
                                  producto: productoSeleccionado,
                                  kilos: k,
                                  precioUnitario: p,
                                  total: k * p,
                                );
                                if (compraAEditar != null &&
                                    indiceAEditar != null) {
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
        },
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    DateTime initial = DateTime.now();
    if (_fechaZarpeCtrl.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_fechaZarpeCtrl.text);
      if (parsed != null &&
          parsed.isAfter(DateTime(2000)) &&
          parsed.isBefore(DateTime(2101))) {
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
        _fechaZarpeCtrl.text =
            "${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<List<Map<String, dynamic>>> _obtenerZarpesDisponibles() async {
    final repo = ref.read(proveedorZarpeRepositorio);
    final historial = await repo.obtenerHistorial('');
    
    // Filtrar zarpes y convertirlos a Map para compatibilidad temporal con el UI
    final zarpes = historial
        .where((z) => z.estado != 'RECIBIDO_LAMBAYEQUE')
        .toList();
    
    // Ordenar por fecha_zarpe DESC
    zarpes.sort((a, b) => b.fechaZarpe.compareTo(a.fechaZarpe));
    
    return zarpes.map((z) => {
      'id': z.id,
      'placa_camara': z.placaCamara,
      'chofer': z.chofer,
      'muelle_partida': z.muellePartida,
      'fecha_zarpe': z.fechaZarpe,
      'estado': z.estado,
    }).toList();
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
      backgroundColor: Colors.white,
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
      style: TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildZarpeItem(Map<String, dynamic> z) {
    final placa = z['placa_camara'] ?? '';
    final info =
        'Chofer: ${z['chofer'] ?? ''}\nMuelle: ${z['muelle_partida'] ?? ''}\nFecha: ${z['fecha_zarpe'] ?? ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0x0D1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x1A1F2937)),
      ),
      child: ListTile(
        leading: _buildZarpeLeading(),
        title: Text(
          'Placa: $placa',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          info,
          style: const TextStyle(
            color: Color(0xB31F2937),
            fontSize: 13,
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF006B54)),
        onTap: () => _onZarpeSelected(z),
      ),
    );
  }

  Widget _buildZarpeLeading() {
    return const CircleAvatar(
      backgroundColor: Color(0xFF006B54),
      child: Icon(Icons.local_shipping, color: Colors.white),
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
      color: const Color(0xB30E3E2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0x0D1F2937)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Cámara',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RawAutocomplete<String>(
                    textEditingController: _placaCtrl,
                    focusNode: FocusNode(),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _placasGuardadas;
                      }
                      return _placasGuardadas.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        style: const TextStyle(color: Color(0xFF1F2937)),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [_PlacaInputFormatter()],
                        decoration: _construirInputDecoration(
                          labelText: 'Placa (Ej: AAA-123)',
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF006B54),
                            ),
                            onPressed: _mostrarSelectorZarpes,
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      );
                    },
                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return InkWell(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option, style: const TextStyle(color: Colors.black87)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fechaZarpeCtrl,
                    readOnly: true,
                    style: const TextStyle(color: Color(0xFF1F2937)),
                    decoration: _construirInputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF006B54),
                        size: 18,
                      ),
                    ),
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
      color: const Color(0xB30E3E2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0x0D1F2937)),
      ),
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
                    'Embarcaciones',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _agregarCompraDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Ingreso Rápido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_compras.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No hay embarcaciones registradas.',
                    style: TextStyle(
                      color: Color(0x8A1F2937),
                    ),
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
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Color(0x33000000),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0x1F1F2937),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      title: Text(
                        c.embarcacion,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.producto} • ${_formatearNumero(c.kilos)} kg a S/ ${_formatearNumero(c.precioUnitario)}',
                            style: const TextStyle(
                              color: Color(0xB31F2937),
                            ),
                          ),
                          if (c.adelanto > 0)
                            Text(
                              'Adelanto Entregado: S/ ${_formatearNumero(c.adelanto)}',
                              style: const TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'S/ ${_formatearNumero(c.total)}',
                            style: const TextStyle(
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0x8A1F2937),
                              size: 20,
                            ),
                            onPressed: () => _agregarCompraDialog(
                              compraAEditar: c,
                              indiceAEditar: i,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _compras.removeAt(i)),
                          ),
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
    return Card(
      color: const Color(0xB30E3E2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0x0D1F2937)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos Operativos',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de 9 gastos pre-establecidos
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, // 2 columnas en móvil
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio:
                  2.2, // Relación de aspecto para inputs compactos
              children: [
                _buildCampoGasto(label: 'Flete', controller: _fleteCtrl),
                _buildCampoGasto(
                  label: 'Facturación',
                  controller: _facturacionCtrl,
                ),
                _buildCampoGasto(label: 'Personal', controller: _personalCtrl),
                _buildCampoGasto(label: 'Apoyo', controller: _apoyoCtrl),
                _buildCampoGasto(label: 'Agua', controller: _aguaCtrl),
                _buildCampoGasto(label: 'Pesador', controller: _pesadorCtrl),
                _buildCampoGasto(label: 'Clorox', controller: _cloroxCtrl),
                _buildCampoGasto(label: 'Hielo', controller: _hieloCtrl),
                _buildCampoGasto(label: 'Otros', controller: _otrosCtrl),
              ],
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesCtrl,
              style: const TextStyle(color: Color(0xFF1F2937)),
              decoration: _construirInputDecoration(
                labelText: 'Observaciones / Notas (Opcional)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoGasto({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}), // Dispara recálculo en vivo
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0x8A1F2937),
          fontSize: 12,
        ),
        prefixText: 'S/ ',
        prefixStyle: const TextStyle(
          color: Colors.orangeAccent,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: const Color(0x80F2F6F3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color(0x141F2937),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orangeAccent),
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
      guardando: _guardando,
      onGuardar: _guardarCuadre,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF004D40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Punto de Venta - Muelle',
          style: TextStyle(color: Color(0xFF004D40), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
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
    final repo = ref.read(proveedorZarpeRepositorio);
    final historial = await repo.obtenerHistorial('');
    final zarpes = historial.where((z) => z.id == id).toList();
    
    if (zarpes.isNotEmpty && mounted) {
      setState(() {
        final z = zarpes.first;
        _zarpeSeleccionado = {
          'id': z.id,
          'placa_camara': z.placaCamara,
          'chofer': z.chofer,
          'muelle_partida': z.muellePartida,
          'fecha_zarpe': z.fechaZarpe,
          'estado': z.estado,
        };
      });
    }
  }

  Future<void> _cargarPlacas() async {
    final placas = await CamarasRepositorioLocal().obtenerPlacasActivas();
    setState(() {
      _placasGuardadas = placas;
    });
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
                  icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
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
    if (urlEvidencia != null && urlEvidencia.isNotEmpty) {
      fotos.addAll(
        urlEvidencia.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    } else if (localPath != null && localPath.isNotEmpty) {
      fotos.addAll(
        localPath.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    }

    if (fotos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Fotos de Evidencia del Zarpe:',
          style: TextStyle(
            color: Color(0xB31F2937),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
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
                    border: Border.all(
                      color: Color(0x3D1F2937),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: esUrl
                        ? Image.network(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.broken_image,
                              color: Color(0x3D1F2937),
                            ),
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.broken_image,
                              color: Color(0x3D1F2937),
                            ),
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
