import 'package:flutter/material.dart';
import 'spotify.dart';

// --- MODELO DE DADOS ---
enum Dificuldade { Facil, Intermediario, Dificil }

class Partitura {
  final String titulo;
  final String artista;
  final Dificuldade dificuldade;

  const Partitura({
    required this.titulo,
    required this.artista,
    required this.dificuldade,
  });
}

// --- DADOS MOCK ---
final List<Partitura> mockPartituras = [
  const Partitura(titulo: 'Stairway to Heaven', artista: 'Led Zeppelin', dificuldade: Dificuldade.Dificil),
  const Partitura(titulo: 'Nothing Else Matters', artista: 'Metallica', dificuldade: Dificuldade.Intermediario),
  const Partitura(titulo: 'Bohemian Rhapsody', artista: 'Queen', dificuldade: Dificuldade.Dificil),
  const Partitura(titulo: 'Sweet Child O\' Mine', artista: 'Guns N\' Roses', dificuldade: Dificuldade.Intermediario),
  const Partitura(titulo: 'Imagine', artista: 'John Lennon', dificuldade: Dificuldade.Facil),
  const Partitura(titulo: 'Hallelujah', artista: 'Leonard Cohen', dificuldade: Dificuldade.Facil),
];

void main() {
  runApp(const BrennerApp());
}

class BrennerApp extends StatelessWidget {
  const BrennerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brenner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.amberAccent,
          surface: Color.fromARGB(255, 129, 117, 117),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

// --- MAIN PAGE ---
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final SpotifyService spotifyService = SpotifyService();

  static late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      SearchPage(spotifyService: spotifyService),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Partituras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// --- HOME PAGE ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildDifficultyChip(Dificuldade dificuldade) {
    Color chipColor;
    String label;

    switch (dificuldade) {
      case Dificuldade.Facil:
        chipColor = Colors.green;
        label = 'Fácil';
        break;
      case Dificuldade.Intermediario:
        chipColor = Colors.orange;
        label = 'Médio';
        break;
      case Dificuldade.Dificil:
        chipColor = Colors.red;
        label = 'Difícil';
        break;
    }
    return Chip(
      label: Text(label),
      backgroundColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      side: BorderSide(color: chipColor),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Partituras')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: mockPartituras.length,
        itemBuilder: (context, index) {
          final partitura = mockPartituras[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              leading: const Icon(Icons.library_music_outlined, size: 32),
              title: Text(partitura.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(partitura.artista, style: TextStyle(color: Colors.grey[400])),
              trailing: _buildDifficultyChip(partitura.dificuldade),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartituraDetailPage(partitura: partitura),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- SEARCH PAGE ---
class SearchPage extends StatefulWidget {
  final SpotifyService spotifyService;
  const SearchPage({super.key, required this.spotifyService});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> spotifyTracks = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadSpotifyTopTracks();
  }

  void loadSpotifyTopTracks() async {
    setState(() => loading = true);
    try {
      await widget.spotifyService.login();
      final tracks = await widget.spotifyService.getTopTracks();
      setState(() {
        spotifyTracks = tracks;
      });
    } catch (e) {
      print('Erro Spotify: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Músicas')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: spotifyTracks.length,
              itemBuilder: (context, index) {
                final track = spotifyTracks[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(track['name']),
                    subtitle: Text(track['artists']),
                  ),
                );
              },
            ),
    );
  }
}

// --- PROFILE PAGE ---
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTdpIz5LgulAXYzUQoBxwSq4zx9CtiZv1WUNys3okHg8GUqwF0N05oHqIAYilbVKaleWRLmZbYv0wWisWFmiqos4K_AmnXmclf4FBgoXmJLNw'),
              ),
              const SizedBox(height: 20),
              Text('Brenner Silva', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('brenner.silva@email.com', style: textTheme.titleMedium?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PARTITURA DETAIL PAGE ---
class PartituraDetailPage extends StatelessWidget {
  final Partitura partitura;

  const PartituraDetailPage({super.key, required this.partitura});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(partitura.titulo), backgroundColor: Theme.of(context).colorScheme.surface),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Artista: ${partitura.artista}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            const Icon(Icons.article_outlined, size: 150, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('A visualização da partitura aparecerá aqui.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
