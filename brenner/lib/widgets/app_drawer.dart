import 'package:flutter/material.dart';
import '../pages/profile_page.dart';
import '../pages/salvas_screen.dart';
import '../pages/search_page.dart';
import '../models/user.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  const AppDrawer({Key? key, required this.user}) : super(key: key);

  void _irParaHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
  }

  void _irParaProfile(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProfileScreen(user: user)));
  }

  void _irParaSalvas(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SalvasScreen()));
  }

  void _irParaSearch(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.username),
            accountEmail: Text(user.email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            decoration: const BoxDecoration(color: Colors.black),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _irParaHome(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Perfil', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _irParaProfile(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save, color: Colors.white),
            title: const Text('Salvas', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _irParaSalvas(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.white),
            title: const Text('Buscar', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _irParaSearch(context);
            },
          ),
        ],
      ),
    );
  }
}
