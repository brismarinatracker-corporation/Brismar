import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controladores/controlador_autenticacion.dart';

/// Componente modular que representa el formulario de inicio de sesión.
///
/// Adaptado exactamente al diseño de la imagen del cliente.
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: _construirFormularioContenido(estaCargando),
      ),
    );
  }

  /// Construye los widgets internos ordenados verticalmente.
  Widget _construirFormularioContenido(bool estaCargando) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _construirLogo()),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'BRIS GROUP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'SISTEMA DE REGISTRO · BAHÍA',
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Separador con el punto cyan
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1), height: 1)),
            const SizedBox(width: 8),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF00E5FF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1), height: 1)),
          ],
        ),
        const SizedBox(height: 28),
        // Etiqueta Usuario
        const Text(
          'USUARIO',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _construirCampoUsuario(estaCargando),
        const SizedBox(height: 20),
        // Etiqueta Contraseña
        const Text(
          'CONTRASEÑA',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _construirCampoContrasena(estaCargando),
        const SizedBox(height: 10),
        _construirBotonOlvido(estaCargando),
        const SizedBox(height: 24),
        _construirBotonLogin(estaCargando),
        const SizedBox(height: 35),
        _construirIndicadores(),
      ],
    );
  }

  /// Construye el logo con bordes redondeados exactos.
  Widget _construirLogo() {
    return Container(
      width: 140,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
        color: Colors.white.withValues(alpha: 0.25),
        fontSize: 13,
        letterSpacing: 0.5,
      ),
      filled: true,
      fillColor: const Color(0xFF070E22), // Fondo oscuro idéntico a la imagen
      prefixIcon: Icon(icon, color: Colors.white38, size: 18),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)), // Borde azul oscuro uniforme
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
    );
  }

  /// Construye el campo de entrada para el usuario.
  Widget _construirCampoUsuario(bool estaCargando) {
    return TextFormField(
      controller: _userController,
      enabled: !estaCargando,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _disenoInput(
        hint: 'Ingresa tu usuario',
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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _disenoInput(
        hint: '........',
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
        color: Colors.white38,
        size: 18,
      ),
      onPressed: () => setState(() => _passwordObscuro = !_passwordObscuro),
    );
  }

  /// Crea el botón de recuperar contraseña.
  Widget _construirBotonOlvido(bool estaCargando) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: estaCargando ? null : () {},
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0077C2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
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
                      letterSpacing: 1.2,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _construirRadarConexion(),
            Text(
              _appVersion,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 35),
        Text(
          'Sistema protegido · Brismar © 2026',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.2),
            fontSize: 11,
            letterSpacing: 0.5,
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
