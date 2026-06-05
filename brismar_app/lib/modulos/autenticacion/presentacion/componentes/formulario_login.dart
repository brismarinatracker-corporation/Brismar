import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controladores/controlador_autenticacion.dart';

/// Componente modular que representa el formulario de inicio de sesión.
///
/// Implementa un diseño premium con bordes semitransparentes, sombras,
/// y un indicador de red estilo LED. Su lógica respeta estrictamente SRP
/// y la limitación de 20 líneas por función.
class FormularioLogin extends ConsumerStatefulWidget {
  /// Constructor constante para [FormularioLogin].
  const FormularioLogin({super.key});

  @override
  ConsumerState<FormularioLogin> createState() => _FormularioLoginState();
}

class _FormularioLoginState extends ConsumerState<FormularioLogin> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  String _appVersion = 'v---';
  bool _hayConexion = true;
  bool _passwordObscuro = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initAppInfo();
  }

  /// Inicializa la información de la versión de la app y la conectividad.
  Future<void> _initAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${info.version}';
      });
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    _actualizarEstadoConexion(connectivityResult);
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_actualizarEstadoConexion);
  }

  /// Actualiza el estado local de conexión basándose en el resultado obtenido.
  void _actualizarEstadoConexion(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() {
        _hayConexion = !result.contains(ConnectivityResult.none) && result.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Intenta iniciar sesión leyendo los valores de los controladores.
  void _intentarLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(proveedorControladorAutenticacion.notifier)
          .iniciarSesion(
            _userController.text.trim(),
            _passController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(proveedorControladorAutenticacion);
    final estaCargando = estado is EstadoAutenticacionCargando;

    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFF0F224A).withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _construirFormularioContenido(estaCargando),
      ),
    );
  }

  /// Construye los widgets internos ordenados verticalmente.
  Widget _construirFormularioContenido(bool estaCargando) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _construirLogo(),
        const SizedBox(height: 28),
        _construirCampoUsuario(estaCargando),
        const SizedBox(height: 18),
        _construirCampoContrasena(estaCargando),
        _construirBotonOlvido(estaCargando),
        const SizedBox(height: 12),
        _construirBotonLogin(estaCargando),
        const SizedBox(height: 24),
        _construirIndicadores(),
      ],
    );
  }

  /// Construye el contenedor para el logo de Brismar con estilo limpio.
  Widget _construirLogo() {
    return Container(
      width: 130,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const Icon(
            Icons.directions_boat_rounded,
            size: 40,
            color: Color(0xFF0077C2),
          ),
        ),
      ),
    );
  }

  /// Crea la decoración uniforme para los campos de entrada de datos.
  InputDecoration _disenoInput({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 13,
        letterSpacing: 0.5,
      ),
      filled: true,
      fillColor: const Color(0xFF172C5C).withValues(alpha: 0.6),
      prefixIcon: Icon(icon, color: const Color(0xFF00E5FF), size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
    );
  }

  /// Construye el campo de entrada para el usuario.
  Widget _construirCampoUsuario(bool estaCargando) {
    return TextFormField(
      controller: _userController,
      enabled: !estaCargando,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: _disenoInput(
        hint: 'USUARIO O CORREO',
        icon: Icons.person_outline_rounded,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, ingrese su usuario';
        }
        return null;
      },
    );
  }

  /// Construye el campo de entrada para la contraseña con toggle.
  Widget _construirCampoContrasena(bool estaCargando) {
    return TextFormField(
      controller: _passController,
      obscureText: _passwordObscuro,
      enabled: !estaCargando,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: _disenoInput(
        hint: 'CONTRASEÑA',
        icon: Icons.lock_outline_rounded,
        suffix: _construirTogglePassword(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su contraseña';
        }
        if (value.length < 4) {
          return 'Mínimo 4 caracteres';
        }
        return null;
      },
    );
  }

  /// Genera el botón para alternar la visibilidad de la contraseña.
  Widget _construirTogglePassword() {
    return IconButton(
      icon: Icon(
        _passwordObscuro
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
        size: 20,
      ),
      onPressed: () => setState(() => _passwordObscuro = !_passwordObscuro),
    );
  }

  /// Crea el botón textual para recuperar contraseña.
  Widget _construirBotonOlvido(bool estaCargando) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: estaCargando ? null : () {},
        child: Text(
          '¿Olvidé mi contraseña?',
          style: TextStyle(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Construye el botón premium de inicio de sesión con degradado.
  Widget _construirBotonLogin(bool estaCargando) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0077C2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: estaCargando ? null : _intentarLogin,
          splashColor: Colors.white24,
          child: Center(
            child: estaCargando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Agrupa la sección inferior del indicador de red y la versión.
  Widget _construirIndicadores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _construirRadarConexion(),
        Text(
          _appVersion,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Construye un LED pulsante y etiqueta para el estado de red.
  Widget _construirRadarConexion() {
    final colorConexion = _hayConexion
        ? const Color(0xFF00E676)
        : const Color(0xFFFF1744);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorConexion,
            boxShadow: [
              BoxShadow(
                color: colorConexion.withValues(alpha: 0.6),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _hayConexion ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            color: colorConexion,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
