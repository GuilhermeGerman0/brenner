import 'package:flutter/material.dart';
import '../models/spotify_track.dart';
import '../services/music_repository.dart';

class SalvasScreen extends StatelessWidget {
  const SalvasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final salvas = MusicRepository.salvas;

    return Scaffold(
      appBar: AppBar(title: const Text('Músicas Salvas')),
      backgroundColor: Colors.black,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: salvas.length,
        itemBuilder: (context, index) {
          SpotifyTrack track = salvas[index];
          return Card(
            color: Colors.grey[900],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: track.imagemUrl.isNotEmpty
                  ? Image.network(track.imagemUrl,
                      width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.music_note, color: Colors.white),
              title: Text(track.nome, style: const TextStyle(color: Colors.white)),
              subtitle:
                  Text(track.artista, style: const TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }
}
