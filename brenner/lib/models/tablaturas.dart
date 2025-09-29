import 'package:equatable/equatable.dart';

class Tablatura extends Equatable {
  final String conteudo;
  final String username;

  const Tablatura({
    required this.conteudo,
    required this.username,
  });

  factory Tablatura.fromJson(Map<String, dynamic> json) {
    return Tablatura(
      conteudo: json['conteudo'] ?? '',
      username: json['username'] ?? '',
    );
  }

  @override
  List<Object?> get props => [conteudo, username];
}
