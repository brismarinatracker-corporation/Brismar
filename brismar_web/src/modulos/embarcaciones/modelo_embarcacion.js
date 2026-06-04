const { DataTypes } = require('sequelize');
const sequelize = require('../../config/database');

/**
 * Modelo de Sequelize para los registros de embarcaciones.
 * Ajustado para coincidir exactamente con el esquema de Supabase (snake_case).
 */
const RegistroEmbarcacion = sequelize.define('RegistroEmbarcacion', {
  id: {
    type: DataTypes.STRING,
    primaryKey: true
  },
  usuario_id: {
    type: DataTypes.UUID,
    allowNull: true
  },
  nombre_embarcacion: {
    type: DataTypes.STRING,
    allowNull: false
  },
  producto: {
    type: DataTypes.STRING,
    allowNull: false
  },
  placa_carro: {
    type: DataTypes.STRING
  },
  kilos: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  precio_por_kilo: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  fecha: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  hora: {
    type: DataTypes.STRING,
    allowNull: false
  },
  muelle_inicio: {
    type: DataTypes.STRING,
    allowNull: false
  },
  gasto_facturacion: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  gasto_personal: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  gasto_apoyo: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  gasto_agua: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  gasto_clorox: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  gasto_flete: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  gasto_hielo: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  gasto_otros: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },

  // Métodos virtuales de lectura para ingreso bruto, total de gastos y utilidad
  ingresoBruto: {
    type: DataTypes.VIRTUAL,
    get() {
      return parseFloat(this.kilos) * parseFloat(this.precio_por_kilo);
    }
  },
  totalGastos: {
    type: DataTypes.VIRTUAL,
    get() {
      return parseFloat(this.gasto_facturacion) +
             parseFloat(this.gasto_personal) +
             parseFloat(this.gasto_apoyo) +
             parseFloat(this.gasto_agua) +
             parseFloat(this.gasto_clorox) +
             parseFloat(this.gasto_flete) +
             parseFloat(this.gasto_hielo) +
             parseFloat(this.gasto_otros);
    }
  },
  utilidadNeta: {
    type: DataTypes.VIRTUAL,
    get() {
      return this.ingresoBruto - this.totalGastos;
    }
  }
}, {
  tableName: 'registro_embarcaciones',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = RegistroEmbarcacion;
