import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../datos/fuente_datos_maestros.dart';
import '../../dominio/modelos/maestros_modelo.dart';

// Proveedor de la fuente de datos
final fuenteDatosMaestrosProvider = Provider<FuenteDatosMaestros>((ref) {
  return FuenteDatosMaestros(Supabase.instance.client);
});

class EstadoMaestros {
  final bool cargando;
  final String? error;
  final List<EspecieModelo> especies;
  final List<TipoGastoModelo> tiposGasto;

  const EstadoMaestros({
    this.cargando = false,
    this.error,
    this.especies = const [],
    this.tiposGasto = const [],
  });

  EstadoMaestros copiarCon({
    bool? cargando,
    String? error,
    List<EspecieModelo>? especies,
    List<TipoGastoModelo>? tiposGasto,
  }) {
    return EstadoMaestros(
      cargando: cargando ?? this.cargando,
      error: error,
      especies: especies ?? this.especies,
      tiposGasto: tiposGasto ?? this.tiposGasto,
    );
  }
}

class ControladorMaestros extends AsyncNotifier<EstadoMaestros> {
  late FuenteDatosMaestros _fuenteDatos;

  @override
  Future<EstadoMaestros> build() async {
    _fuenteDatos = ref.read(fuenteDatosMaestrosProvider);
    return await cargarMaestros();
  }

  Future<EstadoMaestros> cargarMaestros() async {
    state = const AsyncValue.loading();
    try {
      final especies = await _fuenteDatos.obtenerEspecies();
      final tiposGasto = await _fuenteDatos.obtenerTiposGasto();

      final newState = EstadoMaestros(
        cargando: false,
        especies: especies,
        tiposGasto: tiposGasto,
      );
      state = AsyncValue.data(newState);
      return newState;
    } on Exception catch (e) {
      final errState = EstadoMaestros(cargando: false, error: e.toString());
      state = AsyncValue.error(e, StackTrace.current);
      return errState;
    }
  }
}

final controladorMaestrosProvider = AsyncNotifierProvider<ControladorMaestros, EstadoMaestros>(
  () => ControladorMaestros(),
);
