# ==========================================
# BRISMAR MONOREPO ORCHESTRATION MAKEFILE
# ==========================================

.PHONY: help clean get test tracker web build-web

help:
	@echo "Comandos disponibles:"
	@echo "  make clean        - Limpia los builds de bris_tracker y bris_web"
	@echo "  make get          - Descarga dependencias (pub get) en tracker y web"
	@echo "  make test         - Ejecuta las pruebas unitarias en bris_tracker"
	@echo "  make tracker      - Ejecuta la aplicación móvil bris_tracker en local"
	@echo "  make web          - Ejecuta la aplicación de administración web bris_web"
	@echo "  make build-web    - Genera la compilación de producción para bris_web"

clean:
	@echo "🧹 Limpiando bris_tracker..."
	@cd bris_tracker && flutter clean
	@echo "🧹 Limpiando bris_web..."
	@cd bris_web && flutter clean

get:
	@echo "📥 Descargando dependencias en bris_tracker..."
	@cd bris_tracker && flutter pub get
	@echo "📥 Descargando dependencias en bris_web..."
	@cd bris_web && flutter pub get

test:
	@echo "🧪 Ejecutando pruebas unitarias en bris_tracker..."
	@cd bris_tracker && flutter test

tracker:
	@echo "📱 Iniciando bris_tracker..."
	@cd bris_tracker && flutter run

web:
	@echo "🌐 Iniciando bris_web en modo desarrollo..."
	@cd bris_web && flutter run -d chrome

build-web:
	@echo "📦 Compilando bris_web para producción..."
	@cd bris_web && flutter build web --release
