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
    eventsByDay = calendarMockEventsByDay;
    days = _buildDays();
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
      final hasPlannedEvent =
          index < eventsByDay.length && eventsByDay[index].isNotEmpty;

      return CalendarDayOption(
        label: labels[index],
        dayNumber: date.day,
        isToday: date.day == now.day &&
            date.month == now.month &&
            date.year == now.year,
        hasPlannedEvent: hasPlannedEvent,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CalendarViewToggle(
                  selectedMode: selectedMode,
                  onModeChanged: (mode) {
                    setState(() {
                      selectedMode = mode;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (selectedMode == CalendarViewMode.daily) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff03070C),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CalendarDayPicker(
                  days: days,
                  selectedIndex: selectedDayIndex,
                  onDaySelected: (index) {
                    setState(() {
                      selectedDayIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff03070C),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CalendarFilterChips(
                    filters: calendarFilters,
                    selectedFilter: selectedFilter,
                    onFilterSelected: (filter) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff03070C),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${visibleEvents.length} planned',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff03070C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (visibleEvents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'No events in this category for the selected day yet.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff03070C),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (final event in visibleEvents) ...[
                          CalendarEventCard(
                            title: event.title,
                            subtitle: event.subtitle,
                            timeLabel: event.timeLabel,
                            category: event.category,
                            accentColor: event.accentColor,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CalendarMonthPlaceholder(),
                ),
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
