import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado inmutable para el formulario de registro.
/// Almacena los cálculos financieros para no mezclarlos con los Widgets.
class RegistroFormState {
  final double kilosTotales;
  final double precioVenta;
  final double totalVenta;
  final double totalGastos;
  final double totalNeto;
  final String? productoSeleccionado;

  const RegistroFormState({
    this.kilosTotales = 0.0,
    this.precioVenta = 0.0,
    this.totalVenta = 0.0,
    this.totalGastos = 0.0,
    this.totalNeto = 0.0,
    this.productoSeleccionado,
  });

  RegistroFormState copyWith({
    double? kilosTotales,
    double? precioVenta,
    double? totalVenta,
    double? totalGastos,
    double? totalNeto,
    String? productoSeleccionado,
  }) {
    return RegistroFormState(
      kilosTotales: kilosTotales ?? this.kilosTotales,
      precioVenta: precioVenta ?? this.precioVenta,
      totalVenta: totalVenta ?? this.totalVenta,
      totalGastos: totalGastos ?? this.totalGastos,
      totalNeto: totalNeto ?? this.totalNeto,
      productoSeleccionado: productoSeleccionado ?? this.productoSeleccionado,
    );
  }
}

/// Controlador (Notifier) encargado de aplicar las reglas de negocio matemático
/// (Responsabilidad Única) separando los cálculos financieros de la pantalla visual.
class RegistroFormController extends StateNotifier<RegistroFormState> {
  RegistroFormController() : super(const RegistroFormState());

  /// Actualiza el tipo de pescado o producto seleccionado.
  void seleccionarProducto(String? producto) {
    state = state.copyWith(productoSeleccionado: producto);
  }

  /// Calcula dinámicamente los totales basados en los inputs del usuario.
  void calcularTotales({
    required double kilos,
    required double precioVenta,
    required double gFacturacion,
    required double gPersonal,
    required double gApoyo,
    required double gAgua,
    required double gClorox,
    required double gFlete,
    required double gHielo,
    required double gPesador,
    required double gOtros,
  }) {
    final tVenta = kilos * precioVenta;
    final tGastos =
        gFacturacion +
        gPersonal +
        gApoyo +
        gAgua +
        gClorox +
        gFlete +
        gHielo +
        gPesador +
        gOtros;
    final tNeto = tVenta - tGastos;

    state = state.copyWith(
      kilosTotales: kilos,
      precioVenta: precioVenta,
      totalVenta: tVenta,
      totalGastos: tGastos,
      totalNeto: tNeto,
    );
  }

  /// Limpia el estado interno.
  void limpiar() {
    state = const RegistroFormState();
  }
}

/// Proveedor para acceder al estado del formulario desde cualquier componente.
final proveedorRegistroFormController =
    StateNotifierProvider<RegistroFormController, RegistroFormState>((ref) {
      return RegistroFormController();
    });
