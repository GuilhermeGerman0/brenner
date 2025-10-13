import 'package:brenner/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../pages/search_page.dart';
import '../pages/profile_page.dart';
import '../pages/Salvas_screen.dart';
import '../pages/Favoritas_screen.dart';
import '../pages/home_page.dart';

class AppDrawer extends StatelessWidget {
  final User user;

  const AppDrawer({Key? key, required this.user}) : super(key: key);

  void _irparaHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomePage(user: user)),
    );
  } 

  void _irParaSearch(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchPage(user: user)),
    );
  }

  void _irParaProfile(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
    );
  }

  void _irParaSalvas(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SalvasScreen(user: user)),
    );
  }

  void _irParaFavoritas(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FavoritasScreen(user: user)),
    );
  }

  void _irParaLogin(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
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
            leading: const Icon(Icons.search, color: Colors.white),
            title: const Text('Buscar', style: TextStyle(color: Colors.white)),
            onTap: () => _irParaSearch(context),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () => _irparaHome(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.white),
            title: const Text('Favoritas', style: TextStyle(color: Colors.white)),
            onTap: () => _irParaFavoritas(context),
          ),
          ListTile(
            leading: const Icon(Icons.save, color: Colors.white),
            title: const Text('Salvas', style: TextStyle(color: Colors.white)),
            onTap: () => _irParaSalvas(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Perfil', style: TextStyle(color: Colors.white)),
            onTap: () => _irParaProfile(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _irParaLogin(context),
          )
        ],
      ),
    );
  }
}
