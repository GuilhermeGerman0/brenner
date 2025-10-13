import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/music_repository.dart';
import '../models/spotify_track.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String bio = "Carregando ...";
  bool isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarBio();
  }

  Future<void> _carregarBio() async {
    final bioApi = await ApiService.getBiografia(widget.user.username);
    setState(() {
      bio = (bioApi == null || bioApi == 'null' || bioApi.isEmpty)
          ? "Olá! Eu ainda não coloquei minha bio "
          : bioApi.toString();
      _bioController.text = bio;
    });
  }

  void _editarBio() {
    setState(() => isEditingBio = true);
  }

  void _salvarBio() async {
    final novoBio = _bioController.text.trim().isEmpty
        ? "Olá! Eu ainda não coloquei minha bio"
        : _bioController.text.trim();
    setState(() {
      bio = novoBio;
      isEditingBio = false;
    });
    final result = await ApiService.atualizarBio(widget.user.username, novoBio);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'] ?? 'Bio atualizada!')));
  }

  void _verTodasFavoritas() {
    Navigator.pushNamed(context, '/favoritas');
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF121212);
    final Color cardColor = const Color(0xFF1E1E1E);

    // pega as 4 favoritas
    final List<SpotifyTrack> favoritasPreview =
        MusicRepository.favoritas.take(4).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          widget.user.username,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[800],
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.user.username,
                style: const TextStyle(
                  fontSize: 24,
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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isEditingBio
                  ? Column(
                      children: [
                        TextField(
                          controller: _bioController,
                          maxLines: 3,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            bio,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
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
            const SizedBox(height: 20),

            //Seção de músicas favoritas
            if (favoritasPreview.isNotEmpty) ...[
              Text(
                'Músicas Favoritas',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: favoritasPreview.map((track) {
                  return ListTile(
                    leading: track.imagemUrl.isNotEmpty
                        ? Image.network(track.imagemUrl,
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.music_note, color: Colors.white),
                    title: Text(track.nome,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(track.artista,
                        style: const TextStyle(color: Colors.white70)),
                  );
                }).toList(),
              ),
              TextButton(
                onPressed: _verTodasFavoritas,
                child: const Text('Ver todas', style: TextStyle(color: Colors.blue)),
              ),
            ]
          ],
        ),
      ),
      drawer: AppDrawer(user: widget.user),
    );
  }
}
