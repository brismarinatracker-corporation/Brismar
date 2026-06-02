# Guía de Contribución Colaborativa en GitHub 🐙

El sistema de versionamiento sigue el estándar estricto **X1.X2.X3**, donde:
- **X1:** La versión mayor/funcional estable de la App.
- **X2:** La cantidad de Pull Requests integrados.
- **X3:** La cantidad total de Issues que esos PRs resolvieron.

## 1. El Rol del Desarrollador
Tú, como programador, nunca tocas el archivo `pubspec.yaml` ni fusionas en `main`.
Tu ciclo es:
1. Crea tu rama: `git checkout -b feature/issue-3`.
2. Escribe tu código para resolver uno o varios issues (Ej. #3 y #4).
3. Sube tu rama a GitHub: `git push origin feature/issue-3`.
4. Abre un **Pull Request (PR)** hacia la rama `main` y en la descripción pon: "Este PR resuelve los issues 3 y 4".

## 2. El Rol del Revisor de Código (Merge Manager)
Para evitar "Merge Conflicts" y desastres en la numeración, solo UNA persona aprueba y corre la versión.
Antes de hacer click en "Merge Pull Request", el revisor debe:
1. Ir al archivo `docs/ISSUES.md`.
2. Registrar un nuevo PR bajo `## [Pull Requests Fusionados]` (Ej: `- PR #2: Implementación de encriptación`).
3. Mover las Issues 3 y 4 a la sección `## [Issues Resueltos]`.
4. Ejecutar: `python3 scripts/gestor_versiones.py`.
5. Hacer commit del nuevo número de versión y ahora sí, fusionar el PR.

## 3. Reseteo de Versiones (Pase a Producción X1)
Cuando la versión llegue, por ejemplo, a la `1.5.15` y decidamos que la aplicación tiene todas las funciones necesarias de la primera fase:
1. Entramos a `ISSUES.md` y cambiamos `# VERSIÓN FUNCIONAL: 1` a `# VERSIÓN FUNCIONAL: 2`.
2. Cortamos todas las listas de PRs e Issues anteriores y las pegamos abajo en `# VERSIONES FUNCIONALES ANTERIORES` (el basurero histórico).
3. Al correr `python3 scripts/gestor_versiones.py`, encontrará 0 PRs y 0 Issues debajo de la cabecera, así que automáticamente reseteará la versión a **`2.0.0+0`**. Todo empezará de nuevo.
