import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3030";

  // 🔹 Buscar todos os artistas
  static Future<List<dynamic>> getArtistas() async {
    final response = await http.get(Uri.parse("$baseUrl/Artistas"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao buscar artistas");
    }
  }

  // 🔹 Buscar artista por nome
  static Future<Map<String, dynamic>> getArtistaByName(String nome) async {
    final response = await http.get(Uri.parse("$baseUrl/Artistas/$nome"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Artista não encontrado");
    }
  }

  // 🔹 Inserir artista
  static Future<String> addArtista(String nome, String genero) async {
    final response = await http.post(
      Uri.parse("$baseUrl/Artistas"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nomeArtista": nome, "genero": genero}),
    );
    return response.body;
  }

  // 🔹 Deletar artista por ID
  static Future<String> deleteArtistaById(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/Artistas/id/$id"));
    return response.body;
  }

  // 🔹 Atualizar artista
  static Future<String> updateArtista(int id, String nome, String genero) async {
    final response = await http.put(
      Uri.parse("$baseUrl/Artistas/id/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nomeArtista": nome, "genero": genero}),
    );
    return response.body;
  }
}
