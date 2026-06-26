import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/entidades/preferencia_acceso.dart';
import '../controladores/controlador_autenticacion.dart';
import '../../../../nucleo/rutas/enrutador.dart';

/// Pantalla para configurar la huella digital como acceso rápido (opcional).
///
/// Corresponde a [Task_SetupBiometrics] del FLUJO_01_AUTENTICACION.bpmn.
/// El usuario puede configurar la huella o saltar esta etapa.
class ConfigurarBiometriaPantalla extends ConsumerWidget {
  /// Constructor constante de [ConfigurarBiometriaPantalla].
  const ConfigurarBiometriaPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<EstadoAutenticacion>(
      proveedorControladorAutenticacion,
      (_, siguiente) => _escucharEstado(context, siguiente),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF040B1E), Color(0xFF0C1D3F), Color(0xFF143068)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _construirIconoBiometria(),
                const SizedBox(height: 32),
                _construirTextos(),
                const SizedBox(height: 56),
                _construirBotonActivar(ref),
                const SizedBox(height: 16),
                _construirBotonOmitir(ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el ícono animado de huella digital.
  Widget _construirIconoBiometria() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
      ),
      child: const Icon(
        Icons.fingerprint,
        size: 64,
        color: Color(0xFF00E5FF),
      ),
    );
  }

  /// Construye el título y subtítulo de la pantalla.
  Widget _construirTextos() {
    return Column(
      children: [
        const Text(
          'Acceso con Huella',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Activa la huella digital para entrar a BRISMAR más rápido en el futuro. Siempre podrás usar tu PIN.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construye el botón para activar la huella como preferencia.
  Widget _construirBotonActivar(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: const Color(0xFF040B1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.fingerprint, size: 22),
        label: const Text(
          'Activar Huella Digital',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: () => _seleccionarPreferencia(ref, PreferenciaAcceso.huella),
      ),
    );
  }

  /// Construye el botón para omitir y usar solo PIN.
  Widget _construirBotonOmitir(WidgetRef ref) {
    return TextButton(
      onPressed: () => _seleccionarPreferencia(ref, PreferenciaAcceso.pin),
      child: Text(
        'Omitir, usaré solo mi PIN',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
    );
  }

  /// Guarda la preferencia de acceso y navega al Dashboard.
  void _seleccionarPreferencia(WidgetRef ref, PreferenciaAcceso preferencia) {
    ref
        .read(proveedorControladorAutenticacion.notifier)
        .configurarBiometria(preferencia);
  }

  /// Escucha el estado y navega al Dashboard cuando la autenticación es exitosa.
  void _escucharEstado(BuildContext context, EstadoAutenticacion siguiente) {
    if (siguiente is EstadoAutenticacionAutenticado) {
      RegistroRoute().go(context);
    }
  }
}
