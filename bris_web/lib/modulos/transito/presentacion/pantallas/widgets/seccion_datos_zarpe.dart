import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'galeria_lightbox.dart';

class SeccionDatosZarpe extends StatefulWidget {
  final List<String> urlsFotos;
  final TextEditingController placaCtrl;
  final TextEditingController choferCtrl;
  final TextEditingController muelleCtrl;
  final TextEditingController pesoTotalCtrl;
  final TextEditingController cajasLlenasCtrl;
  final TextEditingController cajasVaciasCtrl;
  final TextEditingController pesadorCtrl;
  final TextEditingController tipoCtrl;
  final TextEditingController cuadrillaCtrl;
  final TextEditingController? observacionesCtrl;
  final int tipoProductoActual;
  final ValueChanged<int> onTipoProductoCambiado;

  const SeccionDatosZarpe({
    super.key,
    required this.urlsFotos,
    required this.placaCtrl,
    required this.choferCtrl,
    required this.muelleCtrl,
    required this.pesoTotalCtrl,
    required this.cajasLlenasCtrl,
    required this.cajasVaciasCtrl,
    required this.pesadorCtrl,
    required this.tipoCtrl,
    required this.cuadrillaCtrl,
    this.observacionesCtrl,
    required this.tipoProductoActual,
    required this.onTipoProductoCambiado,
  });

  @override
  State<SeccionDatosZarpe> createState() => _SeccionDatosZarpeState();
}

class _SeccionDatosZarpeState extends State<SeccionDatosZarpe> {
  int _indiceFotoActiva = 0;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final esPantallaPequena = constraints.maxWidth < 450;

          Widget filaResponsiva(Widget a, Widget b) {
            if (esPantallaPequena) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [a, const SizedBox(height: 16), b],
              );
            }
            return Row(
              children: [
                Expanded(child: a),
                const SizedBox(width: 16),
                Expanded(child: b),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('Datos del Zarpe (Cámara)', style: TextStyle(color: Color(0xFF15181A), fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Color(0xFFF1F5F9), height: 32),
          
          if (widget.urlsFotos.isNotEmpty) ...[
            const Text(
              'Evidencia Fotográfica / Guía',
              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => GaleriaLightbox.mostrar(context, widget.urlsFotos, _indiceFotoActiva),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: CachedNetworkImage(
                            imageUrl: widget.urlsFotos[_indiceFotoActiva],
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (c, u, e) => const Center(
                              child: Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.urlsFotos.length > 1)
                      Positioned(
                        left: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          radius: 18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _indiceFotoActiva = (_indiceFotoActiva - 1 + widget.urlsFotos.length) % widget.urlsFotos.length;
                              });
                            },
                          ),
                        ),
                      ),
                    if (widget.urlsFotos.length > 1)
                      Positioned(
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          radius: 18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _indiceFotoActiva = (_indiceFotoActiva + 1) % widget.urlsFotos.length;
                              });
                            },
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_indiceFotoActiva + 1} / ${widget.urlsFotos.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          TextFormField(
            controller: widget.placaCtrl,
            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            readOnly: true,
            decoration: _decoracion('Placa Cámara', icono: Icons.directions_car_filled_outlined, esSoloLectura: true),
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.choferCtrl,
            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            readOnly: true,
            decoration: _decoracion('Chofer', icono: Icons.person_outline, esSoloLectura: true),
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.muelleCtrl,
            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            readOnly: true,
            decoration: _decoracion('Muelle Partida', icono: Icons.anchor_outlined, esSoloLectura: true),
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.pesadorCtrl,
            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            readOnly: true,
            decoration: _decoracion('Pesador (Opcional)', icono: Icons.monitor_weight_outlined, esSoloLectura: true),
          ),
          const SizedBox(height: 16),
          filaResponsiva(
            TextFormField(
              controller: widget.tipoCtrl,
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              readOnly: true,
              decoration: _decoracion('Tipo (Opcional)', icono: Icons.category_outlined, esSoloLectura: true),
            ),
            TextFormField(
              controller: widget.cuadrillaCtrl,
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              readOnly: true,
              decoration: _decoracion('Cuadrilla (Opcional)', icono: Icons.group_outlined, esSoloLectura: true),
            ),
          ),
          const SizedBox(height: 16),
          filaResponsiva(
            TextFormField(
              controller: widget.pesoTotalCtrl,
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              readOnly: true,
              decoration: _decoracion('Peso Total (Kg)', icono: Icons.scale_outlined, esSoloLectura: true),
            ),
            DropdownButtonFormField<int>(
              initialValue: widget.tipoProductoActual,
              decoration: _decoracion('Tipo Producto', icono: Icons.set_meal_outlined, esSoloLectura: true),
              items: const [
                DropdownMenuItem(value: 0, child: Text('No definido')),
                DropdownMenuItem(value: 1, child: Text('Pota')),
                DropdownMenuItem(value: 2, child: Text('Bonito')),
                DropdownMenuItem(value: 3, child: Text('Caballa')),
                DropdownMenuItem(value: 4, child: Text('Jurel')),
                DropdownMenuItem(value: 5, child: Text('Otros')),
              ],
              onChanged: null,
            ),
          ),
          const SizedBox(height: 16),
          filaResponsiva(
            TextFormField(
              controller: widget.cajasLlenasCtrl,
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              keyboardType: TextInputType.number,
              readOnly: true,
              decoration: _decoracion('Cajas Llenas', icono: Icons.inventory_2_outlined, esSoloLectura: true),
            ),
            TextFormField(
              controller: widget.cajasVaciasCtrl,
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              keyboardType: TextInputType.number,
              readOnly: true,
              decoration: _decoracion('Cajas Vacías', icono: Icons.inventory_outlined, esSoloLectura: true),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.observacionesCtrl != null) ...[
            TextFormField(
              controller: widget.observacionesCtrl,
              style: const TextStyle(color: Color(0xFF15181A), fontWeight: FontWeight.w600),
              decoration: _decoracion('Observaciones (Opcional)', icono: Icons.notes_outlined),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Nota: Estos datos actualizan tanto el Zarpe como el Cuadre.', 
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
          ),
        ],
      );
      },
      ),
    );
  }

  InputDecoration _decoracion(String label, {IconData? icono, bool esSoloLectura = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
      floatingLabelStyle: const TextStyle(color: Color(0xFF7EBFC9), fontSize: 14, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: esSoloLectura ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
      prefixIcon: icono != null ? Icon(icono, color: const Color(0xFF94A3B8), size: 20) : null,
      suffixIcon: esSoloLectura 
          ? const Tooltip(
              message: 'Este campo proviene de la App móvil y no puede ser modificado aquí.',
              child: Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 18),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: esSoloLectura ? const Color(0xFFE2E8F0) : Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: esSoloLectura ? const Color(0xFFE2E8F0) : const Color(0xFF7EBFC9), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
