import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget responsable de renderizar y gestionar la lista de fotografías de evidencia
/// para el formulario de zarpe.
///
/// Sigue el principio de Responsabilidad Única (SRP): solo se encarga de la presentación
/// y captura de las imágenes de evidencia.
class SeccionFotosEvidencia extends StatelessWidget {
  final List<XFile> fotosEvidencia;
  final VoidCallback onMostrarOpciones;
  final ValueChanged<int> onEliminarFoto;

  const SeccionFotosEvidencia({
    super.key,
    required this.fotosEvidencia,
    required this.onMostrarOpciones,
    required this.onEliminarFoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fotos de evidencia',
              style: TextStyle(
                color: Color(0xFF006B54),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '(${fotosEvidencia.length}/3)',
              style: const TextStyle(
                color: Color(0xFF006B54),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (fotosEvidencia.isEmpty)
          GestureDetector(
            onTap: onMostrarOpciones,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFA8D5BA),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: Color(0xFF006B54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tomar foto',
                    style: TextStyle(
                      color: Color(0xFF006B54),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Al menos 1 foto requerida',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  fotosEvidencia.length + (fotosEvidencia.length < 3 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == fotosEvidencia.length) {
                  return GestureDetector(
                    onTap: onMostrarOpciones,
                    child: Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFA8D5BA),
                          width: 1.5,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: Color(0xFF006B54),
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Añadir',
                            style: TextStyle(
                              color: Color(0xFF006B54),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final foto = fotosEvidencia[index];
                return Stack(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 130,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(
                                  foto.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(foto.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => onEliminarFoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
