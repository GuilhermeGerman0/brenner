import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String bio = "Carregando ...";
  bool isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();
  String? email; // Novo campo para email

  @override
  void initState() {
    super.initState();
    _carregarBio();
    _carregarEmail(); // Buscar email ao iniciar
  }

  Future<void> _carregarBio() async {
    final bioApi = await ApiService.getBiografia(widget.user.username);
    setState(() {
      bio = (bioApi == null || bioApi == 'null' || bioApi.isEmpty)
          ? "Olá! Eu ainda não coloquei minha bio "
          : bioApi.toString();
      _bioController.text = bio;
    });
  }

  Future<void> _carregarEmail() async {
    try {
      final userData = await ApiService.getUserByUsername(widget.user.username);
      print(userData);
      setState(() {
        email = userData['email'] ?? widget.user.email;
      });
    } catch (e) {
      setState(() {
        email = widget.user.email;
      });
    }
  }

  void _editarBio() {
    setState(() => isEditingBio = true);
  }

  void _salvarBio() async {
    final novoBio = _bioController.text.trim().isEmpty
        ? "Olá! Eu ainda não coloquei minha bio"
        : _bioController.text.trim();
    setState(() {
      bio = novoBio;
      isEditingBio = false;
    });
    final result = await ApiService.atualizarBio(widget.user.username, novoBio);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'] ?? 'Bio atualizada!')));
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: const Text('Perfil', style: TextStyle(color: Colors.white)),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
    drawer: AppDrawer(user: widget.user),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.user.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Text(
              email ?? 'Carregando email...',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: isEditingBio
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _bioController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Sua bio',
                          labelStyle: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => isEditingBio = false),
                            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                          ),
                          ElevatedButton(
                            onPressed: _salvarBio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B8183),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          bio,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white54),
                        tooltip: 'Editar bio',
                        onPressed: _editarBio,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

}
