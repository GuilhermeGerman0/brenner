import 'package:flutter/material.dart';
import '../services/spotify_service.dart';
import '../models/spotify_track.dart';
import 'package:url_launcher/url_launcher.dart';
import 'TrackDetailPage.dart'; // <- importe a página de detalhe

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SpotifyService spotifyService = SpotifyService();
  final TextEditingController _searchController = TextEditingController();
  List<SpotifyTrack> resultados = [];
  bool isLoading = false;

  void search() async {
    if (_searchController.text.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final tracks = await spotifyService.searchTracks(_searchController.text);
      setState(() => resultados = tracks);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar músicas: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _abrirSpotify(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL do Spotify indisponível')),
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não consegui abrir o Spotify')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar no Spotify')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar música ou artista...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: search, child: const Text('Buscar')),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {
                  final track = resultados[index];
                  return ListTile(
                    leading: track.imagemUrl.isNotEmpty
                        ? Image.network(track.imagemUrl, width: 50, fit: BoxFit.cover)
                        : const Icon(Icons.music_note),
                    title: Text(track.nome),
                    subtitle: Text('${track.artista} - ${track.album}'),
                    // aqui: ao clicar abre a página de detalhe (com capa em cima e lista embaixo)
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackDetailPage(track: track),
                        ),
                      );
                    },
                    // ícone para abrir no Spotify diretamente
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.green),
                      onPressed: () => _abrirSpotify(track.spotifyUrl),
                      tooltip: 'Abrir no Spotify',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
