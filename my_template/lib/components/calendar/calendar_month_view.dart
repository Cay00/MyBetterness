import 'package:flutter/material.dart';

import '../../models/calendar_event.dart';

const _weekDays = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

const _monthsPl = [
  'Styczeń',
  'Luty',
  'Marzec',
  'Kwiecień',
  'Maj',
  'Czerwiec',
  'Lipiec',
  'Sierpień',
  'Wrzesień',
  'Październik',
  'Listopad',
  'Grudzień',
];

/// Interaktywna siatka miesiąca (Pn–Nd), nawigacja miesiącami, podświetlenie dziś / wybranego dnia,
/// kropka przy dniach z wydarzeniami.
class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.allEvents,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<CalendarEvent> allEvents;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const _ink = Color(0xff222222);
  static const _border = Color(0xffcbd8eb);

  bool _hasEventOnDay(int year, int month, int day) {
    return allEvents.any(
      (e) =>
          e.startTime.year == year &&
          e.startTime.month == month &&
          e.startTime.day == day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final y = focusedMonth.year;
    final m = focusedMonth.month;
    final first = DateTime(y, m, 1);
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final leading = first.weekday - 1;
    final now = DateTime.now();

    final cells = <int?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(day);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    while (cells.length < 42) {
      cells.add(null);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                color: _ink,
                tooltip: 'Poprzedni miesiąc',
              ),
              Expanded(
                child: Text(
                  '${_monthsPl[m - 1]} $y',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                color: _ink,
                tooltip: 'Następny miesiąc',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _weekDays
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _ink.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final day = cells[index];
              if (day == null) {
                return const SizedBox.shrink();
              }

              final isToday =
                  day == now.day && m == now.month && y == now.year;
              final isSelected = day == selectedDate.day &&
                  m == selectedDate.month &&
                  y == selectedDate.year;
              final hasEvent = _hasEventOnDay(y, m, day);
              final highlightBorder = isSelected || isToday;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onDaySelected(DateTime(y, m, day)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff222222)
                          : const Color(0xfff4f7fb),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: highlightBorder
                            ? const Color(0xff222222)
                            : _border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : _ink,
                          ),
                        ),
                        if (hasEvent) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xff9bac69),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
