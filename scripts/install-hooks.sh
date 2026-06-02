#!/bin/bash
# ============================================================
# 🔄 BRISMAR — Instalador de Git Hooks
# ============================================================

PROYECTO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "\033[0;34m⚓ BRISMAR — Instalando Git Hooks...\033[0m"

# Copiar pre-commit hook
cp "$PROYECTO_DIR/scripts/git-hooks/pre-commit" "$PROYECTO_DIR/.git/hooks/pre-commit"
chmod +x "$PROYECTO_DIR/.git/hooks/pre-commit"

echo -e "\033[0;32m✓ Git Hooks instalados con éxito.\033[0m"
