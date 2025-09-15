import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/spotify_service.dart';
import '../models/spotify_track.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String bio = "Olá! Eu ainda não coloquei minha bio 😎";
  String? spotifyStatus;
  List<SpotifyTrack> spotifyTracks = [];

  void connectSpotify() async {
    setState(() {
      spotifyStatus = "Conectando...";
    });

    try {
      final spotify = SpotifyService();
      final tracks = await spotify.searchTracks("top hits", limit: 5);

      setState(() {
        spotifyTracks = tracks;
        spotifyStatus = "Spotify conectado!";
      });
    } catch (e) {
      setState(() {
        spotifyStatus = "Erro ao conectar Spotify";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Paleta
    final Color bgColor = Color(0xFF121212); // fundo dark
    final Color cardColor = Color(0xFF1E1E1E); // cards
    final Color spotifyGreen = Color(0xFF1DB954);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("${widget.user.username}'s Profile"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + infos
            CircleAvatar(
              radius: 50,
              backgroundColor: spotifyGreen.withOpacity(0.2),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.username,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(widget.user.email, style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bio,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            // Botão Spotify
            ElevatedButton(
              onPressed: connectSpotify,
              style: ElevatedButton.styleFrom(
                backgroundColor: spotifyGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("Conectar Spotify", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (spotifyStatus != null) ...[
              const SizedBox(height: 8),
              Text(spotifyStatus!, style: TextStyle(color: Colors.white70)),
            ],
            const SizedBox(height: 16),
            if (spotifyTracks.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: spotifyTracks.length,
                  itemBuilder: (context, index) {
                    final track = spotifyTracks[index];
                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: track.imagemUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(track.imagemUrl,
                                    width: 50, height: 50, fit: BoxFit.cover),
                              )
                            : Icon(Icons.music_note, color: spotifyGreen),
                        title: Text(track.nome, style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          "${track.artista} • ${track.album}",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        onTap: () => launchUrl(Uri.parse(track.spotifyUrl)),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
