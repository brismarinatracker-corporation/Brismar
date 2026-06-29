// ============================================================
// Componente : SplashCarga — Pantalla de Carga Global
// Archivo    : splash_carga.dart
// Última modificación: 2026-06-29
// Autor      : Antigravity IDE
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';

/// Pantalla de carga animada que se muestra durante la inicialización
/// o durante transiciones de autenticación.
///
/// Características:
/// - Fondo con gradiente marino idéntico al de login.
/// - Animación de rotación de partículas y pulso del logo.
/// - Texto de estado configurable.
/// - Totalmente transparente (glassmorphism) y original.
class SplashCarga extends StatefulWidget {
  /// Mensaje descriptivo que se muestra debajo del logo.
  final String mensaje;

  const SplashCarga({super.key, this.mensaje = 'Cargando...'});

  @override
  State<SplashCarga> createState() => _SplashCargaState();
}

class _SplashCargaState extends State<SplashCarga>
    with TickerProviderStateMixin {
  late final AnimationController _rotacion;
  late final AnimationController _pulso;
  late final AnimationController _aparecer;

  @override
  void initState() {
    super.initState();

    _rotacion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _aparecer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _rotacion.dispose();
    _pulso.dispose();
    _aparecer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _aparecer,
        child: Stack(
          children: [
            _fondo(),
            _esfera(top: -80, left: -60, color: const Color(0x2200E5FF)),
            _esfera(bottom: -120, right: -80, color: const Color(0x1B0D47A1)),
            _esfera(top: 200, right: -40, color: const Color(0x110D47A1)),
            Center(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _animacionOrbital(),
        const SizedBox(height: 40),
        _logo(),
        const SizedBox(height: 24),
        _textoCargando(),
        const SizedBox(height: 16),
        _barraProgreso(),
      ],
    );
  }

  /// Anillo orbital animado alrededor del ancla.
  Widget _animacionOrbital() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo exterior giratorio con partículas
          AnimatedBuilder(
            animation: _rotacion,
            builder: (_, __) => Transform.rotate(
              angle: _rotacion.value * 2 * pi,
              child: CustomPaint(
                size: const Size(140, 140),
                painter: _PintorOrbital(),
              ),
            ),
          ),
          // Anillo interior en sentido contrario
          AnimatedBuilder(
            animation: _rotacion,
            builder: (_, __) => Transform.rotate(
              angle: -_rotacion.value * 2 * pi * 0.6,
              child: CustomPaint(
                size: const Size(100, 100),
                painter: _PintorOrbital(radio: 50, particulas: 4),
              ),
            ),
          ),
          // Ícono central con pulso
          AnimatedBuilder(
            animation: _pulso,
            builder: (_, __) {
              final escala = 0.9 + _pulso.value * 0.15;
              return Transform.scale(
                scale: escala,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF143068), Color(0xFF0C1D3F)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF)
                            .withValues(alpha: 0.3 + _pulso.value * 0.3),
                        blurRadius: 20 + _pulso.value * 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.anchor_rounded,
                    color: Color(0xFF00E5FF),
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF5C6BC0)],
          ).createShader(bounds),
          child: const Text(
            'BRISMAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistema de Gestión de Pesca',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _textoCargando() {
    return AnimatedBuilder(
      animation: _pulso,
      builder: (_, __) => Opacity(
        opacity: 0.6 + _pulso.value * 0.4,
        child: Text(
          widget.mensaje,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _barraProgreso() {
    return SizedBox(
      width: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const LinearProgressIndicator(
          backgroundColor: Color(0x22FFFFFF),
          color: Color(0xFF00E5FF),
          minHeight: 2,
        ),
      ),
    );
  }

  Widget _fondo() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF040B1E), Color(0xFF0C1D3F), Color(0xFF143068)],
        ),
      ),
    );
  }

  Widget _esfera({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Painter de Partículas Orbitales ─────────────────────────────────────────

class _PintorOrbital extends CustomPainter {
  final double radio;
  final int particulas;

  _PintorOrbital({this.radio = 70, this.particulas = 6});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);

    // Anillo base
    final pintorAnillo = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(centro, radio, pintorAnillo);

    // Partículas en el anillo
    final pintorParticula = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particulas; i++) {
      final angulo = (2 * pi / particulas) * i;
      final x = centro.dx + radio * cos(angulo);
      final y = centro.dy + radio * sin(angulo);
      // Tamaño variado por posición
      final tam = (i % 2 == 0) ? 4.0 : 2.5;
      canvas.drawCircle(Offset(x, y), tam, pintorParticula);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
