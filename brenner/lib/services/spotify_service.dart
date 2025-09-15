import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spotify_track.dart';

class SpotifyService {
  final String clientId = '7b0536e1b13245138baae34f9e558a6f';
  final String clientSecret = '64b6f9eee77d4436b17f5d5cbb7302e1';
  String? _token;
  DateTime? _tokenExpiry;

  // Obter token
  Future<void> _getToken() async {
    if (_token != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }

    final credentials = base64.encode(utf8.encode('$clientId:$clientSecret'));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in'] - 60));
    } else {
      throw Exception('Erro ao pegar token Spotify: ${response.body}');
    }
  }

  // Buscar músicas
  Future<List<SpotifyTrack>> searchTracks(String query, {int limit = 10}) async {
    await _getToken();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track&limit=$limit'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['tracks']['items'] as List;
      return items.map((json) => SpotifyTrack.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar músicas Spotify: ${response.body}');
    }
  }
}
