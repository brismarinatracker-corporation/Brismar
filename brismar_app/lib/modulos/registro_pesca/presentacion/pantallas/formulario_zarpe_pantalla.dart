import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/cuadre_entidad.dart';
import '../../dominio/entidades/zarpe_entidad.dart';
import '../controladores/controlador_cuadres.dart';
import '../controladores/controlador_zarpes.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:brismar_mobile/nucleo/componentes/carga_orbital.dart';

class FormularioZarpePantalla extends ConsumerStatefulWidget {
  const FormularioZarpePantalla({super.key});

  @override
  ConsumerState<FormularioZarpePantalla> createState() => _FormularioZarpePantallaState();
}

class _FormularioZarpePantallaState extends ConsumerState<FormularioZarpePantalla> {
  final _formKey = GlobalKey<FormState>();
  final _placaCtrl = TextEditingController();
  final _choferCtrl = TextEditingController();
  final _pesoTotalCtrl = TextEditingController();
  final _cajasLlenasCtrl = TextEditingController();
  final _cajasVaciasCtrl = TextEditingController();
  final _muellePartidaCtrl = TextEditingController();
  final _pesadorCtrl = TextEditingController();

  int _tipoProductoSeleccionado = 1; // 1: Pota, 2: Bonito, 3: Caballa, 4: Jurel, 5: Otros
  final List<XFile> _fotosEvidencia = [];
  bool _guardando = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      _recuperarDatosPerdidos();
    }
  }

  Future<void> _recuperarDatosPerdidos() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.file != null) {
        setState(() {
          _fotosEvidencia.add(response.file!);
        });
      }
    } catch (e) {
      debugPrint('Error al recuperar foto perdida: $e');
    }
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _choferCtrl.dispose();
    _pesoTotalCtrl.dispose();
    _cajasLlenasCtrl.dispose();
    _cajasVaciasCtrl.dispose();
    _muellePartidaCtrl.dispose();
    _pesadorCtrl.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    try {
      if (_fotosEvidencia.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya has agregado el máximo de 3 fotos.'),
            backgroundColor: Colors.amber,
          ),
        );
        return;
      }
      final foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Optimizar peso de imagen
      );
      if (foto != null) {
        setState(() {
          _fotosEvidencia.add(foto);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al acceder a la cámara: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _seleccionarFotoGaleria() async {
    try {
      if (_fotosEvidencia.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya has agregado el máximo de 3 fotos.'),
            backgroundColor: Colors.amber,
          ),
        );
        return;
      }
      final foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (foto != null) {
        setState(() {
          _fotosEvidencia.add(foto);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al acceder a la galería: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotosEvidencia.removeAt(index);
    });
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F224A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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

    if (_fotosEvidencia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe tomar al menos una fotografía de evidencia para registrar el zarpe'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final authState = ref.read(proveedorControladorAutenticacion);
    String usuarioActualId = '';
    if (authState is EstadoAutenticacionAutenticado) {
      usuarioActualId = authState.usuario.id;
    }

    if (usuarioActualId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de sesión: No se puede guardar el zarpe sin una sesión activa'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final idZarpe = const Uuid().v4();
      final pesoTotal = double.tryParse(_pesoTotalCtrl.text) ?? 0.0;
      final cajasLlenas = int.tryParse(_cajasLlenasCtrl.text) ?? 0;
      final cajasVacias = int.tryParse(_cajasVaciasCtrl.text) ?? 0;

      final fechaActual = DateTime.now().toIso8601String().substring(0, 10);

      final nuevoCuadre = CuadreEntidad(
        id: idZarpe,
        usuarioId: usuarioActualId,
        placa: _placaCtrl.text.toUpperCase(),
        fechaZarpe: fechaActual,
        estado: 'zarpe', // Estado especial de zarpe de cámara
        fotoZarpeUrl: _fotosEvidencia.map((f) => f.path).join(','),
        pesoTotal: pesoTotal,
        cajasLlenas: cajasLlenas,
        cajasVacias: cajasVacias,
        tipoProducto: _tipoProductoSeleccionado,
        muellePartida: _muellePartidaCtrl.text.trim().isEmpty ? null : _muellePartidaCtrl.text.trim().toUpperCase(),
        pesador: _pesadorCtrl.text.trim().toUpperCase().isEmpty ? null : _pesadorCtrl.text.trim().toUpperCase(),
        sincronizado: false,
        compras: const [],
        gastos: const [],
        ventas: const [],
      );

      // 1. Guardar en la tabla 'cuadres' para persistir el flujo local en la app móvil
      await ref.read(cuadresProvider.notifier).guardarCuadre(nuevoCuadre);

      // 2. Guardar en la tabla 'zarpes' para que se sincronice con el Radar de Tránsito de la Web Admin
      final nuevoZarpe = ZarpeEntidad(
        id: idZarpe,
        placaCamara: _placaCtrl.text.toUpperCase(),
        chofer: _choferCtrl.text.trim().toUpperCase(),
        muellePartida: _muellePartidaCtrl.text.trim().toUpperCase(),
        fotoUrlEvidencia: _fotosEvidencia.map((f) => f.path).join(','),
        fotoLocalPath: _fotosEvidencia.map((f) => f.path).join(','),
        fechaZarpe: DateTime.now(),
        estado: 'DESPACHADO_PIURA',
      );

      await ref.read(proveedorZarpes.notifier).registrarZarpe(nuevoZarpe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zarpe de Cámara registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar zarpe: $e'),
            backgroundColor: Colors.redAccent,
          ),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar Zarpe de Cámara',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fondo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF040B1E),
                  Color(0xFF0C1D3F),
                  Color(0xFF143068),
                ],
              ),
            ),
          ),
          // Esferas de brillo decorativas
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x1A00E5FF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1A00E5FF).withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
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
                    // Card de Fotografía de Evidencia
                    // Card de Fotografía de Evidencia
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fotos de Evidencia (Máx. 3)',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_fotosEvidencia.length}/3',
                              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_fotosEvidencia.isEmpty)
                          GestureDetector(
                            onTap: _mostrarOpcionesImagen,
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F224A).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, size: 36, color: Color(0xFF00E5FF)),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tomar Foto de Evidencia',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '(Al menos 1 foto requerida para el zarpe)',
                                    style: TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _fotosEvidencia.length + (_fotosEvidencia.length < 3 ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _fotosEvidencia.length) {
                                  // Botón de Añadir otra foto
                                  return GestureDetector(
                                    onTap: _mostrarOpcionesImagen,
                                    child: Container(
                                      width: 110,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F224A).withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo_rounded, color: Color(0xFF00E5FF), size: 28),
                                          SizedBox(height: 8),
                                          Text(
                                            'Añadir',
                                            style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final foto = _fotosEvidencia[index];
                                return Stack(
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      height: 130,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: kIsWeb
                                              ? Image.network(
                                                  foto.path,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  File(foto.path),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 16,
                                      child: GestureDetector(
                                        onTap: () => _eliminarFoto(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.redAccent,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Inputs de datos básicos
                    const Text(
                      'Datos de la Cámara',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Placa
                    TextFormField(
                      controller: _placaCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        _PlacaInputFormatter(),
                      ],
                      decoration: _construirInputDecoration(
                        labelText: 'Placa de la Cámara (Ej: AAA-123)',
                        suffixIcon: const Icon(Icons.local_shipping_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'La placa es requerida';
                        final clean = v.replaceAll('-', '');
                        if (clean.length != 6) return 'La placa debe tener exactamente 6 caracteres (Ej: AAA-123)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Chofer
                    TextFormField(
                      controller: _choferCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        _UpperCaseInputFormatter(),
                      ],
                      decoration: _construirInputDecoration(
                        labelText: 'Nombre del Chofer',
                        suffixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'El nombre del chofer es requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Peso Total
                    TextFormField(
                      controller: _pesoTotalCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: _construirInputDecoration(
                        labelText: 'Peso Total (Kg)',
                        suffixIcon: const Icon(Icons.scale_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'El peso total es requerido';
                        final valor = double.tryParse(v) ?? 0.0;
                        if (valor <= 0) return 'El peso debe ser mayor a 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fila Cajas Llenas y Vacías
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cajasLlenasCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: _construirInputDecoration(labelText: 'Cajas Llenas'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              final valor = int.tryParse(v) ?? -1;
                              if (valor < 0) return 'Mínimo 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cajasVaciasCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: _construirInputDecoration(labelText: 'Cajas Vacías'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              final valor = int.tryParse(v) ?? -1;
                              if (valor < 0) return 'Mínimo 0';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tipo Producto (Selector desplegable)
                    DropdownButtonFormField<int>(
                      initialValue: _tipoProductoSeleccionado,
                      dropdownColor: const Color(0xFF0F224A),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: const Color(0xFFFFD54F),
                      decoration: InputDecoration(
                        labelText: 'Tipo de Producto',
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                        floatingLabelStyle: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFFFFD54F).withValues(alpha: 0.35), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFFD54F), width: 1.8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F224A).withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Pota')),
                        DropdownMenuItem(value: 2, child: Text('Bonito')),
                        DropdownMenuItem(value: 3, child: Text('Caballa')),
                        DropdownMenuItem(value: 4, child: Text('Jurel')),
                        DropdownMenuItem(value: 5, child: Text('Otros')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _tipoProductoSeleccionado = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Muelle de Partida
                    TextFormField(
                      controller: _muellePartidaCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        _UpperCaseInputFormatter(),
                      ],
                      decoration: _construirInputDecoration(
                        labelText: 'Muelle de Partida',
                        suffixIcon: const Icon(Icons.anchor_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'El muelle de partida es requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pesador de Muelle
                    TextFormField(
                      controller: _pesadorCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        _UpperCaseInputFormatter(),
                      ],
                      decoration: _construirInputDecoration(
                        labelText: 'Pesador de Muelle',
                        suffixIcon: const Icon(Icons.person_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'El nombre del pesador es requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botón para Guardar
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
                          ? const CargaOrbital(tamano: 20)
                          : const Text(
                              'REGISTRAR ZARPE DE CÁMARA',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                    ),
                    const SizedBox(height: 12),
                    if (_guardando)
                      const LinearProgressIndicator(
                        color: Color(0xFF00E5FF),
                        backgroundColor: Colors.transparent,
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
    if (text.length > 6) {
      return oldValue;
    }
    String formatted = text;
    if (text.length > 3) {
      formatted = '${text.substring(0, 3)}-${text.substring(3)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _UpperCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
