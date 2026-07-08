import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esNuevo ? 'Añadir embarcación' : 'Editar embarcación',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15181A), fontSize: 22),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los datos de la compra registrada.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
                  style: const TextStyle(color: Color(0xFF15181A), fontSize: 14, fontWeight: FontWeight.w500),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_UpperCaseTextFormatter()],
                  decoration: _decoracionDialogo('Ej. DON LUCHO II', icono: Icons.directions_boat_outlined),
                ),
                _construirEtiquetaDialogo('Especie'),
                DropdownButtonFormField<String>(
                  initialValue: productoSeleccionado,
                  dropdownColor: Colors.white,
                  iconEnabledColor: const Color(0xFF64748B),
                  style: const TextStyle(color: Color(0xFF15181A), fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: _decoracionDialogo('Selecciona especie', icono: Icons.set_meal_outlined),
                  items: especies.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Color(0xFF15181A), fontSize: 14)),
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
                            style: const TextStyle(color: Color(0xFF15181A), fontSize: 14, fontWeight: FontWeight.w500),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('0', icono: Icons.scale_outlined),
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
                            style: const TextStyle(color: Color(0xFF15181A), fontSize: 14, fontWeight: FontWeight.w500),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                            decoration: _decoracionDialogo('S/ 0.00', icono: Icons.payments_outlined),
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
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final k = double.tryParse(kilosCtrl.text) ?? 0;
                final p = double.tryParse(precioCtrl.text) ?? 0;
                if (embarcacionCtrl.text.isEmpty || k <= 0 || p <= 0) return;

                final String idAsignado = (compra?.id == null || compra!.id.isEmpty) 
                    ? const Uuid().v4() 
                    : compra.id;

                final nueva = CompraWebModelo(
                  id: idAsignado,
                  cuadreId: compra?.cuadreId ?? '',
                  embarcacion: embarcacionCtrl.text.trim(),
                  producto: productoSeleccionado,
                  kilos: k,
                  precioUnitario: p,
                  total: k * p,
                );
                onGuardar(nueva);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  static InputDecoration _decoracionDialogo(String hintText, {IconData? icono}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: icono != null ? Icon(icono, color: const Color(0xFF94A3B8), size: 20) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.transparent)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7EBFC9), width: 1.5)),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
