import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'package:bris_web/nucleo/utilidades/formateador_miles.dart';

class SeccionGastos extends StatefulWidget {
  final List<GastoWebModelo> gastos;
  final Function(GastoWebModelo) onGuardar;
  final Function(String) onEliminar;

  const SeccionGastos({
    super.key,
    required this.gastos,
    required this.onGuardar,
    required this.onEliminar,
  });

  @override
  State<SeccionGastos> createState() => _SeccionGastosState();
}

class _SeccionGastosState extends State<SeccionGastos> {
  final Map<String, TextEditingController> _ctrls = {
    'FLETE': TextEditingController(),
    'FACTURACION/SERVICIO': TextEditingController(),
    'BALANZA': TextEditingController(),
    'PERSONAL': TextEditingController(),
    'APOYO': TextEditingController(),
    'AGUA': TextEditingController(),
    'PESADOR': TextEditingController(),
    'CLOROX': TextEditingController(),
    'HIELO': TextEditingController(),
    'OTROS': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _sincronizarDesdeGastos();
  }

  @override
  void didUpdateWidget(covariant SeccionGastos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gastos != oldWidget.gastos) {
      _sincronizarDesdeGastos();
    }
  }

  void _sincronizarDesdeGastos() {
    for (var ctrl in _ctrls.values) {
      ctrl.text = ''; // Limpiar
    }
    for (final g in widget.gastos) {
      var concepto = g.concepto.toUpperCase().trim();
      if (concepto == 'FACTURACION' || concepto == 'FACTURACIÓN') {
        concepto = 'FACTURACION/SERVICIO';
      }
      if (_ctrls.containsKey(concepto)) {
        _ctrls[concepto]!.text = g.total > 0 ? g.total.toStringAsFixed(2) : '';
      }
    }
  }

  void _onFieldChanged(String concepto, String val) {
    final total = FormateadorMiles.parseDouble(val);

    // Buscar si ya existe este gasto
    final idx = widget.gastos.indexWhere(
      (g) => g.concepto.toUpperCase().trim() == concepto,
    );

    if (idx >= 0) {
      final existente = widget.gastos[idx];
      if (total > 0) {
        widget.onGuardar(
          GastoWebModelo(
            id: existente.id,
            cuadreId: existente.cuadreId,
            tipo: 'Otros',
            concepto: concepto,
            cantidad: 1,
            costoUnitario: total,
            total: total,
          ),
        );
      } else {
        widget.onEliminar(existente.id);
      }
    } else {
      if (total > 0) {
        widget.onGuardar(
          GastoWebModelo(
            id: Uuid().v4(),
            cuadreId: '', // Será sobreescrito en RepositorioEdicionZarpe
            tipo: 'Otros',
            concepto: concepto,
            cantidad: 1,
            costoUnitario: total,
            total: total,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var ctrl in _ctrls.values) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos del Muelle',
            style: TextStyle(
              color: Color(0xFF15181A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 32),

          ..._ctrls.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: e.value,
                style: const TextStyle(
                  color: Color(0xFF15181A),
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [FormateadorMiles()],
                decoration: InputDecoration(
                  labelText: e.key,
                  prefixText: 'S/ ',
                  labelStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00796B),
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (val) => _onFieldChanged(e.key, val),
              ),
            );
          }),
        ],
      ),
    );
  }
}
