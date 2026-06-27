import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/zarpe_entidad.dart';
import '../controladores/controlador_zarpes.dart';

class FormularioZarpePantalla extends ConsumerStatefulWidget {
  const FormularioZarpePantalla({super.key});

  @override
  ConsumerState<FormularioZarpePantalla> createState() => _FormularioZarpePantallaState();
}

class _FormularioZarpePantallaState extends ConsumerState<FormularioZarpePantalla> {
  final _formKey = GlobalKey<FormState>();
  final _placaCtrl = TextEditingController();
  final _choferCtrl = TextEditingController();
  final _muelleCtrl = TextEditingController();

  File? _fotoEvidencia;
  bool _guardando = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _placaCtrl.dispose();
    _choferCtrl.dispose();
    _muelleCtrl.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    try {
      final foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Optimizar peso de imagen
      );
      if (foto != null) {
        setState(() {
          _fotoEvidencia = File(foto.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al acceder a la cámara: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _seleccionarFotoGaleria() async {
    try {
      final foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (foto != null) {
        setState(() {
          _fotoEvidencia = File(foto.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al acceder a la galería: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F224A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF00E5FF)),
              title: const Text('Tomar Foto', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _tomarFoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF00E5FF)),
              title: const Text('Seleccionar de Galería', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _seleccionarFotoGaleria();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarZarpe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fotoEvidencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe tomar una fotografía de evidencia para registrar el zarpe'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final nuevoZarpe = ZarpeEntidad(
        id: const Uuid().v4(),
        placaCamara: _placaCtrl.text.toUpperCase(),
        chofer: _choferCtrl.text.trim(),
        muellePartida: _muelleCtrl.text.trim(),
        fotoUrlEvidencia: '', 
        fotoLocalPath: _fotoEvidencia!.path,
        fechaZarpe: DateTime.now(),
        estado: 'pendiente',
      );

      await ref.read(proveedorZarpes.notifier).registrarZarpe(nuevoZarpe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zarpe de Cámara registrado correctamente'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar zarpe: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  InputDecoration _construirInputDecoration({required String labelText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      floatingLabelStyle: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFF0F224A).withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(proveedorZarpes);
    if (estado.isLoading) {
      _guardando = true;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Registrar Zarpe de Cámara', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF040B1E), Color(0xFF0C1D3F), Color(0xFF143068)],
              ),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // FOTO EVIDENCIA
                    GestureDetector(
                      onTap: _mostrarOpcionesImagen,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F224A).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _fotoEvidencia != null ? const Color(0xFF00E5FF).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: _fotoEvidencia != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(_fotoEvidencia!, fit: BoxFit.cover),
                                    Positioned(
                                      bottom: 12, right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.refresh_rounded, color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text('Cambiar Foto', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: const Color(0xFF00E5FF).withValues(alpha: 0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt_rounded, size: 36, color: Color(0xFF00E5FF)),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Tomar Foto de Evidencia', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text('(Obligatorio)', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('Datos de Transporte', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _placaCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [_PlacaInputFormatter()],
                      decoration: _construirInputDecoration(
                        labelText: 'Placa de la Cámara (Ej: AAA-123)',
                        suffixIcon: const Icon(Icons.local_shipping_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (v.replaceAll('-', '').length != 6) return 'Faltan caracteres (6)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _choferCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.words,
                      decoration: _construirInputDecoration(
                        labelText: 'Nombre del Chofer',
                        suffixIcon: const Icon(Icons.person_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _muelleCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.words,
                      decoration: _construirInputDecoration(
                        labelText: 'Muelle de Partida',
                        suffixIcon: const Icon(Icons.anchor_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: const Color(0xFF070E22),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: _guardando ? null : _guardarZarpe,
                      child: _guardando
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF070E22)))
                          : const Text('REGISTRAR ZARPE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (text.length > 6) return oldValue;
    String formatted = text;
    if (text.length > 3) formatted = '${text.substring(0, 3)}-${text.substring(3)}';
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
