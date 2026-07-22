import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../dominio/entidades/preferencia_acceso.dart';
import '../controladores/controlador_autenticacion.dart';
import '../../../../nucleo/rutas/enrutador.dart';
import 'package:bris_tracker/nucleo/componentes/carga_orbital.dart';

/// Pantalla de acceso rápido diario cuando el periodo de gracia de 12h expiró.
///
/// Corresponde a [Gateway_QuickAccessType], [Task_InputPIN] y
/// [Task_ProvideBiometrics] del FLUJO_01_AUTENTICACION.bpmn.
/// Muestra PIN o Huella según la preferencia configurada.
class AccesoRapidoPantalla extends ConsumerStatefulWidget {
  /// Preferencia de acceso rápido del usuario (pin | huella).
  final PreferenciaAcceso preferencia;

  /// Constructor constante de [AccesoRapidoPantalla].
  const AccesoRapidoPantalla({super.key, required this.preferencia});

  @override
  ConsumerState<AccesoRapidoPantalla> createState() =>
      _AccesoRapidoPantallaState();
}

class _AccesoRapidoPantallaState extends ConsumerState<AccesoRapidoPantalla> {
  String _pinIngresado = '';
  String? _error;
  bool _usarPinTemporalmente = false;

  static const int _longitudPin = 4;

  @override
  void initState() {
    super.initState();
    if (widget.preferencia == PreferenciaAcceso.huella) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _iniciarBiometria());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EstadoAutenticacion>(
      proveedorControladorAutenticacion,
      _escucharEstado,
    );

    final mostrarPin =
        widget.preferencia == PreferenciaAcceso.pin || _usarPinTemporalmente;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        _construirCabecera(),
                        const SizedBox(height: 40),
                        mostrarPin
                            ? _construirVistaPin()
                            : _construirVistaBiometria(),
                        const Spacer(),
                        if (mostrarPin) _construirTecladoNumerico(),
                        const SizedBox(height: 16),
                        _construirBotonOlvidePin(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Construye el encabezado con saludo y nombre de la app.
  Widget _construirCabecera() {
    final mostrarPin =
        widget.preferencia == PreferenciaAcceso.pin || _usarPinTemporalmente;

    return Column(
      children: [
        mostrarPin
            ? const Icon(Icons.lock_outline, color: Color(0xFF00E5FF), size: 48)
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  height: 60,
                  width: 60,
                  child: Transform.scale(
                    scale: 1.8,
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                ),
              ),
        const SizedBox(height: 16),
        const Text(
          'Bienvenido de vuelta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mostrarPin
              ? 'Ingresa tu PIN de 4 dígitos'
              : 'Presenta tu huella digital',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Construye la vista de entrada de PIN con indicadores y teclado.
  Widget _construirVistaPin() {
    return Column(
      children: [
        _construirIndicadoresPIN(),
        const SizedBox(height: 16),
        _construirMensajeError(),
      ],
    );
  }

  /// Construye la vista de autenticación biométrica.
  Widget _construirVistaBiometria() {
    final estado = ref.watch(proveedorControladorAutenticacion);
    final cargando = estado is EstadoAutenticacionCargando;

    return Column(
      children: [
        GestureDetector(
          onTap: cargando ? null : _iniciarBiometria,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(
                0xFF00E5FF,
              ).withValues(alpha: cargando ? 0.03 : 0.1),
              border: Border.all(
                color: const Color(
                  0xFF00E5FF,
                ).withValues(alpha: cargando ? 0.3 : 1.0),
                width: 2,
              ),
            ),
            child: cargando
                ? const Padding(
                    padding: EdgeInsets.all(28.0),
                    child: CargaOrbital(tamano: 80),
                  )
                : const Icon(
                    Icons.fingerprint,
                    size: 56,
                    color: Color(0xFF00E5FF),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (_error != null)
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _cambiarAPin,
          child: Text(
            'Usar PIN en su lugar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye los 4 puntos indicadores del PIN.
  Widget _construirIndicadoresPIN() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _longitudPin,
        (i) => _construirPunto(i < _pinIngresado.length),
      ),
    );
  }

  /// Construye un punto del indicador de PIN.
  Widget _construirPunto(bool relleno) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: relleno ? const Color(0xFF00E5FF) : Colors.transparent,
        border: Border.all(
          color: relleno ? const Color(0xFF00E5FF) : Colors.white38,
          width: 2,
        ),
      ),
    );
  }

  /// Construye el mensaje de error si existe.
  Widget _construirMensajeError() {
    if (_error == null) return const SizedBox(height: 20);
    return Text(
      _error!,
      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
    );
  }

  /// Construye el teclado numérico de 0-9 con borrar.
  Widget _construirTecladoNumerico() {
    final filas = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: filas.map((fila) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: fila.map((tecla) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AspectRatio(
                      aspectRatio: 1.8,
                      child: _construirTecla(tecla),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Construye una tecla individual del teclado numérico.
  Widget _construirTecla(String valor) {
    if (valor.isEmpty) return const SizedBox();
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _presionarTecla(valor),
        child: Center(
          child: Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el botón de "Olvidé mi PIN" en la parte inferior.
  Widget _construirBotonOlvidePin() {
    return TextButton(
      onPressed: _confirmarOlvidePIN,
      child: Text(
        'Olvidé mi PIN',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 13,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white38,
        ),
      ),
    );
  }

  /// Procesa la tecla presionada: agrega dígito o borra el último.
  void _presionarTecla(String valor) {
    setState(() {
      _error = null;
      if (valor == '⌫') {
        if (_pinIngresado.isNotEmpty) {
          _pinIngresado = _pinIngresado.substring(0, _pinIngresado.length - 1);
        }
      } else if (_pinIngresado.length < _longitudPin) {
        _pinIngresado += valor;
        if (_pinIngresado.length == _longitudPin) _enviarPin();
      }
    });
  }

  /// Envía el PIN al controlador para verificación.
  void _enviarPin() {
    ref
        .read(proveedorControladorAutenticacion.notifier)
        .verificarPin(_pinIngresado);
  }

  /// Inicia el proceso de autenticación biométrica.
  void _iniciarBiometria() {
    setState(() => _error = null);
    ref.read(proveedorControladorAutenticacion.notifier).verificarBiometria();
  }

  /// Cambia la vista de huella a PIN cuando el usuario lo solicita.
  void _cambiarAPin() {
    setState(() {
      _error = null;
      _pinIngresado = '';
      _usarPinTemporalmente = true;
    });
  }

  /// Muestra diálogo de confirmación antes de invalidar el PIN.
  Future<void> _confirmarOlvidePIN() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0C1D3F),
        title: const Text(
          '¿Olvidaste tu PIN?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deberás iniciar sesión nuevamente con tu correo y contraseña.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Continuar',
              style: TextStyle(color: Color(0xFF00E5FF)),
            ),
          ),
        ],
      ),
    );
    if (confirmado == true && mounted) {
      ref.read(proveedorControladorAutenticacion.notifier).olvidePIN();
    }
  }

  /// Escucha cambios de estado para navegar al Dashboard o mostrar errores.
  void _escucharEstado(EstadoAutenticacion? _, EstadoAutenticacion siguiente) {
    if (siguiente is EstadoAutenticacionAutenticado) {
      RegistroRoute().go(context);
    } else if (siguiente is EstadoAutenticacionNoAutenticado) {
      LoginRoute().go(context);
    } else if (siguiente is EstadoAutenticacionError) {
      _notificarError(siguiente.mensaje);
    }
  }

  /// Vibra y muestra el error en pantalla.
  Future<void> _notificarError(String mensaje) async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 150);
    }
    setState(() {
      _error = mensaje;
      _pinIngresado = '';
    });
  }
}
