import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../nucleo/componentes/estilos_formulario.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/entidades/cuadre_entidad.dart';
import '../../dominio/entidades/zarpe_entidad.dart';
import '../controladores/controlador_cuadres.dart';
import '../controladores/controlador_zarpes.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';
import '../../datos/repositorios/camaras_repositorio_local.dart';
import '../../../../nucleo/utilidades/formateador_miles.dart';
import '../../../../nucleo/utilidades/formateadores_texto.dart';
import '../widgets/seccion_fotos_evidencia.dart';

class FormularioZarpePantalla extends ConsumerStatefulWidget {
  const FormularioZarpePantalla({super.key});

  @override
  ConsumerState<FormularioZarpePantalla> createState() =>
      _FormularioZarpePantallaState();
}

class _FormularioZarpePantallaState
    extends ConsumerState<FormularioZarpePantalla> {
  final _formKey = GlobalKey<FormState>();
  final _placaCtrl = TextEditingController();
  final _choferCtrl = TextEditingController();
  final _numeroChoferCtrl = TextEditingController();
  final _pesoTotalCtrl = TextEditingController();
  final _cajasLlenasCtrl = TextEditingController();
  final _cajasVaciasCtrl = TextEditingController();
  final _muellePartidaCtrl = TextEditingController();
  final _pesadorCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _cuadrillaCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  final _otroProductoCtrl = TextEditingController();

  String? _tipoProductoSeleccionado;
  final List<XFile> _fotosEvidencia = [];
  bool _guardando = false;
  List<String> _placasGuardadas = [];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarPlacas();
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
      // Ignorar
    }
  }

  Future<void> _cargarPlacas() async {
    final placas = await CamarasRepositorioLocal().obtenerPlacasActivas();
    setState(() {
      _placasGuardadas = placas;
    });
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _choferCtrl.dispose();
    _numeroChoferCtrl.dispose();
    _pesoTotalCtrl.dispose();
    _cajasLlenasCtrl.dispose();
    _cajasVaciasCtrl.dispose();
    _muellePartidaCtrl.dispose();
    _pesadorCtrl.dispose();
    _tipoCtrl.dispose();
    _cuadrillaCtrl.dispose();
    _observacionesCtrl.dispose();
    _otroProductoCtrl.dispose();
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
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF00E5FF),
              ),
              title: const Text(
                'Tomar Foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _tomarFoto();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFF00E5FF),
              ),
              title: const Text(
                'Seleccionar de Galería',
                style: TextStyle(color: Colors.white),
              ),
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
          content: Text(
            'Debe tomar al menos una fotografía de evidencia para registrar el zarpe',
          ),
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
          content: Text(
            'Error de sesión: No se puede guardar el zarpe sin una sesión activa',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await CamarasRepositorioLocal().guardarPlacaLocal(_placaCtrl.text);

      final idZarpe = const Uuid().v4();
      final pesoTotal = FormateadorMiles.parseDouble(_pesoTotalCtrl.text);
      final cajasLlenas = int.tryParse(_cajasLlenasCtrl.text) ?? 0;
      final cajasVacias = int.tryParse(_cajasVaciasCtrl.text) ?? 0;

      final fechaActual = DateTime.now().toIso8601String().substring(0, 10);

      final observaciones = _observacionesCtrl.text.trim();
      final gastos = observaciones.isNotEmpty
          ? [
              GastoEntidad(
                id: const Uuid().v4(),
                cuadreId: idZarpe,
                tipo: observaciones,
                concepto: 'OBSERVACIONES',
                cantidad: 1,
                costoUnitario: 0,
                total: 0,
              ),
            ]
          : const <GastoEntidad>[];

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
        tipoProducto: _tipoProductoSeleccionado == 'OTROS'
            ? _otroProductoCtrl.text.trim().toUpperCase()
            : _tipoProductoSeleccionado,
        muellePartida: _muellePartidaCtrl.text.trim().isEmpty
            ? null
            : _muellePartidaCtrl.text.trim().toUpperCase(),
        pesador: _pesadorCtrl.text.trim().toUpperCase(),
        tipo: _tipoCtrl.text.trim().toUpperCase(),
        cuadrilla: _cuadrillaCtrl.text.trim().toUpperCase(),
        sincronizado: false,
        compras: const [],
        gastos: gastos,
        ventas: const [],
      );

      // 1. Guardar en la tabla 'cuadres' para persistir el flujo local en la app móvil
      await ref.read(cuadresProvider.notifier).guardarCuadre(nuevoCuadre);

      // 2. Guardar en la tabla 'zarpes' para que se sincronice con el Radar de Tránsito de la Web Admin
      final nuevoZarpe = ZarpeEntidad(
        id: idZarpe,
        placaCamara: _placaCtrl.text.toUpperCase(),
        chofer: _choferCtrl.text.trim().toUpperCase(),
        numeroChofer: _numeroChoferCtrl.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF004D40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar zarpe',
          style: TextStyle(
            color: Color(0xFF004D40),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SeccionFotosEvidencia(
                  fotosEvidencia: _fotosEvidencia,
                  onMostrarOpciones: _mostrarOpcionesImagen,
                  onEliminarFoto: _eliminarFoto,
                ),
                const SizedBox(height: 24),

                // Inputs de datos básicos
                const Text(
                  'Datos de la camara',
                  style: TextStyle(
                    color: Color(0xFF006B54),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Placa
                RawAutocomplete<String>(
                  textEditingController: _placaCtrl,
                  focusNode: FocusNode(),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _placasGuardadas;
                    }
                    return _placasGuardadas.where((String option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.black87),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [PlacaInputFormatter()],
                          decoration:
                              EstilosFormulario.construirInputDecoration(
                                labelText: 'Placa (Ej: AAA-123)',
                              ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'La placa es requerida';
                            final clean = v.replaceAll('-', '');
                            if (clean.length != 6)
                              return 'La placa debe tener exactamente 6 caracteres (Ej: AAA-123)';
                            return null;
                          },
                        );
                      },
                  optionsViewBuilder:
                      (
                        BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options,
                      ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                                maxWidth: 300,
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(
                                    index,
                                  );
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                ),
                const SizedBox(height: 16),

                // Chofer
                TextFormField(
                  controller: _choferCtrl,
                  style: const TextStyle(color: Colors.black87),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseInputFormatter()],
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Nombre del chofer',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'El nombre del chofer es requerido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Número de Chofer
                TextFormField(
                  controller: _numeroChoferCtrl,
                  style: const TextStyle(color: Colors.black87),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Número del chofer',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'El número del chofer es requerido';
                    if (v.trim().length != 9)
                      return 'El número debe tener exactamente 9 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Peso Total
                TextFormField(
                  controller: _pesoTotalCtrl,
                  style: const TextStyle(color: Colors.black87),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [FormateadorMiles()],
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Peso Total (Kg)',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'El peso total es requerido';
                    final valor = FormateadorMiles.parseDouble(v);
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
                        style: const TextStyle(color: Colors.black87),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: EstilosFormulario.construirInputDecoration(
                          labelText: 'Cajas Llenas',
                        ),
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
                        style: const TextStyle(color: Colors.black87),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: EstilosFormulario.construirInputDecoration(
                          labelText: 'Cajas vacias',
                        ),
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

                DropdownButtonFormField<String>(
                  value: _tipoProductoSeleccionado,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black87),
                  iconEnabledColor: const Color(0xFF006B54),
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Tipo de Producto',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CATANA', child: Text('CATANA')),
                    DropdownMenuItem(value: 'POTA', child: Text('POTA')),
                    DropdownMenuItem(value: '1a', child: Text('1a')),
                    DropdownMenuItem(value: '2a', child: Text('2a')),
                    DropdownMenuItem(value: 'Destare', child: Text('Destare')),
                    DropdownMenuItem(value: 'Caballa', child: Text('Caballa')),
                    DropdownMenuItem(value: 'BONITO', child: Text('BONITO')),
                    DropdownMenuItem(value: 'JUREL', child: Text('JUREL')),
                    DropdownMenuItem(value: 'OTROS', child: Text('OTROS')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _tipoProductoSeleccionado = val;
                        if (val != 'OTROS') {
                          _otroProductoCtrl.clear();
                        }
                      });
                    }
                  },
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                if (_tipoProductoSeleccionado == 'OTROS') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otroProductoCtrl,
                    style: const TextStyle(color: Colors.black87),
                    textCapitalization: TextCapitalization.characters,
                    decoration: EstilosFormulario.construirInputDecoration(
                      labelText: 'Especifique otro producto',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                ],
                const SizedBox(height: 16),

                // Muelle de Partida
                TextFormField(
                  controller: _muellePartidaCtrl,
                  style: const TextStyle(color: Colors.black87),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseInputFormatter()],
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Muelle de Partida',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'El muelle de partida es requerido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pesador de Muelle
                TextFormField(
                  controller: _pesadorCtrl,
                  style: const TextStyle(color: Colors.black87),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseInputFormatter()],
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Pesador de Muelle',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'El nombre del pesador es requerido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo
                TextFormField(
                  controller: _tipoCtrl,
                  style: const TextStyle(color: Colors.black87),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseInputFormatter()],
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Tipo',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'El tipo es requerido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cuadrilla
                TextFormField(
                  controller: _cuadrillaCtrl,
                  style: const TextStyle(color: Colors.black87),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseInputFormatter()],
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Cuadrilla',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'La cuadrilla es requerida';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Observaciones
                TextFormField(
                  controller: _observacionesCtrl,
                  style: const TextStyle(color: Colors.black87),
                  decoration: EstilosFormulario.construirInputDecoration(
                    labelText: 'Observaciones / Notas (Opcional)',
                  ),
                ),
                const SizedBox(height: 32),

                // Botón para Guardar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004236),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _guardando ? null : _guardarZarpe,
                  child: _guardando
                      ? const CargaOrbital(tamano: 20)
                      : const Text(
                          'Guardar registro',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                if (_guardando)
                  const LinearProgressIndicator(
                    color: Color(0xFF006B54),
                    backgroundColor: Colors.transparent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

