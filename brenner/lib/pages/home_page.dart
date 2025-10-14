import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/spotify_track.dart';
import '../services/spotify_service.dart';
import '../widgets/app_drawer.dart';
import 'TrackDetailPage.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SpotifyTrack> ultimasMusicas = [];
  List<SpotifyTrack> historicoMusicas = [];
  final SpotifyService _spotifyService = SpotifyService();

  @override
  void initState() {
    super.initState();
    historicoMusicas.clear();
    ultimasMusicas.clear();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _carregarUltimasMusicas();
    await _carregarHistorico();
  }

  
  Future<void> _carregarUltimasMusicas() async {
    try {
      final apiService = ApiService();
      final favoritas = await apiService.getMusicasFavoritasPorUsername(widget.user.username);

      // 1. Buscar gêneros das favoritas
      List<String> generos = [];
      for (final fav in favoritas) {
        final artistId = await _spotifyService.getArtistIdByName(fav.artista);
        if (artistId != null) {
          final genero = await _spotifyService.getArtistGenre(artistId);
          if (genero != null && genero.isNotEmpty) {
            generos.add(genero);
          }
        }
      }
      generos = generos.toSet().toList(); // remove duplicados

      if (generos.isEmpty) generos = ['pop', 'rock', 'mpb'];

      generos.shuffle();
      final generosAleatorios = generos.take(3).toList(); 
      List<SpotifyTrack> tracks = [];
      for (final genero in generosAleatorios) {
        final tracksGenero = await _spotifyService.searchTracksByGenre(genero);
        tracks.addAll(tracksGenero);
      }

      setState(() => ultimasMusicas = tracks);
    } catch (e) {
      debugPrint('Erro ao carregar top tracks: $e');
    }
  }

  Future<void> _carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final historicoJson = prefs.getStringList('historico_musicas') ?? [];
    setState(() {
      historicoMusicas = historicoJson
          .map((e) => SpotifyTrack.fromJson(
                Map<String, dynamic>.from(jsonDecode(e)),
              ))
          .toList();
    });
  }

  Future<void> _adicionarAoHistorico(SpotifyTrack track) async {
    final prefs = await SharedPreferences.getInstance();
    historicoMusicas.removeWhere((t) => t.spotifyUrl == track.spotifyUrl);
    historicoMusicas.insert(0, track);
    if (historicoMusicas.length > 10) {
      historicoMusicas = historicoMusicas.sublist(0, 10);
    }
    final historicoJson =
        historicoMusicas.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('historico_musicas', historicoJson);
    setState(() {});
  }

  void _abrirDetalheMusica(SpotifyTrack track) async {
    await _adicionarAoHistorico(track);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackDetailPage(track: track, user: widget.user),
      ),
    );
    _carregarHistorico();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black, // fundo escuro elegante
    drawer: AppDrawer(user: widget.user),
    appBar: AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF3B8183), // consistente com botões
      title: const Text('Brenner Músicas'),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
    body: RefreshIndicator(
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (historicoMusicas.isNotEmpty) ...[
              const Text(
                'Músicas visitadas recentemente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: historicoMusicas.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final track = historicoMusicas[index];
                    return GestureDetector(
                      onTap: () => _abrirDetalheMusica(track),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (track.imagemUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  track.imagemUrl,
                                  width: 100,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(
                                Icons.music_note,
                                size: 60,
                                color: Colors.white,
                              ),
                            const SizedBox(height: 6),
                            Text(
                              track.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              track.artista,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Músicas recomendadas para você',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (ultimasMusicas.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else
              Column(
                children: ultimasMusicas.map((track) {
                  return Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: track.imagemUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                track.imagemUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            ),
                      title: Text(
                        track.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${track.artista} • ${track.album}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () => _abrirDetalheMusica(track),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    ),
  );
}

}
