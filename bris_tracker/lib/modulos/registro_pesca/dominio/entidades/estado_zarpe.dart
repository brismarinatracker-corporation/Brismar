enum EstadoZarpe {
  despachadoPiura,
  recibidoLambayeque,
  desconocido;

  static EstadoZarpe desdeString(String? valor) {
    if (valor == null) return EstadoZarpe.despachadoPiura;

    switch (valor.toUpperCase()) {
      case 'DESPACHADO_PIURA':
        return EstadoZarpe.despachadoPiura;
      case 'RECIBIDO_LAMBAYEQUE':
        return EstadoZarpe.recibidoLambayeque;
      default:
        return EstadoZarpe.desconocido;
    }
  }

  String get valor {
    switch (this) {
      case EstadoZarpe.despachadoPiura:
        return 'DESPACHADO_PIURA';
      case EstadoZarpe.recibidoLambayeque:
        return 'RECIBIDO_LAMBAYEQUE';
      case EstadoZarpe.desconocido:
        return 'DESCONOCIDO';
    }
  }
}
