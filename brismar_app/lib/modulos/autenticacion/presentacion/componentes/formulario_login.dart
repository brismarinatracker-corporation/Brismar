import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controladores/controlador_autenticacion.dart';

/// Formulario encapsulado para iniciar sesión.
/// Maneja internamente los controladores de texto y sus validaciones.
class FormularioLogin extends ConsumerStatefulWidget {
  const FormularioLogin({super.key});

  @override
  ConsumerState<FormularioLogin> createState() => _FormularioLoginState();
}

class _FormularioLoginState extends ConsumerState<FormularioLogin> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  String _appVersion = 'v---';
  bool _hayConexion = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initAppInfo();
  }

  Future<void> _initAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${info.version}';
      });
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    _actualizarEstadoConexion(connectivityResult);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_actualizarEstadoConexion);
  }

  void _actualizarEstadoConexion(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() {
        _hayConexion = !result.contains(ConnectivityResult.none) && result.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Dispara la acción de autenticación en el controlador de Riverpod.
  void _intentarLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(proveedorControladorAutenticacion.notifier)
          .iniciarSesion(
            _userController.text.trim(),
            _passController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(proveedorControladorAutenticacion);
    final estaCargando = estado is EstadoAutenticacionCargando;

    return Form(
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
            ),
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
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.directions_boat,
                    size: 40,
                    color: Colors.teal,
                  ),
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
                prefixIcon: const Icon(
                  Icons.person,
                  color: Colors.lightBlueAccent,
                ),
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
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.lightBlueAccent,
                ),
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

            // Olvidé mi contraseña
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
            const SizedBox(height: 20),

            // Estado de Conexión y Versión de la App
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _hayConexion ? Icons.cloud_done : Icons.cloud_off,
                      color: _hayConexion ? Colors.greenAccent : Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _hayConexion ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: _hayConexion ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  _appVersion,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
