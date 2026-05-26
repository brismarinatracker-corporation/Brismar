import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/entidades/usuario.dart';
import '../../dominio/repositorios/auth_repositorio.dart';
import '../../datos/fuentes_datos/auth_remoto_datasource.dart';
import '../../datos/repositorios/auth_repositorio_imp.dart';
import '../../../../nucleo/seguridad/secure_storage_helper.dart';

/// Define los diferentes estados de la autenticación en la interfaz gráfica.
abstract class EstadoAutenticacion {
  const EstadoAutenticacion();
}

class EstadoAutenticacionInicial extends EstadoAutenticacion {
  const EstadoAutenticacionInicial();
}

class EstadoAutenticacionCargando extends EstadoAutenticacion {
  const EstadoAutenticacionCargando();
}

class EstadoAutenticacionAutenticado extends EstadoAutenticacion {
  final Usuario usuario;
  const EstadoAutenticacionAutenticado(this.usuario);
}

class EstadoAutenticacionNoAutenticado extends EstadoAutenticacion {
  const EstadoAutenticacionNoAutenticado();
}

class EstadoAutenticacionError extends EstadoAutenticacion {
  final String mensaje;
  const EstadoAutenticacionError(this.mensaje);
}

/// Proveedor para la instancia de [AuthRepositorio].
final proveedorAuthRepositorio = Provider<AuthRepositorio>((ref) {
  return AuthRepositorioImp(
    remotoDatasource: AuthRemotoDatasource(),
    secureStorage: SecureStorageHelper.instance,
  );
});

/// Proveedor del controlador de estado de autenticación.
final proveedorAuthController =
    StateNotifierProvider<AuthNotifier, EstadoAutenticacion>((ref) {
  final repositorio = ref.read(proveedorAuthRepositorio);
  return AuthNotifier(repositorio: repositorio);
});

/// Controlador encargado de gestionar las acciones de login, logout e inicio.
/// Sigue el principio de Responsabilidad Única (SRP).
class AuthNotifier extends StateNotifier<EstadoAutenticacion> {
  final AuthRepositorio _repositorio;

  AuthNotifier({required AuthRepositorio repositorio})
      : _repositorio = repositorio,
        super(const EstadoAutenticacionInicial()) {
    verificarSesionActiva();
  }

  /// Verifica si el usuario ya tiene una sesión iniciada al abrir la aplicación.
  Future<void> verificarSesionActiva() async {
    state = const EstadoAutenticacionCargando();
    try {
      final usuario = await _repositorio.obtenerUsuarioActual();
      if (usuario != null) {
        state = EstadoAutenticacionAutenticado(usuario);
      } else {
        state = const EstadoAutenticacionNoAutenticado();
      }
    } catch (e) {
      state = EstadoAutenticacionError(e.toString());
    }
  }

  /// Intenta iniciar sesión con las credenciales ingresadas.
  Future<void> iniciarSesion(String usuario, String password) async {
    state = const EstadoAutenticacionCargando();
    try {
      final user = await _repositorio.iniciarSesion(
        usuario: usuario,
        password: password,
      );
      state = EstadoAutenticacionAutenticado(user);
    } catch (e) {
      // Retorna el error de forma legible
      final cleanedMessage = e.toString().replaceAll('Exception: ', '');
      state = EstadoAutenticacionError(cleanedMessage);
    }
  }

  /// Cierra la sesión activa del usuario y limpia el almacenamiento local.
  Future<void> cerrarSesion() async {
    state = const EstadoAutenticacionCargando();
    try {
      await _repositorio.cerrarSesion();
      state = const EstadoAutenticacionNoAutenticado();
    } catch (e) {
      state = EstadoAutenticacionError(e.toString());
    }
  }
}
