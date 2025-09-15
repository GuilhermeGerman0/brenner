class User {
  final String username;
  final String email;
  final String senha;

  const User({
    required this.username,
    required this.email,
    required this.senha,
  });

  // Converte para JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'senha': senha,
      };

  // Construtor a partir de JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json['username'],
        email: json['email'],
        senha: json['senha'],
      );

  // Permite criar uma cópia modificando apenas alguns campos
  User copyWith({String? username, String? email, String? senha}) => User(
        username: username ?? this.username,
        email: email ?? this.email,
        senha: senha ?? this.senha,
      );

  @override
  String toString() => 'User(username: $username, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          email == other.email &&
          senha == other.senha;

  @override
  int get hashCode => username.hashCode ^ email.hashCode ^ senha.hashCode;
}
