import express from 'express';
import cors from 'cors';
import usuariosRouter from './routes/usuarios.js';
import artistasRouter from './routes/artistas.js';
import musicasRouter from './routes/musicas.js';
import tablaturasRouter from './routes/tablaturas.js';
import 'dotenv/config';

const app = express();
app.use(cors());
app.use(express.json());

app.use('/usuarios', usuariosRouter);
app.use('/artistas', artistasRouter);
app.use('/musicas', musicasRouter);
app.use('/tablaturas', tablaturasRouter);

const port = process.env.PORT || 3000;
app.get('/', (req, res) => {
    res.send('Brenner API está funcionando!');
  });
  
app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
