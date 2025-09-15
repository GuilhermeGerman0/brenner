import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/spotify_service.dart';
import '../models/spotify_track.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({required this.user});

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
      // Exemplo: buscar músicas do usuário
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
    return Scaffold(
      appBar: AppBar(title: Text("${widget.user.username}'s Profile")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 16),
            Text(widget.user.username, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.user.email),
            SizedBox(height: 16),
            Text(bio),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: connectSpotify,
              child: Text("Conectar Spotify"),
            ),
            if (spotifyStatus != null) ...[
              SizedBox(height: 8),
              Text(spotifyStatus!),
            ],
            SizedBox(height: 16),
            if (spotifyTracks.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: spotifyTracks.length,
                  itemBuilder: (context, index) {
                    final track = spotifyTracks[index];
                    return ListTile(
                      leading: track.imagemUrl.isNotEmpty
                          ? Image.network(track.imagemUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.music_note),
                      title: Text(track.nome),
                      subtitle: Text("${track.artista} • ${track.album}"),
                      onTap: () {
                        launchUrl(Uri.parse(track.spotifyUrl));
                      },
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
