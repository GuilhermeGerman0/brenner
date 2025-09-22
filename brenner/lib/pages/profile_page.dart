import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import '../models/user.dart';
import '../models/spotify_track.dart';
import '../services/spotify_service.dart';

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
  bool isLoading = false;
  bool isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bioController.text = bio;
  }

  void _editarBio() {
    setState(() => isEditingBio = true);
  }

  void _salvarBio() {
    setState(() {
      bio = _bioController.text.trim().isEmpty
          ? "Olá! Eu ainda não coloquei minha bio 😎"
          : _bioController.text.trim();
      isEditingBio = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bio atualizada!')));
  }

  void _irParaHome() {
    Navigator.pop(context);
  }

  void _irParaSearch() {
    Navigator.pushNamed(context, '/search');
  }

  Future<void> connectSpotify() async {
    setState(() {
      isLoading = true;
      spotifyStatus = "Conectando...";
    });
    try {
      String redirectUri;
      if (kIsWeb) {
        final host = html.window.location.hostname;
        final port = html.window.location.port;
        redirectUri = 'http://$host:$port/callback';
      } else {
        redirectUri = 'brenner://callback';
      }
      final client = SpotifyOAuth2Client(
        redirectUri: redirectUri,
        customUriScheme: 'brenner',
      );
      final tokenResp = await client.getTokenWithAuthCodeFlow(
        clientId: '7b0536e1b13245138baae34f9e558a6f',
        scopes: [
          'user-read-private',
          'user-read-email',
          'playlist-read-private',
          'playlist-read-collaborative',
          'user-library-read',
          'user-top-read',
        ],
      );
      if (tokenResp != null) {
        final spotify = SpotifyService();
        spotify.userToken = tokenResp.accessToken;
        final tracks = await spotify.getUserPlaylistsTracks(limit: 5);
        setState(() {
          spotifyTracks = tracks;
          spotifyStatus = "Playlists do Spotify carregadas!";
        });
      }
    } catch (e) {
      setState(() {
        spotifyStatus = "Erro ao conectar Spotify: $e";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) {
      final hash = html.window.location.hash;
      if (hash.contains('access_token=')) {
        final token = hash
            .replaceFirst('#', '')
            .split('&')
            .firstWhere((e) => e.startsWith('access_token='))
            .split('=')[1];
        final spotify = SpotifyService();
        spotify.userToken = token;
        spotify
            .getUserPlaylistsTracks(limit: 5)
            .then((tracks) {
              setState(() {
                spotifyTracks = tracks;
                spotifyStatus = "Playlists do Spotify carregadas!";
              });
            })
            .catchError((e) {
              setState(() {
                spotifyStatus = "Erro ao buscar playlists: $e";
              });
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF121212);
    final Color cardColor = const Color(0xFF1E1E1E);
    final Color spotifyGreen = const Color(0xFF1DB954);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "${widget.user.username}",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: _irParaHome,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: _irParaSearch,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: spotifyGreen.withOpacity(0.2),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.user.username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Text(
                widget.user.email,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isEditingBio
                  ? Column(
                      children: [
                        TextField(
                          controller: _bioController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Sua bio',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => isEditingBio = false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: _salvarBio,
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            bio,
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white54),
                          tooltip: 'Editar bio',
                          onPressed: _editarBio,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.link),
              onPressed: isLoading ? null : connectSpotify,
              style: ElevatedButton.styleFrom(
                backgroundColor: spotifyGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(45),
              ),
              label: Text(
                isLoading ? "Conectando..." : "Conectar ao Spotify",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (spotifyStatus != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  spotifyStatus!,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (!isLoading && spotifyTracks.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suas playlists recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: spotifyTracks.length,
                    itemBuilder: (context, index) {
                      final track = spotifyTracks[index];
                      return Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: track.imagemUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    track.imagemUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.music_note, color: spotifyGreen),
                          title: Text(
                            track.nome,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "${track.artista} • ${track.album}",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          onTap: () => launchUrl(Uri.parse(track.spotifyUrl)),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
