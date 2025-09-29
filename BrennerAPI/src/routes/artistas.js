import express from 'express';
import { execQuery } from '../index.js';
const router = express.Router();

// GET: Buscar todos os artistas
router.get('/', async (req, res) => {
  try {
    const result = await execQuery('SELECT * FROM brenner.artistas');
    res.json(result.rows);
  } catch (err) {
    console.error("Erro ao buscar artistas:", err);
    res.status(500).json({ error: 'Erro ao buscar artistas' });
  }
});

// POST: Criar um novo artista
router.post('/', async (req, res) => {
  const { nome } = req.body;
  try {
    const result = await execQuery(
      'INSERT INTO brenner.artistas (nome) VALUES ($1) RETURNING *',
      [nome]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Erro ao inserir artista:", err);
    res.status(500).json({ error: 'Erro ao inserir artista' });
  }
});

// PUT: Atualizar um artista
router.put('/:id', async (req, res) => {
  const id = req.params.id;
  const { nome } = req.body;
  try {
    const result = await execQuery(
      'UPDATE brenner.artistas SET nome=$1 WHERE id_artista=$2 RETURNING *',
      [nome, id]
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Artista não encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error("Erro ao atualizar artista:", err);
    res.status(500).json({ error: 'Erro ao atualizar artista' });
  }
});

// DELETE: Deletar um artista
router.delete('/:id', async (req, res) => {
  const id = req.params.id;
  try {
    const result = await execQuery('DELETE FROM brenner.artistas WHERE id_artista=$1', [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Artista não encontrado' });
    }
    res.status(204).send();
  } catch (err) {
    console.error("Erro ao deletar artista:", err);
    res.status(500).json({ error: 'Erro ao deletar artista' });
  }
});

export default router;