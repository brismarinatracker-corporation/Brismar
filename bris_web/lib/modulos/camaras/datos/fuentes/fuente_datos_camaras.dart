import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dominio/modelos/camara_modelo.dart';

class FuenteDatosCamaras {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Camara>> obtenerCamaras() async {
    final respuesta = await _supabase
        .from('camaras')
        .select()
        .order('created_at', ascending: false);

    return (respuesta as List)
        .map((e) => Camara.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Camara> crearCamara(Camara camara) async {
    final respuesta = await _supabase
        .from('camaras')
        .insert({
          'placa': camara.placa.toUpperCase(),
          'chofer': camara.chofer,
          'marca': camara.marca,
          'capacidad_kg': camara.capacidadKg,
          'estado_activo': camara.estadoActivo,
        })
        .select()
        .single();

    return Camara.fromJson(respuesta);
  }

  Future<Camara> actualizarCamara(Camara camara) async {
    final respuesta = await _supabase
        .from('camaras')
        .update(camara.toJson())
        .eq('id', camara.id)
        .select()
        .single();

    return Camara.fromJson(respuesta);
  }

  Future<void> eliminarCamara(String id) async {
    // Delete lógico
    await _supabase
        .from('camaras')
        .update({'estado_activo': false})
        .eq('id', id);
  }
}
