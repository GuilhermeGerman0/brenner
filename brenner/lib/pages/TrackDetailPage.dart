import 'package:flutter/material.dart';
import '../models/spotify_track.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/music_repository.dart'; // importa o repositório

class TrackDetailPage extends StatelessWidget {
  final SpotifyTrack track;

  const TrackDetailPage({Key? key, required this.track}) : super(key: key);

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
    final List<String> tablaturas =
        List.generate(8, (i) => 'Tablatura exemplo ${i + 1}');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(track.nome),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (track.imagemUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
              child: Image.network(
                track.imagemUrl,
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
                  track.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '${track.artista} • ${track.album}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // Botões
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Ouvir no Spotify'),
                      onPressed: () => _abrirSpotify(context, track.spotifyUrl),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Favoritar'),
                      onPressed: () {
                        MusicRepository.addFavorita(track);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Adicionado aos favoritos!')),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Salvar'),
                      onPressed: () {
                        MusicRepository.addSalva(track);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Música salva!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                const Text('Tablaturas',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                ...tablaturas.map((tab) => Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const Icon(Icons.library_music,
                            color: Colors.white),
                        title: Text(tab,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: const Text('Fonte: exemplo.com',
                            style: TextStyle(color: Colors.grey)),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Abrir tablatura: $tab')),
                          );
                        },
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
