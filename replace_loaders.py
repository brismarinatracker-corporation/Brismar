import os
import re

def process_file(filepath, import_path):
    with open(filepath, 'r') as f:
        content = f.read()

    # Import
    if 'CircularProgressIndicator' in content and 'carga_orbital.dart' not in content:
        # Find last import
        imports = re.findall(r'^import .*?;', content, re.MULTILINE)
        if imports:
            last_import = imports[-1]
            content = content.replace(last_import, f"{last_import}\nimport '{import_path}';")

    # Replace CircularProgressIndicator
    # Center(child: CircularProgressIndicator(...)) -> Center(child: CargaOrbital(tamaño: 80))
    # SizedBox(width: X, height: X, child: CircularProgressIndicator(...)) -> CargaOrbital(tamaño: X)
    
    # 1. Big loaders
    content = re.sub(r'CircularProgressIndicator\([^)]*\)', 'CargaOrbital(tamaño: 80)', content)
    # 2. In case of no args
    content = re.sub(r'CircularProgressIndicator\(\)', 'CargaOrbital(tamaño: 80)', content)

    # 3. Clean up SizedBox wrapped ones
    content = re.sub(r'SizedBox\(\s*width:\s*(\d+),\s*height:\s*\d+,\s*child:\s*CargaOrbital\(tamaño: 80\)\s*\)', r'CargaOrbital(tamaño: \1)', content)

    with open(filepath, 'w') as f:
        f.write(content)

# Web Admin files
web_files = [
    'brismar_web_admin/lib/modulos/dashboard/presentacion/pantallas/pantalla_dashboard.dart',
    'brismar_web_admin/lib/modulos/cuadres/presentacion/pantallas/pantalla_cuadres.dart',
    'brismar_web_admin/lib/modulos/usuarios/presentacion/pantallas/pantalla_usuarios.dart',
    'brismar_web_admin/lib/modulos/transito/presentacion/pantallas/pantalla_transito.dart',
    'brismar_web_admin/lib/modulos/transito/presentacion/pantallas/pantalla_edicion_transito.dart',
    'brismar_web_admin/lib/modulos/autenticacion/presentacion/pantallas/pantalla_login.dart',
    'brismar_web_admin/lib/modulos/usuarios/presentacion/widgets/dialogo_formulario_usuario.dart'
]

for wf in web_files:
    if os.path.exists(wf):
        # Calculate import path relative to the file. Easy hack: use package absolute path
        process_file(wf, 'package:brismar_web_admin/nucleo/componentes/carga_orbital.dart')

app_files = [
    'brismar_app/lib/modulos/registro_pesca/presentacion/pantallas/dashboard_cuadres.dart',
    'brismar_app/lib/modulos/registro_pesca/presentacion/pantallas/formulario_cuadre_tabs.dart',
    'brismar_app/lib/modulos/registro_pesca/presentacion/pantallas/formulario_zarpe_pantalla.dart',
    'brismar_app/lib/modulos/autenticacion/presentacion/pantallas/login_pantalla.dart',
    'brismar_app/lib/modulos/autenticacion/presentacion/pantallas/configurar_biometria_pantalla.dart',
    'brismar_app/lib/modulos/autenticacion/presentacion/pantallas/acceso_rapido_pantalla.dart',
    'brismar_app/lib/modulos/autenticacion/presentacion/componentes/formulario_login.dart',
    'brismar_app/lib/modulos/registro_pesca/presentacion/widgets/panel_calculo_vivo.dart'
]

for af in app_files:
    if os.path.exists(af):
        process_file(af, 'package:brismar_app/nucleo/componentes/carga_orbital.dart')

print("Replaced successfully!")
