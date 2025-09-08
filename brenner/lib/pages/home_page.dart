import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> artistas = [];
  bool loading = false;

  Future<void> carregarArtistas() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getArtistas();
      setState(() => artistas = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teste API - Artistas")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: carregarArtistas,
            child: const Text("Carregar Artistas"),
          ),
          if (loading) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: artistas.length,
              itemBuilder: (context, index) {
                final artista = artistas[index];
                return ListTile(
                  title: Text(artista["nomeArtista"] ?? "Sem nome"),
                  subtitle: Text("Gênero: ${artista["genero"] ?? "?"}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
