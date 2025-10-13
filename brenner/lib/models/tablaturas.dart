import 'package:equatable/equatable.dart';

class Tablatura extends Equatable {
  final int id;
  final int? idMusica;
  final int? idArtista;
  final String conteudo;
  final String username;

  const Tablatura({
    required this.id,
    this.idMusica,
    this.idArtista,
    required this.conteudo,
    required this.username,
  });

  factory Tablatura.fromJson(Map<String, dynamic> json) {
    return Tablatura(
      id: json['idTablatura'] ?? json['id'] ?? 0,
      idMusica: json['idMusica'],
      idArtista: json['idArtista'],
      conteudo: json['conteudo'] ?? '',
      username: json['username'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, idMusica, idArtista, conteudo, username];
}
