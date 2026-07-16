import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dominio/modelos/producto_modelo.dart';

class FuenteDatosProductos {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Producto>> obtenerProductos() async {
    final respuesta = await _supabase
        .from('productos')
        .select()
        .order('created_at', ascending: false);

    return (respuesta as List)
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Producto> crearProducto(Producto producto) async {
    final respuesta = await _supabase
        .from('productos')
        .insert({
          'nombre': producto.nombre,
          'descripcion': producto.descripcion,
          'estado_activo': producto.estadoActivo,
        })
        .select()
        .single();

    return Producto.fromJson(respuesta);
  }

  Future<Producto> actualizarProducto(Producto producto) async {
    final respuesta = await _supabase
        .from('productos')
        .update(producto.toJson())
        .eq('id', producto.id)
        .select()
        .single();

    return Producto.fromJson(respuesta);
  }

  Future<void> eliminarProducto(String id) async {
    // Delete lógico
    await _supabase
        .from('productos')
        .update({'estado_activo': false})
        .eq('id', id);
  }
}
