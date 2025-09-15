const express = require('express')
const router = express.Router()
const { deletarPorId, deletarPorNome } = require('../services/deletarTablaturaService')

module.exports = (execQuery) => {
    // Pesquisa por Nome
    router.get('/:nome', async (req, res) => {
        const nome = req.params.nome.toLowerCase()
        try{
            const results = await execQuery("select * from brenner.Musicas where nomeMusica = '" + nome + "'")
            res.json(results)
        }catch(error){
            return res.status(500).json({error: "Erro ao buscar a música - música não encontrada"})
        }
    })

    // Pesquisar todas as músicas
    router.get('/', async (req, res) => {
        const results = await execQuery("select * from brenner.Musicas")
        res.json(results)
    })

    // Inserir musica
    router.post('/', async (req, res) => {
        const nomeMusica = req.body.nomeMusica.toLowerCase()
        const nomeArtista = req.body.nomeArtista.toLowerCase()
        try{
            const resultadoIdArtista = await execQuery(`select idArtista from brenner.Artistas where nomeArtista = '${nomeArtista}'`)
            if(resultadoIdArtista[0] == undefined){
                return res.status(400).json({error: "Artista não encontrado"})
            }
            const idArtista = resultadoIdArtista[0].idArtista
            const album = req.body.album
            const anoLancamento = req.body.anoLancamento
            await execQuery(`insert into brenner.Musicas values ('${nomeMusica}', ${idArtista}, '${album}', ${anoLancamento})`)
            res.sendStatus(201)

        }catch(error){
            return res.status(500).json({error: "Erro ao inserir a música"})
        }
    })

    // Deletar musica por id

    router.delete('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        try {
            const result = await deletarPorId(execQuery, 'Musica', id)
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Música não encontrada" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar a música" })
        }
    })

    // Deletar musica por nome

    router.delete('/nome/:nome', async (req, res) => {
        const nome = req.params.nome.toLowerCase()
        try {
            const result = await deletarPorNome(execQuery, 'Musica', 'nomeMusica', nome)
            if (!result || result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Música não encontrada" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar a música" })
        }
    })

    // Atualizar música por id

    router.put('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        const { nomeMusica, idArtista, album, anoLancamento } = req.body
        try {
            const result = await execQuery(
                `update brenner.Musicas set nomeMusica = '${nomeMusica}', idArtista = ${idArtista}, album = '${album}', anoLancamento = ${anoLancamento} where idMusica = ${id}`
            )
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Música não encontrada" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao atualizar a música" })
        }
    })
    // últimas 5 músicas
    router.get('/ultimas', async (req, res) => {
        try {
            const results = await execQuery(
            `select top 5 * from brenner.Musicas order by idMusica desc`
            )
            res.json(results)
        }   catch (error) {
                return res.status(500).json({ error: "Erro ao buscar últimas músicas" })
        }
    })
    


    return router
}