import express from 'express';
import { execQuery } from '../db/index.js';
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const result = await execQuery('SELECT * FROM brenner.Usuarios');
    res.json(result.rows);
  } catch (err) {
    console.error("ERRO DETALHADO AO BUSCAR USUÁRIOS:", err); 
    res.status(500).json({ error: 'Erro ao buscar usuários' });
  }
});

// inserir
router.post('/', async (req, res) => {
  const { nome, email } = req.body;
  try {
    const result = await execQuery(
      'INSERT INTO brenner.Usuarios (nome, email) VALUES ($1, $2) RETURNING *',
      [nome, email]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Erro ao inserir usuário' });
  }
});

// atualizar
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { nome, email } = req.body;
  try {
    const result = await execQuery(
      'UPDATE brenner.Usuarios SET nome=$1, email=$2 WHERE id=$3',
      [nome, email, id]
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Erro ao atualizar usuário' });
  }
});

// deletar
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await execQuery('DELETE FROM brenner.Usuarios WHERE id=$1', [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: 'Erro ao deletar usuário' });
  }
});

export default router;
