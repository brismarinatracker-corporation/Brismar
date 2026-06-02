const { Sequelize } = require('sequelize');
require('dotenv').config();

/**
 * Instancia de conexión a la base de datos MySQL con Sequelize.
 */
const sequelize = new Sequelize(
  process.env.DB_NAME || 'brismar_db',
  process.env.DB_USER || 'root',
  process.env.DB_PASSWORD || 'root',
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',
    logging: false
  }
);

module.exports = sequelize;
