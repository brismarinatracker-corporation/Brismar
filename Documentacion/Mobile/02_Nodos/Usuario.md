# 👤 Entidad: Usuario

Representa al perfil base de una persona utilizando la aplicación. Esta nota forma parte de las reglas de negocio en la capa de **Dominio**.

## Archivo
📁 `bris_tracker/lib/modulos/autenticacion/dominio/entidades/usuario.dart`

## Estructura (Modelo de Datos)
Típicamente, el `Usuario` abstrae los datos entregados por [[Supabase]] Auth en propiedades simples de Dart:

- `id` (String): El UUID único asignado por la base de datos (Ej: "550e8400-e29b-41d4-a716-446655440000").
- `correo` (String): Email con el que el operario inicia sesión.
- `rol` (String): Rol del usuario (ej. Operario, Administrador). Esto sirve para mostrar partes de UI ocultas.
- `nombre` (String): Nombre descriptivo para encabezados de pantallas.

> El **Dominio** no sabe si este usuario viene de SQLite o de Supabase. Aislamos esa información.

---
#brismar #dominio #entidad #usuario #nodo
