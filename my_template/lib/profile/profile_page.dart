import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../login_page/login_page.dart';
import '../theme/app_theme.dart';
import '../utils/profile_name_helper.dart';

/// Profil użytkownika: dane z Firestore (`users/{uid}`), edycja, przełączniki UI,
/// skróty do ustawień i wylogowanie na dole ekranu.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

String _stringFromFirestore(dynamic v) {
  if (v == null) return '';
  if (v is String) return v.trim();
  if (v is num) {
    if (v is double && v == v.roundToDouble()) {
      return v.round().toString();
    }
    return v.toString();
  }
  return v.toString().trim();
}

/// Szuka pierwszej sensownej wartości wzrostu (cm) w kilku możliwych polach dokumentu.
String _readHeightCmFromDoc(Map<String, dynamic> d) {
  const keys = [
    'wzrost',
    'Wzrost',
    'height',
    'Height',
    'wzrostCm',
    'wzrost_cm',
    'heightCm',
  ];
  for (final k in keys) {
    if (!d.containsKey(k)) continue;
    final raw = _stringFromFirestore(d[k]);
    if (raw.isEmpty) continue;
    final p = tryParseHeightCm(raw);
    if (p != null) return p;
  }
  return '';
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _ink = Color(0xff222222);
  static const Color _border = Color(0xffcbd8eb);

  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String _email = '';
  bool _loading = true;
  bool _saving = false;

  bool _notifyMeds = true;
  bool _notifyCalendar = true;
  bool _notifyDailySummary = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _email = user.email ?? '';
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        final imie = _stringFromFirestore(d['imie']);
        final nazwisko = _stringFromFirestore(d['nazwisko']);
        final legacyName = _stringFromFirestore(d['imieNazwisko']);
        final fromParts = '$imie $nazwisko'.trim();

        /// Najpierw skład z `imie` + `nazwisko`; jeśli puste (stare dokumenty),
        /// użyj `imieNazwisko`.
        var fullName = fromParts.isNotEmpty ? fromParts : legacyName;

        final wzrostDisplay = _readHeightCmFromDoc(d);

        final rawWzrostField = _stringFromFirestore(d['wzrost']);
        final rawWzrostCap = _stringFromFirestore(d['Wzrost']);
        final rawMisplaced =
            rawWzrostField.isNotEmpty ? rawWzrostField : rawWzrostCap;
        if (wzrostDisplay.isEmpty &&
            rawMisplaced.isNotEmpty &&
            tryParseHeightCm(rawMisplaced) == null &&
            !RegExp(r'\d').hasMatch(rawMisplaced)) {
          fullName = fullName.isEmpty
              ? rawMisplaced
              : '$fullName $rawMisplaced'.trim();
        }

        _nameCtrl.text = fullName;
        _heightCtrl.text = wzrostDisplay;
        _weightCtrl.text = _stringFromFirestore(d['waga']);
        _ageCtrl.text = _stringFromFirestore(d['wiek']);
        if (d['notifyMeds'] is bool) _notifyMeds = d['notifyMeds'] as bool;
        if (d['notifyCalendar'] is bool) {
          _notifyCalendar = d['notifyCalendar'] as bool;
        }
        if (d['notifyDailySummary'] is bool) {
          _notifyDailySummary = d['notifyDailySummary'] as bool;
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie udało się wczytać profilu.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final full = _nameCtrl.text.trim();
      final split = splitLegacyFullName(full);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'uid': user.uid,
          'email': user.email,
          'imie': split.$1,
          'nazwisko': split.$2,
          'imieNazwisko': full,
          'wzrost': _heightCtrl.text.trim(),
          'waga': _weightCtrl.text.trim(),
          'wiek': _ageCtrl.text.trim(),
          'notifyMeds': _notifyMeds,
          'notifyCalendar': _notifyCalendar,
          'notifyDailySummary': _notifyDailySummary,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zapisano zmiany.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd zapisu: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  InputDecoration _decoration(String label) {
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
      padding: const EdgeInsets.only(bottom: 14, top: 8),
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }

  String _fullName() {
    return _nameCtrl.text.trim();
  }

  String _initials() {
    final n = _fullName();
    if (n.isEmpty) {
      final e = _email;
      if (e.isEmpty) return '?';
      return e[0].toUpperCase();
    }
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return n.length >= 2 ? n.substring(0, 2).toUpperCase() : n.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.35),
                  child: Text(
                    _initials(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _fullName().isEmpty ? 'Twój profil' : _fullName(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email.isEmpty ? 'Brak adresu e-mail' : _email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Moje dane'),
          _card(
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Imię i nazwisko'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _heightCtrl,
                  onChanged: (_) => setState(() {}),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _decoration('Wzrost (cm)'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _weightCtrl,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: _decoration('Waga (kg)'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _ageCtrl,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: _decoration('Wiek'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 22),
                InputDecorator(
                  decoration: _decoration('E-mail (do logowania)'),
                  child: Text(
                    _email.isEmpty ? '—' : _email,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _ink.withValues(alpha: _email.isEmpty ? 0.35 : 0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _saveProfile,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff222222),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Zapisz zmiany',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Powiadomienia'),
          _card(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Przypomnienia o lekach',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
                  ),
                  subtitle: Text(
                    'Powiadomienia o przyjęciu leków',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _ink.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  value: _notifyMeds,
                  activeThumbColor: const Color(0xff222222),
                  onChanged: (v) => setState(() => _notifyMeds = v),
                ),
                const Divider(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Wydarzenia z kalendarza',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
                  ),
                  subtitle: Text(
                    'Zbliżające się wizyty i zadania',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _ink.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  value: _notifyCalendar,
                  activeThumbColor: const Color(0xff222222),
                  onChanged: (v) => setState(() => _notifyCalendar = v),
                ),
                const Divider(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Podsumowanie dnia',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
                  ),
                  subtitle: Text(
                    'Krótkie przypomnienie rano',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _ink.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  value: _notifyDailySummary,
                  activeThumbColor: const Color(0xff222222),
                  onChanged: (v) => setState(() => _notifyDailySummary = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Przełączniki zapisują się razem z przyciskiem „Zapisz zmiany”.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _ink.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Ustawienia'),
          _card(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_rounded, color: _ink),
                  title: const Text(
                    'Język aplikacji',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
                  ),
                  subtitle: const Text('Polski'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wkrótce więcej języków.')),
                    );
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.palette_outlined, color: _ink),
                  title: const Text(
                    'Motyw',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
                  ),
                  subtitle: const Text('Jasny'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tryb ciemny — w przygotowaniu.'),
                      ),
                    );
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shield_outlined, color: _ink),
                  title: const Text(
                    'Prywatność i dane',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tu pojawią się ustawienia prywatności.'),
                      ),
                    );
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.help_outline_rounded, color: _ink),
                  title: const Text(
                    'Pomoc i opinie',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dziękujemy! Formularz kontaktu wkrótce.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Color(0xffef3d3d)),
              label: const Text(
                'Wyloguj się',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xffef3d3d),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xffef3d3d), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
