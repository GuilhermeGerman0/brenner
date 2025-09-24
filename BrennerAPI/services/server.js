import 'dotenv/config'; // ESSENCIAL: Deve ser a PRIMEIRA linha
import express from 'express';
import cors from 'cors';

// Importa os roteadores
import usuariosRouter from '../routes/usuarios.js';
import artistasRouter from '../routes/artistas.js';
import musicasRouter from '../routes/musicas.js';
import tablaturasRouter from '../routes/tablaturas.js';

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Rota de teste
app.get('/', (req, res) => {
  res.send('Brenner API está funcionando!');
});

// Define as rotas da API
app.use('/usuarios', usuariosRouter);
app.use('/artistas', artistasRouter);
app.use('/musicas', musicasRouter);
app.use('/tablaturas', tablaturasRouter);

// Inicia o servidor
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
