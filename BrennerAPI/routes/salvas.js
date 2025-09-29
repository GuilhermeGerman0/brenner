const express = require('express')
const router = express.Router()

module.exports = (execQuery) => {
    // Adicionar música às salvas
    router.post('/', async (req, res) => {
        const idUsuario = req.body.idUsuario;
        const idMusica = req.body.idMusica;
        try {
            await execQuery(`insert into brenner.Salvas (idUsuario, idMusica) values (${idUsuario}, ${idMusica})`);
            res.sendStatus(201);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao adicionar música às salvas" });
        }
    });

    // Remover música das salvas
    router.delete('/', async (req, res) => {
        const idUsuario = req.body.idUsuario;
        const idMusica = req.body.idMusica;
        try {
            const result = await execQuery(`delete from brenner.Salvas where idUsuario = ${idUsuario} and idMusica = ${idMusica}`);
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Música não encontrada nas salvas" });
            }
            res.sendStatus(200);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao remover música das salvas" });
        }
    });

    // Listar músicas salvas de um usuário
    router.get('/:idUsuario', async (req, res) => {
        const idUsuario = parseInt(req.params.idUsuario);
        try {
            const results = await execQuery(`select m.* from brenner.Musicas m join brenner.Salvas f on m.idMusica = f.idMusica where f.idUsuario = ${idUsuario}`);
            res.json(results);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao buscar músicas salvas" });
        }
    });
}