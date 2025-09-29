import 'package:equatable/equatable.dart';

class SpotifyTrack extends Equatable {
  final String nome;
  final String artista;
  final String album;
  final String imagemUrl;
  final String spotifyUrl;
  final String ano;
  final String genero;

  const SpotifyTrack({
    required this.nome,
    required this.artista,
    required this.album,
    required this.imagemUrl,
    required this.spotifyUrl,
    this.ano = '',
    this.genero = '',
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final artists = (json['artists'] as List<dynamic>?)
            ?.map((a) => a['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .join(', ') ??
        '';

    final albumInfo = json['album'] as Map<String, dynamic>?;

    final imageUrl = (albumInfo?['images'] as List<dynamic>? ?? []).isNotEmpty
        ? (albumInfo?['images'] as List).first['url'] as String
        : '';

    final releaseDate = albumInfo?['release_date'] as String? ?? '';
    final ano = releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : '';

    final genero = (json['genero'] as String?) ?? '';

    return SpotifyTrack(
      nome: json['name'] as String? ?? '',
      artista: artists,
      album: albumInfo?['name'] as String? ?? '',
      imagemUrl: imageUrl,
      spotifyUrl: (json['external_urls']?['spotify'] as String?) ?? '',
      ano: ano,
      genero: genero,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': nome,
        'artists': artista.split(', '),
        'album': album,
        'imageUrl': imagemUrl,
        'spotifyUrl': spotifyUrl,
        'ano': ano,
        'genero': genero,
      };

  @override
  List<Object?> get props => [nome, artista, album, imagemUrl, spotifyUrl, ano, genero];
}
