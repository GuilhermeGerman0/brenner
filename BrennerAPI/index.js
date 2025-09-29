require("dotenv").config()
const port = process.env.PORT
const stringSQL = process.env.CONNECTION_STRING
const express = require('express')
const app = express()
const mssql = require('mssql')
const cors = require('cors')
const multer = require("multer")
const path = require("path")

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

// Import routers
const musicasRouter = require('./routes/musicas')(execQuery)
const artistasRouter = require('./routes/artistas')(execQuery)
const usuariosRouter = require('./routes/usuarios')(execQuery)
const tablaturasRouter = require('./routes/tablaturas')(execQuery)

// Use routers
app.use('/Musicas', musicasRouter)
app.use('/Artistas', artistasRouter)
app.use('/Usuarios', usuariosRouter)
app.use('/Tablaturas', tablaturasRouter)

app.use('/', (req, res) => res.json ({
    message: 'Servidor em execucao!'
}))

app.listen(port, () => {
    console.log("API funcionando na porta", port)
})