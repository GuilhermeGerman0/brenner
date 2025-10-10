import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spotify_track.dart';
import '../models/tablaturas.dart'; // <-- Aqui usamos a model
import '../services/api_service.dart';
import '../models/user.dart';

class TrackDetailPage extends StatefulWidget {
  final SpotifyTrack track;
  final User user;

  const TrackDetailPage({Key? key, required this.track, required this.user})
    : super(key: key);

  @override
  State<TrackDetailPage> createState() => _TrackDetailPageState();
}

class _TrackDetailPageState extends State<TrackDetailPage> {
  late Future<List<Tablatura>> _tablaturasFuture;

  @override
  void initState() {
    super.initState();
    _tablaturasFuture = ApiService.getTablaturas(
      widget.track.nome,
      widget.track.artista,
    );
  }

  Future<void> _abrirSpotify(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL do Spotify indisponível')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não consegui abrir o Spotify')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.track.nome),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.track.imagemUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                widget.track.imagemUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.track.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.track.artista} • ${widget.track.album}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (widget.track.ano.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ano de lançamento: ${widget.track.ano}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                if (widget.track.genero.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Gênero: ${widget.track.genero}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Ouvir no Spotify'),
                      onPressed: () =>
                          _abrirSpotify(context, widget.track.spotifyUrl),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      icon: const Icon(Icons.star_border),
                      label: const Text('Salvar'),
                      onPressed: () async {
                        final result = await ApiService.salvarMusicaPorUsername(
                          widget.user.username,
                          widget.track.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Erro ao salvar',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      icon: const Icon(Icons.favorite),
                      label: const Text('Favoritar'),
                      onPressed: () async {
                        final result = await ApiService.favoritarMusicaPorUsername(
                          widget.user.username,
                          widget.track.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Erro ao favoritar',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                const Text(
                  'Tablaturas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Tablatura>>(
                  future: _tablaturasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        'Erro ao carregar tablaturas:\n${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      );
                    } else if (snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Text(
                        'Nenhuma tablatura disponível para esta música.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    final tablaturas = snapshot.data!;
                    return Column(
                      children: tablaturas.map((tab) {
                        return Card(
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.library_music,
                              color: Colors.white,
                            ),
                            title: Text(
                              tab.conteudo.length > 50
                                  ? '${tab.conteudo.substring(0, 50)}...'
                                  : tab.conteudo,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Postado por: ${tab.username}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: Text(
                                    'Tablatura - ${widget.track.nome}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      tab.conteudo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text(
                                        'Fechar',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
