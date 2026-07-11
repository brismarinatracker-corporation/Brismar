import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../dominio/modelos/producto_modelo.dart';
import '../controladores/controlador_productos.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

class DialogoFormularioProducto extends ConsumerStatefulWidget {
  final Producto? productoAEditar;

  const DialogoFormularioProducto({super.key, this.productoAEditar});

  @override
  ConsumerState<DialogoFormularioProducto> createState() => _DialogoFormularioProductoState();
}

class _DialogoFormularioProductoState extends ConsumerState<DialogoFormularioProducto> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  bool _guardando = false;
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic)
    );
    _animController.forward();

    final p = widget.productoAEditar;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
  }

  @override
  void dispose() {
    _animController.dispose();
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  void _cerrar() {
    _animController.reverse().then((_) => Navigator.of(context).pop());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _mensajeError = null;
    });

    try {
      final producto = Producto(
        id: widget.productoAEditar?.id ?? '',
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        estadoActivo: widget.productoAEditar?.estadoActivo ?? true,
        createdAt: widget.productoAEditar?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(controladorProductosProvider.notifier).guardarProducto(producto);
      if (mounted) _cerrar();
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _mensajeError = 'Error al guardar el producto: $e';
        });
      }
    }
  }

  Widget _construirCampo({
    required String etiqueta, 
    required TextEditingController controller, 
    int maxLines = 1,
    bool requerido = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta.toUpperCase(), style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(color: const Color(0xFF15181A), fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0E3E2C), width: 2.0)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 2.0)),
            ),
            validator: requerido ? (v) => v!.trim().isEmpty ? 'Requerido' : null : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esMovil = anchoPantalla < 550;
    final esEdicion = widget.productoAEditar != null;

    return Stack(
      children: [
        GestureDetector(
          onTap: _guardando ? null : _cerrar,
          child: Container(color: Colors.black54),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: esMovil ? anchoPantalla : 480,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  border: const Border(left: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(-8, 0)),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(esEdicion ? 'Editar Producto' : 'Nuevo Producto', style: GoogleFonts.sora(color: const Color(0xFF15181A), fontSize: 24, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close, color: Color(0xFF64748B)), onPressed: _cerrar),
                        ],
                      ),
                    ),
                    
                    // Form Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_mensajeError != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.1),
                                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(_mensajeError!, style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500)),
                                ),
                              
                              _construirCampo(etiqueta: 'Nombre del Producto', controller: _nombreCtrl),
                              _construirCampo(etiqueta: 'Descripción', controller: _descripcionCtrl, maxLines: 3, requerido: false),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Botón Guardar
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E3E2C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _guardando ? null : _guardar,
                          child: _guardando 
                              ? const CargaOrbital(tamano: 24)
                              : Text('Guardar Cambios', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
