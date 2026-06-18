/// Preferencia de método de acceso rápido diario del usuario.
///
/// Definida en el FLUJO_01_AUTENTICACION.bpmn — Gateway_QuickAccessType.
/// Se configura tras el primer login exitoso y se persiste en la Bóveda Segura.
enum PreferenciaAcceso {
  /// Acceso rápido mediante PIN numérico de 4 dígitos.
  pin,

  /// Acceso rápido mediante huella digital (biometría del dispositivo).
  huella;

  /// Convierte un String guardado en la bóveda a [PreferenciaAcceso].
  ///
  /// Retorna [PreferenciaAcceso.pin] por defecto si el valor es desconocido.
  static PreferenciaAcceso fromString(String? valor) {
    if (valor == 'huella') return PreferenciaAcceso.huella;
    return PreferenciaAcceso.pin;
  }

  /// Convierte la preferencia a String para persistencia en la bóveda.
  String toStorageString() => name;
}
