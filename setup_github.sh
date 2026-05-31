#!/bin/bash
# ============================================
# BRISMAR_APP — Setup GitHub Issues & Labels
# Ejecutar después de: sudo dnf install -y gh && gh auth login
# ============================================

REPO="SuyonRiccy/BRISMAR_APP"

echo "🏷️  Creando Labels..."
gh label create "priority:high"   --color "B60205" --description "Prioridad alta"       --repo $REPO 2>/dev/null
gh label create "priority:medium" --color "FBCA04" --description "Prioridad media"      --repo $REPO 2>/dev/null
gh label create "priority:low"    --color "0E8A16" --description "Prioridad baja"       --repo $REPO 2>/dev/null
gh label create "feature"         --color "1D76DB" --description "Nueva funcionalidad"  --repo $REPO 2>/dev/null
gh label create "ui"              --color "5319E7" --description "Interfaz de usuario"  --repo $REPO 2>/dev/null
gh label create "backend"         --color "D93F0B" --description "Backend / Supabase"   --repo $REPO 2>/dev/null
gh label create "setup"           --color "C2E0C6" --description "Configuración"        --repo $REPO 2>/dev/null
gh label create "docs"            --color "0075CA" --description "Documentación"        --repo $REPO 2>/dev/null
gh label create "refactor"        --color "E4E669" --description "Refactorización"      --repo $REPO 2>/dev/null

echo ""
echo "📋  Creando Issues..."

gh issue create --repo $REPO \
  --title "Portar UI profesional del login a Clean Architecture" \
  --body "## Descripción
Tomar el diseño del login de la rama test1 (eliminada) que tenía:
- Animaciones FadeTransition + SlideTransition
- Orbes radiales decorativos (cyan glow)
- Botón con gradiente y sombra glow
- Toggle de visibilidad de contraseña
- Divisor decorativo con punto central

Y portarlo a \`login_pantalla.dart\` dentro de la Clean Architecture actual.

## Archivos
- \`lib/modulos/autenticacion/presentacion/pantallas/login_pantalla.dart\`

## Credenciales de test
- Usuario: \`usuario\` / Contraseña: \`1234\`" \
  --label "enhancement,ui,priority:high"

gh issue create --repo $REPO \
  --title "Configurar Supabase con credenciales reales" \
  --body "## Descripción
Reemplazar la URL de plantilla en \`supabase_client.dart\` con las credenciales reales del proyecto Supabase de Brismar.

## Archivos
- \`lib/nucleo/red/supabase_client.dart\`

## Tareas
- [ ] Crear proyecto en Supabase
- [ ] Crear tabla \`usuarios\` (id, nombre_real, rol)
- [ ] Actualizar URL y anon key
- [ ] Probar login real" \
  --label "setup,backend,priority:high"

gh issue create --repo $REPO \
  --title "Implementar flujo de registro completo con Supabase" \
  --body "## Descripción
Conectar el módulo de registro de embarcaciones con Supabase para persistir datos en la nube.

## Tareas
- [ ] Crear tablas en Supabase (registros, embarcaciones, gastos)
- [ ] Actualizar \`registro_remoto_datasource.dart\`
- [ ] Implementar sincronización offline → online
- [ ] Validar datos antes de enviar" \
  --label "feature,backend,priority:high"

gh issue create --repo $REPO \
  --title "Implementar pantalla de Historial" \
  --body "## Descripción
Crear pantalla de historial para consultar registros anteriores con filtros por fecha y embarcación.

## Archivos
- \`lib/modulos/registro/presentacion/pantallas/historial_pantalla.dart\`" \
  --label "feature,ui,priority:medium"

gh issue create --repo $REPO \
  --title "Implementar pantalla de Sincronización" \
  --body "## Descripción
Crear pantalla que muestre registros pendientes de sincronizar y permita sincronización manual.

## Archivos
- \`lib/modulos/registro/presentacion/pantallas/sync_pantalla.dart\`" \
  --label "feature,ui,priority:medium"

gh issue create --repo $REPO \
  --title "Implementar pantalla de Perfil de usuario" \
  --body "## Descripción
Crear pantalla de perfil con datos del usuario logueado, opción de cerrar sesión y editar perfil.

## Archivos
- \`lib/modulos/autenticacion/presentacion/pantallas/perfil_pantalla.dart\`" \
  --label "feature,ui,priority:low"

gh issue create --repo $REPO \
  --title "Generar reportes PDF desde la app" \
  --body "## Descripción
Implementar generación de reportes diarios en PDF con los datos de registro.

## Archivos
- \`lib/nucleo/utilidades/pdf_helper.dart\`" \
  --label "feature,priority:medium"

gh issue create --repo $REPO \
  --title "Proteger rama main con branch protection rules" \
  --body "## Descripción
Configurar reglas de protección para la rama main:
- Requerir pull request antes de merge
- Requerir al menos 1 review
- No permitir force push

## Pasos
Settings → Branches → Add rule → main" \
  --label "setup,priority:medium"

gh issue create --repo $REPO \
  --title "Refactorizar login_pantalla.dart para usar LoginForm (Deduplicación de código)" \
  --body "## Descripción
La pantalla \`login_pantalla.dart\` actualmente contiene todo el código del formulario de login de forma inline, duplicando el código ya encapsulado en \`LoginForm\`.

## Tareas
- [ ] Eliminar los controladores de texto locales de la pantalla.
- [ ] Remover el Form inline y reemplazarlo por \`LoginForm()\`.
- [ ] Asegurarse de mantener la escucha de estados del controlador para navegación y alertas.
- [ ] Verificar que no haya errores estáticos." \
  --label "refactor,ui,priority:medium"

gh issue create --repo $REPO \
  --title "Refactorizar registro_pantalla.dart para usar FormularioRegistroTab (Deduplicación de código)" \
  --body "## Descripción
La pantalla \`registro_pantalla.dart\` tiene más de 500 líneas y duplica la lógica de cálculo financiero y formularios que ya están listos en \`FormularioRegistroTab\` y \`RegistroFormController\`.

## Tareas
- [ ] Limpiar controladores de texto y listeners de cálculo local en \`registro_pantalla.dart\`.
- [ ] Instanciar \`FormularioRegistroTab\` en lugar del formulario inline.
- [ ] Reducir el archivo a menos de 100 líneas respetando SRP y el manual de IA.
- [ ] Ejecutar flutter analyze para certificar cero errores." \
  --label "refactor,ui,priority:medium"

echo ""
echo "✅  Setup completado! Verifica en: https://github.com/$REPO/issues"
echo ""
echo "📊  Creando Project Board..."
gh project create --owner SuyonRiccy --title "BRISMAR APP v1.x" --body "Tablero Kanban para gestión de tareas de BRISMAR APP" 2>/dev/null || echo "⚠️  No se pudo crear Project automáticamente. Créalo manualmente en: https://github.com/$REPO/projects"
