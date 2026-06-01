import os
import re

script_dir = os.path.dirname(os.path.abspath(__file__))
issues_file = os.path.join(script_dir, '../docs/ISSUES.md')
pubspec_file = os.path.join(script_dir, '../pubspec.yaml')

with open(issues_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_prs = False
in_issues = False
x1_funcional = "1" # Default
x2_prs = 0
x3_issues = 0

for line in lines:
    # 1. Buscar Versión Funcional (X1)
    match_x1 = re.search(r'# VERSIÓN FUNCIONAL:\s*([0-9]+)', line)
    if match_x1:
        x1_funcional = match_x1.group(1)
        
    # 2. Controladores de sección
    if line.startswith('## [Pull Requests Fusionados]'):
        in_prs = True
        in_issues = False
    elif line.startswith('## [Issues Resueltos]'):
        in_prs = False
        in_issues = True
    elif line.startswith('## [En Progreso]') or line.startswith('## [Abiertas]') or line.startswith('---') or line.startswith('# VERSIONES'):
        in_prs = False
        in_issues = False
        
    # 3. Contar PRs (X2)
    if in_prs and re.match(r'^-\s*PR\s*#', line):
        x2_prs += 1
        
    # 4. Contar Issues (X3)
    if in_issues and re.match(r'^-\s*\*\*Issue\s*#', line):
        x3_issues += 1

print(f"📊 Análisis de Arquitectura Semántica:")
print(f"   - X1 (Versión Funcional): {x1_funcional}")
print(f"   - X2 (Pull Requests): {x2_prs}")
print(f"   - X3 (Issues Resueltos): {x3_issues}")

with open(pubspec_file, 'r', encoding='utf-8') as f:
    pubspec_content = f.read()

# Construir la nueva versión matemática (X1.X2.X3+X3)
new_version_string = f"version: {x1_funcional}.{x2_prs}.{x3_issues}+{x3_issues}"

new_pubspec_content = re.sub(r'^version:\s*.*$', new_version_string, pubspec_content, flags=re.MULTILINE)

if new_pubspec_content != pubspec_content:
    with open(pubspec_file, 'w', encoding='utf-8') as f:
        f.write(new_pubspec_content)
    print(f"🚀 ¡Éxito! pubspec.yaml actualizado dinámicamente a la versión: {new_version_string}")
else:
    print(f"ℹ️ La versión en pubspec.yaml ya está sincronizada: {new_version_string}")
