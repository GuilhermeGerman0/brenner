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

    // Pesquisa por nome da música

    router.get('/:nomeMusica', async (req, res) => {
        const nomeMusica = req.params.nomeMusica
        try{
            const results = await execQuery(`select conteudo from brenner.Tablaturas where idMusica = (select idMusica from brenner.Musicas where nomeMusica = '${nomeMusica}')`)
            res.json(results)
        }catch(error){
            return res.status(500).json({error: "Erro ao buscar a tablatura - tablatura para essa música não encontrada"})
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
        const { idMusica, idArtista, idUsuario, conteudo } = req.body
        try {
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