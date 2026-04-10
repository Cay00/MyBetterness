import 'package:flutter/material.dart';

class CalendarDayOption {
  const CalendarDayOption({
    required this.label,
    required this.dayNumber,
    this.isToday = false,
    this.hasPlannedEvent = false,
  });

  final String label;
  final int dayNumber;
  final bool isToday;
  final bool hasPlannedEvent;
}

class CalendarDayPicker extends StatelessWidget {
  const CalendarDayPicker({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  final List<CalendarDayOption> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onDaySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff222222) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected || day.isToday
                      ? const Color(0xff222222)
                      : const Color(0xffcbd8eb),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xff222222),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${day.dayNumber}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xff222222),
                    ),
                  ),
                  if (day.hasPlannedEvent) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xff9bac69),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}