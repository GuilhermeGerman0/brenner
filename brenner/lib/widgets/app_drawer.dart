import 'package:brenner/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../pages/search_page.dart';
import '../pages/profile_page.dart';
import '../pages/Salvas_screen.dart';
import '../pages/Favoritas_screen.dart';
import '../pages/home_page.dart';
import '../services/api_service.dart';

class AppDrawer extends StatefulWidget {
  final User user;

  const AppDrawer({Key? key, required this.user}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? email;

  @override
  void initState() {
    super.initState();
    _carregarEmail();
  }

  Future<void> _carregarEmail() async {
    try {
      final userData = await ApiService.getUserByUsername(widget.user.username);
      setState(() {
        email = userData['email'] ?? widget.user.email;
      });
    } catch (e) {
      setState(() {
        email = widget.user.email;
      });
    }
  }

  void _navegar(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 209, 207, 207), // Cor sólida e clara
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email ?? 'Carregando email...'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF3B8183), // Cor consistente com botões
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            text: 'Home',
            onTap: () => _navegar(HomePage(user: widget.user)),
          ),
          _buildDrawerItem(
            icon: Icons.search,
            text: 'Buscar',
            onTap: () => _navegar(SearchPage(user: widget.user)),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            text: 'Perfil',
            onTap: () => _navegar(ProfileScreen(user: widget.user)),
          ),
          _buildDrawerItem(
            icon: Icons.bookmark,
            text: 'Salvas',
            onTap: () => _navegar(SalvasScreen(user: widget.user)),
          ),
          _buildDrawerItem(
            icon: Icons.favorite,
            text: 'Favoritas',
            onTap: () => _navegar(FavoritasScreen(user: widget.user)),
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Sair',
            onTap: () => _navegar(LoginScreen()),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.grey.shade200,
    );
  }
}
