import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controladores/controlador_autenticacion.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

/// Pantalla de Autenticación (Login) para la plataforma Web de Brismar.
/// Presenta un diseño premium responsivo con Glassmorphism y micro-animaciones.
class PantallaLogin extends ConsumerStatefulWidget {
  const PantallaLogin({super.key});

  @override
  ConsumerState<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends ConsumerState<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _cargando = false;
  String? _mensajeError;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensajeError = null;
    });

    try {
      await ref.read(proveedorAutenticacion.notifier).iniciarSesion(
            _correoController.text.trim(),
            _contrasenaController.text,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensajeError = 'Credenciales incorrectas o rol de usuario no autorizado.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estadoAuth = ref.watch(proveedorAutenticacion);
    final errorParaMostrar = _mensajeError ?? estadoAuth.error;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado de alto contraste premium (Estilo Espacio/Bahía)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF030712),
                  Color(0xFF0A152E),
                  Color(0xFF0D2545),
                ],
                stops: [0.1, 0.6, 1.0],
              ),
            ),
          ),
          
          // Efecto de luz difusa de fondo en el centro
          Positioned(
            left: MediaQuery.of(context).size.width * 0.35,
            top: MediaQuery.of(context).size.height * 0.25,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return Transform.translate(
                    offset: Offset(0, 40 * (1.0 - animValue)),
                    child: Opacity(
                      opacity: animValue,
                      child: child,
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                      decoration: BoxDecoration(
                        color: const Color(0x730C1D3F),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0x3300E5FF),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                            blurRadius: 35,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icono animado del timón/ancla de Brismar
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0x1F00E5FF),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.anchor_rounded,
                                  color: Color(0xFF00E5FF),
                                  size: 48,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'BrisWeb',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ingresa tus credenciales para acceder',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: Colors.white54,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 36),
                            
                            // Banner de Error
                            if (errorParaMostrar != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.1),
                                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  errorParaMostrar,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFF5252),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            // Campo Correo
                            TextFormField(
                              controller: _correoController,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                labelStyle: GoogleFonts.outfit(color: Colors.white70),
                                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
                                filled: true,
                                fillColor: const Color(0x33000000),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingresa tu correo';
                                }
                                if (!value.contains('@')) {
                                  return 'Ingresa un correo válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Campo Contraseña
                            TextFormField(
                              controller: _contrasenaController,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: GoogleFonts.outfit(color: Colors.white70),
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                                filled: true,
                                fillColor: const Color(0x33000000),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingresa tu contraseña';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _iniciarSesion(),
                            ),
                            const SizedBox(height: 36),
                            
                            // Botón Ingresar
                            ElevatedButton(
                              onPressed: _cargando ? null : _iniciarSesion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: const Color(0xFF030712),
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                              ),
                              child: _cargando
                                  ? const CargaOrbital(tamano: 24)
                                  : Text(
                                      'INICIAR SESIÓN',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overlay de Carga Molecular
          if (_cargando)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: const Color(0xFF030712).withValues(alpha: 0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CargaOrbital(tamano: 100),
                        const SizedBox(height: 32),
                        Text(
                          'Conectando con Supabase...',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF00E5FF),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
