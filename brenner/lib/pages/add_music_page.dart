import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddMusicPage extends StatefulWidget {
  @override
  _AddMusicPageState createState() => _AddMusicPageState();
}

class _AddMusicPageState extends State<AddMusicPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeMusicaController = TextEditingController();
  final _nomeArtistaController = TextEditingController();
  final _albumController = TextEditingController();
  final _anoController = TextEditingController();

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final musica = {
      "nomeMusica": _nomeMusicaController.text,
      "nomeArtista": _nomeArtistaController.text,
      "album": _albumController.text,
      "anoLancamento": int.tryParse(_anoController.text) ?? 0,
    };

    try {
      final url = Uri.parse('http://localhost:3030/musicas');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(musica),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Música adicionada com sucesso!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Música')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeMusicaController,
                decoration: InputDecoration(labelText: 'Nome da Música'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _nomeArtistaController,
                decoration: InputDecoration(labelText: 'Nome do Artista'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _albumController,
                decoration: InputDecoration(labelText: 'Álbum'),
              ),
              TextFormField(
                controller: _anoController,
                decoration: InputDecoration(labelText: 'Ano de Lançamento'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
