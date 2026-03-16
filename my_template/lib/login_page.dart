import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRegister = false;
  String error = '';

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password.length < 6) {
      setState(() {
        error = 'haslo musi miec minimum 6 znakow';
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('konto zostalo utworzone')),
        );

        setState(() {
          isRegister = false;
          error = '';
          passwordController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'blad rejestracji';
      });
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password.length < 6) {
      setState(() {
        error = 'haslo musi miec minimum 6 znakow';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('zalogowano')));
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'blad logowania';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'haslo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isRegister ? register : login,
                child: Text(isRegister ? 'zarejestruj' : 'zaloguj'),
              ),
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isRegister = !isRegister;
                    error = '';
                  });
                },
                child: const Text(
                  'Nie masz konta? Zarejestruj się',
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
