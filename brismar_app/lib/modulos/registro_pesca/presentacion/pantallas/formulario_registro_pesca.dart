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

  double get totalKilosCompras => _compras.fold(0.0, (sum, c) => sum + c.kilos);
  double get totalCostoCompras => _compras.fold(0.0, (sum, c) => sum + c.total);
  double get totalAdelantos => _compras.fold(0.0, (sum, c) => sum + c.adelanto);
  
  double get totalGastosOperativos {
    double sum = 0.0;
    final ctrls = [_facturacionCtrl, _personalCtrl, _apoyoCtrl, _aguaCtrl, _pesadorCtrl, _cloroxCtrl, _hieloCtrl, _fleteCtrl, _otrosCtrl];
    for (var c in ctrls) {
      final val = double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0.0;
      sum += val;
    }
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
            id: const Uuid().v4(), cuadreId: _cuadreId, tipo: 'Muelle', concepto: concepto, cantidad: 1, costoUnitario: valor, total: valor,
          ));
        }
      }
    });

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

  Widget _construirCampoGasto({required String labelText, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        decoration: _construirInputDecoration(labelText: labelText).copyWith(
          prefixText: 'S/ ',
          prefixStyle: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), // Más alto para POS
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        onChanged: (val) => setState((){}), // Trigger rebuild for total summary
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKeyDialog,
                  child: SingleChildScrollView(
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
        onTap: () => _onZarpeSelected(placa, z['fecha_zarpe'] ?? ''),
      ),
    );
  }

  Widget _buildZarpeLeading() {
    return const CircleAvatar(
      backgroundColor: Color(0xFF00E5FF),
      child: Icon(Icons.local_shipping, color: Color(0xFF040B1E)),
    );
  }

  void _onZarpeSelected(String placa, String fecha) {
    setState(() {
      _placaCtrl.text = placa;
      _fechaZarpeCtrl.text = fecha;
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
    return Card(
      color: const Color(0xFF0F224A).withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gastos Operativos Muelle', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _construirCampoGasto(labelText: 'Facturación', controller: _facturacionCtrl),
            _construirCampoGasto(labelText: 'Personal', controller: _personalCtrl),
            _construirCampoGasto(labelText: 'Hielo', controller: _hieloCtrl),
            _construirCampoGasto(labelText: 'Flete', controller: _fleteCtrl),
            _construirCampoGasto(labelText: 'Apoyo', controller: _apoyoCtrl),
            _construirCampoGasto(labelText: 'Agua', controller: _aguaCtrl),
            _construirCampoGasto(labelText: 'Pesador', controller: _pesadorCtrl),
            _construirCampoGasto(labelText: 'Clorox', controller: _cloroxCtrl),
            _construirCampoGasto(labelText: 'Otros', controller: _otrosCtrl),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observacionesCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _construirInputDecoration(labelText: 'Observaciones / Notas'),
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
}
