import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controladores/controlador_autenticacion.dart';
import '../../../../nucleo/rutas/enrutador.dart';

/// Pantalla para configurar el PIN de acceso rápido (obligatorio).
///
/// Corresponde a [Task_SetupPIN] del FLUJO_01_AUTENTICACION.bpmn.
/// El usuario ingresa su PIN de 4 dígitos y lo confirma antes de guardar.
class ConfigurarPinPantalla extends ConsumerStatefulWidget {
  /// Constructor constante de [ConfigurarPinPantalla].
  const ConfigurarPinPantalla({super.key});

  @override
  ConsumerState<ConfigurarPinPantalla> createState() =>
      _ConfigurarPinPantallaState();
}

class _ConfigurarPinPantallaState extends ConsumerState<ConfigurarPinPantalla> {
  String _pinIngresado = '';
  String _pinConfirmacion = '';
  bool _confirmando = false;
  String? _error;

  static const int _longitudPin = 4;

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
                        _construirIndicadoresPIN(),
                        const SizedBox(height: 16),
                        _construirMensajeError(),
                        const Spacer(),
                        _construirTecladoNumerico(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  /// Construye el encabezado con título e instrucciones.
  Widget _construirCabecera() {
    return Column(
      children: [
        const Icon(Icons.lock_outline, color: Color(0xFF00E5FF), size: 48),
        const SizedBox(height: 16),
        Text(
          _confirmando ? 'Confirma tu PIN' : 'Crea tu PIN de acceso',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _confirmando
              ? 'Ingresa el PIN nuevamente para confirmar'
              : 'Elige 4 dígitos para el acceso diario rápido',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construye los 4 puntos indicadores del PIN.
  Widget _construirIndicadoresPIN() {
    final pinActual = _confirmando ? _pinConfirmacion : _pinIngresado;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _longitudPin,
        (i) => _construirPunto(i < pinActual.length),
      ),
    );
  }

  /// Construye un punto del indicador de PIN (relleno o vacío).
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
    if (_error == null) return const SizedBox(height: 24);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        _error!,
        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Construye el teclado numérico de 0-9 con borrar usando Column y Row para evitar GridView.
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

  /// Procesa la tecla presionada: agrega dígito o borra el último.
  void _presionarTecla(String valor) {
    setState(() {
      _error = null;
      if (valor == '⌫') {
        _borrarUltimo();
      } else {
        _agregarDigito(valor);
      }
    });
  }

  /// Borra el último dígito del campo activo.
  void _borrarUltimo() {
    if (_confirmando && _pinConfirmacion.isNotEmpty) {
      _pinConfirmacion = _pinConfirmacion.substring(0, _pinConfirmacion.length - 1);
    } else if (!_confirmando && _pinIngresado.isNotEmpty) {
      _pinIngresado = _pinIngresado.substring(0, _pinIngresado.length - 1);
    }
  }

  /// Agrega un dígito y avanza al siguiente estado cuando se completan 4 dígitos.
  void _agregarDigito(String digito) {
    if (_confirmando) {
      if (_pinConfirmacion.length < _longitudPin) {
        _pinConfirmacion += digito;
        if (_pinConfirmacion.length == _longitudPin) _validarYGuardarPin();
      }
    } else {
      if (_pinIngresado.length < _longitudPin) {
        _pinIngresado += digito;
        if (_pinIngresado.length == _longitudPin) _solicitarConfirmacion();
      }
    }
  }

  /// Pasa al modo de confirmación del PIN.
  void _solicitarConfirmacion() {
    setState(() => _confirmando = true);
  }

  /// Valida que ambos PINes coincidan y llama al controlador para guardarlo.
  void _validarYGuardarPin() {
    if (_pinIngresado != _pinConfirmacion) {
      setState(() {
        _error = 'Los PINes no coinciden. Intenta de nuevo.';
        _confirmando = false;
        _pinIngresado = '';
        _pinConfirmacion = '';
      });
      return;
    }
    ref
        .read(proveedorControladorAutenticacion.notifier)
        .configurarPin(_pinIngresado);
  }

  /// Escucha los cambios de estado para navegar a la pantalla de biometría.
  void _escucharEstado(EstadoAutenticacion? _, EstadoAutenticacion siguiente) {
    if (siguiente is EstadoConfigurarBiometria) {
      ConfigurarBiometriaRoute().go(context);
    } else if (siguiente is EstadoAutenticacionError) {
      setState(() {
        _error = siguiente.mensaje;
        _pinIngresado = '';
        _pinConfirmacion = '';
        _confirmando = false;
      });
    }
  }
}
