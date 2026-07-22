import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../maestros/presentacion/controladores/controlador_maestros.dart';
import 'package:bris_web/nucleo/utilidades/formateador_miles.dart';

class DialogoGasto {
  static void mostrar(
    BuildContext context,
    GastoWebModelo? gasto,
    Function(GastoWebModelo) onGuardar,
  ) {
    final esNuevo = gasto == null;
    String tipoSeleccionado = gasto?.tipo ?? 'Flete';
    final conceptoCtrl = TextEditingController(text: gasto?.concepto ?? '');
    final cantidadCtrl = TextEditingController(
      text: gasto?.cantidad.toString() ?? '',
    );
    final costoCtrl = TextEditingController(
      text: gasto?.costoUnitario.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final estadoMaestros = ref.watch(controladorMaestrosProvider).value;
          List<String> tiposGasto = [
            'Flete',
            'Hielo',
            'Estiba',
            'Administrativo',
            'Otros',
          ];
          if (estadoMaestros != null && estadoMaestros.tiposGasto.isNotEmpty) {
            tiposGasto = estadoMaestros.tiposGasto
                .map((t) => t.nombre)
                .toList();
          }

          if (!tiposGasto.contains(tipoSeleccionado) && tiposGasto.isNotEmpty) {
            tipoSeleccionado = tiposGasto.first;
          }

          return StatefulBuilder(
            builder: (context, setStateDialog) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esNuevo ? 'Añadir gasto' : 'Editar gasto',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15181A),
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Registra los gastos asociados a este zarpe.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
                      dropdownColor: Colors.white,
                      iconEnabledColor: const Color(0xFF64748B),
                      style: const TextStyle(
                        color: Color(0xFF15181A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _decoracionDialogo(
                        'Selecciona tipo',
                        icono: Icons.category_outlined,
                      ),
                      items: tiposGasto
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Color(0xFF15181A),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setStateDialog(() => tipoSeleccionado = val);
                      },
                    ),
                    _construirEtiquetaDialogo('Concepto / Detalle'),
                    TextField(
                      controller: conceptoCtrl,
                      style: const TextStyle(
                        color: Color(0xFF15181A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoracionDialogo(
                        'Ej. Flete Piura - Paita',
                        icono: Icons.description_outlined,
                      ),
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
                                style: const TextStyle(
                                  color: Color(0xFF15181A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [FormateadorMiles()],
                                decoration: _decoracionDialogo(
                                  '1',
                                  icono: Icons.numbers_outlined,
                                ),
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
                                style: const TextStyle(
                                  color: Color(0xFF15181A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [FormateadorMiles()],
                                decoration: _decoracionDialogo(
                                  'S/ 0.00',
                                  icono: Icons.payments_outlined,
                                ),
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
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final c = FormateadorMiles.parseDouble(cantidadCtrl.text);
                    final costo = FormateadorMiles.parseDouble(costoCtrl.text);
                    if (conceptoCtrl.text.isEmpty || c <= 0 || costo <= 0)
                      return;

                    final String idAsignado =
                        (gasto?.id == null || gasto!.id.isEmpty)
                        ? Uuid().v4()
                        : gasto.id;

                    final nuevo = GastoWebModelo(
                      id: idAsignado,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static InputDecoration _decoracionDialogo(
    String hintText, {
    IconData? icono,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: icono != null
          ? Icon(icono, color: const Color(0xFF94A3B8), size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7EBFC9), width: 1.5),
      ),
    );
  }
}
