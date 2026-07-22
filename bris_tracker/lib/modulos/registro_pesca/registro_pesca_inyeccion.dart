import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';

import 'datos/fuentes_datos/fuente_datos_cuadres_local.dart';
import 'datos/fuentes_datos/fuente_datos_cuadres_remota.dart';
import 'datos/repositorios/cuadre_repositorio_imp.dart';

import 'datos/fuentes_datos/fuente_datos_zarpes_local.dart';
import 'datos/fuentes_datos/fuente_datos_zarpes_remota.dart';
import 'datos/repositorios/zarpe_repositorio_imp.dart';

// --- ZARPES ---
final proveedorFuenteZarpesLocal = Provider<FuenteDatosZarpesLocal>((ref) {
  return FuenteDatosZarpesLocal(GestorBaseDatos.instance);
});

final proveedorFuenteZarpesRemota = Provider<FuenteDatosZarpesRemota>((ref) {
  return FuenteDatosZarpesRemota(Supabase.instance.client);
});

final proveedorZarpeRepositorio = Provider<ZarpeRepositorioImp>((ref) {
  return ZarpeRepositorioImp(
    local: ref.read(proveedorFuenteZarpesLocal),
    remota: ref.read(proveedorFuenteZarpesRemota),
  );
});

// --- CUADRES ---
final cuadreRepositorioProvider = Provider<CuadreRepositorioImp>((ref) {
  final local = FuenteDatosCuadresLocal(GestorBaseDatos.instance);
  final remota = FuenteDatosCuadresRemota(Supabase.instance.client);
  return CuadreRepositorioImp(local: local, remota: remota);
});
