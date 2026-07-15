import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../autenticacion/presentacion/controladores/controlador_autenticacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bris_web/compartido/widgets/cabecera_pagina_web.dart';

class PantallaPerfil extends ConsumerStatefulWidget {
  const PantallaPerfil({super.key});

  @override
  ConsumerState<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends ConsumerState<PantallaPerfil> {
  bool _editando = false;
  bool _subiendoFoto = false;
  late TextEditingController _nombreCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _subirNuevaFoto(BuildContext context, String userId) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _subiendoFoto = true);
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final ext = image.name.split('.').last;
        final ruta = 'avatar_$userId.$ext';
        
        await Supabase.instance.client.storage.from('avatars').uploadBinary(
          ruta,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
        
        final urlPublica = Supabase.instance.client.storage.from('avatars').getPublicUrl(ruta);
        final urlConCacheBuster = '$urlPublica?t=${DateTime.now().millisecondsSinceEpoch}';
        
        await ref.read(proveedorAutenticacion.notifier).actualizarPerfil(fotoPerfil: urlConCacheBuster);
        
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Foto de perfil actualizada con éxito'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al subir la foto: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _guardarNombre() async {
    if (_nombreCtrl.text.trim().isEmpty) return;
    
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _subiendoFoto = true);
    try {
      await ref.read(proveedorAutenticacion.notifier).actualizarPerfil(nombreReal: _nombreCtrl.text.trim());
      setState(() {
        _editando = false;
      });
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Nombre actualizado con éxito'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estadoAuth = ref.watch(proveedorAutenticacion);
    final nombre = estadoAuth.nombreReal ?? 'Usuario';
    final correo = estadoAuth.usuario?.email ?? 'Sin correo';
    final rol = (estadoAuth.rol ?? 'Rol no definido').toUpperCase();
    final sede = (estadoAuth.sede ?? 'Sede no definida').toUpperCase();
    final esMovil = MediaQuery.of(context).size.width < 600;

    if (!_editando) {
      _nombreCtrl.text = nombre;
    }

    return Container(
      color: const Color(0xFFF2F6F3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CabeceraPaginaWeb(
            titulo: 'Mi Perfil',
            subtitulo: 'Información de tu cuenta y sesión activa.',
          ),
          // Main profile card
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(esMovil ? 16 : 40),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(esMovil ? 20 : 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Flex(
                        direction: esMovil ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: esMovil ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                        children: [
                          // Avatar Stack with Hover Camera Icon
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00796B).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF00796B).withValues(alpha: 0.3), width: 2),
                                  image: estadoAuth.fotoPerfil != null && estadoAuth.fotoPerfil!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(estadoAuth.fotoPerfil!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: estadoAuth.fotoPerfil == null || estadoAuth.fotoPerfil!.isEmpty
                                    ? Center(
                                        child: Text(
                                          nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
                                          style: const TextStyle(
                                            color: Color(0xFF00796B),
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              if (_subiendoFoto)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black38,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Color(0xFF00796B)),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Tooltip(
                                  message: 'Cambiar foto de perfil',
                                  child: Material(
                                    color: const Color(0xFF00796B),
                                    shape: const CircleBorder(),
                                    elevation: 4,
                                    child: InkWell(
                                      onTap: _subiendoFoto ? null : () => _subirNuevaFoto(context, estadoAuth.usuario!.id),
                                      customBorder: const CircleBorder(),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: esMovil ? 0 : 32, height: esMovil ? 24 : 0),
                          
                          // Details Section
                          Builder(builder: (ctx) {
                            final details = Column(
                              crossAxisAlignment: esMovil ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                              children: [
                                Flex(
                                  direction: esMovil ? Axis.vertical : Axis.horizontal,
                                  mainAxisAlignment: esMovil ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                                  children: [
                                    _editando
                                        ? SizedBox(
                                            width: esMovil ? double.infinity : 300,
                                            child: TextFormField(
                                              controller: _nombreCtrl,
                                              textAlign: esMovil ? TextAlign.center : TextAlign.start,
                                              style: const TextStyle(color: Color(0xFF15181A), fontSize: 22, fontWeight: FontWeight.bold),
                                              decoration: InputDecoration(
                                                hintText: 'Tu nombre',
                                                filled: true,
                                                fillColor: const Color(0xFFF8FAFC),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00796B))),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            nombre,
                                            textAlign: esMovil ? TextAlign.center : TextAlign.start,
                                            style: const TextStyle(
                                              color: Color(0xFF15181A),
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    SizedBox(height: esMovil ? 16 : 0, width: esMovil ? 0 : 16),
                                    if (!_editando)
                                      OutlinedButton.icon(
                                        onPressed: () => setState(() => _editando = true),
                                        icon: const Icon(Icons.edit_rounded, size: 16),
                                        label: const Text('Editar'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF00796B),
                                          side: const BorderSide(color: Color(0xFF00796B)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment: esMovil ? MainAxisAlignment.center : MainAxisAlignment.start,
                                        children: [
                                          TextButton(
                                            onPressed: () => setState(() => _editando = false),
                                            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: _guardarNombre,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF00796B),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Guardar'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  correo,
                                  textAlign: esMovil ? TextAlign.center : TextAlign.start,
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: esMovil ? WrapAlignment.center : WrapAlignment.start,
                                  children: [
                                    _InfoChip(icono: Icons.admin_panel_settings_rounded, titulo: 'Rol', valor: rol),
                                    _InfoChip(icono: Icons.location_on_rounded, titulo: 'Sede', valor: sede),
                                  ],
                                ),
                              ],
                            );
                            
                            return esMovil ? details : Expanded(child: details);
                          }),
                        ],
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
}

class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _InfoChip({required this.icono, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: const Color(0xFF00796B), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  color: Color(0xFF15181A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
