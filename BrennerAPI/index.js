require("dotenv").config()
const port = process.env.PORT
const stringSQL = process.env.CONNECTION_STRING
const express = require('express')
const app = express()
const mssql = require('mssql')
const cors = require('cors')

app.use(express.json())


app.use(express.json())
app.use(cors())


async function conectaBD(){
    try {
        await mssql.connect(stringSQL)
    } catch (err) {
        console.log(err)
    }
}

conectaBD()

async function execQuery(querySQL) {
    const request = new mssql.Request()
    const { recordset } = await request.query(querySQL)

    return recordset
}

// ------------ Rotas de Músicas ------------

app.get("/Musicas/:nome", async (req, res) => {
    const nome = req.params.nome.toLowerCase()
    const results = await execQuery("select * from brenner.Musicas where nomeMusica = '" + nome + "'")
    res.json(results)
})

// Pesquisa por Nome

app.get("/Musicas", async (req, res) => {
    const results = await execQuery("select * from brenner.Musicas")
    res.json(results)
})

// Inserir musica (não colocar o id do Artista, colocar o nome dele)

app.post("/Musicas", async (req, res) => {
    const nomeMusica = req.body.nomeMusica.toLowerCase()

    const nomeArtista = req.body.nomeArtista.toLowerCase()
    const resultadoIdArtista = await execQuery(`select idArtista from brenner.Artistas where nomeArtista = '${nomeArtista}'`)
    const idArtista = resultadoIdArtista[0].idArtista

    const album = req.body.album
    const anoLancamento = req.body.anoLancamento

    await execQuery(`insert into brenner.Musicas values ('${nomeMusica}', ${idArtista}, '${album}', ${anoLancamento})`)

    res.sendStatus(201)
})



// ------------ Rotas de Artistas ------------

app.get("/Artistas", async (req, res) => {
    const results = await execQuery("select * from brenner.Artistas")
    res.json(results)
})

// Pesquisa por nome

app.get("/Artistas/:nome", async (req, res) => {
    const nome = req.params.nome.toLowerCase()
    const results = await execQuery("select * from brenner.Artistas where nomeArtista = '" + nome + "'")

    res.json(results)
})

// Inserir artista

app.post("/Artistas", async (req, res) => {
    const nomeArtista = req.body.nomeArtista.toLowerCase()
    const genero = req.body.genero.toLowerCase()
    await execQuery(`insert into brenner.Artistas values ('${nomeArtista}', '${genero}')`)
    res.sendStatus(201)
})


// ------------ Rotas de usuários ------------

app.get("/Usuarios", async (req, res) => {
    const results = await execQuery("select * from brenner.Usuarios")
    res.json(results)
})

// Pesquisa por id

app.get("/Usuarios/:id", async (req, res) => {
    const id = parseInt(req.params.id)
    const results = await execQuery("select * from brenner.Usuarios where idUsuario = " + id)
    res.json(results)
})

// Inserir

app.post("/Usuarios", async (req, res) => {
    console.log(req.body)
    const username = req.body.username
    const email = req.body.email
    const senha = req.body.senha

    await execQuery(`insert into brenner.Usuarios values ('${username}', '${email}', '${senha}')`)

    res.sendStatus(201)
})

app.use('/', (req, res) => res.json ({
    message: 'Servidor em execucao!'
}))



app.listen(port, () => {
    console.log("API funcionando na porta", port)
})