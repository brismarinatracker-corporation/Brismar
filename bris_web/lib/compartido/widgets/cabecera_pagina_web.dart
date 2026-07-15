import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabeceraPaginaWeb extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? widgetAccion;
  final Widget? contenidoExtra;

  const CabeceraPaginaWeb({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.widgetAccion,
    this.contenidoExtra,
  });

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: esMovil ? 20 : 40, vertical: esMovil ? 20 : 24),
      child: esMovil
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.sora(color: const Color(0xFF0E3E2C), fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitulo!,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
                if (contenidoExtra != null) ...[
                  const SizedBox(height: 8),
                  contenidoExtra!,
                ],
                if (widgetAccion != null) ...[
                  const SizedBox(height: 16),
                  widgetAccion!,
                ],
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: GoogleFonts.sora(color: const Color(0xFF0E3E2C), fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      if (subtitulo != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitulo!,
                          style: const TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ],
                      if (contenidoExtra != null) ...[
                        const SizedBox(height: 4),
                        contenidoExtra!,
                      ],
                    ],
                  ),
                ),
                if (widgetAccion != null) ...[
                  const SizedBox(width: 16),
                  widgetAccion!,
                ],
              ],
            ),
    );
  }
}
