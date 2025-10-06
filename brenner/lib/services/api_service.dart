import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/tablaturas.dart';
import '../models/spotify_track.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:3030";
    if (Platform.isAndroid) return "http://10.0.2.2:3030";
    return "http://192.168.0.160:3030";
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String usernameOrEmail,
    String senha,
  ) async {
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

      if (response.statusCode == 200)
        return {"success": true, "message": "Login realizado com sucesso"};
      final Map<String, dynamic> error = jsonDecode(response.body);
      return {
        "success": false,
        "message": error["error"] ?? "Erro desconhecido",
      };
    } catch (e) {
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

      if (response.statusCode == 201)
        return {"success": true, "message": "Usuário cadastrado com sucesso"};
      if (response.statusCode == 409)
        return {"success": false, "message": "Usuário já existe"};
      final Map<String, dynamic> error = jsonDecode(response.body);
      return {
        "success": false,
        "message": error["error"] ?? "Erro desconhecido",
      };
    } catch (e) {
      return {"success": false, "message": "Erro ao conectar: $e"};
    }
  }

  // GET genérico
  static Future<dynamic> httpGet(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro GET $path: ${response.body}');
  }

  // POST genérico
  static Future<Map<String, dynamic>> httpPost(String path, Map body) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'message': 'Operação realizada'};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['error'] ?? 'Erro desconhecido',
      };
    }
  }

  // GET Tablaturas por música e artista
  static Future<List<Tablatura>> getTablaturas(
    String nomeMusica,
    String nomeArtista,
  ) async {
    final path =
        "/tablaturas/${Uri.encodeComponent(nomeMusica.toLowerCase())}/${Uri.encodeComponent(nomeArtista.toLowerCase())}";
    final response = await httpGet(path);
    return (response as List).map((json) => Tablatura.fromJson(json)).toList();
  }

  // Buscar músicas salvas do usuário
  static Future<List<SpotifyTrack>> getMusicasSalvas(int idUsuario) async {
    final response = await httpGet('/Salvas/$idUsuario');
    return (response as List)
        .map((json) => SpotifyTrack.fromJson(json))
        .toList();
  }

  // Buscar músicas favoritas do usuário
  static Future<List<SpotifyTrack>> getMusicasFavoritas(int idUsuario) async {
    final response = await httpGet('/Favoritas/$idUsuario');
    return (response as List)
        .map((json) => SpotifyTrack.fromJson(json))
        .toList();
  }

  // Remover música das favoritas
  static Future<Map<String, dynamic>> removerFavorita(
    int idUsuario,
    int idMusica,
  ) async {
    final url = '/Favoritas';
    return await httpPost(url, {'idUsuario': idUsuario, 'idMusica': idMusica});
  }

  // Buscar músicas salvas pelo username
  static Future<List<SpotifyTrack>> getMusicasSalvasPorUsername(
    String username,
  ) async {
    final response = await httpGet('/Salvas/username/$username');
    if (response is List) {
      return response.map((json) => SpotifyTrack.fromJson(json)).toList();
    } else {
      throw Exception('Resposta inesperada da API: $response');
    }
  }

  // Buscar músicas favoritas do usuário por username
  static Future<List<SpotifyTrack>> getMusicasFavoritasPorUsername(
    String username,
  ) async {
    final response = await httpGet(
      '/Favoritas/' + Uri.encodeComponent(username),
    );
    return (response as List)
        .map((json) => SpotifyTrack.fromJson(json))
        .toList();
  }

  // Remover música das favoritas por username
  static Future<Map<String, dynamic>> removerFavoritaPorUsername(
    String username,
    int idMusica,
  ) async {
    final url = Uri.parse('$baseUrl/Favoritas');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'idMusica': idMusica}),
    );
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Removido das favoritas'};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['error'] ?? 'Erro desconhecido',
      };
    }
  }

  // Salvar música nas favoritas por username
  static Future<Map<String, dynamic>> salvarMusicaPorUsername(
    String username,
    String idMusica,
  ) async {
    return await httpPost('/Salvas', {
      'username': username,
      'idMusica': idMusica,
    });
  }

  // Favoritar música por username
  static Future<Map<String, dynamic>> favoritarMusicaPorUsername(
    String username,
    String idMusica,
  ) async {
    return await httpPost('/Favoritas', {
      'username': username,
      'idMusica': idMusica,
    });
  }
}
