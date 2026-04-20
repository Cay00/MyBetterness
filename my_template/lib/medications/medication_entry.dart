/// Sposób określania dni przyjmowania leku.
enum MedicationScheduleKind {
  /// Konkretne dni tygodnia (1 = poniedziałek … 7 = niedziela, jak [DateTime.weekday]).
  weekdays,

  /// Co [everyNDays] dni (np. 2 = co drugi dzień).
  everyNDays,
}

/// Wpis leku tylko do UI (bez zapisu w bazie).
class MedicationEntry {
  const MedicationEntry({
    required this.id,
    required this.name,
    required this.formSize,
    this.packageSize,
    required this.dose,
    required this.intakeTimes,
    this.imageUrl,
    this.scheduleKind = MedicationScheduleKind.weekdays,
    this.selectedWeekdays = const {},
    this.everyNDays,
    this.timeMorning,
    this.timeNoon,
    this.timeEvening,
    this.timeNight,
  });

  final String id;
  final String name;
  /// Siła preparatu (np. mg, g jednej tabletki / dawki).
  final String formSize;

  /// Wielkość opakowania (np. liczba tabletek, ml) — opcjonalnie.
  final String? packageSize;
  final String dose;

  /// Lista godzin (np. z czterech pór) — używana w skrócie na liście.
  final List<String> intakeTimes;
  final String? imageUrl;

  final MedicationScheduleKind scheduleKind;
  final Set<int> selectedWeekdays;
  final int? everyNDays;

  /// Godziny w formacie `HH:mm` albo `null`, jeśli dana pora jest wyłączona.
  final String? timeMorning;
  final String? timeNoon;
  final String? timeEvening;
  final String? timeNight;

  /// Krótka etykieta „siła · opakowanie” do listy.
  String get strengthPackageLabel {
    final s = formSize.trim();
    final p = packageSize?.trim() ?? '';
    if (p.isEmpty) return s;
    if (s.isEmpty) return p;
    return '$s · $p';
  }

  String get timesLabel {
    if (intakeTimes.isEmpty) return '—';
    return intakeTimes.join(', ');
  }

  /// Krótki opis harmonogramu dni (dla kafelka / szczegółów).
  String get scheduleLabel {
    if (scheduleKind == MedicationScheduleKind.everyNDays) {
      final n = everyNDays;
      if (n == null || n < 1) return '—';
      if (n == 1) return 'Codziennie (co 1 dzień)';
      return 'Co $n dni';
    }
    if (selectedWeekdays.isEmpty) return '—';
    const short = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
    final ordered = selectedWeekdays.toList()..sort();
    return ordered.map((d) => short[d - 1]).join(', ');
  }

  /// Tekst z pór dnia i godzin (np. „Rano 8:00, Wieczór 20:00”).
  String get slotTimesLabel {
    final parts = <String>[];
    if (timeMorning != null && timeMorning!.isNotEmpty) {
      parts.add('Rano $timeMorning');
    }
    if (timeNoon != null && timeNoon!.isNotEmpty) {
      parts.add('Południe $timeNoon');
    }
    if (timeEvening != null && timeEvening!.isNotEmpty) {
      parts.add('Wieczór $timeEvening');
    }
    if (timeNight != null && timeNight!.isNotEmpty) {
      parts.add('Noc $timeNight');
    }
    if (parts.isEmpty) return timesLabel;
    return parts.join(', ');
  }

  /// Zbiera niepuste godziny z pór w kolejności rano → noc (do [intakeTimes]).
  static List<String> collectIntakeTimes({
    String? timeMorning,
    String? timeNoon,
    String? timeEvening,
    String? timeNight,
  }) {
    return [
      timeMorning,
      timeNoon,
      timeEvening,
      timeNight,
    ]
        .whereType<String>()
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}
