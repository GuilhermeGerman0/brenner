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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFAD089),
              Color(0xFFFF9C5B),
              Color(0xFFF5634A),
              Color(0xFFED303C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SizedBox(
                width: 500,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_alt_1,
                          size: 64,
                          color: Color(0xFF3B8183),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Criar Conta',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (error.isNotEmpty)
                          Text(
                            error,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        const SizedBox(height: 24),
                        isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: signup,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color(0xFF3B8183),
                                  ),
                                  child: const Text(
                                    'Cadastrar',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Voltar para login',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
