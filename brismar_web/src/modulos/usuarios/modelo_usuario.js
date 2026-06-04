const { DataTypes } = require('sequelize');
const sequelize = require('../../config/database');

/**
 * Modelo de Sequelize para la entidad Usuario.
 */
const Usuario = sequelize.define('Usuario', {
  nombre_usuario: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  },
  nombre_real: {
    type: DataTypes.STRING
  },
  rol: {
    type: DataTypes.STRING,
    defaultValue: 'bahia'
  }
}, {
  tableName: 'usuarios',
  timestamps: true
});

module.exports = Usuario;
