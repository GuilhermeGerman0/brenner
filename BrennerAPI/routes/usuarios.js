const express = require('express')
const router = express.Router()
const { deletarPorId, deletarPorNome } = require('../services/deletarTablaturaService')

module.exports = (execQuery) => {

    // Pesquisar todos os usuários

    router.get('/', async (req, res) => {
        const results = await execQuery("select * from brenner.Usuarios")
        res.json(results)
    })

    // Pesquisa por Username

    router.get('/username/:username', async (req, res) => {
        const username = req.params.username
        try{
            const results = await execQuery(`select * from brenner.Usuarios where username = '${username}'`)
            res.json(results)
        }catch(error){
            return res.status(500).json({error: "Erro ao buscar o usuário - usuário não encontrado"})
        }
    })

    // Pesquisa por ID

    router.get('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        try{
            const results = await execQuery("select * from brenner.Usuarios where idUsuario = " + id)
            res.json(results)
        }catch(error){
            return res.status(500).json({error: "Erro ao buscar o usuário - usuário não encontrado"})
        }
    })

    // Login

    router.post('/login', async (req, res) => {
        const { username, email, senha } = req.body

        if (!senha || (!username && !email)) {
            return res.status(400).json({ error: "Informe username ou email e senha" })
        }

        let query
        if (username) {
            query = `select senha from brenner.Usuarios where username = '${username}'`
        } else {
            query = `select senha from brenner.Usuarios where email = '${email}'`
        }

        try {
            const result = await execQuery(query)
            if (!result[0]) {
                return res.status(401).json({ error: "Usuário não encontrado" })
            }
            if (result[0].senha === senha) {
                return res.json({ message: "Login realizado com sucesso" })
            } else {
                return res.status(401).json({ error: "Credenciais inválidas" })
            }
        } catch (error) {
            return res.status(500).json({ error: "Erro ao realizar login" })
        }
    })

    // Inserir usuário

    router.post('/', async (req, res) => {
        const username = req.body.username
        const email = req.body.email
        const senha = req.body.senha
        await execQuery(`insert into brenner.Usuarios values ('${username}', '${email}', '${senha}')`)
        res.sendStatus(201)
    })

    // Deletar usuário por id

    router.delete('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        try {
            const result = await deletarPorId(execQuery, 'Usuario', id)
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Usuário não encontrado" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar o usuário" })
        }
    })

    // Deletar usuário por username

    router.delete('/username/:username', async (req, res) => {
        const username = req.params.username
        try {
            const result = await deletarPorNome(execQuery, 'Usuario', 'username', username)
            if (!result || result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Usuário não encontrado" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao deletar o usuário" })
        }
    })

    // Atualizar usuário por id

    router.put('/id/:id', async (req, res) => {
        const id = parseInt(req.params.id)
        const { username, email, senha } = req.body
        try {
            const result = await execQuery(
                `update brenner.Usuarios set username = '${username}', email = '${email}', senha = '${senha}' where idUsuario = ${id}`
            )
            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: "Usuário não encontrado" })
            }
            res.sendStatus(200)
        } catch (error) {
            return res.status(500).json({ error: "Erro ao atualizar o usuário" })
        }
    })


    return router
}