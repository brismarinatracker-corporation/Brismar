# ⚠️ MENSAJE GENERAL PARA EL EQUIPO (IMPORTANTE)

Hola equipo (Belén, JJGS y demás colaboradores)!

e ha realizado una **limpieza profunda y unificación** del código base en la rama `develop` y `web`. Esto significa que se han eliminado carpetas antiguas (como `brismar_executive_app` y `brismar_mobile`) y se ha unificado todo bajo la nueva estructura limpia (`bris_tracker` y `bris_web`).

*Para evitar conflictos horribles y asegurarnos de que todos tengamos exactamente la misma versión limpia (100x100 idéntica), DEBEN ejecutar los siguientes comandos** en su terminal apenas abran el proyecto:

# Instrucciones obligatorias para sincronizar sus máquinas locales

. **Descargar todos los cambios de la nube y limpiar ramas muertas:**
   ```bash
   git fetch --all --prune
   ```

. **Pasarse a la rama principal de desarrollo:**
   ```bash
   git checkout develop
   ```

. **Traer la última versión obligatoria (forzar la limpieza en tu máquina local):**
   ```bash
   git pull origin develop
   ```

. **(Opcional pero recomendado) Actualizar tu rama personal:**
   Si estabas trabajando en tu rama personal (por ejemplo, `develop-belen`), pásate a ella y fusiolana con la nueva versión de develop:

   ```bash
   git checkout tu-rama-personal
   git pull origin tu-rama-personal
   git merge develop
   ```

 **Nota:** Si al hacer `git pull` el sistema les arroja algún error sobre "archivos no rastreados que serían sobreescritos", significa que tienen basura local de las carpetas eliminadas. En ese caso extremo, ejecuten `git clean -fd` (OJO: esto borra cualquier archivo local que no esté guardado en git, úsenlo con cuidado).

Gracias por mantener el código ordenado y limpio! 🚀
