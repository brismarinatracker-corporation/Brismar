import 'dart:math';
import 'package:flutter/material.dart';

/// Indicador de carga animado tipo orbital con partículas (Glassmorphism).
/// Puede usarse en pantallas completas o tamanos reducidos ajustando [tamano].
class CargaOrbital extends StatefulWidget {
  final double tamano;
  final Color colorPrimario;

  const CargaOrbital({
    super.key,
    this.tamano = 140.0,
    this.colorPrimario = const Color(0xFF00E5FF),
  });

  @override
  State<CargaOrbital> createState() => _CargaOrbitalState();
}

class _CargaOrbitalState extends State<CargaOrbital>
    with TickerProviderStateMixin {
  late final AnimationController _rotacion;
  late final AnimationController _pulso;

  @override
  void initState() {
    super.initState();
    _rotacion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotacion.dispose();
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.tamano,
      height: widget.tamano,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo exterior giratorio con partículas
          AnimatedBuilder(
            animation: _rotacion,
            builder: (_, _) => Transform.rotate(
              angle: _rotacion.value * 2 * pi,
              child: CustomPaint(
                size: Size(widget.tamano, widget.tamano),
                painter: _PintorOrbital(
                  radio: widget.tamano / 2,
                  particulas: 6,
                  colorBase: widget.colorPrimario,
                ),
              ),
            ),
          ),
          // Anillo interior en sentido contrario
          AnimatedBuilder(
            animation: _rotacion,
            builder: (_, _) => Transform.rotate(
              angle: -_rotacion.value * 2 * pi * 0.6,
              child: CustomPaint(
                size: Size(widget.tamano * 0.7, widget.tamano * 0.7),
                painter: _PintorOrbital(
                  radio: (widget.tamano / 2) * 0.7,
                  particulas: 4,
                  colorBase: widget.colorPrimario,
                ),
              ),
            ),
          ),
          // Ícono central con pulso (solo si es lo suficientemente grande)
          if (widget.tamano >= 40)
            AnimatedBuilder(
              animation: _pulso,
              builder: (_, _) {
                final escala = 0.9 + _pulso.value * 0.15;
                final tamIcono = widget.tamano * 0.45;
                return Transform.scale(
                  scale: escala,
                  child: Container(
                    width: tamIcono,
                    height: tamIcono,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF143068), Color(0xFF0C1D3F)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.colorPrimario.withValues(
                            alpha: 0.3 + _pulso.value * 0.3,
                          ),
                          blurRadius:
                              (widget.tamano * 0.14) +
                              _pulso.value * (widget.tamano * 0.14),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.anchor_rounded,
                      color: widget.colorPrimario,
                      size: tamIcono * 0.5,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PintorOrbital extends CustomPainter {
  final double radio;
  final int particulas;
  final Color colorBase;

  _PintorOrbital({
    required this.radio,
    this.particulas = 6,
    required this.colorBase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);

    // Anillo base
    final pintorAnillo = Paint()
      ..color = colorBase.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(centro, radio, pintorAnillo);

    // Partículas en el anillo
    final pintorParticula = Paint()
      ..color = colorBase.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particulas; i++) {
      final angulo = (2 * pi / particulas) * i;
      final x = centro.dx + radio * cos(angulo);
      final y = centro.dy + radio * sin(angulo);

      // Tamaño variado por posición proporcional al radio
      final maxTam = radio * 0.08;
      final minTam = radio * 0.05;
      final tam = (i % 2 == 0) ? maxTam : minTam;

      canvas.drawCircle(Offset(x, y), tam.clamp(1.5, 8.0), pintorParticula);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
