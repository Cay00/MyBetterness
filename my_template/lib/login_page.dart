import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showRegister = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "email"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "haslo"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (passwordController.text.length < 6) {
                    setState(() {
                      error = "haslo musi miec minimum 6 znakow";
                    });
                    return;
                  }
                },
                child: Text(showRegister ? "zarejestruj" : "zaloguj"),
              ),

              const SizedBox(height: 10),

              Text(error),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  setState(() {
                    showRegister = !showRegister;
                  });
                },
                child: const Text(
                  "Nie masz konta? Zarejestruj się",
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
