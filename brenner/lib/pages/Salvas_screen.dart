import 'package:brenner/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
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
    final apiService = ApiService();
    setState(() {
      _salvasFuture = apiService.getMusicasSalvasPorUsername(
        widget.user.username,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF121212);
    final Color cardColor = const Color(0xFF1E1E1E);
    final Color titleColor = Colors.white;
    final Color subtitleColor = Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: AppDrawer(user: widget.user),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Músicas Salvas',
          style: TextStyle(color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
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
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    track.artista,
                    style: TextStyle(color: subtitleColor),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackDetailPage(track: track, user: widget.user),
                      ),
                    );
                    _carregarSalvas(); // Recarrega após voltar
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
