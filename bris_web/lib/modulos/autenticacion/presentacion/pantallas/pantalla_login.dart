import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controladores/controlador_autenticacion.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _ocultarContrasena = true;
  bool _recordarme = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    final correoGuardado = prefs.getString('recordar_correo');
    if (correoGuardado != null && correoGuardado.isNotEmpty) {
      setState(() {
        _correoController.text = correoGuardado;
        _recordarme = true;
      });
    }
  }
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

      final prefs = await SharedPreferences.getInstance();
      if (_recordarme) {
        await prefs.setString('recordar_correo', _correoController.text.trim());
      } else {
        await prefs.remove('recordar_correo');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensajeError = 'Credenciales incorrectas o usuario no autorizado.';
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
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esPantallaAncha = anchoPantalla >= 950;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Panel Derecho & Fondo General (Tono Espuma)
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF7F7F7), // Foam tone
              child: Row(
                children: [
                  if (esPantallaAncha)
                    const Spacer(flex: 11), // Deja espacio para el panel izquierdo
                  Expanded(
                    flex: 9,
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Logo móvil visible al colapsar el panel
                                  if (!esPantallaAncha) ...[
                                    Center(
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 24),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0E3E2C),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.anchor_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Cabecera Formulario
                                  Text(
                                    'ACCESO AL PANEL',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF0F766E), // Sea green
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Bienvenido de vuelta',
                                    style: GoogleFonts.sora(
                                      color: const Color(0xFF15181A),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ingresa tus credenciales para continuar con la operación.',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF64748B),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Mensaje de Error
                                  if (errorParaMostrar != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        border: Border.all(color: Colors.red.shade200),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              errorParaMostrar,
                                              style: GoogleFonts.inter(
                                                color: Colors.red.shade800,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Campo Correo
                                  Text(
                                    'Correo electrónico',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF334155),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _correoController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.inter(color: const Color(0xFF15181A), fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'nombre@brismar.pe',
                                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                                      prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B), size: 20),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF0E3E2C), width: 2.0), // Dark Green Focus
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor, ingresa tu correo';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Ingresa un correo válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Campo Contraseña
                                  Text(
                                    'Contraseña',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF334155),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _contrasenaController,
                                    obscureText: _ocultarContrasena,
                                    style: GoogleFonts.inter(color: const Color(0xFF15181A), fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _ocultarContrasena ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: const Color(0xFF64748B),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _ocultarContrasena = !_ocultarContrasena;
                                          });
                                        },
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF0E3E2C), width: 2.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
                                  const SizedBox(height: 20),

                                  // Recordarme & Olvidaste Contraseña
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: _recordarme,
                                              activeColor: const Color(0xFF0E3E2C),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                              onChanged: (val) {
                                                setState(() {
                                                  _recordarme = val ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Recordarme',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF64748B),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () => _mostrarDialogoRecuperarContrasena(),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor: const Color(0xFF0F766E), // Sea green
                                        ),
                                        child: Text(
                                          '¿Olvidaste tu contraseña?',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Botón Ingresar (Negro Tinta)
                                  ElevatedButton(
                                    onPressed: _cargando ? null : _iniciarSesion,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF15181A), // Negro Tinta
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _cargando
                                        ? const CargaOrbital(tamano: 22)
                                        : Text(
                                            'Ingresar',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Divisor restringido
                                  Row(
                                    children: [
                                      const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1.2)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'acceso restringido al personal autorizado',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1.2)),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Soporte Técnico
                                  Center(
                                    child: Text.rich(
                                      TextSpan(
                                        text: '¿Problemas para ingresar? ',
                                        style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                                        children: [
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Text(
                                                'Contacta a soporte',
                                                style: GoogleFonts.inter(
                                                  color: const Color(0xFF15181A),
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
                ],
              ),
            ),
          ),

          // 2. Panel Izquierdo (Corte Diagonal de Horizonte, visible en pantallas anchas)
          if (esPantallaAncha)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: anchoPantalla * 0.55, // 55% de la pantalla de ancho
              child: ClipPath(
                clipper: ClipperHorizonte(),
                child: Container(
                  color: const Color(0xFF0E3E2C), // Verde dominante
                  child: Stack(
                    children: [
                      // Líneas de contorno tipo batimetría / Carta Náutica
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DibujadorCartaNautica(),
                        ),
                      ),
                      // Contenido de branding
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 64),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                'NEGOCIOS BRISMAR S.R.L.',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF7EBFC9), // Celeste Accent
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Cada zarpe,\ncada descarga,\nbajo control.',
                                style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontSize: 44,
                                  height: 1.15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Panel de gestión portuaria y logística pesquera:\nregistro de faenas, control de bahía y\ntrazabilidad en un solo lugar.',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 16,
                                  height: 1.55,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoRecuperarContrasena() async {
    final TextEditingController correoDialogController = TextEditingController(text: _correoController.text);
    bool enviando = false;
    String? errorLocal;

    await showDialog(
      context: context,
      builder: (contextDialog) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Recuperar contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: correoDialogController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (errorLocal != null) ...[
                    const SizedBox(height: 12),
                    Text(errorLocal!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: enviando ? null : () => Navigator.pop(contextDialog),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: enviando ? null : () async {
                    if (correoDialogController.text.trim().isEmpty) {
                      setStateDialog(() => errorLocal = 'Por favor ingresa un correo');
                      return;
                    }
                    setStateDialog(() {
                      enviando = true;
                      errorLocal = null;
                    });
                    try {
                      await ref.read(proveedorAutenticacion.notifier).enviarCorreoRecuperacion(correoDialogController.text.trim());
                      if (contextDialog.mounted) {
                        Navigator.pop(contextDialog);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Te hemos enviado un correo con instrucciones para restablecer tu contraseña.'),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      setStateDialog(() {
                        enviando = false;
                        errorLocal = e.toString().replaceAll('Exception: ', '');
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                  ),
                  child: enviando 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Clipper que realiza un corte diagonal dinámico estilo "horizonte"
class ClipperHorizonte extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width * 0.88, 0); // Empieza diagonal ligeramente metido arriba
    path.lineTo(size.width, size.height); // Termina en la esquina inferior derecha
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Dibuja curvas batimétricas concéntricas e incluye el marcador de Pimentel
class DibujadorCartaNautica extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincelBatimetria = Paint()
      ..color = const Color(0xFF14B8A6).withValues(alpha: 0.04) // Sea green sutil
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pincelBatimetriaFuerte = Paint()
      ..color = const Color(0xFF14B8A6).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujamos curvas batimétricas concéntricas simulando profundidades marinas
    final centroX = size.width * 0.75;
    final centroY = size.height * 0.65;

    for (int i = 1; i <= 6; i++) {
      final radio = i * 75.0;
      final pincelActivo = (i % 3 == 0) ? pincelBatimetriaFuerte : pincelBatimetria;
      
      canvas.drawCircle(
        Offset(centroX, centroY),
        radio,
        pincelActivo,
      );
    }

    // Dibujamos líneas de cuadrícula técnica tipo carta de navegación
    final pincelGrilla = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), pincelGrilla);
    }
    for (double y = 0; y < size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pincelGrilla);
    }

    // Marcador de Ubicación Operativa: Pimentel
    final dotX = centroX - 40;
    final dotY = centroY + 20;

    // Anillo exterior brillante (Accento Ámbar)
    final pincelAnillo = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(dotX, dotY), 12, pincelAnillo);

    // Punto central (Amber Accent)
    final pincelPunto = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), 4, pincelPunto);

    // Etiqueta de coordenadas usando IBM Plex Mono
    final textSpan = TextSpan(
      text: 'PIMENTEL\n06°50\'S 79°56\'W',
      style: GoogleFonts.ibmPlexMono(
        color: const Color(0xFF14B8A6), // Sea Green
        fontSize: 11,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: 0.5,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Posiciona el texto a la derecha del marcador
    textPainter.paint(canvas, Offset(dotX + 18, dotY - 14));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
