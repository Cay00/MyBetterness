import 'package:flutter/material.dart';
import '../components/calendar/calendar_day_picker.dart';
import '../components/calendar/calendar_event_card.dart';
import '../components/calendar/calendar_filter_chips.dart';
import '../components/calendar/calendar_month_placeholder.dart';
import '../components/calendar/calendar_view_toggle.dart';
import '../data/calendar_mock_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final List<CalendarDayOption> days;
  late final List<List<CalendarEventData>> eventsByDay;

  CalendarViewMode selectedMode = CalendarViewMode.daily;
  int selectedDayIndex = 0;
  String selectedFilter = calendarFilters.first;

  @override
  void initState() {
    super.initState();
    days = _buildDays();
    eventsByDay = calendarMockEventsByDay;
    selectedDayIndex = _findInitialDayIndex();
  }

  int _findInitialDayIndex() {
    final index = days.indexWhere((day) => day.isToday);
    return index == -1 ? 0 : index;
  }

  List<CalendarDayOption> _buildDays() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      return CalendarDayOption(
        label: labels[index],
        dayNumber: date.day,
        isToday: date.day == now.day &&
            date.month == now.month &&
            date.year == now.year,
      );
    });
  }

  List<CalendarEventData> get visibleEvents {
    final dayEvents = eventsByDay[selectedDayIndex];
    if (selectedFilter == 'All') {
      return dayEvents;
    }
    return dayEvents
        .where((event) => event.category == selectedFilter)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarViewToggle(
                selectedMode: selectedMode,
                onModeChanged: (mode) {
                  setState(() {
                    selectedMode = mode;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (selectedMode == CalendarViewMode.daily) ...[
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff222222),
                  ),
                ),
                const SizedBox(height: 14),
                CalendarDayPicker(
                  days: days,
                  selectedIndex: selectedDayIndex,
                  onDaySelected: (index) {
                    setState(() {
                      selectedDayIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 22),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff222222),
                  ),
                ),
                const SizedBox(height: 12),
                CalendarFilterChips(
                  filters: calendarFilters,
                  selectedFilter: selectedFilter,
                  onFilterSelected: (filter) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff222222),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${visibleEvents.length} planned',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff222222),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (visibleEvents.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'No events in this category for the selected day yet.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff222222),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final event in visibleEvents) ...[
                        CalendarEventCard(
                          title: event.title,
                          subtitle: event.subtitle,
                          timeLabel: event.timeLabel,
                          category: event.category,
                          accentColor: event.accentColor,
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
              ] else ...[
                const CalendarMonthPlaceholder(),
              ],
            ],
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add event action placeholder')),
              );
            },
            backgroundColor: const Color(0xffef3d3d),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Event',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
