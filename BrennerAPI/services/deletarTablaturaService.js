const sql = require('mssql');
require('dotenv').config();

const config = {
  connectionString: process.env.CONNECTION_STRING,
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

async function execQuery(query, params = {}) {
  let pool;
  
  try {
    pool = await sql.connect(config);
    const request = pool.request();

    // Adiciona parâmetros, se existirem
    for (let key in params) {
      request.input(key, params[key]);
    }

    const result = await request.query(query);
    return result.recordset;
  } catch (error) {
    console.error('Erro na query:', error);
    throw error;
  } finally {
    if (pool) await pool.close();
  }
}

module.exports = { execQuery };
