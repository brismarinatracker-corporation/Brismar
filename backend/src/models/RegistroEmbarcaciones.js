const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const RegistroEmbarcacion = sequelize.define('RegistroEmbarcacion', {
    // --- Información de la Embarcación ---
    nombreEmbarcacion: { 
        type: DataTypes.STRING, 
        allowNull: false 
    },
    producto: { 
        type: DataTypes.STRING, 
        allowNull: false 
    },
    placaCarro: { 
        type: DataTypes.STRING 
    },
    kilos: { 
        type: DataTypes.DECIMAL(10, 2), 
        allowNull: false 
    },
    precioPorKilo: { 
        type: DataTypes.DECIMAL(10, 2), 
        allowNull: false 
    },

    // --- Logística (Fecha, Hora y Muelle) ---
    fecha: { 
        type: DataTypes.DATEONLY, 
        allowNull: false 
    },
    hora: { 
        type: DataTypes.STRING, // Guardamos el formato "10:19 a. m."
        allowNull: false 
    },
    muelleInicio: { 
        type: DataTypes.STRING,
        allowNull: false
    },

    // --- Gastos del Muelle ---
    gastoFacturacion: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    gastoPersonal: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    gastoApoyo: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    gastoAgua: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    gastoClorox: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    gastoFlete: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
    gastoHielo: { type: DataTypes.DECIMAL(10, 2), defaultValue:0 },
    gastoOtros: { type: DataTypes.DECIMAL(10, 2), defaultValue:0},

    // --- Cálculos Virtuales (No se guardan en la DB, se calculan al vuelo) ---
    ingresoBruto: { 
        type: DataTypes.VIRTUAL,
        get() { return parseFloat(this.kilos) * parseFloat(this.precioPorKilo); }
    },
    totalGastos: {
        type: DataTypes.VIRTUAL,
        get() {
            return parseFloat(this.gastoFacturacion) + parseFloat(this.gastoPersonal) + 
                   parseFloat(this.gastoApoyo) + parseFloat(this.gastoAgua) + 
                   parseFloat(this.gastoClorox) + parseFloat(this.gastoFlete);
        }
    },
    utilidadNeta: {
        type: DataTypes.VIRTUAL,
        get() { return this.ingresoBruto - this.totalGastos; }
    }
}, { 
    tableName: 'registro_embarcaciones',
    timestamps: true 
});

module.exports = RegistroEmbarcacion;