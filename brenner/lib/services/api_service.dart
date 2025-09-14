// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'dart:io';

class ApiService {
  // URL base dependendo do ambiente
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:3030";
    if (Platform.isAndroid) return "http://10.0.2.2:3030";
    return "http://192.168.0.160:3030"; // IP da sua máquina
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
      String usernameOrEmail, String senha) async {
    final url = Uri.parse('$baseUrl/usuarios/login');
    final body = usernameOrEmail.contains('@')
        ? {'email': usernameOrEmail, 'senha': senha}
        : {'username': usernameOrEmail, 'senha': senha};

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {"success": true, "message": "Login realizado com sucesso"};
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["error"] ?? "Erro desconhecido"
        };
      }
    } catch (e) {
      debugPrint('Erro API login: $e');
      return {"success": false, "message": "Erro ao conectar: $e"};
    }
  }

  // CADASTRO
  static Future<Map<String, dynamic>> signup(User user) async {
    final url = Uri.parse('$baseUrl/usuarios');
    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(user.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        return {"success": true, "message": "Usuário cadastrado com sucesso"};
      } else if (response.statusCode == 409) {
        return {"success": false, "message": "Usuário já existe"};
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["error"] ?? "Erro desconhecido"
        };
      }
    } catch (e) {
      debugPrint('Erro API signup: $e');
      return {"success": false, "message": "Erro ao conectar: $e"};
    }
  }
}
