# 🤖 Reglas para IAs

> Reglas que TODA IA debe seguir al trabajar en BRISMAR.
> Vuelve a [[CONTEXTO_PROYECTO]] · Ver [[MAPA_ARQUITECTURA]]

---

## Arquitectura
- Usar Clean Architecture: 3 capas
- Ver [[MAPA_ARQUITECTURA]] para detalles
- **NUNCA** importar `datos/` desde `dominio/`
- Cada módulo nuevo necesita: `datos/`, `dominio/`, `presentacion/`

## Código
- Máximo **20 líneas** por función
- **SIEMPRE** try/catch con mensajes claros
- **NUNCA** usar `print(e)`
- Documentar con DartDoc (`///`)

## Patrones
- Singleton → [[SQLite]], [[SecureStorage]]
- Repository → todos los módulos
- StateNotifier → [[Riverpod]]

## Nomenclatura (español)
- Clases: `PascalCase` → `RegistroEntidad`
- Variables: `camelCase` → `iniciarSesion`
- Archivos: `snake_case` → `auth_repositorio_imp.dart`

## Stack
- [[Riverpod]] para estado
- [[GoRouter]] para navegación
- [[Supabase]] para backend
- [[SQLite]] para datos locales

---

#brismar #reglas #ia
