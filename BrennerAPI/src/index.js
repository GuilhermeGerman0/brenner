import 'dotenv/config'; // Garante que a DATABASE_URL seja lida
import pg from 'pg';
const { Pool } = pg;

// Configura a pool de conexões
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { 
    rejectUnauthorized: false // Necessário para Supabase/Render
  }
});

/**
 * Executa uma query SQL no banco de dados.
 * @param {string} sql - O comando SQL a ser executado.
 * @param {Array} params - Os parâmetros para a query.
 * @returns {Promise<QueryResult>} O resultado da query.
 */
export async function execQuery(sql, params = []) {
  const client = await pool.connect();
  try {
    const result = await client.query(sql, params);
    return result; // contém .rows e .rowCount
  } catch (err) {
    console.error('ERRO NA QUERY DO BANCO:', err); // Loga o erro real
    throw err; // Lança o erro para a rota poder tratar
  } finally {
    client.release(); // Libera o cliente de volta para a pool
  }
}
