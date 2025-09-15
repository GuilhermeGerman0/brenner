import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_music_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> ultimasMusicas = [];

  @override
  void initState() {
    super.initState();
    _carregarUltimasMusicas();
  }

  Future<void> _carregarUltimasMusicas() async {
    try {
      final url = Uri.parse('http://localhost:3030/musicas/ultimas');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          ultimasMusicas = jsonDecode(response.body);
        });
      } else {
        print('Erro: ${response.body}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  Future<void> _irParaAdd() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddMusicPage()),
    );
    if (resultado == true) {
      _carregarUltimasMusicas();
    }
  }

  Future<void> _irParaSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brenner Músicas'),
        actions: [
          IconButton(onPressed: _irParaSearch, icon: const Icon(Icons.search)),
          IconButton(onPressed: _irParaAdd, icon: const Icon(Icons.add)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarUltimasMusicas,
        child: ultimasMusicas.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: ultimasMusicas.length,
                itemBuilder: (context, index) {
                  final musica = ultimasMusicas[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade200,
                        child: const Icon(Icons.music_note, color: Colors.white),
                      ),
                      title: Text(
                        musica['nomeMusica'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${musica['album']} (${musica['anoLancamento']})'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
