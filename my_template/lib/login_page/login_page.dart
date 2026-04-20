import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../default_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _ink = Color(0xff222222);
  static const Color _border = Color(0xffcbd8eb);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  bool isRegister = false;
  String error = '';

  Future<void> _saveSession(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('userEmail', email);
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: _ink),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _ink, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
    );
  }

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

        await _saveSession(user.uid, email);

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
      if (!mounted) return;
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

      await _saveSession(FirebaseAuth.instance.currentUser!.uid, email);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DefaultScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message ?? 'Błąd logowania';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xffffffff),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xff03070c),
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'MyBetterness',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                isRegister ? 'Załóż konto' : 'Witaj ponownie',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isRegister
                    ? 'Uzupełnij dane, aby zacząć korzystać z aplikacji.'
                    : 'Zaloguj się, aby zobaczyć podsumowanie i kalendarz opieki.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _ink.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isRegister) ...[
                      _sectionTitle('Dane osobowe'),
                      TextField(
                        controller: firstNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration('Imię'),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: lastNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration('Nazwisko'),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Profil zdrowia'),
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration('Wzrost (cm)'),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration('Waga (kg)'),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration('Wiek'),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Logowanie'),
                    ],
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration('E-mail'),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) =>
                          isRegister ? register() : login(),
                      decoration: _fieldDecoration('Hasło'),
                    ),
                    if (error.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffffebee),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xffe57373).withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 22,
                              color: Colors.red.shade800,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: isRegister ? register : login,
                      style: FilledButton.styleFrom(
                        backgroundColor: _ink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isRegister ? 'Zarejestruj się' : 'Zaloguj się',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isRegister = !isRegister;
                      error = '';
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff2f6df6),
                  ),
                  child: Text(
                    isRegister
                        ? 'Masz konto? Zaloguj się'
                        : 'Nie masz konta? Zarejestruj się',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
