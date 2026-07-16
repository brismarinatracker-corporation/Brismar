import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../cuadres/dominio/modelos/cuadre_web_modelo.dart';
import '../../../../nucleo/utilidades/formateador_miles.dart';

class SeccionRecepcionVenta extends StatefulWidget {
  final List<VentaWebModelo> ventas;
  final Function(VentaWebModelo) onGuardar;
  final Function(String) onEliminar;

  const SeccionRecepcionVenta({
    super.key,
    required this.ventas,
    required this.onGuardar,
    required this.onEliminar,
  });

  @override
  State<SeccionRecepcionVenta> createState() => _SeccionRecepcionVentaState();
}

class _SeccionRecepcionVentaState extends State<SeccionRecepcionVenta> {
  void _mostrarDialogoVenta([VentaWebModelo? ventaExistente]) {
    String plantaSeleccionada =
        ventaExistente?.lugar != null &&
            [
              'PERU FROST',
              'ARCOPA',
              'ALTAMAR',
              'PROANCO',
              'INVERSIONES EL RIVALDO (EL MAYOR)',
              'KSL',
              'CORPOESMAR',
              'PERUVIAN',
            ].contains(ventaExistente!.lugar)
        ? ventaExistente.lugar
        : (ventaExistente != null ? 'OTROS' : 'PERU FROST');

    String especieSeleccionada =
        ventaExistente?.producto != null &&
            [
              "CATANA",
              "POTA",
              "1A",
              "2A",
              "DESTARE",
              "CABALLA",
              "BONITO",
              "JUREL",
            ].contains(ventaExistente!.producto)
        ? ventaExistente.producto
        : (ventaExistente != null ? 'OTROS' : 'POTA');
    final otraEspecieCtrl = TextEditingController(
      text: (ventaExistente != null && especieSeleccionada == 'OTROS')
          ? ventaExistente.producto
          : '',
    );
    final kilosCtrl = TextEditingController(
      text: ventaExistente?.kilos.toString() ?? '',
    );
    final precioCtrl = TextEditingController(
      text: ventaExistente?.precioUnitario.toString() ?? '',
    );
    final otraPlantaCtrl = TextEditingController(
      text: (ventaExistente != null && plantaSeleccionada == 'OTROS')
          ? ventaExistente.lugar
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (contextDialog, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(
            ventaExistente == null ? 'Nueva Recepción' : 'Editar Recepción',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF15181A),
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _construirEtiqueta('Planta de Destino (Procesadora)'),
                DropdownButtonFormField<String>(
                  value: plantaSeleccionada,
                  dropdownColor: Colors.white,
                  decoration: _decoracionInput('Selecciona planta'),
                  items:
                      [
                            'PERU FROST',
                            'ARCOPA',
                            'ALTAMAR',
                            'PROANCO',
                            'INVERSIONES EL RIVALDO (EL MAYOR)',
                            'KSL',
                            'CORPOESMAR',
                            'PERUVIAN',
                            'OTROS',
                          ]
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setStateDialog(() => plantaSeleccionada = val);
                  },
                ),
                if (plantaSeleccionada == 'OTROS') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: otraPlantaCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _decoracionInput('Nombre de la planta'),
                  ),
                ],
                const SizedBox(height: 12),
                _construirEtiqueta('Especie'),
                DropdownButtonFormField<String>(
                  value: especieSeleccionada,
                  dropdownColor: Colors.white,
                  decoration: _decoracionInput('Selecciona especie'),
                  items:
                      [
                            "CATANA",
                            "POTA",
                            "1A",
                            "2A",
                            "DESTARE",
                            "CABALLA",
                            "BONITO",
                            "JUREL",
                            "OTROS",
                          ]
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setStateDialog(() => especieSeleccionada = val);
                  },
                ),
                if (especieSeleccionada == 'OTROS') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: otraEspecieCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _decoracionInput('Nombre del producto'),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiqueta('Kilos Finales'),
                          TextField(
                            controller: kilosCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FormateadorMiles(),
                            ],
                            decoration: _decoracionInput('0.00'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirEtiqueta('Precio (x Kg)'),
                          TextField(
                            controller: precioCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FormateadorMiles(),
                            ],
                            decoration: _decoracionInput('S/ 0.00'),
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
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final kilos = FormateadorMiles.parseDouble(kilosCtrl.text);
                final precio = FormateadorMiles.parseDouble(precioCtrl.text);
                final planta = plantaSeleccionada == 'OTROS'
                    ? otraPlantaCtrl.text.trim().toUpperCase()
                    : plantaSeleccionada;
                final producto = especieSeleccionada == 'OTROS'
                    ? otraEspecieCtrl.text.trim().toUpperCase()
                    : especieSeleccionada;

                if (planta.isEmpty || kilos <= 0 || producto.isEmpty) return;

                final nuevaVenta = VentaWebModelo(
                  id: ventaExistente?.id ?? '',
                  cuadreId: ventaExistente?.cuadreId ?? '',
                  lugar: planta,
                  producto: producto,
                  kilos: kilos,
                  precioUnitario: precio,
                  total: kilos * precio,
                );

                widget.onGuardar(nuevaVenta);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D5C75),
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirEtiqueta(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracionInput(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: Color(0xFF1B5E20),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recepción en Planta',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF15181A),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoVenta(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C75),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          if (widget.ventas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No hay recepciones registradas.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.ventas.length,
              separatorBuilder: (ctx, i) =>
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (ctx, i) {
                final v = widget.ventas[i];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.factory_outlined,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${v.lugar} - ${v.producto}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15181A),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${v.kilos.toStringAsFixed(2)} kg @ S/ ${v.precioUnitario.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'S/ ${v.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5C75),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            onPressed: () => _mostrarDialogoVenta(v),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => widget.onEliminar(v.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
