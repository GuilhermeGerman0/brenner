import 'package:flutter/material.dart';
import '../models/spotify_track.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackDetailPage extends StatelessWidget {
  final SpotifyTrack track;

  const TrackDetailPage({Key? key, required this.track}) : super(key: key);

  Future<void> _abrirSpotify(BuildContext context, String url) async {
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
    // placeholder de tablaturas — substitua pela sua fonte/API depois
    final List<String> tablaturas = List.generate(8, (i) => 'Tablatura exemplo ${i + 1}');

    return Scaffold(
      appBar: AppBar(title: Text(track.nome)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // capa do álbum
          if (track.imagemUrl.isNotEmpty)
            Image.network(track.imagemUrl, height: 250, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Column(
              children: [
                Text(
                  track.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${track.artista} • ${track.album}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Ouvir no Spotify'),
                      onPressed: () => _abrirSpotify(context, track.spotifyUrl),
                    ),
                    const SizedBox(width: 12),
                    // exemplo: botão para favoritar (funcionalidade extra opcional)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.star_border),
                      label: const Text('Salvar'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Salvo (placeholder)')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Lista de tablaturas (expandida)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Tablaturas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: tablaturas.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final tab = tablaturas[index];
                return ListTile(
                  leading: const Icon(Icons.library_music),
                  title: Text(tab),
                  subtitle: Text('Fonte: exemplo.com'),
                  onTap: () {
                    // ação ao clicar na tablatura — abrir página da tablatura, mostrar modal, etc.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abrir tablatura: $tab (placeholder)')),
                    );
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
