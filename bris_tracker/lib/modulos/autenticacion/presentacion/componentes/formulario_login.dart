import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controladores/controlador_autenticacion.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';

// ── Providers reactivos (file-private) ───────────────────────────────────────

/// Lee la versión real del paquete desde el sistema operativo.
///
/// Al ser [FutureProvider.autoDispose] se libera cuando el widget
/// se desmonta y no produce el flash de 'v---'.
final _versionAppProvider = FutureProvider.autoDispose<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return 'v${info.version}';
});

/// Emite el estado de conectividad en tiempo real.
///
/// [StreamProvider.autoDispose] gestiona el ciclo de vida del stream
/// sin requerir [StreamSubscription] ni [dispose] manuales.
final _conectividadProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield _esConectado(initial);
  await for (final result in connectivity.onConnectivityChanged) {
    yield _esConectado(result);
  }
});

/// Devuelve `true` si al menos un resultado indica conexión activa.
bool _esConectado(List<ConnectivityResult> result) =>
    result.isNotEmpty && !result.contains(ConnectivityResult.none);

// ── Widget principal ──────────────────────────────────────────────────────────

/// Formulario de inicio de sesión modular y responsivo para BRISMAR APP.
///
/// Adapta tamanos de texto, campos y espaciados según el ancho disponible
/// usando [LayoutBuilder] para cubrir móvil, tablet y escritorio.
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
  bool _passwordObscuro = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Valida el formulario e invoca el caso de uso de autenticación.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final escala = _calcularEscala(constraints.maxWidth);
        return Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: escala.paddingH),
            child: _construirContenido(estaCargando, escala),
          ),
        );
      },
    );
  }

  // ── Construcción del contenido ─────────────────────────────────────────────

  /// Apila todos los elementos del formulario con espaciados escalados.
  Widget _construirContenido(bool estaCargando, _Escala e) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _construirLogo(e)),
        SizedBox(height: e.espacioMedio),
        _construirTitulo(e),
        SizedBox(height: e.espacioMedio),
        _construirSeparador(),
        SizedBox(height: e.espacioGrande),
        _construirEtiqueta('USUARIO', e),
        SizedBox(height: e.espacioChico),
        _construirCampoUsuario(estaCargando, e),
        SizedBox(height: e.espacioMedio),
        _construirEtiqueta('CONTRASEÑA', e),
        SizedBox(height: e.espacioChico),
        _construirCampoContrasena(estaCargando, e),
        SizedBox(height: e.espacioChico),
        _construirBotonOlvido(estaCargando, e),
        SizedBox(height: e.espacioGrande),
        _construirBotonLogin(estaCargando, e),
        SizedBox(height: e.espacioGrande),
        _construirIndicadores(e),
      ],
    );
  }

  // ── Logo ───────────────────────────────────────────────────────────────────

  /// Logo con tamano escalado según el ancho disponible.
  Widget _construirLogo(_Escala e) {
    return Container(
      width: e.anchoLogo,
      height: e.altoLogo,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(e.radiusLogo),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(e.radiusLogo),
        child: Padding(
          padding: EdgeInsets.all(e.paddingLogo * 0.5),
          child: Transform.scale(
            scale: 1.8,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.directions_boat_rounded,
                size: e.anchoLogo * 0.35,
                color: const Color(0xFF0077C2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Título y separador ─────────────────────────────────────────────────────

  /// Título "BRIS GROUP" y subtítulo del sistema escalados.
  Widget _construirTitulo(_Escala e) {
    return Column(
      children: [
        Text(
          'BRIS GROUP',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: e.fuenteTitulo,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: e.espacioChico * 0.5),
        Text(
          'SISTEMA DE REGISTRO · BAHÍA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF00E5FF),
            fontSize: e.fuenteSubtitulo,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  /// Divisor decorativo central con punto cyan.
  Widget _construirSeparador() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
        ),
        const SizedBox(width: 10),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFF00E5FF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
        ),
      ],
    );
  }

  // ── Etiquetas de campo ─────────────────────────────────────────────────────

  /// Etiqueta superior con color cyan escalada.
  Widget _construirEtiqueta(String texto, _Escala e) {
    return Text(
      texto,
      style: TextStyle(
        color: const Color(0xFF00E5FF),
        fontSize: e.fuenteEtiqueta,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
      ),
    );
  }

  // ── Campos de entrada ──────────────────────────────────────────────────────

  /// Decoración uniforme escalada para todos los campos de texto.
  InputDecoration _disenoInput({
    required String hint,
    required IconData icon,
    required _Escala e,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.25),
        fontSize: e.fuenteCampo,
        letterSpacing: 0.5,
      ),
      filled: true,
      fillColor: const Color(0xFF070E22),
      prefixIcon: Icon(icon, color: Colors.white38, size: e.iconoCampo),
      suffixIcon: suffix,
      contentPadding: EdgeInsets.symmetric(
        vertical: e.paddingCampoV,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(e.radiusCampo),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(e.radiusCampo),
        borderSide: const BorderSide(color: Color(0xFF1C2A54)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(e.radiusCampo),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(e.radiusCampo),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(e.radiusCampo),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
      errorStyle: TextStyle(
        color: Colors.orangeAccent,
        fontSize: e.fuenteEtiqueta,
      ),
    );
  }

  /// Campo de texto para el nombre de usuario.
  Widget _construirCampoUsuario(bool estaCargando, _Escala e) {
    return TextFormField(
      controller: _userController,
      enabled: !estaCargando,
      keyboardType: TextInputType.emailAddress,
      enableSuggestions: false,
      autocorrect: false,
      style: TextStyle(color: Colors.white, fontSize: e.fuenteCampo),
      decoration: _disenoInput(
        hint: 'Ingresa tu usuario',
        icon: Icons.person_outline_rounded,
        e: e,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, ingrese su usuario';
        }
        return null;
      },
    );
  }

  /// Campo de texto para la contraseña con toggle de visibilidad.
  Widget _construirCampoContrasena(bool estaCargando, _Escala e) {
    return TextFormField(
      controller: _passController,
      obscureText: _passwordObscuro,
      enabled: !estaCargando,
      enableSuggestions: false,
      autocorrect: false,
      style: TextStyle(color: Colors.white, fontSize: e.fuenteCampo),
      decoration: _disenoInput(
        hint: '• • • • • • • •',
        icon: Icons.lock_outline_rounded,
        e: e,
        suffix: _construirTogglePassword(e),
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

  /// Botón de ojo para alternar visibilidad de la contraseña.
  Widget _construirTogglePassword(_Escala e) {
    return IconButton(
      icon: Icon(
        _passwordObscuro
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: Colors.white38,
        size: e.iconoCampo,
      ),
      onPressed: () => setState(() => _passwordObscuro = !_passwordObscuro),
    );
  }

  // ── Botones ────────────────────────────────────────────────────────────────

  /// Enlace "¿Olvidaste tu contraseña?" alineado a la derecha.
  Widget _construirBotonOlvido(bool estaCargando, _Escala e) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: estaCargando ? null : () {},
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              color: const Color(0xFF00E5FF),
              fontSize: e.fuenteEtiqueta,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Botón principal de login con degradado y efecto de splash.
  Widget _construirBotonLogin(bool estaCargando, _Escala e) {
    return Container(
      width: double.infinity,
      height: e.altoBoton,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(e.radiusCampo),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0077C2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(e.radiusCampo),
        child: InkWell(
          onTap: estaCargando ? null : _intentarLogin,
          splashColor: Colors.white24,
          child: Center(
            child: estaCargando
                ? SizedBox(
                    width: e.altoBoton * 0.42,
                    height: e.altoBoton * 0.42,
                    child: const CargaOrbital(tamano: 80),
                  )
                : Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                      fontSize: e.fuenteBoton,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Indicadores inferiores ─────────────────────────────────────────────────

  /// Fila inferior con el indicador de red reactivo y la versión de la app.
  ///
  /// La versión se obtiene de [_versionAppProvider] y solo aparece cuando
  /// ya está disponible — sin flash de placeholder.
  Widget _construirIndicadores(_Escala e) {
    final versionAsync = ref.watch(_versionAppProvider);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _construirRadarConexion(e),
            versionAsync.when(
              data: (version) => Text(
                version,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: e.fuenteEtiqueta,
                  fontWeight: FontWeight.w500,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: e.espacioGrande),
        Text(
          'Sistema protegido · Brismar © 2026',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.2),
            fontSize: e.fuenteEtiqueta * 0.9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// LED + etiqueta ONLINE/OFFLINE basados en [_conectividadProvider].
  ///
  /// Se actualiza automáticamente sin [StreamSubscription] manual.
  Widget _construirRadarConexion(_Escala e) {
    final conectividadAsync = ref.watch(_conectividadProvider);
    final hayConexion = conectividadAsync.valueOrNull ?? true;
    final color = hayConexion
        ? const Color(0xFF00E676)
        : const Color(0xFFFF1744);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: e.tamanoLed,
          height: e.tamanoLed,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 7,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        SizedBox(width: e.espacioChico),
        Text(
          hayConexion ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            color: color,
            fontSize: e.fuenteEtiqueta,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  // ── Escala responsiva ──────────────────────────────────────────────────────

  /// Calcula todos los valores escalados en función del ancho disponible.
  _Escala _calcularEscala(double ancho) => _Escala.desde(ancho);
}

// ── Modelo de escala ──────────────────────────────────────────────────────────

/// Encapsula todos los valores de tamano y espaciado responsivos.
///
/// Se calcula una sola vez por rebuild usando el ancho del [LayoutBuilder].
final class _Escala {
  const _Escala({
    required this.paddingH,
    required this.anchoLogo,
    required this.altoLogo,
    required this.paddingLogo,
    required this.radiusLogo,
    required this.fuenteTitulo,
    required this.fuenteSubtitulo,
    required this.fuenteEtiqueta,
    required this.fuenteCampo,
    required this.fuenteBoton,
    required this.iconoCampo,
    required this.paddingCampoV,
    required this.radiusCampo,
    required this.altoBoton,
    required this.tamanoLed,
    required this.espacioChico,
    required this.espacioMedio,
    required this.espacioGrande,
  });

  final double paddingH;
  final double anchoLogo;
  final double altoLogo;
  final double paddingLogo;
  final double radiusLogo;
  final double fuenteTitulo;
  final double fuenteSubtitulo;
  final double fuenteEtiqueta;
  final double fuenteCampo;
  final double fuenteBoton;
  final double iconoCampo;
  final double paddingCampoV;
  final double radiusCampo;
  final double altoBoton;
  final double tamanoLed;
  final double espacioChico;
  final double espacioMedio;
  final double espacioGrande;

  /// Factory que genera la escala correcta según el ancho de pantalla.
  ///
  /// Breakpoints:
  /// - **< 360 px**: pantallas muy pequeñas (valores mínimos)
  /// - **360–599 px**: móviles estándar
  /// - **≥ 600 px**: tablets y escritorio
  factory _Escala.desde(double ancho) {
    if (ancho >= 600) {
      return const _Escala(
        paddingH: 36,
        anchoLogo: 180,
        altoLogo: 104,
        paddingLogo: 14,
        radiusLogo: 20,
        fuenteTitulo: 22,
        fuenteSubtitulo: 13,
        fuenteEtiqueta: 12,
        fuenteCampo: 16,
        fuenteBoton: 16,
        iconoCampo: 22,
        paddingCampoV: 20,
        radiusCampo: 14,
        altoBoton: 60,
        tamanoLed: 10,
        espacioChico: 10,
        espacioMedio: 28,
        espacioGrande: 36,
      );
    } else if (ancho >= 360) {
      return const _Escala(
        paddingH: 28,
        anchoLogo: 150,
        altoLogo: 88,
        paddingLogo: 12,
        radiusLogo: 18,
        fuenteTitulo: 18,
        fuenteSubtitulo: 11,
        fuenteEtiqueta: 11,
        fuenteCampo: 14,
        fuenteBoton: 14,
        iconoCampo: 19,
        paddingCampoV: 17,
        radiusCampo: 12,
        altoBoton: 54,
        tamanoLed: 9,
        espacioChico: 8,
        espacioMedio: 22,
        espacioGrande: 30,
      );
    } else {
      return const _Escala(
        paddingH: 20,
        anchoLogo: 120,
        altoLogo: 72,
        paddingLogo: 10,
        radiusLogo: 14,
        fuenteTitulo: 16,
        fuenteSubtitulo: 10,
        fuenteEtiqueta: 10,
        fuenteCampo: 13,
        fuenteBoton: 13,
        iconoCampo: 17,
        paddingCampoV: 14,
        radiusCampo: 10,
        altoBoton: 48,
        tamanoLed: 8,
        espacioChico: 6,
        espacioMedio: 18,
        espacioGrande: 24,
      );
    }
  }
}
