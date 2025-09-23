import express from 'express';
import cors from 'cors';
import { execQuery } from '../index.js';
import usuariosRouter from '../routes/usuarios.js';
import artistasRouter from '../routes/artistas.js';
import musicasRouter from '../routes/musicas.js';
import tablaturasRouter from '../routes/tablaturas.js';


const app = express();
app.use(cors());
app.use(express.json());

app.use('/usuarios', usuariosRouter);
app.use('/artistas', artistasRouter);
app.use('/musicas', musicasRouter);
app.use('/tablaturas', tablaturasRouter);

const port = process.env.PORT || 3000;

app.listen(port, async () => {
  console.log(`Servidor rodando na porta ${port}`);
  try {
    const res = await execQuery('SELECT 1');
    console.log('Banco conectado com sucesso:', res.rowCount);
  } catch (err) {
    console.error('Erro ao conectar ao banco:', err);
  }
});
