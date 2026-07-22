# ☁️ Base de Datos Remota (Supabase)

Supabase es nuestro "backend as a service". Provee base de datos PostgreSQL, autenticación y storage.

## Archivos de Infraestructura
📁 `bris_tracker/lib/nucleo/red/cliente_supabase.dart`

## Funcionalidad
El núcleo inicializa el cliente con la URL y la API Key pública (`anon key`).
Cualquier módulo (como [[MODULO_AUTENTICACION]] o [[MODULO_REGISTRO]]) que necesite acceder a la nube usa inyección de dependencias para llamar a métodos como:

```dart
supabase.from('cuadres').insert(json).execute();
```

## Relación con Clean Architecture
Supabase solo debe ser importado en los archivos `_remoto_datasource.dart` (Fuentes de Datos) dentro de la capa de **Datos**. ¡Nunca debe haber referencias a `supabase` en el **Dominio** ni en la **Presentación**!

---
#brismar #datos #supabase #remoto #nodo
