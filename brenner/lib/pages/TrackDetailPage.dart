import 'package:flutter/material.dart';
import '../models/spotify_track.dart';

class TrackDetailPage extends StatelessWidget {
  final SpotifyTrack track;

  const TrackDetailPage({Key? key, required this.track}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(track.nome)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // capa do álbum
          if (track.imagemUrl.isNotEmpty)
            Image.network(track.imagemUrl,
                height: 250, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              track.nome,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${track.artista} • ${track.album}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Aqui virá a lista de recomendações/relacionadas
          Expanded(
            child: ListView.builder(
              itemCount: 10, // troca depois pela sua lista real
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                  onTap: () {
                    // ação do item
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
