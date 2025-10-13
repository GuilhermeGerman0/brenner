const express = require('express')
const router = express.Router()

module.exports = (execQuery) => {

    // Inserir tablatura

    router.post('/', async (req, res) => {
        const idMusica = req.body.idMusica
        const idArtista = req.body.idArtista
        const idUsuario = req.body.idUsuario
        const conteudo = req.body.conteudo
        await execQuery(`insert into brenner.Tablaturas (idMusica, idArtista, idUsuario, conteudo) values (${idMusica}, ${idArtista}, ${idUsuario}, '${conteudo}')`)
        res.sendStatus(201)
    })

    // Inserir tablatura com nome da música e nome do artista

    router.post('/nome', async (req, res) => {
        const nomeMusica = req.body.nomeMusica.toLowerCase()
        const nomeArtista = req.body.nomeArtista.toLowerCase()
        const username = req.body.username
        let conteudo = req.body.conteudo
        conteudo = conteudo.replace(/'/g, "''") 
        try {
            // Busca o idUsuario pelo username
            let usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`)
            if (!usuario[0]) {
                return res.status(400).json({error: "Usuário não encontrado"})
            }
            const idUsuario = usuario[0].idUsuario

            let artista = await execQuery(`select idArtista from brenner.Artistas where nomeArtista = '${nomeArtista}'`)
            let idArtista
            if (!artista[0]) {
                await execQuery(`insert into brenner.Artistas (nomeArtista, genero) values ('${nomeArtista}', 'genero desconhecido')`)
                artista = await execQuery(`select idArtista from brenner.Artistas where nomeArtista = '${nomeArtista}'`)
            }
            idArtista = artista[0].idArtista

            let musica = await execQuery(`select idMusica from brenner.Musicas where nomeMusica = '${nomeMusica}'`)
            let idMusica
            if (!musica[0]) {
                await execQuery(`insert into brenner.Musicas (nomeMusica, idArtista, album, anoLancamento) values ('${nomeMusica}', ${idArtista}, 'album desconhecido', 0)`)
                musica = await execQuery(`select idMusica from brenner.Musicas where nomeMusica = '${nomeMusica}'`)
            }
            idMusica = musica[0].idMusica

            await execQuery(`insert into brenner.Tablaturas (idMusica, idArtista, idUsuario, conteudo) values (${idMusica}, ${idArtista}, ${idUsuario}, '${conteudo}')`)
            res.sendStatus(201)
        } catch (error) {
            console.log(error)
            return res.status(500).json({error: "Erro ao inserir a tablatura - problema ao criar artista ou música"})
        }   
    })

    // Pesquisar por nome e artista e pegar o username do usuário que postou

    router.get('/:nomeMusica/:nomeArtista', async (req, res) => {
        let nomeMusica = req.params.nomeMusica.toLowerCase();
        let nomeArtista = req.params.nomeArtista.toLowerCase();
        nomeMusica = nomeMusica.replace(/'/g, "''");
        nomeArtista = nomeArtista.replace(/'/g, "''");
        try{
            const results = await execQuery(
                `select t.idTablatura, t.idMusica, t.idArtista, t.conteudo, u.username 
                 from brenner.Tablaturas t 
                 join brenner.Usuarios u on t.idUsuario = u.idUsuario 
                 where t.idMusica = (select idMusica from brenner.Musicas where nomeMusica = '${nomeMusica}') 
                 and t.idArtista = (select idArtista from brenner.Artistas where nomeArtista = '${nomeArtista}')`
            );
            res.json(results);
        }catch(error){
            return res.status(500).json({error: "Erro ao buscar a tablatura - tablatura para essa música e artista não encontrada"});
        }
    })

    // Pesquisa por nome da música

    router.get('/:nomeMusica', async (req, res) => {
        let nomeMusica = req.params.nomeMusica;
        nomeMusica = nomeMusica.replace(/'/g, "''");
        try{
            const results = await execQuery(
                `select conteudo from brenner.Tablaturas where idMusica = (select idMusica from brenner.Musicas where nomeMusica = '${nomeMusica}')`
            );
            res.json(results);
        }catch(error){
            return res.status(500).json({error: "Erro ao buscar a tablatura - tablatura para essa música não encontrada"});
        }
    })

    // Deletar tablatura por id

    router.delete('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        try {
            const result = await execQuery(`delete from brenner.Tablaturas where idTablatura = ${id}`)
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Tablatura não encontrada" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar a tablatura" })
        }
    })

    // Deletar tablatura por nome da música

    router.delete('/nome/:nomeMusica', async (req, res) => {
        const nomeMusica = req.params.nomeMusica
        try {
            const result = await execQuery(`delete from brenner.Tablaturas where idMusica = (select idMusica from brenner.Musicas where nomeMusica = '${nomeMusica}')`)
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Tablatura não encontrada" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar a tablatura" })
        }
    })

    // Atualizar tablatura por id

    router.put('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        let { idMusica, idArtista, username, conteudo } = req.body
        conteudo = conteudo.replace(/'/g, "''"); // Escapa apóstrofos
        try {
            // Busca o idUsuario pelo username
            let usuario = await execQuery(`select idUsuario from brenner.Usuarios where username = '${username}'`)
            if (!usuario[0]) {
                return res.status(400).json({error: "Usuário não encontrado"})
            }
            const idUsuario = usuario[0].idUsuario

            const result = await execQuery(
                `update brenner.Tablaturas set idMusica = ${idMusica}, idArtista = ${idArtista}, idUsuario = ${idUsuario}, conteudo = '${conteudo}' where idTablatura = ${id}`
            )
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Tablatura não encontrada" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao atualizar a tablatura" })
        }
    })

    return router
}