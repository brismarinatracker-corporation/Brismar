const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Usuario = sequelize.define('Usuario', {
    nombre_usuario: {
        type: DataTypes.STRING,
        allowHe: false,
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
    tableName: 'usuarios', // Aquí le decimos que use la tabla que creaste en MySQL
    timestamps: true       // Para que use createdAt y updatedAt
});

module.exports = Usuario;