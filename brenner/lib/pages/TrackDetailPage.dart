import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/spotify_track.dart';
import '../models/tablaturas.dart'; 
import '../services/api_service.dart';
import '../models/user.dart';

class TrackDetailPage extends StatefulWidget {
  final SpotifyTrack track;
  final User user;

  const TrackDetailPage({Key? key, required this.track, required this.user})
    : super(key: key);

  @override
  State<TrackDetailPage> createState() => _TrackDetailPageState();
}

class _TrackDetailPageState extends State<TrackDetailPage> {
  late Future<List<Tablatura>> _tablaturasFuture;
  bool _jaSalva = false;
  bool _loadingSalva = true;
  bool _jaFavorita = false;
  bool _loadingFavorita = true;

  @override
  void initState() {
    super.initState();
    _tablaturasFuture = ApiService.getTablaturas(
      widget.track.nome,
      widget.track.artista,
    );
    _verificarSeSalva();
    _verificarSeFavorita();
  }

  void _verificarSeSalva() async {
    setState(() {
      _loadingSalva = true;
    });
    final apiService = ApiService();
    final salvas = await apiService.getMusicasSalvasPorUsername(widget.user.username);
    setState(() {
      _jaSalva = salvas.any((track) => track.id == widget.track.id);
      _loadingSalva = false;
    });
  }

  void _verificarSeFavorita() async {
    setState(() {
      _loadingFavorita = true;
    });
    final apiService = ApiService();
    final favoritas = await apiService.getMusicasFavoritasPorUsername(widget.user.username);
    setState(() {
      _jaFavorita = favoritas.any((track) => track.id == widget.track.id);
      _loadingFavorita = false;
    });
  }

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.track.nome),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.track.imagemUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                widget.track.imagemUrl,
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
                  widget.track.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.track.artista} • ${widget.track.album}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (widget.track.ano.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ano de lançamento: ${widget.track.ano}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                if (widget.track.genero.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Gênero: ${widget.track.genero}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B8183),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Ouvir no Spotify'),
                      onPressed: () =>
                          _abrirSpotify(context, widget.track.spotifyUrl),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      icon: _loadingSalva
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(_jaSalva ? Icons.star : Icons.star_border),
                      label: Text(_jaSalva ? 'Remover Salva' : 'Salvar'),
                      onPressed: _loadingSalva
                          ? null
                          : () async {
                              String message;
                              if (_jaSalva) {
                                // Remove dos salvos
                                final result = await ApiService.removerMusicaSalvaPorUsername(
                                  widget.user.username,
                                  widget.track.id,
                                );
                                message = result['message'] ?? 'Removido das salvas';
                              } else {
                                // Adiciona aos salvos
                                final result = await ApiService.salvarMusicaPorUsername(
                                  widget.user.username,
                                  widget.track.id,
                                );
                                message = result['message'] ?? 'Salvo com sucesso';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                              _verificarSeSalva();
                            },
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      icon: _loadingFavorita
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(_jaFavorita ? Icons.favorite : Icons.favorite_border),
                      label: Text(_jaFavorita ? 'Remover Favorita' : 'Favoritar'),
                      onPressed: _loadingFavorita
                          ? null
                          : () async {
                              String message;
                              if (_jaFavorita) {
                                final result = await ApiService.removerMusicaFavoritaPorUsername(
                                  widget.user.username,
                                  widget.track.id,
                                );
                                message = result['message'] ?? 'Removido das favoritas';
                              } else {
                                final result = await ApiService.favoritarMusicaPorUsername(
                                  widget.user.username,
                                  widget.track.id,
                                );
                                message = result['message'] ?? 'Favoritado com sucesso';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                              _verificarSeFavorita();
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                const Text(
                  'Tablaturas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Tablatura>>(
                  future: _tablaturasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        'Erro ao carregar tablaturas:\n${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      );
                    } else if (snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Text(
                        'Nenhuma tablatura disponível para esta música.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    final tablaturas = snapshot.data!;
                    return Column(
                      children: tablaturas.map((tab) {
                        final isOwner = tab.username == widget.user.username;
                        return MouseRegion(
                          cursor: isOwner ? SystemMouseCursors.click : MouseCursor.defer,
                          child: Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.library_music,
                                color: Colors.white,
                              ),
                              title: Text(
                                tab.conteudo.length > 50
                                    ? '${tab.conteudo.substring(0, 50)}...'
                                    : tab.conteudo,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Postado por: ${tab.username}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: Colors.grey[900],
                                    title: Text(
                                      'Tablatura - ${widget.track.nome}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Text(
                                        tab.conteudo,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      if (isOwner)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              tooltip: 'Editar',
                                              icon: const Icon(Icons.edit, color: Color(0xFF3B8183)),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                final controller = TextEditingController(text: tab.conteudo);
                                                final edited = await showDialog<String>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Editar Tablatura'),
                                                    content: TextField(
                                                      controller: controller,
                                                      maxLines: 8,
                                                      decoration: const InputDecoration(
                                                        labelText: 'Edite a tablatura',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Cancelar'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.pop(context, controller.text.trim()),
                                                        child: const Text('Salvar'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (edited != null && edited.isNotEmpty && edited != tab.conteudo) {
                                                  try {
                                                    await ApiService.httpPut(
                                                      '/tablaturas/id/${tab.id}',
                                                      {
                                                        'idMusica': tab.idMusica,
                                                        'idArtista': tab.idArtista,
                                                        'username': widget.user.username,
                                                        'conteudo': edited,
                                                      },
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Tablatura editada com sucesso!')),
                                                    );
                                                    setState(() {
                                                      _tablaturasFuture = ApiService.getTablaturas(
                                                        widget.track.nome,
                                                        widget.track.artista,
                                                      );
                                                    });
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Erro ao editar tablatura: $e')),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                            IconButton(
                                              tooltip: 'Excluir',
                                              icon: const Icon(CupertinoIcons.trash , color: Colors.redAccent),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Excluir Tablatura'),
                                                    content: const Text('Tem certeza que deseja excluir esta tablatura?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: const Text('Cancelar'),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: const Text('Excluir'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  try {
                                                    await ApiService.httpDelete('/tablaturas/id/${tab.id}');
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Tablatura excluída com sucesso!')),
                                                    );
                                                    setState(() {
                                                      _tablaturasFuture = ApiService.getTablaturas(
                                                        widget.track.nome,
                                                        widget.track.artista,
                                                      );
                                                    });
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Erro ao excluir tablatura: $e')),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      TextButton(
                                        child: const Text(
                                          'Fechar',
                                          style: TextStyle(color: Color(0xFF3B8183)),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final conteudoController = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Adicionar Tablatura'),
              content: TextField(
                controller: conteudoController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Digite a tablatura',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, conteudoController.text.trim()),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          );
          if (result != null && result.isNotEmpty) {
            try {
              await ApiService.httpPost(
                '/tablaturas/nome',
                {
                  'nomeMusica': widget.track.nome,
                  'nomeArtista': widget.track.artista,
                  'username': widget.user.username,
                  'conteudo': result,
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tablatura adicionada com sucesso!')),
              );
              setState(() {
                _tablaturasFuture = ApiService.getTablaturas(
                  widget.track.nome,
                  widget.track.artista,
                );
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao adicionar tablatura: $e')),
              );
            }
          }
        },
        backgroundColor: Color(0xFF3B8183),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
