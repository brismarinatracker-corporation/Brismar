import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../nucleo/rutas/enrutador.dart';
import '../controladores/controlador_autenticacion.dart';
import '../componentes/formulario_login.dart';

/// Pantalla de inicio de sesión de BRISMAR APP.
/// Utiliza [ConsumerStatefulWidget] de Riverpod para reaccionar al estado de sesión y
/// renderiza el formulario modular [FormularioLogin].
class LoginPantalla extends ConsumerStatefulWidget {
  const LoginPantalla({super.key});

  @override
  ConsumerState<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends ConsumerState<LoginPantalla> {
  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el estado de autenticación para disparar navegación o alertas
    ref.listen<EstadoAutenticacion>(proveedorControladorAutenticacion, (
      previous,
      next,
    ) {
      if (next is EstadoAutenticacionAutenticado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido: ${next.usuario.nombreReal}'),
            backgroundColor: Colors.green,
          ),
        );
        // Navegación estricta fuertemente tipada
        const RegistroRoute().go(context);
      } else if (next is EstadoAutenticacionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.mensaje), backgroundColor: Colors.red),
        );
      }
    });

    return const Scaffold(
      backgroundColor: Color(0xFF0D255F),
      body: Center(child: SingleChildScrollView(child: FormularioLogin())),
    );
  }
}
