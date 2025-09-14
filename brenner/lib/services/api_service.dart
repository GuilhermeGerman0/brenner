import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3030"; // sua API

  // Login com Email ou Username
  static Future<Map<String, dynamic>> login(String usernameOrEmail, String senha) async {
    final url = Uri.parse('$baseUrl/usuarios/login');

    // decide se é email ou username
    final body = usernameOrEmail.contains('@')
        ? {'email': usernameOrEmail, 'senha': senha}
        : {'username': usernameOrEmail, 'senha': senha};

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "Login realizado com sucesso"};
    } else {
      final Map<String, dynamic> error = jsonDecode(response.body);
      return {"success": false, "message": error["error"] ?? "Erro desconhecido"};
    }
  }

  // Cadastro
  static Future<Map<String, dynamic>> signup(User user) async {
    final url = Uri.parse('$baseUrl/usuarios');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return {"success": true, "message": "Usuário cadastrado com sucesso"};
    } else if (response.statusCode == 409) {
      return {"success": false, "message": "Usuário já existe"};
    } else {
      final Map<String, dynamic> error = jsonDecode(response.body);
      return {"success": false, "message": error["error"] ?? "Erro desconhecido"};
    }
  }
}
