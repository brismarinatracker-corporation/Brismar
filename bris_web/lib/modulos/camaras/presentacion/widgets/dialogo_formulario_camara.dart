import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../dominio/modelos/camara_modelo.dart';
import '../controladores/controlador_camaras.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

class DialogoFormularioCamara extends ConsumerStatefulWidget {
  final Camara? camaraAEditar;

  const DialogoFormularioCamara({super.key, this.camaraAEditar});

  @override
  ConsumerState<DialogoFormularioCamara> createState() =>
      _DialogoFormularioCamaraState();
}

class _DialogoFormularioCamaraState
    extends ConsumerState<DialogoFormularioCamara>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placaCtrl;
  late TextEditingController _choferCtrl;
  late TextEditingController _marcaCtrl;
  late TextEditingController _capacidadCtrl;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  bool _guardando = false;
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();

    final c = widget.camaraAEditar;
    _placaCtrl = TextEditingController(text: c?.placa ?? '');
    _choferCtrl = TextEditingController(text: c?.chofer ?? '');
    _marcaCtrl = TextEditingController(text: c?.marca ?? '');
    _capacidadCtrl = TextEditingController(
      text: c?.capacidadKg != null ? c!.capacidadKg.toString() : '',
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _placaCtrl.dispose();
    _choferCtrl.dispose();
    _marcaCtrl.dispose();
    _capacidadCtrl.dispose();
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
      final camara = Camara(
        id: widget.camaraAEditar?.id ?? '',
        placa: _placaCtrl.text.trim().toUpperCase(),
        chofer: _choferCtrl.text.trim(),
        marca: _marcaCtrl.text.trim(),
        capacidadKg: double.tryParse(_capacidadCtrl.text.trim()),
        estadoActivo: widget.camaraAEditar?.estadoActivo ?? true,
        createdAt: widget.camaraAEditar?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(controladorCamarasProvider.notifier).guardarCamara(camara);
      if (mounted) _cerrar();
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _mensajeError = 'Error al guardar la cámara: $e';
        });
      }
    }
  }

  Widget _construirCampo({
    required String etiqueta,
    required TextEditingController controller,
    bool requerido = true,
    bool esNumero = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta.toUpperCase(),
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: esNumero
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            inputFormatters: esNumero
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                : [],
            style: GoogleFonts.inter(
              color: const Color(0xFF15181A),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0E3E2C),
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 2.0,
                ),
              ),
            ),
            validator: requerido
                ? (v) => v!.trim().isEmpty ? 'Requerido' : null
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esMovil = anchoPantalla < 550;
    final esEdicion = widget.camaraAEditar != null;

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
                  border: const Border(
                    left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(-8, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            esEdicion ? 'Editar Cámara' : 'Nueva Cámara',
                            style: GoogleFonts.sora(
                              color: const Color(0xFF15181A),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF64748B),
                            ),
                            onPressed: _cerrar,
                          ),
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
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.1,
                                    ),
                                    border: Border.all(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _mensajeError!,
                                    style: GoogleFonts.inter(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              _construirCampo(
                                etiqueta: 'Placa',
                                controller: _placaCtrl,
                              ),
                              _construirCampo(
                                etiqueta: 'Nombre del Chofer',
                                controller: _choferCtrl,
                                requerido: false,
                              ),
                              _construirCampo(
                                etiqueta: 'Marca',
                                controller: _marcaCtrl,
                                requerido: false,
                              ),
                              _construirCampo(
                                etiqueta: 'Capacidad Total (KG)',
                                controller: _capacidadCtrl,
                                requerido: false,
                                esNumero: true,
                              ),
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
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E3E2C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _guardando ? null : _guardar,
                          child: _guardando
                              ? const CargaOrbital(tamano: 24)
                              : Text(
                                  'Guardar Cambios',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
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
