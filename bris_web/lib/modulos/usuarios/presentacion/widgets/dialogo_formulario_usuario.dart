import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../dominio/modelos/usuario_admin_modelo.dart';
import '../controladores/controlador_usuarios.dart';
import '../../infraestructura/servicios/servicio_dni.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';
import 'package:bris_web/nucleo/constantes/app_constants.dart';

class DialogoFormularioUsuario extends ConsumerStatefulWidget {
  final UsuarioAdminModelo? usuarioAEditar;

  const DialogoFormularioUsuario({super.key, this.usuarioAEditar});

  @override
  ConsumerState<DialogoFormularioUsuario> createState() =>
      _DialogoFormularioUsuarioState();
}

class _DialogoFormularioUsuarioState
    extends ConsumerState<DialogoFormularioUsuario>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dniCtrl;
  late TextEditingController _nombresCtrl;
  late TextEditingController _apellidoPaternoCtrl;
  late TextEditingController _apellidoMaternoCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _nombreCtrl;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  String _rolSeleccionado = 'empleado';
  String _sedeSeleccionada = 'paita';
  bool _buscandoDNI = false;
  bool _ocultarPassword = true;
  String? _mensajeError;

  final _servicioDNI = ServicioDNI();

  DateTime? _fechaNacimientoSeleccionada;
  String? _fotoPerfilUrl;
  Uint8List? _fotoBytes;
  String? _fotoExtension;

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

    final u = widget.usuarioAEditar;

    _dniCtrl = TextEditingController(text: u?.dni ?? '');
    _nombresCtrl = TextEditingController();
    _apellidoPaternoCtrl = TextEditingController();
    _apellidoMaternoCtrl = TextEditingController();
    _correoCtrl = TextEditingController(text: u?.correo ?? '');
    _passwordCtrl = TextEditingController();
    _nombreCtrl = TextEditingController(text: u?.nombre ?? '');

    if (u != null) {
      _correoCtrl.text = u.correo;
      _nombreCtrl.text = u.nombre;
      if ([
        'empleado',
        'administrador',
        'bahia',
        'supervisor',
      ].contains(u.rol)) {
        _rolSeleccionado = u.rol;
      }
      if (AppConstants.sedesValidas.contains(u.sede)) {
        _sedeSeleccionada = u.sede;
      } else if (u.sede.isNotEmpty) {
        _sedeSeleccionada = AppConstants.sedePorDefecto;
      }
      _fechaNacimientoSeleccionada = u.fechaNacimiento;
      _fotoPerfilUrl = u.fotoPerfil;

      if (u.nombre.isNotEmpty) {
        final partes = u.nombre.split(' ');
        if (partes.isNotEmpty) _nombresCtrl.text = partes.first;
        if (partes.length > 1) _apellidoPaternoCtrl.text = partes[1];
        if (partes.length > 2) {
          _apellidoMaternoCtrl.text = partes.sublist(2).join(' ');
        }
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _dniCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidoPaternoCtrl.dispose();
    _apellidoMaternoCtrl.dispose();
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _cerrar() {
    _animController.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      final extension = imagen.name.split('.').last;

      setState(() {
        _fotoBytes = bytes;
        _fotoExtension = extension;
      });
    }
  }

  String _quitarAcentos(String texto) {
    const conAcento = 'áéíóúÁÉÍÓÚñÑüÜ';
    const sinAcento = 'aeiouAEIOUnNuu';
    for (int i = 0; i < conAcento.length; i++) {
      texto = texto.replaceAll(conAcento[i], sinAcento[i]);
    }
    return texto;
  }

  void _generarCorreoCorporativo(
    String nombres,
    String apellidoPaterno,
    String apellidoMaterno,
  ) {
    if (nombres.isEmpty || apellidoPaterno.isEmpty) return;

    final partesNombres = nombres.trim().split(RegExp(r'\s+'));
    String inicialesNombres = '';
    for (var nombre in partesNombres) {
      if (nombre.isNotEmpty) {
        inicialesNombres += nombre.substring(0, 1);
      }
    }

    final apellidoPat = apellidoPaterno.trim().split(RegExp(r'\s+')).first;
    final inicialMat = apellidoMaterno.trim().isNotEmpty
        ? apellidoMaterno.trim().substring(0, 1)
        : '';
    final prefijoBase = _quitarAcentos(
      '$inicialesNombres$apellidoPat$inicialMat',
    ).toLowerCase();

    String correoFinal = '$prefijoBase@brismar.com.pe';

    final usuariosActuales = ref.read(controladorUsuariosProvider).usuarios;
    int contador = 1;
    while (usuariosActuales.any((u) => u.correo == correoFinal)) {
      correoFinal = '$prefijoBase$contador@brismar.com.pe';
      contador++;
    }

    setState(() {
      _correoCtrl.text = correoFinal;
      _mensajeError = null;
    });
  }

  void _autogenerarPassword() {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!@#\$%^&*';
    Random rnd = Random();
    String newPassword = String.fromCharCodes(
      Iterable.generate(12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    setState(() {
      _passwordCtrl.text = newPassword;
      _ocultarPassword = false;
      _mensajeError = null;
    });
  }

  void _mostrarErrorInline(String mensaje) {
    setState(() {
      _mensajeError = mensaje;
    });
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarErrorInline('Revisa los campos requeridos marcados en rojo.');
      return;
    }

    if (widget.usuarioAEditar == null && _passwordCtrl.text.length < 6) {
      _mostrarErrorInline('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (widget.usuarioAEditar != null &&
        _passwordCtrl.text.isNotEmpty &&
        _passwordCtrl.text.length < 6) {
      _mostrarErrorInline(
        'La nueva contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    final usuariosActuales = ref.read(controladorUsuariosProvider).usuarios;
    final dniDuplicado = usuariosActuales.any((u) => u.dni == _dniCtrl.text.trim() && u.uid != widget.usuarioAEditar?.uid);
    if (dniDuplicado) {
      _mostrarErrorInline('Este DNI ya se encuentra registrado en otro usuario.');
      return;
    }

    setState(() {
      _mensajeError = null;
    });

    final ctrl = ref.read(controladorUsuariosProvider.notifier);

    // Subir foto si existe
    String? fotoFinalUrl = _fotoPerfilUrl;
    if (_fotoBytes != null && _fotoExtension != null) {
      final nuevaUrl = await ctrl.subirAvatar(_fotoBytes, _fotoExtension!);
      if (nuevaUrl != null) {
        fotoFinalUrl = nuevaUrl;
      } else {
        _mostrarErrorInline('Error al subir la foto de perfil.');
        return;
      }
    }

    final usuario = UsuarioAdminModelo(
      uid: widget.usuarioAEditar?.uid ?? '',
      dni: _dniCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      rol: _rolSeleccionado,
      sede: _sedeSeleccionada,
      activo: widget.usuarioAEditar?.activo ?? true,
      fotoPerfil: fotoFinalUrl,
      fechaNacimiento: _fechaNacimientoSeleccionada,
    );

    bool exito;

    if (widget.usuarioAEditar == null) {
      exito = await ctrl.crearUsuario(usuario, _passwordCtrl.text);
    } else {
      exito = await ctrl.actualizarUsuario(
        usuario,
        nuevaPassword: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
      );
    }

    if (!mounted) return;

    if (exito) {
      _cerrar();
    } else {
      String errorServer =
          ref.read(controladorUsuariosProvider).error ?? 'Error desconocido';

      // Traducción de errores comunes de Supabase
      if (errorServer.contains('already been registered') ||
          errorServer.contains(
            'duplicate key value violates unique constraint',
          )) {
        errorServer =
            'Este correo corporativo ya se encuentra registrado en el sistema. Intenta generar uno distinto.';
      } else if (errorServer.contains('invalid format') ||
          errorServer.contains('Unable to validate email address')) {
        errorServer =
            'El formato del correo electrónico proporcionado es inválido.';
      } else if (errorServer.contains('Invalid login credentials')) {
        errorServer = 'Credenciales inválidas. Verifica los datos ingresados.';
      } else if (errorServer.contains('weak_password')) {
        errorServer =
            'La contraseña es muy débil. Debe contener al menos 6 caracteres y ser más compleja.';
      } else if (errorServer.contains('Failed to create user')) {
        errorServer =
            'Hubo un problema de conexión al registrar la cuenta. Reintente en un momento.';
      }

      _mostrarErrorInline(errorServer);
    }
  }

  Future<void> _buscarDNI() async {
    final dni = _dniCtrl.text.trim();
    if (dni.length != 8) {
      _mostrarErrorInline('El DNI debe tener exactamente 8 dígitos.');
      return;
    }

    setState(() {
      _buscandoDNI = true;
      _mensajeError = null;
    });

    try {
      final datosDNI = await _servicioDNI.consultarDNI(dni);
      setState(() {
        _nombreCtrl.text = datosDNI['nombreCompleto']!;
      });
      _generarCorreoCorporativo(
        datosDNI['nombres']!,
        datosDNI['apellidoPaterno']!,
        datosDNI['apellidoMaterno']!,
      );
    } catch (e) {
      _mostrarErrorInline(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _buscandoDNI = false);
      }
    }
  }

  Widget _construirCampoAbs({
    required String etiqueta,
    required TextEditingController controller,
    bool esPassword = false,
    bool requerido = true,
    bool readOnly = false,
    Widget? suffixIcon,
    String? Function(String?)? validadorPersonalizado,
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
            obscureText: esPassword ? _ocultarPassword : false,
            readOnly: readOnly,
            style: GoogleFonts.inter(
              color: readOnly
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF15181A),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
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
              suffixIcon: esPassword
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.password,
                            color: Color(0xFF7EBFC9),
                            size: 18,
                          ),
                          onPressed: _autogenerarPassword,
                        ),
                        IconButton(
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF64748B),
                            size: 18,
                          ),
                          onPressed: () => setState(
                            () => _ocultarPassword = !_ocultarPassword,
                          ),
                        ),
                      ],
                    )
                  : suffixIcon,
            ),
            validator:
                validadorPersonalizado ??
                (requerido
                    ? (v) => v!.trim().isEmpty ? 'Requerido' : null
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _construirBannerError() {
    if (_mensajeError == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _mensajeError!,
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(controladorUsuariosProvider);
    final esEdicion = widget.usuarioAEditar != null;
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esMovil = anchoPantalla < 550;

    return Stack(
      children: [
        GestureDetector(
          onTap: _cerrar,
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
                            esEdicion ? 'Actualizar Perfil' : 'Nuevo Registro',
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
                              _construirBannerError(),

                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: const Color(0xFF1E2336),
                                      backgroundImage: _fotoBytes != null
                                          ? MemoryImage(_fotoBytes!)
                                          : (_fotoPerfilUrl != null
                                                ? NetworkImage(_fotoPerfilUrl!)
                                                      as ImageProvider
                                                : null),
                                      child:
                                          (_fotoBytes == null &&
                                              _fotoPerfilUrl == null)
                                          ? const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Color(0xFF64748B),
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _seleccionarFoto,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF7EBFC9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 16,
                                            color: Color(0xFF070E22),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              esMovil
                                  ? Column(
                                      children: [
                                        _construirCampoAbs(
                                          etiqueta: 'DNI',
                                          controller: _dniCtrl,
                                          readOnly: esEdicion,
                                          suffixIcon: IconButton(
                                            icon: _buscandoDNI
                                                ? const CargaOrbital(tamano: 14)
                                                : const Icon(
                                                    Icons.manage_search,
                                                    color: Color(0xFF7EBFC9),
                                                    size: 20,
                                                  ),
                                            onPressed: _buscandoDNI || esEdicion
                                                ? null
                                                : _buscarDNI,
                                          ),
                                        ),
                                        _construirCampoRol(),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _construirCampoAbs(
                                            etiqueta: 'DNI',
                                            controller: _dniCtrl,
                                            readOnly: esEdicion,
                                            suffixIcon: IconButton(
                                              icon: _buscandoDNI
                                                  ? const CargaOrbital(
                                                      tamano: 14,
                                                    )
                                                  : const Icon(
                                                      Icons.manage_search,
                                                      color: Color(0xFF7EBFC9),
                                                      size: 20,
                                                    ),
                                              onPressed:
                                                  _buscandoDNI || esEdicion
                                                  ? null
                                                  : _buscarDNI,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          flex: 3,
                                          child: _construirCampoRol(),
                                        ),
                                      ],
                                    ),

                              _construirCampoAbs(
                                etiqueta: 'Nombre Completo',
                                controller: _nombreCtrl,
                                readOnly: esEdicion,
                              ),
                              _construirCampoAbs(
                                etiqueta: 'Correo Corporativo',
                                controller: _correoCtrl,
                                validadorPersonalizado: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Requerido';
                                  }
                                  final correo = v.trim();

                                  // Validar formato general de correo electrónico.
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(correo)) {
                                    return 'Formato de correo inválido (ej: usuario@empresa.com)';
                                  }

                                  // Restricción de dominio corporativo (configurable en AppConstants).
                                  if (AppConstants.soloDominioCorporativo &&
                                      !correo.endsWith(AppConstants.dominioCorporativo)) {
                                    return 'Solo se permite el dominio corporativo (${AppConstants.dominioCorporativo})';
                                  }

                                  return null;
                                },
                              ),

                              esMovil
                                  ? Column(
                                      children: [
                                        _construirCampoAbs(
                                          etiqueta: esEdicion
                                              ? 'Reemplazar Contraseña'
                                              : 'Clave de Acceso',
                                          controller: _passwordCtrl,
                                          esPassword: true,
                                          requerido: !esEdicion,
                                        ),
                                        _construirCampoSede(),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _construirCampoAbs(
                                            etiqueta: esEdicion
                                                ? 'Reemplazar Contraseña'
                                                : 'Clave de Acceso',
                                            controller: _passwordCtrl,
                                            esPassword: true,
                                            requerido: !esEdicion,
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(child: _construirCampoSede()),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer actions
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: estado.cargando ? null : _cerrar,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0E3E2C),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Descartar',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: estado.cargando ? null : _guardar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF15181A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: estado.cargando
                                  ? const CargaOrbital(tamano: 20)
                                  : Text(
                                      esEdicion
                                          ? 'Confirmar Cambios'
                                          : 'Registrar Nuevo',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                        ],
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

  Widget _construirCampoRol() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROL ASIGNADO',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _rolSeleccionado,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            style: GoogleFonts.inter(
              color: const Color(0xFF15181A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
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
            ),
            items: ['empleado', 'administrador', 'bahia', 'supervisor'].map((
              rol,
            ) {
              return DropdownMenuItem(
                value: rol,
                child: Text(rol.toUpperCase()),
              );
            }).toList(),
            onChanged: (v) => setState(() => _rolSeleccionado = v!),
          ),
        ],
      ),
    );
  }

  Widget _construirCampoSede() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SEDE DE OPERACIÓN',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _sedeSeleccionada,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            style: GoogleFonts.inter(
              color: const Color(0xFF15181A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
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
            ),
            items: ['paita', 'piura', 'lambayeque'].map((sede) {
              final sedeMayuscula = sede[0].toUpperCase() + sede.substring(1);
              return DropdownMenuItem(value: sede, child: Text(sedeMayuscula));
            }).toList(),
            onChanged: (v) => setState(() => _sedeSeleccionada = v!),
          ),
        ],
      ),
    );
  }
}
