require('dotenv').config();
const app = require('./app');
const sequelize = require('./src/config/database');

const PORT = process.env.PORT || 8080;

/**
 * Arranca la aplicación de Express escuchando en el puerto configurado.
 */
function arrancarServidor() {
  app.listen(PORT, () => {
    console.log(`Servidor de BRISMAR corriendo en http://localhost:${PORT}`);
  });
}

/**
 * Inicializa la conexión a la base de datos y arranca el servidor.
 */
async function inicializar() {
  try {
    await sequelize.authenticate();
    console.log('Conexión exitosa a la base de datos de BRISMAR');
    arrancarServidor();
  } catch (error) {
    console.error('No se pudo conectar a la base de datos:', error);
    process.exit(1);
  }
}

inicializar();
