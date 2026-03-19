import 'package:flutter/material.dart';

class CalendarFilterChips extends StatelessWidget {
  const CalendarFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters.map((filter) {
        final isSelected = filter == selectedFilter;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onFilterSelected(filter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff222222) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? const Color(0xff222222)
                    : const Color(0xffcbd8eb),
              ),
            ),
            child: Text(
              filter,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xff222222),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}