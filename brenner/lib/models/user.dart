class User {
  final String username;
  final String email;
  final String senha;

  User({
    required this.username,
    required this.email,
    required this.senha,
  });

  // Converte para JSON (útil para salvar no SharedPreferences ou enviar via API)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'senha': senha,
    };
  }

  // Construtor a partir de JSON (útil para carregar dados salvos)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      senha: json['senha'],
    );
  }
}
