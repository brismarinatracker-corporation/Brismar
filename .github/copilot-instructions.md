# BRISMAR APP — Instrucciones para GitHub Copilot

Lee `docs/CONTEXTO_PROYECTO.md` antes de sugerir código.

## Reglas
- Clean Architecture: presentacion/ → dominio/ ← datos/
- Máximo 20 líneas por función
- SIEMPRE try/catch con mensajes descriptivos, NUNCA print(e)
- DartDoc (///) en métodos públicos
- Nomenclatura en ESPAÑOL (PascalCase clases, camelCase variables, snake_case archivos)
- Stack: Flutter/Dart, Riverpod, GoRouter, Supabase, SQLite
- Patrones: Singleton, Repository, Use Case, StateNotifier, Factory
