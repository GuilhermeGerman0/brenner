-- CRIA O SCHEMA 'brenner' PARA ORGANIZAR AS TABELAS
CREATE SCHEMA IF NOT EXISTS brenner;

-- APAGA AS TABELAS ANTIGAS DENTRO DO SCHEMA 'brenner' ANTES DE CRIAR DE NOVO
DROP TABLE IF EXISTS brenner.tablaturas;
DROP TABLE IF EXISTS brenner.musicas;
DROP TABLE IF EXISTS brenner.artistas;
DROP TABLE IF EXISTS brenner.usuarios;

-- TABELA DE USUÁRIOS
CREATE TABLE brenner.usuarios (
  id_usuario SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  senha VARCHAR(100) NOT NULL
);

-- TABELA DE ARTISTAS
CREATE TABLE brenner.artistas (
  id_artista SERIAL PRIMARY KEY,
  nome VARCHAR(100) UNIQUE NOT NULL
);

-- TABELA DE MÚSICAS
CREATE TABLE brenner.musicas (
  id_musica SERIAL PRIMARY KEY,
  nome VARCHAR(100) UNIQUE NOT NULL
);

-- TABELA DE TABLATURAS (RELACIONA TUDO)
CREATE TABLE brenner.tablaturas (
  id_tablatura SERIAL PRIMARY KEY,
  id_artista INT NOT NULL REFERENCES brenner.artistas(id_artista) ON DELETE CASCADE,
  id_musica INT NOT NULL REFERENCES brenner.musicas(id_musica) ON DELETE CASCADE,
  id_usuario INT NOT NULL REFERENCES brenner.usuarios(id_usuario) ON DELETE CASCADE,
  conteudo TEXT NOT NULL
);

-- INSERE DADOS DE TESTE PARA VERIFICAR SE TUDO FUNCIONA
INSERT INTO brenner.usuarios (username, email, senha) VALUES ('guilherme', 'gui@email.com', '1234');
INSERT INTO brenner.artistas (nome) VALUES ('Artista Teste');
INSERT INTO brenner.musicas (nome) VALUES ('Música Teste');
INSERT INTO brenner.tablaturas (id_artista, id_musica, id_usuario, conteudo) VALUES (1, 1, 1, 'e|--0--| B|--1--| G|--0--| D|--2--| A|--3--| E|-----|');