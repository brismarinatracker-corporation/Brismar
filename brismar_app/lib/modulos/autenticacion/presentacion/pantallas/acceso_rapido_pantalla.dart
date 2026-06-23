import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../dominio/entidades/preferencia_acceso.dart';
import '../controladores/controlador_autenticacion.dart';
import '../../../../nucleo/rutas/enrutador.dart';

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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF040B1E), Color(0xFF0C1D3F), Color(0xFF143068)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              _construirCabecera(),
              const SizedBox(height: 40),
              widget.preferencia == PreferenciaAcceso.pin
                  ? _construirVistaPin()
                  : _construirVistaBiometria(),
              const Spacer(),
              _construirBotonOlvidePin(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el encabezado con saludo y nombre de la app.
  Widget _construirCabecera() {
    return Column(
      children: [
        Image.asset('assets/logo.png', height: 60),
        const SizedBox(height: 20),
        const Text(
          'Bienvenido de vuelta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.preferencia == PreferenciaAcceso.pin
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
        const SizedBox(height: 24),
        _construirTecladoNumerico(),
      ],
    );
  }

  /// Construye la vista de autenticación biométrica.
  Widget _construirVistaBiometria() {
    return Column(
      children: [
        GestureDetector(
          onTap: _iniciarBiometria,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFF00E5FF), width: 2),
            ),
            child: const Icon(
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
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
    final teclas = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.8,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: teclas.length,
        itemBuilder: (_, i) => _construirTecla(teclas[i]),
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
    ref.read(proveedorControladorAutenticacion.notifier).verificarPin(_pinIngresado);
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
    });
  }

  /// Muestra diálogo de confirmación antes de invalidar el PIN.
  Future<void> _confirmarOlvidePIN() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0C1D3F),
        title: const Text('¿Olvidaste tu PIN?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deberás iniciar sesión nuevamente con tu correo y contraseña.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar', style: TextStyle(color: Color(0xFF00E5FF))),
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
