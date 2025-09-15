import 'package:flutter/material.dart';
import '../services/spotify_service.dart';
import '../models/spotify_track.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: search, child: Text('Buscar')),
              ],
            ),
          ),
          isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: resultados.length,
                    itemBuilder: (context, index) {
                      final track = resultados[index];
                      return ListTile(
                        leading: track.imagemUrl.isNotEmpty
                            ? Image.network(track.imagemUrl, width: 50, fit: BoxFit.cover)
                            : Icon(Icons.music_note),
                        title: Text(track.nome),
                        subtitle: Text('${track.artista} - ${track.album}'),
                        onTap: () async {
                          final url = track.spotifyUrl;
                          if (await canLaunch(url)) await launch(url);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
