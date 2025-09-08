import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  String? _message;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    final response = await http.post(
      Uri.parse("http://localhost:3030/Usuarios/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _usernameController.text,
        "senha": _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = "✅ Login efetuado com sucesso!";
      });
    } else {
      setState(() {
        _message = "❌ Falha no login!";
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Usuário ou Email"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text("Entrar"),
                    ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(_message!, style: const TextStyle(fontSize: 16)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
