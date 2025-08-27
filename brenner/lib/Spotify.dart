import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = '7b0536e1b13245138baae34f9e558a6f';
  final String clientSecret = '64b6f9eee77d4436b17f5d5cbb7302e1';
  final String redirectUri = 'myapp://callback';

  String? _accessToken;

  Future<void> login() async {
    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': 'user-top-read',
    });

    final result = await FlutterWebAuth.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'myapp',
    );

    final code = Uri.parse(result).queryParameters['code'];

    final tokenUrl = Uri.parse('https://accounts.spotify.com/api/token');
    final response = await http.post(tokenUrl, body: {
      'grant_type': 'authorization_code',
      'code': code!,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'client_secret': clientSecret,
    });

    final data = json.decode(response.body);
    _accessToken = data['access_token'];
  }

  Future<List<Map<String, dynamic>>> getTopTracks() async {
    if (_accessToken == null) throw Exception('Usuário não logado');

    final url = Uri.parse(
        'https://api.spotify.com/v1/me/top/tracks?time_range=long_term&limit=10');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);
    final items = data['items'] as List<dynamic>;
    return items.map((track) {
      return {
        'name': track['name'],
        'artists': (track['artists'] as List)
            .map((artist) => artist['name'])
            .join(', ')
      };
    }).toList();
  }
}
