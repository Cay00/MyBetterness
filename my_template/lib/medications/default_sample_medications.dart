import 'medication_entry.dart';

/// Przykładowe wpisy wyświetlane domyślnie na liście (tylko UI).
List<MedicationEntry> defaultSampleMedications() {
  return [
    const MedicationEntry(
      id: 'sample_1',
      name: 'Metformina',
      formSize: '500 mg',
      packageSize: '60 tabl.',
      dose: '1 tabletka',
      intakeTimes: ['09:00', '19:00'],
      scheduleKind: MedicationScheduleKind.weekdays,
      selectedWeekdays: {1, 2, 3, 4, 5, 6, 7},
      timeMorning: '09:00',
      timeEvening: '19:00',
    ),
    const MedicationEntry(
      id: 'sample_2',
      name: 'Atorwastatyna',
      formSize: '20 mg',
      packageSize: '30 tabl.',
      dose: '1 tabletka wieczorem',
      intakeTimes: ['21:00'],
      scheduleKind: MedicationScheduleKind.weekdays,
      selectedWeekdays: {1, 2, 3, 4, 5, 6, 7},
      timeEvening: '21:00',
    ),
    const MedicationEntry(
      id: 'sample_3',
      name: 'Omeprazol',
      formSize: '20 mg',
      dose: '1 kapsułka na czczo',
      intakeTimes: ['07:30'],
      scheduleKind: MedicationScheduleKind.weekdays,
      selectedWeekdays: {1, 2, 3, 4, 5},
      timeMorning: '07:30',
    ),
    const MedicationEntry(
      id: 'sample_4',
      name: 'Paracetamol',
      formSize: '500 mg',
      packageSize: '20 tabl.',
      dose: '1–2 tabletki w razie bólu',
      intakeTimes: ['12:00'],
      scheduleKind: MedicationScheduleKind.everyNDays,
      selectedWeekdays: {},
      everyNDays: 1,
      timeNoon: '12:00',
    ),
    const MedicationEntry(
      id: 'sample_5',
      name: 'Amlodipina',
      formSize: '5 mg',
      packageSize: '28 tabl.',
      dose: '1 tabletka rano',
      intakeTimes: ['08:00'],
      scheduleKind: MedicationScheduleKind.weekdays,
      selectedWeekdays: {1, 3, 5, 7},
      timeMorning: '08:00',
    ),
  ];
}
