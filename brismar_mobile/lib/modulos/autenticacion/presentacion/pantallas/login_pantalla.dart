import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controladores/auth_controlador.dart';

/// Pantalla de inicio de sesión de BRISMAR APP.
/// Utiliza [ConsumerStatefulWidget] de Riverpod para reaccionar al estado de sesión.
class LoginPantalla extends ConsumerStatefulWidget {
  const LoginPantalla({super.key});

  @override
  ConsumerState<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends ConsumerState<LoginPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Dispara la acción de autenticación en el controlador.
  void _intentarLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(proveedorAuthController.notifier).iniciarSesion(
            _userController.text.trim(),
            _passController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el estado de autenticación para disparar navegación o alertas
    ref.listen<EstadoAutenticacion>(proveedorAuthController, (previous, next) {
      if (next is EstadoAutenticacionAutenticado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido: ${next.usuario.nombreReal}'),
            backgroundColor: Colors.green,
          ),
        );
        // Navegación declarativa hacia el registro de bahía
        context.go('/registro');
      } else if (next is EstadoAutenticacionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final estado = ref.watch(proveedorAuthController);
    final estaCargando = estado is EstadoAutenticacionCargando;

    return Scaffold(
      backgroundColor: const Color(0xFF0D255F),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF223B82),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo de la Empresa
                  Container(
                    width: 140,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.directions_boat, size: 40, color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Campo Usuario / Correo
                  TextFormField(
                    controller: _userController,
                    enabled: !estaCargando,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'USUARIO O CORREO',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF3250A4),
                      prefixIcon: const Icon(Icons.person, color: Colors.lightBlueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(color: Colors.orangeAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingrese su usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Contraseña
                  TextFormField(
                    controller: _passController,
                    obscureText: true,
                    enabled: !estaCargando,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'CONTRASEÑA',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF3250A4),
                      prefixIcon: const Icon(Icons.lock, color: Colors.lightBlueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(color: Colors.orangeAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su contraseña';
                      }
                      if (value.length < 4) {
                        return 'Mínimo 4 caracteres';
                      }
                      return null;
                    },
                  ),

                  // Olvidé mi contraseña (Mock)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: estaCargando ? null : () {},
                      child: const Text(
                        '¿Olvidé mi contraseña?',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Botón Iniciar Sesión con Estado de Carga
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0088CC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: estaCargando ? null : _intentarLogin,
                      child: estaCargando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'INICIAR SESIÓN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
