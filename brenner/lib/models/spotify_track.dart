class SpotifyTrack {
  final String nome;
  final String artista;
  final String album;
  final String imagemUrl;
  final String spotifyUrl;

  const SpotifyTrack({
    required this.nome,
    required this.artista,
    required this.album,
    required this.imagemUrl,
    required this.spotifyUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final artists = (json['artists'] as List<dynamic>?)
        ?.map((a) => a['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ') ?? '';

    final albumInfo = json['album'] as Map<String, dynamic>?;

    final imageUrl = (albumInfo?['images'] as List<dynamic>?)
        ?.firstOrNull?['url'] as String? ?? '';

    return SpotifyTrack(
      nome: json['name'] as String? ?? '',
      artista: artists,
      album: albumInfo?['name'] as String? ?? '',
      imagemUrl: imageUrl,
      spotifyUrl: (json['external_urls']?['spotify'] as String?) ?? '',
    );
  }

  SpotifyTrack copyWith({
    String? nome,
    String? artista,
    String? album,
    String? imagemUrl,
    String? spotifyUrl,
  }) =>
      SpotifyTrack(
        nome: nome ?? this.nome,
        artista: artista ?? this.artista,
        album: album ?? this.album,
        imagemUrl: imagemUrl ?? this.imagemUrl,
        spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      );

  @override
  String toString() => 'SpotifyTrack(nome: $nome, artista: $artista, album: $album)';
}

// Extensão útil para pegar o primeiro elemento ou null
extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
