import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import '../../../../maestros/presentacion/controladores/controlador_maestros.dart';


class DialogoCompra {
  static void mostrar(
    BuildContext context, 
    CompraWebModelo? compra,
    Function(CompraWebModelo) onGuardar,
  ) {
    final esNuevo = compra == null;
    final embarcacionCtrl = TextEditingController(text: compra?.embarcacion ?? '');
    String productoSeleccionado = compra?.producto ?? 'POTA';
    final kilosCtrl = TextEditingController(text: compra?.kilos.toString() ?? '');
    final precioCtrl = TextEditingController(text: compra?.precioUnitario.toString() ?? '');
    final adelantoCtrl = TextEditingController(text: compra?.adelanto?.toString() ?? '0.00');

    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final estadoMaestros = ref.watch(controladorMaestrosProvider).value;
          List<String> especies = ["POTA", "JUREL", "BONITO", "CABALLA", "PERICO"];
          if (estadoMaestros != null && estadoMaestros.especies.isNotEmpty) {
            especies = estadoMaestros.especies.map((e) => e.nombre).toList();
          }
          
          if (!especies.contains(productoSeleccionado) && especies.isNotEmpty) {
            productoSeleccionado = especies.first;
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
                esNuevo ? 'Añadir embarcación' : 'Editar embarcación',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los datos de la compra registrada.',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _construirEtiquetaDialogo('Nombre de la embarcación'),
                TextField(
                  controller: embarcacionCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_UpperCaseTextFormatter()],
                  decoration: _decoracionDialogo('Ej. DON LUCHO II'),
                ),
                _construirEtiquetaDialogo('Especie'),
                DropdownButtonFormField<String>(
                  initialValue: productoSeleccionado,
                  dropdownColor: const Color(0xFF1E201E),
                  iconEnabledColor: Colors.white70,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _decoracionDialogo('Selecciona especie'),
                  items: especies.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                  onChanged: (val) { if (val != null) setStateDialog(() => productoSeleccionado = val); },
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Kilos'),
                          TextField(
                            controller: kilosCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiquetaDialogo('Precio unitario'),
                          TextField(
                            controller: precioCtrl,
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
                _construirEtiquetaDialogo('Adelanto Entregado (S/)'),
                TextField(
                  controller: adelantoCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                  decoration: _decoracionDialogo('S/ 0.00'),
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
                final k = double.tryParse(kilosCtrl.text) ?? 0;
                final p = double.tryParse(precioCtrl.text) ?? 0;
                final a = double.tryParse(adelantoCtrl.text) ?? 0;
                if (embarcacionCtrl.text.isEmpty || k <= 0 || p <= 0) return;

                final nueva = CompraWebModelo(
                  id: compra?.id ?? '',
                  cuadreId: compra?.cuadreId ?? '',
                  embarcacion: embarcacionCtrl.text.trim(),
                  producto: productoSeleccionado,
                  kilos: k,
                  precioUnitario: p,
                  total: k * p,
                  adelanto: a,
                );
                onGuardar(nueva);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
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

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
