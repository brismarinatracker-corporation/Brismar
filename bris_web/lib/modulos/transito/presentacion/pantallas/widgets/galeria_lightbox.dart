import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bris_web/nucleo/componentes/carga_orbital.dart';

class GaleriaLightbox {
  static void mostrar(
    BuildContext context,
    List<String> urls,
    int indiceInicial,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        int indiceLocal = indiceInicial;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: urls[indiceLocal],
                        placeholder: (context, url) =>
                            const Center(child: CargaOrbital(tamano: 60)),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (urls.length > 1)
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        radius: 28,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              indiceLocal =
                                  (indiceLocal - 1 + urls.length) % urls.length;
                            });
                          },
                        ),
                      ),
                    ),
                  if (urls.length > 1)
                    Positioned(
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        radius: 28,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              indiceLocal = (indiceLocal + 1) % urls.length;
                            });
                          },
                        ),
                      ),
                    ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      radius: 24,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Foto ${indiceLocal + 1} de ${urls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
