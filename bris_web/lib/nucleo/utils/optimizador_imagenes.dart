class OptimizadorImagenes {
  /// Transforma una URL pública de Supabase Storage para utilizar
  /// la funcionalidad de Image Transformations de Supabase.
  /// 
  /// Solo aplica si la URL contiene `/storage/v1/object/public/`.
  static String optimizarSupabaseUrl(String originalUrl, {int width = 400, int quality = 70}) {
    if (originalUrl.isEmpty) return originalUrl;
    
    // Si ya fue transformada, no la tocamos
    if (originalUrl.contains('/render/image/public/')) return originalUrl;

    if (originalUrl.contains('/storage/v1/object/public/')) {
      return originalUrl.replaceFirst(
        '/storage/v1/object/public/', 
        '/storage/v1/render/image/public/'
      ) + '?width=$width&quality=$quality';
    }
    
    return originalUrl;
  }
}
