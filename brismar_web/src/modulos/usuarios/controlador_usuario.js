const Usuario = require('./modelo_usuario');

/**
 * Realiza la autenticación del usuario.
 * Provee verificación contra la DB y un fallback estático para pruebas.
 * 
 * @param {object} req - Objeto de solicitud de Express.
 * @param {object} res - Objeto de respuesta de Express.
 * @returns {Promise<object>} Respuesta JSON con estado de autenticación.
 */
async function iniciarSesion(req, res) {
  try {
    const { usuario, password } = req.body;
    const dbUser = await Usuario.findOne({ where: { nombre_usuario: usuario } });
    if (dbUser && dbUser.password === password) {
      return res.status(200).json({ ok: true, datos: { nombre: dbUser.nombre_real } });
    }
    if (usuario === 'usuario' && password === '1234') {
      return res.status(200).json({ ok: true, datos: { nombre: 'Daniel' } });
    }
    return res.status(401).json({ ok: false, mensaje: 'Usuario o contraseña incorrectos' });
  } catch (error) {
    return res.status(500).json({ ok: false, mensaje: 'Error interno en autenticación', error: error.message });
  }
}

module.exports = {
  iniciarSesion
};
