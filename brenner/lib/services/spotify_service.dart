// lib/services/spotify_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../models/spotify_track.dart';
import 'package:flutter/foundation.dart';

class SpotifyService {
  final String clientId = '7b0536e1b13245138baae34f9e558a6f';
  final String clientSecret = '64b6f9eee77d4436b17f5d5cbb7302e1';
  final String redirectUri = kIsWeb
      ? 'http://127.0.0.1:8000/callback'
      : 'brenner://callback';
  final List<String> scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-read-collaborative',
    'user-library-read',
    'user-top-read',
  ];

  String? _token;
  DateTime? _tokenExpiry;
  String? _userToken;

  // setter público para web
  set userToken(String? token) => _userToken = token;

  // ======================
  // TOKEN APP (Client Credentials)
  // ======================
  Future<void> _getToken() async {
    if (_token != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) return;

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

  Map<String, String> get _headers => {'Authorization': 'Bearer $_token'};

  // ======================
  // USUÁRIO (User Token)
  // ======================
  Future<void> authenticateUser() async {
    final authUrl =
        'https://accounts.spotify.com/authorize?response_type=token&client_id=$clientId&redirect_uri=$redirectUri&scope=${scopes.join('%20')}';
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'brenner',
    );
    final token = Uri.parse(result).fragment
        .split('&')
        .firstWhere((e) => e.startsWith('access_token='))
        .split('=')[1];
    _userToken = token;
  }

  Map<String, String> get _userHeaders => {'Authorization': 'Bearer $_userToken'};

  // ======================
  // SEARCH TRACKS
  // ======================
  Future<List<SpotifyTrack>> searchTracks(String query, {int limit = 10}) async {
    await _getToken();
    final url = 'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track&limit=$limit';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final items = jsonDecode(response.body)['tracks']['items'] as List;
      return items.map((json) => SpotifyTrack.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar músicas Spotify: ${response.body}');
    }
  }

  // ======================
  // TRACK DETAIL
  // ======================
  Future<SpotifyTrack> getTrackById(String trackId) async {
    await _getToken();
    final url = 'https://api.spotify.com/v1/tracks/$trackId';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return SpotifyTrack.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar detalhes da música: ${response.body}');
    }
  }

  // ======================
  // RECOMMENDATIONS
  // ======================
  Future<List<SpotifyTrack>> getRecommendationsForTrack(String trackId, {int limit = 10}) async {
    await _getToken();
    final url = 'https://api.spotify.com/v1/recommendations?limit=$limit&seed_tracks=$trackId';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final items = jsonDecode(response.body)['tracks'] as List;
      return items.map((json) => SpotifyTrack.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar recomendações: ${response.body}');
    }
  }

  // ======================
  // USER PLAYLIST TRACKS
  // ======================
  Future<List<SpotifyTrack>> getUserPlaylistsTracks({int limit = 10}) async {
    if (_userToken == null) throw Exception('Usuário não autenticado');
    final playlistsResp = await http.get(Uri.parse('https://api.spotify.com/v1/me/playlists?limit=1'), headers: _userHeaders);
    if (playlistsResp.statusCode != 200) throw Exception('Erro ao buscar playlists: ${playlistsResp.body}');

    final playlists = (jsonDecode(playlistsResp.body)['items'] as List);
    if (playlists.isEmpty) return [];

    final playlistId = playlists.first['id'];
    final tracksResp = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=$limit'),
      headers: _userHeaders,
    );
    if (tracksResp.statusCode != 200) throw Exception('Erro ao buscar faixas: ${tracksResp.body}');

    final items = (jsonDecode(tracksResp.body)['items'] as List);
    return items.map((item) => SpotifyTrack.fromJson(item['track'])).where((t) => t.nome.isNotEmpty).toList();
  }

  // ======================
  // TOP 50 GLOBAL
  // ======================
  Future<List<SpotifyTrack>> getTop10Global() async {
    await _getToken();
    // Playlist oficial do Top 50 Global do Spotify
    const playlistId = '37i9dQZEVXbMDoHDwVN2tF';
    final url = 'https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=50';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final items = (jsonDecode(response.body)['items'] as List);
      return items.map((item) => SpotifyTrack.fromJson(item['track'])).toList();
    } else {
      throw Exception('Erro ao buscar Top 10 Global: ${response.body}');
    }
  }
}
