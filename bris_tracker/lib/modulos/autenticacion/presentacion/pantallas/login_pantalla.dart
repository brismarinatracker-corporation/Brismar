import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controladores/controlador_autenticacion.dart';
import '../componentes/formulario_login.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';

/// Pantalla principal de inicio de sesión en BRISMAR APP.
///
/// Diseño completamente responsivo: adapta el ancho del formulario
/// según el tamano disponible usando [LayoutBuilder].
/// En tablets/escritorio limita el card a 480 px y lo centra.
class LoginPantalla extends ConsumerStatefulWidget {
  /// Constructor constante para [LoginPantalla].
  const LoginPantalla({super.key});

  @override
  ConsumerState<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends ConsumerState<LoginPantalla> {
  // ── Constantes de breakpoints ──────────────────────────────────────────────
  static const double _anchoMaximoFormulario = 480.0;
  static const double _breakpointTablet = 600.0;

  @override
  void initState() {
    super.initState();
    _initScreenProtector();
  }

  Future<void> _initScreenProtector() async {
    if (!kIsWeb) {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageOn();
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      ScreenProtector.preventScreenshotOff();
      ScreenProtector.protectDataLeakageOff();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EstadoAutenticacion>(
      proveedorControladorAutenticacion,
      _escucharEstadoAutenticacion,
    );

    final estado = ref.watch(proveedorControladorAutenticacion);
    final estaCargando = estado is EstadoAutenticacionCargando;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _construirFondoGradiente(),
          _construirEsferaBrillo(
            top: -100,
            left: -50,
            color: const Color(0x2200E5FF),
          ),
          _construirEsferaBrillo(
            bottom: -150,
            right: -100,
            color: const Color(0x1B0D47A1),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _construirContenidoResponsivo(constraints);
              },
            ),
          ),
          if (estaCargando) _construirOverlayCarga(),
        ],
      ),
    );
  }

  /// Decide el layout según el ancho disponible:
  /// - **Móvil** (< 600 px): formulario a ancho completo con padding lateral.
  /// - **Tablet / escritorio** (≥ 600 px): card centrado de 480 px máximo.
  Widget _construirContenidoResponsivo(BoxConstraints constraints) {
    final esTablet = constraints.maxWidth >= _breakpointTablet;
    final anchoFormulario = esTablet
        ? _anchoMaximoFormulario
        : constraints.maxWidth;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: esTablet ? 48.0 : 24.0),
        child: SizedBox(
          width: anchoFormulario,
          child: esTablet
              ? _envolverEnCard(child: const FormularioLogin())
              : const FormularioLogin(),
        ),
      ),
    );
  }

  /// En tablet/escritorio envuelve el formulario en un card con glassmorphism.
  Widget _envolverEnCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C1D3F).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
          child: child,
        ),
      ),
    );
  }

  /// Overlay animado de carga con desenfoque de fondo.
  Widget _construirOverlayCarga() {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, val, child) {
          return Opacity(
            opacity: val,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5 * val, sigmaY: 5 * val),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4 * val),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CargaOrbital(tamano: 100),
                      const SizedBox(height: 32),
                      Text(
                        'Conectando con Supabase...',
                        style: TextStyle(
                          color: const Color(0xFF00E5FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Escucha cambios de estado y muestra feedback visual al usuario.
  ///
  /// La navegación la maneja exclusivamente el [enrutadorProvider] mediante
  /// redirect declarativo. Aquí solo mostramos snackbars informativos.
  void _escucharEstadoAutenticacion(
    EstadoAutenticacion? anterior,
    EstadoAutenticacion siguiente,
  ) {
    if (siguiente is EstadoConfigurarPin) {
      _mostrarSnack(
        'Bienvenido, ${siguiente.usuario.nombreReal.split(' ').first} 👋',
        Colors.teal.shade600,
      );
    } else if (siguiente is EstadoAutenticacionError) {
      _mostrarSnack(siguiente.mensaje, Colors.redAccent.shade700);
    }
  }

  /// SnackBar flotante con estilo premium.
  void _mostrarSnack(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Fondo degradado marino principal.
  Widget _construirFondoGradiente() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF040B1E), Color(0xFF0C1D3F), Color(0xFF143068)],
        ),
      ),
    );
  }

  /// Esfera de brillo decorativa posicionada en el fondo.
  Widget _construirEsferaBrillo({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 120,
              spreadRadius: 60,
            ),
          ],
        ),
      ),
    );
  }
}
