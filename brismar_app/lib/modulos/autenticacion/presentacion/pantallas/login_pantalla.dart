import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../nucleo/rutas/enrutador.dart';
import '../controladores/controlador_autenticacion.dart';
import '../componentes/formulario_login.dart';

/// Pantalla principal para el inicio de sesión en BRISMAR APP.
///
/// Ofrece un diseño premium con degradados marinos y esferas de luz
/// de fondo para emular el océano. Escucha los cambios del estado
/// de autenticación a través de Riverpod.
class LoginPantalla extends ConsumerStatefulWidget {
  /// Constructor constante para [LoginPantalla].
  const LoginPantalla({super.key});

  @override
  ConsumerState<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends ConsumerState<LoginPantalla> {
  @override
  Widget build(BuildContext context) {
    ref.listen<EstadoAutenticacion>(
      proveedorControladorAutenticacion,
      _escucharEstadoAutenticacion,
    );

    final estado = ref.watch(proveedorControladorAutenticacion);
    final estaCargando = estado is EstadoAutenticacionCargando;

    return Scaffold(
      body: Stack(
        children: [
          _construirFondoGradiente(),
          _construirEsferaBrillo(top: -100, left: -50, color: const Color(0x2200E5FF)),
          _construirEsferaBrillo(bottom: -150, right: -100, color: const Color(0x1B0D47A1)),
          const Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: FormularioLogin(),
            ),
          ),
          if (estaCargando) _construirOverlayCarga(),
        ],
      ),
    );
  }

  /// Construye un overlay oscuro con desenfoque mientras se conecta al servidor.
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
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00E5FF),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Escucha los cambios de estado de autenticación y reacciona.
  void _escucharEstadoAutenticacion(EstadoAutenticacion? anterior, EstadoAutenticacion siguiente) {
    if (siguiente is EstadoConfigurarPin) {
      // Primer login exitoso → configurar PIN obligatorio
      _mostrarSnack('Bienvenido: ${siguiente.usuario.nombreReal}', Colors.teal.shade600);
      const ConfigurarPinRoute().go(context);
    } else if (siguiente is EstadoAutenticacionAutenticado) {
      // Sesión existente restaurada → ir al Dashboard directamente
      const RegistroRoute().go(context);
    } else if (siguiente is EstadoAccesoRapidoRequerido) {
      // Periodo de gracia expiró → pantalla de acceso rápido
      AccesoRapidoRoute(preferencia: siguiente.preferencia.toStorageString()).go(context);
    } else if (siguiente is EstadoAutenticacionError) {
      _mostrarSnack(siguiente.mensaje, Colors.redAccent.shade700);
    }
  }

  /// Muestra un mensaje en un SnackBar con estilo premium.
  void _mostrarSnack(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Construye el fondo degradado principal de la pantalla.
  Widget _construirFondoGradiente() {
    return Container(
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
    );
  }

  /// Genera una esfera decorativa de brillo de fondo para la interfaz premium.
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

