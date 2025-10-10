const express = require('express')
const router = express.Router()

module.exports = (execQuery) => {

    // Adicionar música às salvas
    router.post('/', async (req, res) => {
        const username = req.body.username;
        const idMusica = req.body.idMusica;
        try {
            const usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`);
            if (!usuario[0]) {
                return res.status(404).json({ error: "Usuário não encontrado" });
            }
            const idUsuario = usuario[0].idUsuario;
            // Verifica se já existe
            const jaSalva = await execQuery(`select 1 from brenner.Salvas where idUsuario = ${idUsuario} and idMusicaSpotify = '${idMusica}'`);
            if (jaSalva[0]) {
                return res.status(409).json({ error: "Música já está nas salvas" });
            }
            await execQuery(`insert into brenner.Salvas (idUsuario, idMusicaSpotify) values (${idUsuario}, '${idMusica}')`);
            res.sendStatus(201);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao adicionar música às salvas" });
        }
    });

    // Remover música das salvas
    router.delete('/', async (req, res) => {
        const username = req.body.username;
        const idMusica = req.body.idMusica;
        try {
            const usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`);
            if (!usuario[0]) {
                return res.status(404).json({ error: "Usuário não encontrado" });
            }
            const idUsuario = usuario[0].idUsuario;
            const result = await execQuery(`delete from brenner.Salvas where idUsuario = ${idUsuario} and idMusicaSpotify = ${idMusica}`);
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Música não encontrada nas salvas" });
            }
            res.sendStatus(200);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao remover música das salvas" });
        }
    });

    // Listar id das musicas salvas de um usuário
    router.get('/:username', async (req, res) => {
        const username = req.params.username;
        try {
            const usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`);
            if (!usuario[0]) {
                return res.status(404).json({ error: "Usuário não encontrado" });
            }
            const idUsuario = usuario[0].idUsuario;
            const results = await execQuery(`select s.idMusicaSpotify from brenner.Salvas s join brenner.Usuarios u on s.idUsuario = u.idUsuario where s.idUsuario = ${idUsuario}`);
            res.json(results);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao buscar músicas salvas" });
        }
    });
    
    return router
}