import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spotify_track.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'TrackDetailPage.dart';

class SalvasScreen extends StatefulWidget {
  final User user;

  const SalvasScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SalvasScreen> createState() => _SalvasScreenState();
}

class _SalvasScreenState extends State<SalvasScreen> {
  late Future<List<SpotifyTrack>> _salvasFuture;

  @override
  void initState() {
    super.initState();
    _carregarSalvas();
  }

  Future<void> _carregarSalvas() async {
    setState(() {
      _salvasFuture = ApiService.getMusicasSalvasPorUsername(
        widget.user.username,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Músicas Salvas')),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<SpotifyTrack>>(
        future: _salvasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar músicas salvas:\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma música salva encontrada.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final salvas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: salvas.length,
            itemBuilder: (context, index) {
              SpotifyTrack track = salvas[index];
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TrackDetailPage(track: track, user: widget.user),
                      ),
                    );
                    _carregarSalvas();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
