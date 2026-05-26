# Graph Report - brismar_mobile  (2026-05-26)

## Corpus Check
- 64 files · ~27,787 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 337 nodes · 335 edges · 42 communities (30 shown, 12 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `57af3ff1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 10 edges
2. `AppDelegate` - 8 edges
3. `Create()` - 6 edges
4. `Destroy()` - 6 edges
5. `package:flutter_riverpod/flutter_riverpod.dart` - 5 edges
6. `../../dominio/entidades/registro_entidad.dart` - 5 edges
7. `MessageHandler()` - 5 edges
8. `RunnerTests` - 4 edges
9. `OnCreate()` - 4 edges
10. `WndProc()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/flutter/generated_plugin_registrant.cc
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp

## Communities (42 total, 12 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.06
Nodes (34): ../../../autenticacion/presentacion/controladores/auth_controlador.dart, ../componentes/historial_lista.dart, ../componentes/seccion_totales.dart, ../componentes/tab_selector.dart, ../componentes/user_header.dart, ../controladores/registro_controlador.dart, AppBar, build (+26 more)

### Community 1 - "Community 1"
Cohesion: 0.07
Nodes (26): ../../datos/fuentes_datos/auth_remoto_datasource.dart, ../../datos/repositorios/auth_repositorio_imp.dart, ../../dominio/entidades/usuario.dart, ../../dominio/repositorios/auth_repositorio.dart, ../fuentes_datos/auth_remoto_datasource.dart, AuthRemotoDatasource, Exception, _iniciarSesionSimulado (+18 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (26): AppBar, build, _buildAppBar, _buildBotonRegistrar, _buildCardWrapper, _buildMiniLabel, _buildSeccionEmbarcaciones, _buildSeccionGastos (+18 more)

### Community 3 - "Community 3"
Cohesion: 0.09
Nodes (21): ../../datos/fuentes_datos/registro_local_datasource.dart, ../../datos/fuentes_datos/registro_remoto_datasource.dart, ../../datos/repositorios/registro_repositorio_imp.dart, ../../dominio/casos_uso/guardar_registro_caso_uso.dart, ../../dominio/casos_uso/obtener_historial_caso_uso.dart, ../../dominio/casos_uso/sincronizar_pendientes_caso_uso.dart, ../../dominio/entidades/registro_entidad.dart, ../../dominio/repositorios/registro_repositorio.dart (+13 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (21): build, _buildMiniLabel, Column, Container, Divider, SeccionTotales, build, _buildTabItem (+13 more)

### Community 5 - "Community 5"
Cohesion: 0.14
Nodes (18): RegisterPlugins(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle(), GetWindowClass() (+10 more)

### Community 6 - "Community 6"
Cohesion: 0.1
Nodes (18): ../controladores/auth_controlador.dart, build, main, MyApp, ProviderScope, build, dispose, Icon (+10 more)

### Community 7 - "Community 7"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 8 - "Community 8"
Cohesion: 0.15
Nodes (12): build, _buildCardRegistro, _buildDetalleCard, _buildEncabezadoCard, _buildIconoSincronizacion, Card, Center, Divider (+4 more)

### Community 9 - "Community 9"
Cohesion: 0.18
Nodes (9): Exception, RegistroLocalDatasource, DatabaseHelper, openDatabase, registro_embarcaciones, ../modelos/registro_modelo.dart, ../../../../nucleo/base_datos/database_helper.dart, package:path/path.dart (+1 more)

### Community 10 - "Community 10"
Cohesion: 0.22
Nodes (6): ../entidades/registro_entidad.dart, GuardarRegistroCasoUso, ObtenerHistorialCasoUso, SincronizarPendientesCasoUso, RegistroRepositorio, ../repositorios/registro_repositorio.dart

### Community 11 - "Community 11"
Cohesion: 0.2
Nodes (9): build, _buildInfoFecha, _buildInfoUsuario, CircleAvatar, Container, Row, SizedBox, Text (+1 more)

### Community 12 - "Community 12"
Cohesion: 0.22
Nodes (3): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate

### Community 13 - "Community 13"
Cohesion: 0.25
Nodes (7): build, _buildListOption, Card, HomeScreen, Scaffold, SizedBox, profile_screen.dart

### Community 14 - "Community 14"
Cohesion: 0.25
Nodes (7): dart:io, PdfHelper, _savePdfFile, ../../modulos/registro/dominio/entidades/registro_entidad.dart, package:path_provider/path_provider.dart, package:pdf/pdf.dart, package:pdf/widgets.dart

### Community 15 - "Community 15"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 16 - "Community 16"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 20 - "Community 20"
Cohesion: 0.5
Nodes (3): Exception, SecureStorageHelper, package:flutter_secure_storage/flutter_secure_storage.dart

### Community 21 - "Community 21"
Cohesion: 0.5
Nodes (3): main, package:brismar_mobile/modulos/registro/dominio/entidades/registro_entidad.dart, package:flutter_test/flutter_test.dart

## Knowledge Gaps
- **197 isolated node(s):** `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `HomeScreen`, `build` (+192 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 4` to `Community 0`, `Community 2`, `Community 6`, `Community 8`, `Community 11`, `Community 13`?**
  _High betweenness centrality (0.218) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 6` to `Community 0`, `Community 1`, `Community 3`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Why does `../../dominio/entidades/registro_entidad.dart` connect `Community 3` to `Community 8`, `Community 0`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **What connects `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _197 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._