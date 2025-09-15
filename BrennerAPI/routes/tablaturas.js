const express = require('express');

module.exports = (execQuery) => {
  const router = express.Router();

  router.get('/', async (req, res) => {
    try {
      const result = await execQuery('SELECT * FROM brenner.Tablaturas');
      res.json(result);
    } catch (err) {
      res.status(500).json({ error: 'Erro ao buscar tablaturas' });
    }
  });

  return router;
};
