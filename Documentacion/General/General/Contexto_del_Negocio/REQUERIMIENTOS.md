# Documento de Requerimientos (BRISMAR APP)

Este documento detalla los requisitos funcionales y no funcionales estratégicos del proyecto Brismar.

## Requisitos Funcionales
1. **Pesaje en Muelle:** Registro y gestión de datos de pesaje en tiempo real o diferido desde el lugar de operaciones.
2. **Prorrateo Matemático Automatizado (50/50):** Cálculos automáticos para el reparto equitativo de utilidades, rendimientos y márgenes operativos.
3. **Generación de Guías Electrónicas SUNAT:** Emisión de comprobantes y guías de remisión integradas de acuerdo con la normativa.
4. **Sincronización Offline-first:** Arquitectura local-first que permite a los operarios seguir trabajando sin red y encolar eventos de sincronización.

## Requisitos No Funcionales
1. **Cifrado Local (SQLCipher):** Protección de la base de datos SQLite y preferencias para salvaguardar la información en caso de robo de dispositivos en el muelle.
2. **Tiempos de Sincronización Reactiva:** Resolución eficiente y rápida de conflictos mediante UUIDs y políticas de Last-Write-Wins.
3. **Seguridad y Control de Acceso:** Restricciones de operaciones por medio de Row Level Security (RLS) en Supabase.
4. **Políticas de Bloqueo Post-Cierre:** Auditoría y bloqueo inmutable en base de datos para registros y cuadres marcados como cerrados, impidiendo modificaciones posteriores.
