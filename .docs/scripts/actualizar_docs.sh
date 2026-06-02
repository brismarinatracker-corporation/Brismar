#!/bin/bash
# ============================================================
# 🔄 BRISMAR — Actualizar Documentación de Obsidian
# ============================================================
# Este script escanea el código fuente de brismar_mobile/lib/
# y regenera automáticamente la documentación en docs/
#
# USO:   bash scripts/actualizar_docs.sh
# DESDE: la raíz del proyecto BRISMAR_APP
# ============================================================

set -e

PROYECTO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LIB_DIR="$PROYECTO_DIR/brismar_mobile/lib"
DOCS_DIR="$PROYECTO_DIR/docs"
FECHA=$(date '+%d de %B de %Y a las %H:%M')

# Colores para la terminal
VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARILLO='\033[1;33m'
NC='\033[0m'

echo -e "${AZUL}⚓ BRISMAR — Actualizando documentación...${NC}"
echo ""

# ──────────────────────────────────────────────
# 1. Contar archivos y líneas
# ──────────────────────────────────────────────
TOTAL_ARCHIVOS=$(find "$LIB_DIR" -name "*.dart" | wc -l)
TOTAL_LINEAS=$(find "$LIB_DIR" -name "*.dart" -exec cat {} + | wc -l)
TOTAL_MODULOS=$(find "$LIB_DIR/modulos" -maxdepth 1 -type d | tail -n +2 | wc -l)

echo -e "${VERDE}✓${NC} Encontrados: $TOTAL_ARCHIVOS archivos Dart, $TOTAL_LINEAS líneas, $TOTAL_MODULOS módulos"

# ──────────────────────────────────────────────
# 2. Detectar módulos
# ──────────────────────────────────────────────
MODULOS=""
for dir in "$LIB_DIR/modulos"/*/; do
  NOMBRE=$(basename "$dir")
  MODULOS="$MODULOS $NOMBRE"
done
echo -e "${VERDE}✓${NC} Módulos detectados:$MODULOS"

# ──────────────────────────────────────────────
# 3. Detectar dependencias del pubspec.yaml
# ──────────────────────────────────────────────
PUBSPEC="$PROYECTO_DIR/brismar_mobile/pubspec.yaml"
DEPS=""
if [ -f "$PUBSPEC" ]; then
  DEPS=$(grep -E '^\s+\w+:.*\^' "$PUBSPEC" | sed 's/^\s*//' | sed 's/: /|/' | head -20)
fi
echo -e "${VERDE}✓${NC} Dependencias detectadas del pubspec.yaml"

# ──────────────────────────────────────────────
# 4. Detectar rutas de GoRouter
# ──────────────────────────────────────────────
ENRUTADOR="$LIB_DIR/nucleo/rutas/enrutador.dart"
RUTAS=""
if [ -f "$ENRUTADOR" ]; then
  RUTAS=$(grep -oP "path: '([^']+)'" "$ENRUTADOR" | sed "s/path: '//;s/'//")
fi
echo -e "${VERDE}✓${NC} Rutas detectadas: $RUTAS"

# ──────────────────────────────────────────────
# 5. Detectar entidades del dominio
# ──────────────────────────────────────────────
ENTIDADES=""
for entidad_dir in "$LIB_DIR"/modulos/*/dominio/entidades/; do
  if [ -d "$entidad_dir" ]; then
    for archivo in "$entidad_dir"*.dart; do
      if [ -f "$archivo" ]; then
        CLASE=$(grep -oP 'class \K\w+' "$archivo" | head -1)
        if [ -n "$CLASE" ]; then
          ENTIDADES="$ENTIDADES $CLASE"
        fi
      fi
    done
  fi
done
echo -e "${VERDE}✓${NC} Entidades detectadas:$ENTIDADES"

# ──────────────────────────────────────────────
# 6. Generar DASHBOARD actualizado
# ──────────────────────────────────────────────
echo -e "${AZUL}📊 Generando Dashboard...${NC}"

# Contar archivos por módulo
MODULO_TABLA=""
for dir in "$LIB_DIR/modulos"/*/; do
  NOMBRE=$(basename "$dir")
  ARCHIVOS_MOD=$(find "$dir" -name "*.dart" | wc -l)
  LINEAS_MOD=$(find "$dir" -name "*.dart" -exec cat {} + | wc -l)
  
  # Detectar capas presentes
  CAPAS=""
  [ -d "$dir/datos" ] && CAPAS="${CAPAS}datos "
  [ -d "$dir/dominio" ] && CAPAS="${CAPAS}dominio "
  [ -d "$dir/presentacion" ] && CAPAS="${CAPAS}presentacion"
  
  # Determinar nombre de enlace Obsidian
  NOMBRE_UPPER=$(echo "$NOMBRE" | tr '[:lower:]' '[:upper:]')
  MODULO_TABLA="${MODULO_TABLA}| [[MODULO_${NOMBRE_UPPER}]] | $ARCHIVOS_MOD archivos | $LINEAS_MOD líneas | $CAPAS |\n"
done

# Contar archivos del núcleo
NUCLEO_ARCHIVOS=$(find "$LIB_DIR/nucleo" -name "*.dart" | wc -l)
NUCLEO_LINEAS=$(find "$LIB_DIR/nucleo" -name "*.dart" -exec cat {} + | wc -l)

cat > "$DOCS_DIR/00_Dashboard/DASHBOARD.md" << DASHEOF
# 📊 Dashboard — BRISMAR APP

> 🔄 **Última actualización automática:** $FECHA
> Vuelve a [[CONTEXTO_PROYECTO]] para el menú principal.

---

## Números del proyecto

| Métrica | Valor |
|---|---|
| 📄 Archivos Dart | **$TOTAL_ARCHIVOS** |
| 📝 Líneas de código | **$TOTAL_LINEAS** |
| 📦 Módulos | **$TOTAL_MODULOS** |
| 🔧 Archivos del núcleo | **$NUCLEO_ARCHIVOS** ($NUCLEO_LINEAS líneas) |

---

## Módulos

| Módulo | Archivos | Líneas | Capas |
|---|---|---|---|
$(echo -e "$MODULO_TABLA")

---

## Rutas de navegación ([[GoRouter]])

| Ruta | Descripción |
|---|---|
$(for ruta in $RUTAS; do echo "| \`$ruta\` | Pantalla de $ruta |"; done)

---

## Entidades del dominio

$(for ent in $ENTIDADES; do echo "- [[$ent]]"; done)

---

## Tecnologías usadas

| Paquete | Versión |
|---|---|
$(echo "$DEPS" | while IFS='|' read -r paquete version; do
  echo "| $paquete | $version |"
done)

---

## Archivos del proyecto (árbol)

\`\`\`
$(find "$LIB_DIR" -name "*.dart" | sed "s|$LIB_DIR/||" | sort | sed 's|^|  |')
\`\`\`

---

#brismar #dashboard #autogenerado
DASHEOF

echo -e "${VERDE}✓${NC} Dashboard actualizado"

# ──────────────────────────────────────────────
# 7. Generar MAPA_ARQUITECTURA actualizado
# ──────────────────────────────────────────────
echo -e "${AZUL}🏗️ Generando Mapa de Arquitectura...${NC}"

cat > "$DOCS_DIR/01_Arquitectura/MAPA_ARQUITECTURA.md" << ARQEOF
# 🏗️ Mapa de Arquitectura

> 🔄 **Última actualización automática:** $FECHA
> Vuelve a [[CONTEXTO_PROYECTO]] · Ver [[DASHBOARD]]

---

## Las 3 capas (Clean Architecture)

\`\`\`
PRESENTACIÓN  →  DOMINIO  ←  DATOS
  (lo que ves)    (las reglas)   (de dónde salen los datos)
\`\`\`

### 🎨 Presentación (lo que el usuario ve)
- Pantallas y componentes de UI
- Controladores con [[Riverpod]]
- Solo habla con el **Dominio**

### 📐 Dominio (las reglas del negocio)
$(for ent in $ENTIDADES; do echo "- [[$ent]]"; done)
- Contratos abstractos
- Casos de uso
- **NUNCA toca datos directamente**

### 💾 Datos (de dónde vienen)
- [[Supabase]] — datos remotos (internet)
- [[SQLite]] — datos locales (sin internet)

---

## Carpetas del proyecto (actual)

\`\`\`
$(find "$LIB_DIR" -type d | sed "s|$LIB_DIR|lib|" | sort | while read dir; do
  PROFUNDIDAD=$(echo "$dir" | tr -cd '/' | wc -c)
  INDENT=$(printf '  %.0s' $(seq 1 $PROFUNDIDAD))
  NOMBRE=$(basename "$dir")
  echo "${INDENT}├── ${NOMBRE}/"
done)
\`\`\`

---

## Módulos detectados

$(for dir in "$LIB_DIR/modulos"/*/; do
  NOMBRE=$(basename "$dir")
  NOMBRE_UPPER=$(echo "$NOMBRE" | tr '[:lower:]' '[:upper:]')
  ARCHIVOS_MOD=$(find "$dir" -name "*.dart" | wc -l)
  echo "### [[MODULO_${NOMBRE_UPPER}]] ($ARCHIVOS_MOD archivos)"
  echo ""
  echo "| Capa | Archivos |"
  echo "|---|---|"
  for capa in datos dominio presentacion; do
    if [ -d "$dir/$capa" ]; then
      CAPA_ARCHIVOS=$(find "$dir/$capa" -name "*.dart" | wc -l)
      echo "| $capa | $CAPA_ARCHIVOS |"
    fi
  done
  echo ""
done)

---

## Núcleo (infraestructura compartida)

| Carpeta | Archivos | Tecnología |
|---|---|---|
$(for dir in "$LIB_DIR/nucleo"/*/; do
  if [ -d "$dir" ]; then
    NOMBRE=$(basename "$dir")
    ARCH=$(find "$dir" -name "*.dart" | wc -l)
    echo "| $NOMBRE | $ARCH | - |"
  fi
done)

---

## Patrones detectados

| Patrón | Dónde |
|---|---|
$(grep -rl "static final.*instance" "$LIB_DIR" 2>/dev/null | sed "s|$LIB_DIR/||" | while read f; do echo "| Singleton | \`$f\` |"; done)
$(grep -rl "abstract class.*Repositorio" "$LIB_DIR" 2>/dev/null | sed "s|$LIB_DIR/||" | while read f; do echo "| Repository (contrato) | \`$f\` |"; done)
$(grep -rl "class.*CasoUso" "$LIB_DIR" 2>/dev/null | sed "s|$LIB_DIR/||" | while read f; do echo "| Use Case | \`$f\` |"; done)
$(grep -rl "StateNotifier" "$LIB_DIR" 2>/dev/null | sed "s|$LIB_DIR/||" | while read f; do echo "| StateNotifier | \`$f\` |"; done)

---

#brismar #arquitectura #autogenerado
ARQEOF

echo -e "${VERDE}✓${NC} Mapa de Arquitectura actualizado"

# ──────────────────────────────────────────────
# 8. Resumen final
# ──────────────────────────────────────────────
echo ""
echo -e "${AMARILLO}════════════════════════════════════════${NC}"
echo -e "${VERDE}✅ Documentación actualizada exitosamente${NC}"
echo -e "${AMARILLO}════════════════════════════════════════${NC}"
echo ""
echo -e "   📊 Dashboard     → docs/00_Dashboard/DASHBOARD.md"
echo -e "   🏗️ Arquitectura  → docs/01_Arquitectura/MAPA_ARQUITECTURA.md"
echo ""
echo -e "   📅 Fecha: $FECHA"
echo -e "   📄 $TOTAL_ARCHIVOS archivos · $TOTAL_LINEAS líneas · $TOTAL_MODULOS módulos"
echo ""
echo -e "${AZUL}Abre Obsidian para ver los cambios en el grafo.${NC}"
