import 'package:flutter/material.dart';
import '../models/spotify_track.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'TrackDetailPage.dart';

class FavoritasScreen extends StatefulWidget {
  final User user;
  const FavoritasScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FavoritasScreen> createState() => _FavoritasScreenState();
}

class _FavoritasScreenState extends State<FavoritasScreen> {
  late Future<List<SpotifyTrack>> _favoritasFuture;

  @override
  void initState() {
    super.initState();
    _carregarFavoritas();
  }

  void _carregarFavoritas() {
    setState(() {
      _favoritasFuture = ApiService.getMusicasFavoritasPorUsername(
        widget.user.username,
      );
    });
  }

  void _abrirDetalheMusica(SpotifyTrack track) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackDetailPage(track: track, user: widget.user),
      ),
    );
    _carregarFavoritas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Músicas Favoritas')),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<SpotifyTrack>>(
        future: _favoritasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar músicas favoritas:\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma música favorita encontrada.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final favoritas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoritas.length,
            itemBuilder: (context, index) {
              SpotifyTrack track = favoritas[index];
              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: track.imagemUrl.isNotEmpty
                      ? Image.network(
                          track.imagemUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.music_note, color: Colors.white),
                  title: Text(
                    track.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    track.artista,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                    tooltip: 'Remover dos favoritos',
                    onPressed: () async {
                      final result =
                          await ApiService.removerFavoritaPorUsername(
                            widget.user.username,
                            int.parse(track.id),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? 'Removido!'),
                        ),
                      );
                      _carregarFavoritas();
                    },
                  ),
                  onTap: () => _abrirDetalheMusica(track),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
