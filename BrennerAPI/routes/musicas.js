import express from 'express';
import { execQuery } from '../index.js';

const router = express.Router();

// últimas 5 músicas
router.get('/ultimas', async (req, res) => {
  try {
    const result = await execQuery(
      'SELECT * FROM brenner.Musicas ORDER BY idMusica DESC LIMIT 5'
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Erro ao buscar últimas músicas' });
  }
});

// inserir música
router.post('/', async (req, res) => {
  const { nomeMusica, idArtista, album, anoLancamento } = req.body;
  try {
    const result = await execQuery(
      `INSERT INTO brenner.Musicas (nomeMusica, idArtista, album, anoLancamento)
       VALUES ($1,$2,$3,$4) RETURNING *`,
      [nomeMusica, idArtista, album, anoLancamento]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Erro ao inserir música' });
  }
});

// atualizar música
router.put('/:id', async (req, res) => {
  const { id } = req.params;      
  const { nomeMusica, idArtista, album, anoLancamento } = req.body;      
  try {
    const result = await execQuery(
      `UPDATE brenner.Musicas 
       SET nomeMusica=$1, idArtista=$2, album=$3, anoLancamento=$4 
       WHERE idMusica=$5`,    
      [nomeMusica, idArtista, album, anoLancamento, id]
    );  
    if (result.rowCount === 0) {      
      return res.status(404).json({ error: 'Música não encontrada' });      
    }   
    res.sendStatus(204);
  } catch (err) {      
    res.status(500).json({ error: 'Erro ao atualizar música' });      
  }   
});

// exporta depois de todas as rotas
export default router;
