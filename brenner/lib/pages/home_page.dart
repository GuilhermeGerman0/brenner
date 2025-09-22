import 'dart:convert';
import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'search_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spotify_track.dart';
import 'TrackDetailPage.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> ultimasMusicas = [];
  List<SpotifyTrack> historicoMusicas = [];
  String? erroUltimasMusicas;

  @override
  void initState() {
    super.initState();
    _carregarUltimasMusicas();
    _carregarHistorico();
  }

  Future<void> _carregarUltimasMusicas() async {
    setState(() {
      erroUltimasMusicas = null;
    });
    try {
      // Use o IP correto para mobile, se necessário
      final url = Uri.parse('http://localhost:3030/musicas/ultimas');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          ultimasMusicas = jsonDecode(response.body);
        });
      } else {
        setState(() {
          erroUltimasMusicas = 'Erro ao buscar músicas: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        erroUltimasMusicas = 'Erro de conexão: $e';
      });
    }
  }

  Future<void> _carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final historicoJson = prefs.getStringList('historico_musicas') ?? [];
    setState(() {
      historicoMusicas = historicoJson
          .map(
            (e) =>
                SpotifyTrack.fromJson(Map<String, dynamic>.from(jsonDecode(e))),
          )
          .toList();
    });
  }

  Future<void> _adicionarAoHistorico(SpotifyTrack track) async {
    final prefs = await SharedPreferences.getInstance();
    historicoMusicas.removeWhere((t) => t.spotifyUrl == track.spotifyUrl);
    historicoMusicas.insert(0, track);
    if (historicoMusicas.length > 10)
      historicoMusicas = historicoMusicas.sublist(0, 10);
    final historicoJson = historicoMusicas
        .map(
          (t) => jsonEncode({
            'name': t.nome,
            'artists': t.artista.split(',').map((a) => {'name': a}).toList(),
            'album': {
              'name': t.album,
              'images': [
                {'url': t.imagemUrl},
              ],
            },
            'external_urls': {'spotify': t.spotifyUrl},
          }),
        )
        .toList();
    await prefs.setStringList('historico_musicas', historicoJson);
    setState(() {});
  }

  Future<void> _irParaSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchPage()),
    );
  }

  Future<void> _irParaProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user)),
    );
  }

  void _irParaAdicionarMusica() {
    // TODO: implementar tela de adicionar música
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de adicionar música em breve!'),
      ),
    );
  }

  void _abrirDetalheMusica(SpotifyTrack track) async {
    await _adicionarAoHistorico(track);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackDetailPage(track: track)),
    );
    _carregarHistorico();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brenner Músicas'),
        actions: [
          IconButton(onPressed: _irParaSearch, icon: const Icon(Icons.search)),
          IconButton(onPressed: _irParaProfile, icon: const Icon(Icons.person)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irParaAdicionarMusica,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Música'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _carregarUltimasMusicas();
          await _carregarHistorico();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cabeçalho do usuário
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: const Icon(Icons.person, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Histórico de músicas
            if (historicoMusicas.isNotEmpty) ...[
              const Text(
                'Músicas visitadas recentemente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: historicoMusicas.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final track = historicoMusicas[index];
                    return GestureDetector(
                      onTap: () => _abrirDetalheMusica(track),
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (track.imagemUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  track.imagemUrl,
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(Icons.music_note, size: 40),
                            const SizedBox(height: 6),
                            Text(
                              track.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
            // Últimas músicas do backend
            const Text(
              'Últimas músicas adicionadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (erroUltimasMusicas != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  erroUltimasMusicas!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else if (ultimasMusicas.isEmpty)
              const Center(
                child: Text(
                  'Nenhuma música encontrada.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...ultimasMusicas.map((musica) {
                final track = SpotifyTrack(
                  nome: musica['nomeMusica'] ?? '',
                  artista: musica['nomeArtista'] ?? '',
                  album: musica['album'] ?? '',
                  imagemUrl: '',
                  spotifyUrl: '',
                );
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.music_note, color: Colors.white),
                    ),
                    title: Text(
                      track.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${track.artista} • ${track.album}'),
                    onTap: () => _abrirDetalheMusica(track),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
