import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para convertir los datos a formato JSON
import 'registro_screen.dart'; // Importamos la nueva pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BRISMAR APP',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D255F),
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  // URL de tu servidor Node.js
  final String urlBackend = 'http://127.0.0.1:8080/api/usuarios/login';

  // FUNCIÓN ASÍNCRONA PARA CONECTAR AL BACKEND
  Future<void> _intentarLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 1. Aviso visual de conexión en proceso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verificando credenciales...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );

        // 2. Petición HTTP al servidor Node.js
        final response = await http.post(
          Uri.parse(urlBackend),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usuario': _userController.text,
            'password': _passController.text,
          }),
        );

        // 3. Verificamos si el widget sigue activo en pantalla tras la espera
        if (!mounted) return;

        // 4. Transformamos la respuesta de JSON a código que Dart entienda
        final data = jsonDecode(response.body);

        // 5. Evaluamos la respuesta del servidor
        if (response.statusCode == 200) {
          // ÉXITO: Navegamos directo al Registro de Bahía
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bienvenido: ${data['datos']['nombre']}'),
              backgroundColor: Colors.green,
            ),
          );

          // CAMBIO CLAVE: Usamos pushReplacement para ir al Registro y borrar el Login de la memoria
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegistroScreen()),
          );
        } else {
          // ERROR DE CREDENCIALES
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['mensaje'] ?? 'Usuario o contraseña incorrectos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // ERROR DE RED O SERVIDOR CAÍDO
        if (!mounted) return;
        print("Error de conexión: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo conectar con el servidor (Backend apagado)'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
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
                            const Icon(Icons.business, size: 40, color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Campo Usuario
                  TextFormField(
                    controller: _userController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'USUARIO',
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
                      if (value == null || value.isEmpty) {
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

                  // Olvidé mi contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => print("Recuperar pass"),
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

                  // Botón Iniciar Sesión
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
                      onPressed: _intentarLogin,
                      child: const Text(
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