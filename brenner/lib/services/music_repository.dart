import '../models/spotify_track.dart';

class MusicRepository {
  static final List<SpotifyTrack> _favoritas = [];
  static final List<SpotifyTrack> _salvas = [];

  static List<SpotifyTrack> get favoritas => _favoritas;
  static List<SpotifyTrack> get salvas => _salvas;

  static void addFavorita(SpotifyTrack track) {
    // evita duplicata
    if (!_favoritas.any((t) => t.spotifyUrl == track.spotifyUrl)) {
      _favoritas.add(track);
    }
  }

  static void addSalva(SpotifyTrack track) {
    if (!_salvas.any((t) => t.spotifyUrl == track.spotifyUrl)) {
      _salvas.add(track);
    }
  }
}
  