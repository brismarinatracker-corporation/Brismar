import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../dominio/entidades/preferencia_acceso.dart';
import '../controladores/controlador_autenticacion.dart';
import 'package:brismar_mobile/nucleo/componentes/carga_orbital.dart';

/// Pantalla para configurar la huella digital como acceso rápido (opcional).
///
/// Corresponde a [Task_SetupBiometrics] del FLUJO_01_AUTENTICACION.bpmn.
/// El usuario puede configurar la huella (verificando soporte) o saltar esta etapa.
class ConfigurarBiometriaPantalla extends ConsumerStatefulWidget {
  /// Constructor constante de [ConfigurarBiometriaPantalla].
  const ConfigurarBiometriaPantalla({super.key});

  @override
  ConsumerState<ConfigurarBiometriaPantalla> createState() =>
      _ConfigurarBiometriaPantallaState();
}

class _ConfigurarBiometriaPantallaState
    extends ConsumerState<ConfigurarBiometriaPantalla> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _verificando = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    ref.listen<EstadoAutenticacion>(
      proveedorControladorAutenticacion,
      _escucharEstado,
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
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _construirBotonActivar(),
                const SizedBox(height: 16),
                _construirBotonOmitir(),
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
      child: _verificando
          ? const Padding(
              padding: EdgeInsets.all(32.0),
              child: CargaOrbital(tamano: 80),
            )
          : const Icon(
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
  Widget _construirBotonActivar() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: const Color(0xFF040B1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.fingerprint, size: 22),
        label: Text(
          _verificando ? 'Verificando...' : 'Activar Huella Digital',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: _verificando ? null : _verificarYActivarHuella,
      ),
    );
  }

  /// Construye el botón para omitir y usar solo PIN.
  Widget _construirBotonOmitir() {
    return TextButton(
      onPressed: _verificando ? null : () => _seleccionarPreferencia(PreferenciaAcceso.pin),
      child: Text(
        'Omitir, usaré solo mi PIN',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
    );
  }

  /// Verifica soporte biométrico y exige autenticación antes de activar.
  Future<void> _verificarYActivarHuella() async {
    setState(() {
      _error = null;
      _verificando = true;
    });

    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isSupported) {
        setState(() {
          _error = 'Tu dispositivo no soporta biometría.';
          _verificando = false;
        });
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Confirma tu huella para activar el acceso rápido a BRISMAR.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _seleccionarPreferencia(PreferenciaAcceso.huella);
      } else {
        setState(() {
          _error = 'No se pudo verificar la huella. Intenta de nuevo.';
          _verificando = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al acceder al sensor biométrico.';
        _verificando = false;
      });
    }
  }

  /// Guarda la preferencia de acceso delegando al controlador.
  void _seleccionarPreferencia(PreferenciaAcceso preferencia) {
    ref
        .read(proveedorControladorAutenticacion.notifier)
        .configurarBiometria(preferencia);
  }

  /// Escucha el estado y reacciona a errores.
  void _escucharEstado(EstadoAutenticacion? _, EstadoAutenticacion siguiente) {
    if (siguiente is EstadoAutenticacionError) {
      setState(() {
        _error = siguiente.mensaje;
        _verificando = false;
      });
    }
  }
}
