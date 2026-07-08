import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';

class SeccionGastosAdministrativos extends StatefulWidget {
  final List<GastoWebModelo> gastos;
  final Function(GastoWebModelo) onGuardar;
  final Function(String) onEliminar;

  const SeccionGastosAdministrativos({
    super.key,
    required this.gastos,
    required this.onGuardar,
    required this.onEliminar,
  });

  @override
  State<SeccionGastosAdministrativos> createState() => _SeccionGastosAdministrativosState();
}

class _SeccionGastosAdministrativosState extends State<SeccionGastosAdministrativos> {
  final Map<String, TextEditingController> _ctrlsFijos = {
    'FACTURACION_PLANTA': TextEditingController(),
    'PESADOR_PLANTA': TextEditingController(),
    'GASTOS FINANCIEROS': TextEditingController(),
    'CERTIFICADO': TextEditingController(),
    'LIQUIDACION': TextEditingController(),
    'IMPUESTO DE RENTA': TextEditingController(),
  };

  // Para los gastos "Otros" (conceptos dinámicos)
  List<GastoWebModelo> _otrosGastos = [];

  @override
  void initState() {
    super.initState();
    _sincronizarDesdeGastos();
  }

  @override
  void didUpdateWidget(covariant SeccionGastosAdministrativos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gastos != oldWidget.gastos) {
      _sincronizarDesdeGastos();
    }
  }

  void _sincronizarDesdeGastos() {
    for (var ctrl in _ctrlsFijos.values) {
      ctrl.text = '';
    }
    _otrosGastos.clear();

    for (final g in widget.gastos) {
      final concepto = g.concepto.toUpperCase().trim();
      if (_ctrlsFijos.containsKey(concepto)) {
        _ctrlsFijos[concepto]!.text = g.total > 0 ? g.total.toStringAsFixed(2) : '';
      } else {
        // Es un gasto que no pertenece ni a los fijos de Administrativos, 
        // pero tenemos que tener cuidado de no mostrar los de Muelle aquí.
        // Vamos a verificar que no sea uno de Muelle.
        final esMuelle = ['FLETE', 'FACTURACION', 'PERSONAL', 'APOYO', 'AGUA', 'PESADOR', 'CLOROX', 'HIELO', 'OTROS'].contains(concepto);
        if (!esMuelle && g.tipo == 'Administrativo') {
           _otrosGastos.add(g);
        }
      }
    }
  }

  void _onFieldChangedFijo(String concepto, String val) {
    final valorStr = val.replaceAll(',', '.').trim();
    final total = double.tryParse(valorStr) ?? 0.0;

    final idx = widget.gastos.indexWhere((g) => g.concepto.toUpperCase().trim() == concepto);
    
    if (idx >= 0) {
      final existente = widget.gastos[idx];
      if (total > 0) {
        widget.onGuardar(GastoWebModelo(
          id: existente.id,
          cuadreId: existente.cuadreId,
          tipo: 'Administrativo',
          concepto: concepto,
          cantidad: 1,
          costoUnitario: total,
          total: total,
        ));
      } else {
        widget.onEliminar(existente.id);
      }
    } else {
      if (total > 0) {
        widget.onGuardar(GastoWebModelo(
          id: const Uuid().v4(),
          cuadreId: '',
          tipo: 'Administrativo',
          concepto: concepto,
          cantidad: 1,
          costoUnitario: total,
          total: total,
        ));
      }
    }
  }

  void _mostrarDialogoOtroGasto([GastoWebModelo? gastoExistente]) {
    final conceptoCtrl = TextEditingController(text: gastoExistente?.concepto ?? '');
    final montoCtrl = TextEditingController(text: gastoExistente != null && gastoExistente.total > 0 ? gastoExistente.total.toStringAsFixed(2) : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(gastoExistente == null ? 'Añadir Otro Gasto' : 'Editar Otro Gasto', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: conceptoCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del Gasto (Concepto)'),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase())),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(labelText: 'Monto (S/)', prefixText: 'S/ '),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
            onPressed: () {
              final concepto = conceptoCtrl.text.toUpperCase().trim();
              final valorStr = montoCtrl.text.replaceAll(',', '.').trim();
              final total = double.tryParse(valorStr) ?? 0.0;

              if (concepto.isNotEmpty && total > 0) {
                final nuevoGasto = GastoWebModelo(
                  id: gastoExistente?.id ?? const Uuid().v4(),
                  cuadreId: gastoExistente?.cuadreId ?? '',
                  tipo: 'Administrativo', // Siempre tipo administrativo para estos
                  concepto: concepto,
                  cantidad: 1,
                  costoUnitario: total,
                  total: total,
                );
                
                widget.onGuardar(nuevoGasto);
                
                setState(() {
                  final idx = _otrosGastos.indexWhere((g) => g.id == nuevoGasto.id);
                  if (idx >= 0) {
                    _otrosGastos[idx] = nuevoGasto;
                  } else {
                    _otrosGastos.add(nuevoGasto);
                  }
                });
                
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var ctrl in _ctrlsFijos.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gastos Administrativos / Planta', style: TextStyle(color: Color(0xFF15181A), fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Color(0xFFF1F5F9), height: 32),
          
          ..._ctrlsFijos.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: e.value,
                style: const TextStyle(color: Color(0xFF15181A), fontWeight: FontWeight.bold),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: e.key,
                  prefixText: 'S/ ',
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00796B), width: 1.5)),
                ),
                onChanged: (val) => _onFieldChangedFijo(e.key, val),
              ),
            );
          }),

          const SizedBox(height: 16),
          const Text('OTROS GASTOS (Dinamicos)', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          ..._otrosGastos.map((g) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                title: Text(g.concepto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('S/ ${g.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.w600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF64748B), size: 20),
                      onPressed: () => _mostrarDialogoOtroGasto(g),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        widget.onEliminar(g.id);
                        setState(() {
                          _otrosGastos.removeWhere((item) => item.id == g.id);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar Otro Gasto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00796B),
                side: const BorderSide(color: Color(0xFF00796B)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _mostrarDialogoOtroGasto(),
            ),
          ),
        ],
      ),
    );
  }
}
