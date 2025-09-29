const express = require('express');
const router = express.Router();

module.exports = (execQuery) => {
    // Adicionar música às favoritas
    router.post('/', async (req, res) => {
        const idUsuario = req.body.idUsuario;
        const idMusica = req.body.idMusica;
        try {
            await execQuery(`insert into brenner.Favoritas (idUsuario, idMusica) values (${idUsuario}, ${idMusica})`);
            res.sendStatus(201);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao adicionar música às favoritas" });
        }
    });

    // Remover música das favoritas
    router.delete('/', async (req, res) => {
        const idUsuario = req.body.idUsuario;
        const idMusica = req.body.idMusica;
        try {
            const result = await execQuery(`delete from brenner.Favoritas where idUsuario = ${idUsuario} and idMusica = ${idMusica}`);
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Música não encontrada nas favoritas" });
            }
            res.sendStatus(200);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao remover música das favoritas" });
        }
    });

    // Listar músicas favoritas de um usuário
    router.get('/:idUsuario', async (req, res) => {
        const idUsuario = parseInt(req.params.idUsuario);
        try {
            const results = await execQuery(`select m.* from brenner.Musicas m join brenner.Favoritas f on m.idMusica = f.idMusica where f.idUsuario = ${idUsuario}`);
            res.json(results);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao buscar músicas favoritas" });
        }
    });
}