import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../maestros/presentacion/controladores/controlador_maestros.dart';

class DialogoGasto {
  static void mostrar(
    BuildContext context, 
    GastoWebModelo? gasto,
    Function(GastoWebModelo) onGuardar,
  ) {
    final esNuevo = gasto == null;
    String tipoSeleccionado = gasto?.tipo ?? 'Flete';
    final conceptoCtrl = TextEditingController(text: gasto?.concepto ?? '');
    final cantidadCtrl = TextEditingController(text: gasto?.cantidad.toString() ?? '');
    final costoCtrl = TextEditingController(text: gasto?.costoUnitario.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final estadoMaestros = ref.watch(controladorMaestrosProvider).value;
          List<String> tiposGasto = ['Flete', 'Hielo', 'Estiba', 'Otros'];
          if (estadoMaestros != null && estadoMaestros.tiposGasto.isNotEmpty) {
            tiposGasto = estadoMaestros.tiposGasto.map((t) => t.nombre).toList();
          }

          if (!tiposGasto.contains(tipoSeleccionado) && tiposGasto.isNotEmpty) {
            tipoSeleccionado = tiposGasto.first;
          }

          return StatefulBuilder(
            builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1E201E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esNuevo ? 'Añadir gasto' : 'Editar gasto',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 4),
              const Text(
                'Registra los gastos asociados a este zarpe.',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _construirEtiquetaDialogo('Tipo de gasto'),
                DropdownButtonFormField<String>(
                  initialValue: tipoSeleccionado,
                  dropdownColor: const Color(0xFF1E201E),
                  iconEnabledColor: Colors.white70,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona tipo'),
                  items: tiposGasto.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                  onChanged: (val) { if (val != null) setStateDialog(() => tipoSeleccionado = val); },
                ),
                _construirEtiquetaDialogo('Concepto / Detalle'),
                TextField(
                  controller: conceptoCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoracionDialogo('Ej. Flete Piura - Paita'),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Cantidad'),
                          TextField(
                            controller: cantidadCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('1'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Costo unitario'),
                          TextField(
                            controller: costoCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('S/ 0.00'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final c = double.tryParse(cantidadCtrl.text) ?? 1.0;
                final costo = double.tryParse(costoCtrl.text) ?? 0;
                if (conceptoCtrl.text.isEmpty || c <= 0 || costo <= 0) return;

                final nuevo = GastoWebModelo(
                  id: gasto?.id ?? '',
                  cuadreId: gasto?.cuadreId ?? '',
                  tipo: tipoSeleccionado,
                  concepto: conceptoCtrl.text.trim(),
                  cantidad: c,
                  costoUnitario: costo,
                  total: c * costo,
                );
                onGuardar(nuevo);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA580C)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
     },
    ),
   );
  }

  static Widget _construirEtiquetaDialogo(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  static InputDecoration _decoracionDialogo(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF2D302D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white38)),
    );
  }
}
