/// Rozpoznaje wartość wyglądającą na wzrost w cm (liczba), a nie tekst (np. nazwisko).
/// Obsługuje m.in. `175`, `175.5`, `175 cm` — wcześniej sufiks „cm” był błędnie
/// traktowany jako tekst (litery c, m) i wzrost trafiał do pola imienia.
bool looksLikeHeightCm(String raw) {
  return tryParseHeightCm(raw) != null;
}

/// Wyciąga wzrost w cm do wyświetlenia (np. `"175"`), albo null jeśli to nie liczba w sensownym zakresie.
String? tryParseHeightCm(String raw) {
  var t = raw.trim();
  if (t.isEmpty) return null;

  t = t.toLowerCase().replaceAll(',', '.');
  t = t.replaceAll(RegExp(r'\s*cm\s*$', caseSensitive: false), '');
  t = t.replaceAll(RegExp(r'\s'), '');

  var n = num.tryParse(t);
  if (n == null) {
    t = t.replaceAll(RegExp(r'[^0-9.]'), '');
    if (t.isEmpty) return null;
    n = num.tryParse(t);
  }
  if (n == null) return null;
  if (n < 30 || n > 280) return null;

  if (n == n.roundToDouble()) {
    return n.round().toString();
  }
  return n.toString();
}

/// Dzieli zapisane „Jan Kowalski” na imię i nazwisko (pierwszy token / reszta).
(String imie, String nazwisko) splitLegacyFullName(String full) {
  final t = full.trim();
  if (t.isEmpty) return ('', '');
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length == 1) return (parts[0], '');
  return (parts.first, parts.sublist(1).join(' '));
}
