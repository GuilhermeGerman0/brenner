import express from 'express';
import { execQuery } from '../index.js';
const router = express.Router();

// GET: Buscar todos os usuários
router.get('/', async (req, res) => {
  try {
    const result = await execQuery('SELECT id_usuario, username, email FROM brenner.usuarios');
    res.json(result.rows);
  } catch (err) {
    console.error("Erro ao buscar usuários:", err); 
    res.status(500).json({ error: 'Erro ao buscar usuários' });
  }
});

// POST: Criar um novo usuário
router.post('/', async (req, res) => {
  const { username, email, senha } = req.body;
  try {
    const result = await execQuery(
      'INSERT INTO brenner.usuarios (username, email, senha) VALUES ($1, $2, $3) RETURNING id_usuario, username, email',
      [username, email, senha]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Erro ao inserir usuário:", err); 
    res.status(500).json({ error: 'Erro ao inserir usuário' });
  }
});

// PUT: Atualizar um usuário
router.put('/:id', async (req, res) => {
  const id = req.params.id;
  const { username, email } = req.body;
  try {
    const result = await execQuery(
      'UPDATE brenner.usuarios SET username=$1, email=$2 WHERE id_usuario=$3 RETURNING id_usuario, username, email',
      [username, email, id]
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error("Erro ao atualizar usuário:", err); 
    res.status(500).json({ error: 'Erro ao atualizar usuário' });
  }
});

// DELETE: Deletar um usuário
router.delete('/:id', async (req, res) => {
  const id = req.params.id;
  try {
    const result = await execQuery('DELETE FROM brenner.usuarios WHERE id_usuario=$1', [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.status(204).send();
  } catch (err) {
    console.error("Erro ao deletar usuário:", err); 
    res.status(500).json({ error: 'Erro ao deletar usuário' });
  }
});

export default router;