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


// async function conectaBD() {
//     try {
//         await mssql.connect(stringSQL)
//         const result = await mssql.query`select * from brenner.Musicas`
//         console.log(result)

//     }catch(err){
//         console.log("Erro na conexão do banco de dados! ", err)
//     }
// }


app.use('/', (req, res) => res.json ({
    message: 'Servidor em execucao!'
}))



app.listen(port, () => {
    console.log("API funcionando na porta ", port)
})