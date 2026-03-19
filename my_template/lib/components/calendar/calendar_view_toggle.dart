import 'package:flutter/material.dart';

enum CalendarViewMode { daily, monthly }

class CalendarViewToggle extends StatelessWidget {
  const CalendarViewToggle({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final CalendarViewMode selectedMode;
  final ValueChanged<CalendarViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Daily',
              isSelected: selectedMode == CalendarViewMode.daily,
              onTap: () => onModeChanged(CalendarViewMode.daily),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ToggleButton(
              label: 'Monthly',
              isSelected: selectedMode == CalendarViewMode.monthly,
              onTap: () => onModeChanged(CalendarViewMode.monthly),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff222222) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xff222222),
          ),
        ),
      ),
    );
  }
}