import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/entidades/usuario.dart';
import '../../dominio/entidades/preferencia_acceso.dart';
import '../../dominio/repositorios/repositorio_autenticacion.dart';
import '../../datos/fuentes_datos/fuente_datos_autenticacion_remota.dart';
import '../../datos/repositorios/repositorio_autenticacion_impl.dart';
import '../../../../nucleo/seguridad/gestor_almacenamiento_seguro.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';

// ─── Estados de Autenticación ────────────────────────────────────────────────

/// Estado base abstracto para todos los estados del flujo de autenticación.
abstract class EstadoAutenticacion {
  const EstadoAutenticacion();
}

/// Estado inicial mientras se evalúa la sesión.
class EstadoAutenticacionInicial extends EstadoAutenticacion {
  const EstadoAutenticacionInicial();
}

/// Estado de carga durante operaciones asíncronas.
class EstadoAutenticacionCargando extends EstadoAutenticacion {
  const EstadoAutenticacionCargando();
}

/// Estado exitoso: usuario autenticado con acceso al Dashboard.
class EstadoAutenticacionAutenticado extends EstadoAutenticacion {
  /// Usuario autenticado.
  final Usuario usuario;
  const EstadoAutenticacionAutenticado(this.usuario);
}

/// Estado: sin sesión activa, se muestra el Login completo.
class EstadoAutenticacionNoAutenticado extends EstadoAutenticacion {
  const EstadoAutenticacionNoAutenticado();
}

/// Estado de error con mensaje descriptivo para mostrar al usuario.
class EstadoAutenticacionError extends EstadoAutenticacion {
  /// Mensaje de error legible.
  final String mensaje;
  const EstadoAutenticacionError(this.mensaje);
}

/// Estado post-login inicial: el usuario debe configurar su PIN (obligatorio).
///
/// Corresponde al [Task_SetupPIN] del FLUJO_01_AUTENTICACION.bpmn.
class EstadoConfigurarPin extends EstadoAutenticacion {
  /// Usuario recién autenticado, en espera de configurar PIN.
  final Usuario usuario;
  const EstadoConfigurarPin(this.usuario);
}

/// Estado post-PIN: el usuario puede configurar biometría (opcional).
///
/// Corresponde al [Task_SetupBiometrics] del FLUJO_01_AUTENTICACION.bpmn.
class EstadoConfigurarBiometria extends EstadoAutenticacion {
  const EstadoConfigurarBiometria();
}

/// Estado de acceso diario rápido: periodo de gracia expiró.
///
/// Corresponde al [Gateway_QuickAccessType] del FLUJO_01_AUTENTICACION.bpmn.
/// La preferencia determina si se muestra PIN o Huella.
class EstadoAccesoRapidoRequerido extends EstadoAutenticacion {
  /// Preferencia de acceso rápido configurada por el usuario.
  final PreferenciaAcceso preferencia;
  const EstadoAccesoRapidoRequerido(this.preferencia);
}

// ─── Proveedores ──────────────────────────────────────────────────────────────

/// Proveedor para la instancia de [RepositorioAutenticacion].
final proveedorRepositorioAutenticacion = Provider<RepositorioAutenticacion>((
  ref,
) {
  return RepositorioAutenticacionImpl(
    fuenteDatosRemota: FuenteDatosAutenticacionRemota(),
    almacenamientoSeguro: GestorAlmacenamientoSeguro.instance,
  );
});

/// Proveedor del controlador de estado de autenticación.
final proveedorControladorAutenticacion =
    StateNotifierProvider<NotificadorAutenticacion, EstadoAutenticacion>((ref) {
      final repositorio = ref.read(proveedorRepositorioAutenticacion);
      return NotificadorAutenticacion(repositorio: repositorio);
    });

// ─── Controlador ─────────────────────────────────────────────────────────────

/// Controlador de autenticación que gestiona todos los nodos del BPMN Flujo 01.
///
/// Sigue el principio de Responsabilidad Única (SRP): cada método
/// representa exactamente una transición de estado del diagrama BPMN.
class NotificadorAutenticacion extends StateNotifier<EstadoAutenticacion> {
  final RepositorioAutenticacion _repositorio;
  Usuario? _usuarioActivo;

  NotificadorAutenticacion({required RepositorioAutenticacion repositorio})
    : _repositorio = repositorio,
      super(const EstadoAutenticacionInicial()) {
    verificarSesionActiva();
  }

  /// [Gateway_HasSession + Gateway_GracePeriod] — Verifica sesión y gracia 12h.
  Future<void> verificarSesionActiva() async {
    state = const EstadoAutenticacionCargando();
    try {
      final usuario = await _repositorio.obtenerUsuarioActual();
      if (usuario != null) {
        state = EstadoAutenticacionAutenticado(usuario);
      } else {
        state = const EstadoAutenticacionNoAutenticado();
      }
    } on SesionExpiradaException {
      await _transicionarAAccesoRapido();
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// [Task_FullLoginInput + Task_SupabaseAuth] — Login completo con credenciales.
  Future<void> iniciarSesion(String usuario, String password) async {
    state = const EstadoAutenticacionCargando();
    try {
      final user = await _repositorio.iniciarSesion(
        usuario: usuario,
        password: password,
      );
      _usuarioActivo = user;
      state = EstadoConfigurarPin(user);
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// [Task_SetupPIN] — Guarda el PIN de 4 dígitos (obligatorio).
  Future<void> configurarPin(String pin) async {
    state = const EstadoAutenticacionCargando();
    try {
      await _repositorio.configurarPin(pin);
      state = const EstadoConfigurarBiometria();
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// [Task_SetupBiometrics] — Guarda preferencia de huella y finaliza setup.
  Future<void> configurarBiometria(PreferenciaAcceso preferencia) async {
    state = const EstadoAutenticacionCargando();
    try {
      await _repositorio.guardarPreferenciaAcceso(
        preferencia.toStorageString(),
      );
      state = EstadoAutenticacionAutenticado(_usuarioActivo!);
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// [Task_InputPIN + Gateway_PINCheck] — Verifica PIN diario y renueva gracia.
  Future<void> verificarPin(String pin) async {
    state = const EstadoAutenticacionCargando();
    try {
      final valido = await _repositorio.verificarPin(pin);
      if (valido) {
        final usuario = await _repositorio.obtenerUsuarioActual();
        state = EstadoAutenticacionAutenticado(usuario!);
      } else {
        state = EstadoAutenticacionError(
          DiccionarioErrores.obtener('AUTH-002').toString(),
        );
      }
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// [Task_ProvideBiometrics + Gateway_BiometricCheck] — Verifica huella.
  Future<void> verificarBiometria() async {
    state = const EstadoAutenticacionCargando();
    try {
      final valido = await _repositorio.verificarBiometria();
      if (valido) {
        final usuario = await _repositorio.obtenerUsuarioActual();
        state = EstadoAutenticacionAutenticado(usuario!);
      } else {
        state = EstadoAutenticacionError(
          DiccionarioErrores.obtener('BIO-003').toString(),
        );
      }
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// [Task_ClearSession] — "Olvidé mi PIN": invalida bóveda y vuelve al login.
  Future<void> olvidePIN() async {
    state = const EstadoAutenticacionCargando();
    try {
      await _repositorio.invalidarPinYToken();
      state = const EstadoAutenticacionNoAutenticado();
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// [Task_ClearSession logout] — Cierra sesión explícitamente.
  Future<void> cerrarSesion() async {
    state = const EstadoAutenticacionCargando();
    try {
      await _repositorio.cerrarSesion();
      state = const EstadoAutenticacionNoAutenticado();
    } catch (e) {
      state = EstadoAutenticacionError(DiccionarioErrores.mapear(e).toString());
    }
  }

  /// Determina y emite el estado de acceso rápido según preferencia guardada.
  Future<void> _transicionarAAccesoRapido() async {
    final prefRaw = await GestorAlmacenamientoSeguro.instance
        .obtenerPreferenciaAcceso();
    final preferencia = PreferenciaAcceso.fromString(prefRaw);
    state = EstadoAccesoRapidoRequerido(preferencia);
  }
}
