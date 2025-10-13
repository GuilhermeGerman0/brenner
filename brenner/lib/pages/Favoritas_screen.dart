import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spotify_track.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
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

  Future<void> _carregarFavoritas() async {
    final apiService = ApiService();
    setState(() {
      _favoritasFuture = apiService.getMusicasFavoritasPorUsername(
        widget.user.username,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: AppDrawer(user: widget.user),
      appBar: AppBar(
        title: const Text('Músicas Favoritas'),
        backgroundColor: Colors.black,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
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
          return RefreshIndicator(
            onRefresh: _carregarFavoritas,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      track.artista,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackDetailPage(
                            track: track,
                            user: widget.user,
                          ),
                        ),
                      );
                      _carregarFavoritas();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}