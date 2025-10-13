import 'package:flutter/material.dart';
import '../services/spotify_service.dart';
import '../models/spotify_track.dart';
import 'package:url_launcher/url_launcher.dart';
import 'TrackDetailPage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';

class SearchPage extends StatefulWidget {
  final User user;
  const SearchPage({Key? key, required this.user}) : super(key: key);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao buscar músicas: $e')));
    }

    setState(() => isLoading = false);
  }

  Future<void> _abrirSpotify(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('URL do Spotify indisponível')));
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Não consegui abrir o Spotify')));
    }
  }

  void _abrirDetalheMusica(SpotifyTrack track) async {
    // Adiciona ao histórico ao abrir detalhe
    final prefs = await SharedPreferences.getInstance();
    final historicoJson = prefs.getStringList('historico_musicas') ?? [];
    // Remove duplicados
    final novo = jsonEncode({
      'name': track.nome,
      'artists': track.artista.split(',').map((a) => {'name': a}).toList(),
      'album': {
        'name': track.album,
        'images': [
          {'url': track.imagemUrl},
        ],
      },
      'external_urls': {'spotify': track.spotifyUrl},
    });
    historicoJson.removeWhere((e) => e.contains(track.spotifyUrl));
    historicoJson.insert(0, novo);
    if (historicoJson.length > 10) historicoJson.removeLast();
    await prefs.setStringList('historico_musicas', historicoJson);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackDetailPage(track: track, user: widget.user),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    drawer: AppDrawer(user: widget.user),
    appBar: AppBar(
      backgroundColor: const Color(0xFF3B8183),
      title: const Text('Buscar no Spotify'),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar música ou artista...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => search(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B8183),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Buscar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: Colors.white),
          )
        else
          Expanded(
            child: resultados.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum resultado encontrado.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: resultados.length,
                    itemBuilder: (context, index) {
                      final track = resultados[index];
                      return Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: track.imagemUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    track.imagemUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.music_note, color: Colors.white),
                          title: Text(
                            track.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${track.artista} - ${track.album}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () => _abrirDetalheMusica(track),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new, color: Color(0xFF3B8183)),
                            onPressed: () => _abrirSpotify(track.spotifyUrl),
                            tooltip: 'Abrir no Spotify',
                          ),
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
