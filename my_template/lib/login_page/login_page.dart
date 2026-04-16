import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../default_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  bool isRegister = false;
  String error = '';

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final imie = firstNameController.text.trim();
    final nazwisko = lastNameController.text.trim();
    final height = heightController.text.trim();
    final weight = weightController.text.trim();
    final age = ageController.text.trim();

    if (imie.isEmpty ||
        nazwisko.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        age.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() {
        error = 'Uzupełnij wszystkie pola';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        error = 'Hasło musi mieć minimum 6 znaków';
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'imie': imie,
          'nazwisko': nazwisko,
          'imieNazwisko': '$imie $nazwisko'.trim(),
          'wzrost': height,
          'waga': weight,
          'wiek': age,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DefaultScreen()),
        );

        setState(() {
          isRegister = false;
          error = '';
          emailController.clear();
          passwordController.clear();
          firstNameController.clear();
          lastNameController.clear();
          heightController.clear();
          weightController.clear();
          ageController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Błąd rejestracji';
      });
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = 'Uzupełnij e-mail i hasło';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        error = 'Hasło musi mieć minimum 6 znaków';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DefaultScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Błąd logowania';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRegister) ...[
                  TextField(
                    controller: firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Imię',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nazwisko',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Wzrost (cm)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Waga (kg)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Wiek'),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Hasło'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isRegister ? register : login,
                  child: Text(isRegister ? 'Zarejestruj się' : 'Zaloguj się'),
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
                  child: Text(
                    isRegister
                        ? 'Masz konto? Zaloguj się'
                        : 'Nie masz konta? Zarejestruj się',
                    style: const TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
