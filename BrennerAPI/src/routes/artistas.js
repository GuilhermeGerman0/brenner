import express from 'express';
import { execQuery } from '../index.js'; // caminho relativo correto
const router = express.Router();


    // Pesquisar todos os artistas

    router.get('/', async (req, res) => {
        const results = await execQuery("select * from brenner.Artistas")
        res.json(results)
    })

    // Pesquisa por Nome

    router.get('/:nome', async (req, res) => {
        const nome = req.params.nome.toLowerCase()
        try{
            const results = await execQuery("select * from brenner.Artistas where nomeArtista = '" + nome + "'")
            res.json(results)
        }catch(error){
            return res.status(500).json({error: "Erro ao buscar o artista - artista não encontrado"})
        }
    })

    // Inserir artista

    router.post('/', async (req, res) => {
        const nomeArtista = req.body.nomeArtista.toLowerCase()
        const genero = req.body.genero.toLowerCase()
        await execQuery(`insert into brenner.Artistas values ('${nomeArtista}', '${genero}')`)
        res.sendStatus(201)
    })

    // Deletar artista por id

    router.delete('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        try {
            const artista = await execQuery(`select * from brenner.Artistas where idArtista = ${id}`)
            if (!artista[0]) {
                return res.status(404).json({ error: "Artista não encontrado" })
            }
            await execQuery(`delete from brenner.Musicas where idArtista = ${id}`)
            const result = await deletarPorId(execQuery, 'Artista', id)
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar o artista" })
        }
    })

    // Deletar artista por nome

    router.delete('/nome/:nome', async (req, res) => {
        const nome = req.params.nome.toLowerCase()
        try {
            const artista = await execQuery(`select idArtista from brenner.Artistas where nomeArtista = '${nome}'`)
            if (!artista[0]) {
                return res.status(404).json({ error: "Artista não encontrado" })
            }
            const idArtista = artista[0].idArtista
            await execQuery(`delete from brenner.Musicas where idArtista = ${idArtista}`)
            const result = await deletarPorNome(execQuery, 'Artista', 'nomeArtista', nome)
            if (!result || result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Artista não encontrado" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar o artista" })
        }
    })

    // Atualizar artista por id

    router.put('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        const { nomeArtista, genero } = req.body
        try {
            const result = await execQuery(
                `update brenner.Artistas set nomeArtista = '${nomeArtista}', genero = '${genero}' where idArtista = ${id}`
            )
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Artista não encontrado" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao atualizar o artista" })
        }
    })

    export default router;

