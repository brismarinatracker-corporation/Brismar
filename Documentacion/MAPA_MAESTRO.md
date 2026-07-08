# 🗺️ Mapa Maestro de Arquitectura y Guía (BRISMAR)

¡Bienvenido al índice central! Este documento te explicará **paso a paso cómo viajan los datos en nuestra aplicación** conectando los nodos que ya hemos documentado. Además, incluye una **guía práctica para identificar código sin sentido (Anti-patrones)** basada en nuestro propio código.

> 🔄 **Enlace rápido:** Vuelve a [[DASHBOARD]] o a [[MAPA_ARQUITECTURA]] para ver gráficas.

---

## 1. Flujo Paso a Paso: ¿Cómo funciona la App?

Imagina que eres un capitán en el muelle registrando un nuevo zarpe de pesca. Así es como el código procesa tu acción:

1. **La Puerta de Entrada (UI):** 
   Todo comienza cuando tocas un botón en tu pantalla móvil. Esta interfaz gráfica está gestionada por el enrutamiento de [[GoRouter]].

2. **El Cerebro de la Pantalla (Presentación):**
   La pantalla no guarda los datos directamente. En su lugar, avisa al controlador reactivo manejado por [[Riverpod]]. Este controlador dice: *"¡Ojo! El usuario quiere guardar un zarpe"*. 
   *(Ver nodo: [[MODULO_REGISTRO]] o [[MODULO_AUTENTICACION]])*

3. **Las Reglas del Juego (Dominio):**
   El controlador envía los datos puros a un *Caso de Uso*, el cual verifica si la información cumple con las reglas. Aquí se crea una [[RegistroEntidad]] o se verifica un [[Usuario]]. Esta capa es **pura** (no sabe de bases de datos ni de internet).

4. **El Almacenamiento (Datos):**
   Finalmente, el Caso de Uso le pasa la entidad a un Repositorio. Aquí ocurre la magia del *Offline-First*:
   - ¿Hay internet? 👉 Se envía a la nube vía [[Supabase]].
   - ¿Estamos en alta mar sin señal? 👉 Se guarda localmente usando [[SQLite]].

---

## 2. Guía de Olfato: ¿Cómo identificar algo que NO tiene sentido?

La *Clean Architecture* existe para que si mañana cambiamos Supabase por Firebase, o SQLite por Hive, **no tengamos que reescribir toda la aplicación**.

Aquí te muestro cómo diferenciar el **código que tiene sentido** del **código espagueti (anti-patrón)** en nuestra propia base de código.

### 🔴 Anti-Patrón 1: Bases de datos mezcladas en la Interfaz (UI)
**El problema:** Si ves imports de bases de datos en un controlador o pantalla, algo anda muy mal. La pantalla solo debe pedir datos al Controlador, no a internet.

**❌ CÓDIGO SIN SENTIDO (Anti-Patrón)**
```dart
// Archivo: controlador_autenticacion.dart (Capa de Presentación)
import 'package:supabase_flutter/supabase_flutter.dart'; // 🚨 ¡ALERTA! Importación prohibida.

class NotificadorAutenticacion extends StateNotifier<EstadoAutenticacion> {
  // ...
  Future<void> iniciarSesion(String correo, String password) async {
    // 🚨 INCORRECTO: El controlador haciendo la petición HTTP directa.
    final respuesta = await Supabase.instance.client.auth.signIn(
      email: correo, password: password
    );
  }
}
```

**✅ CÓDIGO CON SENTIDO (Arquitectura Limpia)**
```dart
// Archivo: controlador_autenticacion.dart (Capa de Presentación real)
import '../../dominio/repositorios/repositorio_autenticacion.dart'; // ✅ Correcto: Solo conoce el contrato.

class NotificadorAutenticacion extends StateNotifier<EstadoAutenticacion> {
  final RepositorioAutenticacion _repositorio; // Dependencia inyectada.
  
  Future<void> iniciarSesion(String usuario, String password) async {
    // ✅ CORRECTO: Delega el trabajo al repositorio. El controlador no sabe si es Supabase o un mock de prueba.
    final user = await _repositorio.iniciarSesion(usuario: usuario, password: password);
    state = EstadoConfigurarPin(user);
  }
}
```

---

### 🔴 Anti-Patrón 2: Contaminación del Dominio (La Regla de Oro)
**El problema:** La carpeta `dominio` es sagrada. Contiene las entidades puras (como `usuario.dart`). Si ves librerías de Flutter (UI) o JSON ahí adentro, el código está contaminado.

**❌ CÓDIGO SIN SENTIDO (Anti-Patrón)**
```dart
// Archivo: dominio/entidades/usuario.dart
import 'package:flutter/material.dart'; // 🚨 ¡ALERTA! El dominio no pinta pantallas.

class Usuario {
  final String id;
  final String nombre;
  final Color colorFavorito; // 🚨 El dominio no debe saber de "Color" de Flutter.
  
  // 🚨 El dominio no debe saber de JSON. Eso es trabajo de la capa de "Datos" (Modelos).
  factory Usuario.fromJson(Map<String, dynamic> json) { ... }
}
```

**✅ CÓDIGO CON SENTIDO (Arquitectura Limpia)**
```dart
// Archivo: dominio/entidades/usuario.dart
// ✅ Sin imports de terceros. Puro Dart.

class Usuario {
  final String id;
  final String correo;
  final String rol;
  final String nombre;

  const Usuario({
    required this.id,
    required this.correo,
    required this.rol,
    required this.nombre,
  });
}
```
*(Nota: La serialización a JSON ocurre en los `Modelos` dentro de la capa de `Datos`, extendiendo esta entidad).*

---

### Resumen Rápido para Auditorías de Código
Si estás leyendo código y ves esto, **¡levanta la bandera roja! 🚩**

1. ¿Una pantalla (`.dart` en `presentacion/pantallas`) está haciendo peticiones a una URL externa? **Mal.**
2. ¿Un archivo en `dominio/entidades` importa bibliotecas de diseño (Material/Cupertino)? **Mal.**
3. ¿Un controlador (`Riverpod`) importa `Supabase` o `SQLite` en lugar del Repositorio? **Mal.**
4. ¿Las contraseñas o tokens se guardan en variables globales en lugar de usar `GestorAlmacenamientoSeguro`? **Mal.**

¡Sigue estas reglas y el código será eterno y fácil de probar!

---
#brismar #arquitectura #mapa-maestro #anti-patrones
