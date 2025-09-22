

-- Criar schema
CREATE SCHEMA brenner;

-- Tabela Artistas
CREATE TABLE brenner.Artistas (
    idArtista int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nomeArtista varchar(50) NOT NULL,
    genero varchar(20) NOT NULL
);

-- Tabela Usuarios
CREATE TABLE brenner.Usuarios (
    idUsuario int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username varchar(40) NOT NULL UNIQUE,
    email varchar(50) NOT NULL UNIQUE,
    senha varchar(30) NOT NULL
);

-- Tabela Musicas
CREATE TABLE brenner.Musicas (
    idMusica int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nomeMusica varchar(40) NOT NULL,
    idArtista int REFERENCES brenner.Artistas(idArtista),
    album varchar(30) NOT NULL,
    anoLancamento int NOT NULL
);

-- Tabela Tablaturas
CREATE TABLE brenner.Tablaturas (
    idTablatura int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idMusica int REFERENCES brenner.Musicas(idMusica),
    idArtista int REFERENCES brenner.Artistas(idArtista),
    idUsuario int REFERENCES brenner.Usuarios(idUsuario),
    conteudo text NOT NULL
);
