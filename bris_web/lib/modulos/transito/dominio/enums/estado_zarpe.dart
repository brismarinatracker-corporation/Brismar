// ============================================================
// Módulo   : Tránsito — Web Admin
// Archivo  : estado_zarpe.dart
// Propósito: Enumeraciones de dominio para el módulo de Zarpes.
// ============================================================

/// Estados posibles de un zarpe/cámara en el sistema.
///
/// Elimina los magic strings dispersos por el código. Cualquier cambio
/// de nombre en la DB falla en compile time, no en runtime.
enum EstadoZarpe {
  /// Zarpe registrado en la aplicación móvil, en tránsito hacia Piura.
  despachado('DESPACHADO_PIURA'),

  /// Zarpe recibido en Lambayeque/planta procesadora.
  recibido('RECIBIDO_LAMBAYEQUE'),

  /// Zarpe pendiente de procesamiento.
  pendiente('PENDIENTE'),

  /// Estado desconocido o no mapeado desde la base de datos.
  desconocido('DESCONOCIDO');

  /// Valor exacto almacenado en la columna `estado` de Supabase.
  final String valorDb;

  const EstadoZarpe(this.valorDb);

  /// Construye desde el string de la base de datos.
  ///
  /// Retorna [EstadoZarpe.desconocido] si el valor no está mapeado,
  /// en lugar de lanzar una excepción en runtime.
  factory EstadoZarpe.desdeDb(String? valor) {
    if (valor == null) return EstadoZarpe.desconocido;
    return EstadoZarpe.values.firstWhere(
      (e) => e.valorDb == valor.toUpperCase(),
      orElse: () => EstadoZarpe.desconocido,
    );
  }

  /// Etiqueta legible para mostrar en la UI.
  String get etiqueta => switch (this) {
        EstadoZarpe.despachado => 'En Tránsito',
        EstadoZarpe.recibido => 'Recibido',
        EstadoZarpe.pendiente => 'Pendiente',
        EstadoZarpe.desconocido => 'Desconocido',
      };

  /// Indica si el zarpe ya fue procesado en la planta.
  bool get estaFinalizado => this == EstadoZarpe.recibido;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Especies de pesca manejadas en el sistema.
///
/// Centraliza la lista de especies para formularios y filtros,
/// eliminando los string arrays hardcodeados en los diálogos.
enum EspeciePesca {
  pota('POTA'),
  jurel('JUREL'),
  bonito('BONITO'),
  caballa('CABALLA'),
  perico('PERICO');

  /// Valor almacenado en la base de datos y mostrado en la UI.
  final String valor;

  const EspeciePesca(this.valor);

  /// Lista de todos los valores de string para DropdownButtonFormField.
  static List<String> get todos => EspeciePesca.values.map((e) => e.valor).toList();

  /// Construye desde string, retorna [EspeciePesca.pota] como defecto.
  factory EspeciePesca.desdeString(String? valor) {
    return EspeciePesca.values.firstWhere(
      (e) => e.valor == valor?.toUpperCase(),
      orElse: () => EspeciePesca.pota,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Tipos de gasto operativo.
enum TipoGasto {
  muelle('MUELLE'),
  flete('FLETE'),
  otros('OTROS');

  final String valor;
  const TipoGasto(this.valor);

  static List<String> get todos => TipoGasto.values.map((e) => e.valor).toList();

  factory TipoGasto.desdeString(String? valor) => TipoGasto.values.firstWhere(
        (e) => e.valor == valor?.toUpperCase(),
        orElse: () => TipoGasto.otros,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

/// Conceptos de gasto disponibles.
enum ConceptoGasto {
  facturacion('FACTURACION'),
  personal('PERSONAL'),
  apoyo('APOYO'),
  agua('AGUA'),
  pesador('PESADOR'),
  clorox('CLOROX'),
  hielo('HIELO'),
  flete('FLETE'),
  otros('OTROS');

  final String valor;
  const ConceptoGasto(this.valor);

  static List<String> get todos => ConceptoGasto.values.map((e) => e.valor).toList();

  factory ConceptoGasto.desdeString(String? valor) => ConceptoGasto.values.firstWhere(
        (e) => e.valor == valor?.toUpperCase(),
        orElse: () => ConceptoGasto.otros,
      );
}
