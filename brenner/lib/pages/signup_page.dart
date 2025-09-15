import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:brenner/models/user.dart';
import 'profile_page.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String error = '';

  void signup() async {
  setState(() {
    isLoading = true;
    error = '';
  });

  final result = await ApiService.signup(
    User(
      username: usernameController.text,
      email: emailController.text,
      senha: passwordController.text,
    ),
  );

  if (result["success"] == true) {
    // Navegar direto para a tela de perfil, passando os dados do usuário
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          user: User(
            username: usernameController.text,
            email: emailController.text,
            senha: passwordController.text,
          ),
        ),
      ),
    );
  } else {
    setState(() {
      error = result["message"] ?? "Erro desconhecido";
    });
  }

  setState(() {
    isLoading = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Conta')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            SizedBox(height: 16),
            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: signup, child: Text('Cadastrar')),
          ],
        ),
      ),
    );
  }
}
