/// Kategorie w UI i nowych zapisach są po polsku; w Firestore mogą zostać
/// starsze wartości angielskie — mapujemy je do polskich etykiet.
String polishCalendarCategoryLabel(String raw) {
  switch (raw) {
    case 'Doctor':
    case 'Lekarz':
      return 'Lekarz';
    case 'Rehab':
    case 'Rehabilitacja':
      return 'Rehabilitacja';
    case 'Medications':
    case 'Leki':
      return 'Leki';
    case 'Meals':
    case 'Posiłki':
      return 'Posiłki';
    case 'Other':
    case 'Inne':
      return 'Inne';
    default:
      return raw;
  }
}
