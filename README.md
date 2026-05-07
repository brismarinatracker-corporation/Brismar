# ⚓ BRISMAR APP - Sistema de Gestión de Bahía

Sistema de gestión y control de registros de pesca diseñado para **Negocios Brismar S.R.L.** Esta API RESTful permite la administración eficiente de ingresos, gastos operativos y generación de reportes automatizados en la bahía.

## 🚀 Características Principales

* **Gestión de Embarcaciones:** Registro detallado de la pesca del día (kilos, precio, nombre del pesador, etc.).
* **Control de Gastos:** Seguimiento en tiempo real de los costos operativos (hielo, personal, flete, agua y otros).
* **Cálculo de Utilidad:** Procesamiento automático de la utilidad neta por jornada.
* **Autenticación (Login):** Acceso seguro para el personal de bahía y administradores.
* **Reportes Automatizados:** Generación y descarga de resúmenes diarios en formato PDF.

> **Nota:** Este sistema está enfocado exclusivamente en el registro de pesca y control de bahía. Los módulos de SARDE, PTH y liquidaciones no forman parte del alcance de este proyecto.

## 🛠️ Tecnologías Utilizadas

* **Backend:** Node.js, Express.js
* **Base de Datos:** MySQL
* **ORM:** Sequelize
* **Diseño de Interfaz:** Figma
* **Otras Librerías:** dotenv, pdfkit (para reportes)

## 📋 Requisitos Previos

Antes de ejecutar el proyecto, asegúrate de tener instalado:
* [Node.js](https://nodejs.org/) (v14 o superior)
* [MySQL Server](https://dev.mysql.com/downloads/mysql/) y MySQL Workbench

## ⚙️ Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone [URL_DEL_REPOSITORIO]
   cd BRISMAR_APP