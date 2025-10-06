const express = require('express');
const router = express.Router();

module.exports = (execQuery) => {
    
    // Adicionar música às favoritas
    router.post('/', async (req, res) => {
        const username = req.body.username;
        const idMusica = req.body.idMusica;
        try {
            const usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`);
            console.log(usuario);
            if (!usuario[0]) {
                return res.status(404).json({ error: "Usuário não encontrado" });
            }
            const idUsuario = usuario[0].idUsuario;
            console.log(idUsuario);
            console.log(idMusica);
            await execQuery(`insert into brenner.Favoritas (idUsuario, idMusicaSpotify) values (${idUsuario}, ${idMusica})`);
            res.sendStatus(201);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao adicionar música às favoritas" });
        }
    });

    // Remover música das favoritas
    router.delete('/', async (req, res) => {
        const username = req.body.username;
        const idMusica = req.body.idMusica;
        try {
            const usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`);
            if (!usuario[0]) {
                return res.status(404).json({ error: "Usuário não encontrado" });
            }
            const idUsuario = usuario[0].idUsuario;
            const result = await execQuery(`delete from brenner.Favoritas where idUsuario = ${idUsuario} and idMusicaSpotify = ${idMusica}`);
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Música não encontrada nas favoritas" });
            }
            res.sendStatus(200);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao remover música das favoritas" });
        }
    });

    // Listar id das músicas favoritas de um usuário
    router.get('/:username', async (req, res) => {
        const username = req.params.username;
        try {
            const usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`);
            if (!usuario[0]) {
                return res.status(404).json({ error: "Usuário não encontrado" });
            }
            const idUsuario = usuario[0].idUsuario;
            const results = await execQuery(`select f.idMusicaSpotify from brenner.Favoritas f join brenner.Usuarios u on f.idUsuario = u.idUsuario where f.idUsuario = ${idUsuario}`);
            res.json(results);
        } catch (error) {
            return res.status(500).json({ error: "Erro ao buscar músicas favoritas" });
        }
    });
    return router;
}