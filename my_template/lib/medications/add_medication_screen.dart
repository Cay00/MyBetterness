import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'medication_entry.dart';

const Color _ink = Color(0xff222222);
const Color _border = Color(0xffcbd8eb);
const Color _accentRed = Color(0xffef3d3d);

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _name = TextEditingController();
  final _strength = TextEditingController();
  final _packageSize = TextEditingController();
  final _dose = TextEditingController();
  final _everyNDays = TextEditingController(text: '1');
  final _imageUrl = TextEditingController();

  MedicationScheduleKind _scheduleKind = MedicationScheduleKind.weekdays;
  final Set<int> _weekdays = {};

  bool _useMorning = false;
  bool _useNoon = false;
  bool _useEvening = false;
  bool _useNight = false;

  TimeOfDay? _morning;
  TimeOfDay? _noon;
  TimeOfDay? _evening;
  TimeOfDay? _night;

  static const TimeOfDay _defaultMorning = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay _defaultNoon = TimeOfDay(hour: 12, minute: 0);
  static const TimeOfDay _defaultEvening = TimeOfDay(hour: 19, minute: 0);
  static const TimeOfDay _defaultNight = TimeOfDay(hour: 0, minute: 0);

  static const _weekdayMeta = <int, String>{
    1: 'Pn',
    2: 'Wt',
    3: 'Śr',
    4: 'Cz',
    5: 'Pt',
    6: 'So',
    7: 'Nd',
  };

  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _packageSize.dispose();
    _dose.dispose();
    _everyNDays.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      hintStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: _ink.withValues(alpha: 0.45),
      ),
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

  static const TextStyle _fieldTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _ink,
  );

  String? _formatTime(TimeOfDay? t) {
    if (t == null) return null;
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime({
    required TimeOfDay initial,
    required void Function(TimeOfDay) onSet,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => onSet(picked));
    }
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
    );
  }

  Widget _weekdayChip(int day, String label) {
    final sel = _weekdays.contains(day);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        setState(() {
          if (sel) {
            _weekdays.remove(day);
          } else {
            _weekdays.add(day);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _ink : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: sel ? _ink : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: sel ? Colors.white : const Color(0xff03070c),
          ),
        ),
      ),
    );
  }

  Widget _slotRow({
    required String label,
    required bool enabled,
    required TimeOfDay? time,
    required TimeOfDay slotDefault,
    required void Function(bool) onToggle,
    required void Function(TimeOfDay) onTime,
  }) {
    final effective = time ?? slotDefault;
    final timeText = _formatTime(effective)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: enabled,
              onChanged: (v) => onToggle(v ?? false),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _ink;
                }
                return null;
              }),
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled
                      ? () => _pickTime(
                            initial: time ?? slotDefault,
                            onSet: onTime,
                          )
                      : null,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: _ink.withValues(alpha: enabled ? 1 : 0.35),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _ink.withValues(
                                    alpha: enabled ? 0.5 : 0.35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                enabled ? timeText : 'Nie wybrano',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: enabled
                                      ? _ink
                                      : _ink.withValues(alpha: 0.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (enabled)
                          Icon(
                            Icons.chevron_right_rounded,
                            color: _ink.withValues(alpha: 0.35),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    final strength = _strength.text.trim();
    final pkg = _packageSize.text.trim();
    final dose = _dose.text.trim();

    if (name.isEmpty || strength.isEmpty || dose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Uzupełnij nazwę, siłę preparatu (mg, g) i dawkę.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.textDark,
        ),
      );
      return;
    }

    if (_scheduleKind == MedicationScheduleKind.weekdays && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Zaznacz co najmniej jeden dzień tygodnia.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.textDark,
        ),
      );
      return;
    }

    int? everyN;
    if (_scheduleKind == MedicationScheduleKind.everyNDays) {
      everyN = int.tryParse(_everyNDays.text.trim());
      if (everyN == null || everyN < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Podaj liczbę dni większą lub równą 1 (np. co 2 dni → 2).',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.textDark,
          ),
        );
        return;
      }
    }

    if (!_useMorning && !_useNoon && !_useEvening && !_useNight) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Zaznacz co najmniej jedną porę dnia (rano, południe, wieczór lub noc).',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.textDark,
        ),
      );
      return;
    }

    final tm = _useMorning
        ? _formatTime(_morning ?? _defaultMorning)
        : null;
    final tn = _useNoon ? _formatTime(_noon ?? _defaultNoon) : null;
    final te = _useEvening
        ? _formatTime(_evening ?? _defaultEvening)
        : null;
    final tnt = _useNight ? _formatTime(_night ?? _defaultNight) : null;
    final times = MedicationEntry.collectIntakeTimes(
      timeMorning: tm,
      timeNoon: tn,
      timeEvening: te,
      timeNight: tnt,
    );

    final url = _imageUrl.text.trim();
    final id = 'local_${DateTime.now().microsecondsSinceEpoch}';

    Navigator.of(context).pop(
      MedicationEntry(
        id: id,
        name: name,
        formSize: strength,
        packageSize: pkg.isEmpty ? null : pkg,
        dose: dose,
        intakeTimes: times,
        imageUrl: url.isEmpty ? null : url,
        scheduleKind: _scheduleKind,
        selectedWeekdays: _scheduleKind == MedicationScheduleKind.weekdays
            ? Set<int>.from(_weekdays)
            : const {},
        everyNDays: _scheduleKind == MedicationScheduleKind.everyNDays ? everyN : null,
        timeMorning: tm,
        timeNoon: tn,
        timeEvening: te,
        timeNight: tnt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 4,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Nowy lek',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uzupełnij dane leku i harmonogram przyjmowania.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _ink.withValues(alpha: 0.65),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Dane preparatu'),
            TextField(
              controller: _name,
              style: _fieldTextStyle,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Nazwa preparatu'),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _strength,
              style: _fieldTextStyle,
              decoration: _dec(
                'Siła preparatu (mg, g…)',
                hint: 'np. 500 mg, 5 mg/ml',
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _packageSize,
              style: _fieldTextStyle,
              decoration: _dec(
                'Wielkość opakowania (opcjonalnie)',
                hint: 'np. 30 tabl., 100 ml',
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _dose,
              style: _fieldTextStyle,
              decoration: _dec('Dawka', hint: 'np. 1 tabletka, 5 ml'),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Dni przyjmowania'),
            SegmentedButton<MedicationScheduleKind>(
              segments: const [
                ButtonSegment(
                  value: MedicationScheduleKind.weekdays,
                  label: Text('Dni tygodnia'),
                  icon: Icon(Icons.date_range_outlined, size: 18),
                ),
                ButtonSegment(
                  value: MedicationScheduleKind.everyNDays,
                  label: Text('Co ile dni'),
                  icon: Icon(Icons.repeat_rounded, size: 18),
                ),
              ],
              selected: {_scheduleKind},
              onSelectionChanged: (s) {
                setState(() => _scheduleKind = s.first);
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return _ink;
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return _ink;
                  }
                  return Colors.white;
                }),
                side: WidgetStateProperty.all(const BorderSide(color: _border)),
              ),
            ),
            const SizedBox(height: 14),
            if (_scheduleKind == MedicationScheduleKind.weekdays)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _weekdayMeta.entries
                    .map((e) => _weekdayChip(e.key, e.value))
                    .toList(),
              )
            else
              TextField(
                controller: _everyNDays,
                style: _fieldTextStyle,
                keyboardType: TextInputType.number,
                decoration: _dec(
                  'Co ile dni',
                  hint: 'np. 1 = codziennie, 2 = co drugi dzień',
                ),
              ),
            const SizedBox(height: 20),
            _sectionLabel('Pory dnia'),
            Text(
              'Zaznacz pory, w których przyjmujesz lek. Domyślne godziny: '
              'rano 9:00, południe 12:00, wieczór 19:00, noc 0:00 — możesz je zmienić.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _ink.withValues(alpha: 0.55),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            _slotRow(
              label: 'Rano',
              enabled: _useMorning,
              time: _morning,
              slotDefault: _defaultMorning,
              onToggle: (v) {
                setState(() {
                  _useMorning = v;
                  if (v) {
                    _morning ??= _defaultMorning;
                  } else {
                    _morning = null;
                  }
                });
              },
              onTime: (t) => _morning = t,
            ),
            _slotRow(
              label: 'Południe',
              enabled: _useNoon,
              time: _noon,
              slotDefault: _defaultNoon,
              onToggle: (v) {
                setState(() {
                  _useNoon = v;
                  if (v) {
                    _noon ??= _defaultNoon;
                  } else {
                    _noon = null;
                  }
                });
              },
              onTime: (t) => _noon = t,
            ),
            _slotRow(
              label: 'Wieczór',
              enabled: _useEvening,
              time: _evening,
              slotDefault: _defaultEvening,
              onToggle: (v) {
                setState(() {
                  _useEvening = v;
                  if (v) {
                    _evening ??= _defaultEvening;
                  } else {
                    _evening = null;
                  }
                });
              },
              onTime: (t) => _evening = t,
            ),
            _slotRow(
              label: 'Noc',
              enabled: _useNight,
              time: _night,
              slotDefault: _defaultNight,
              onToggle: (v) {
                setState(() {
                  _useNight = v;
                  if (v) {
                    _night ??= _defaultNight;
                  } else {
                    _night = null;
                  }
                });
              },
              onTime: (t) => _night = t,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _imageUrl,
              style: _fieldTextStyle,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: _dec(
                'Adres obrazka (opcjonalnie)',
                hint: 'https://…',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _accentRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Dodaj do listy',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
