import 'package:flutter/material.dart';
import '../components/calendar/calendar_day_picker.dart';
import '../components/calendar/calendar_event_card.dart';
import '../components/calendar/calendar_filter_chips.dart';
import '../components/calendar/calendar_month_placeholder.dart';
import '../components/calendar/calendar_view_toggle.dart';
import 'add_event_screen.dart';
import '../models/calendar_event.dart';
import '../services/firebase/calendar_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarService _calendarService = CalendarService();
  final List<String> _calendarFilters = [
    'All',
    'Doctor',
    'Rehab',
    'Medications',
    'Meals',
    'Other',
  ];

  CalendarViewMode selectedMode = CalendarViewMode.daily;
  int selectedDayIndex = 0;
  late String selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = _calendarFilters.first;
    selectedDayIndex = _findInitialDayIndex();
  }

  int _findInitialDayIndex() {
    final now = DateTime.now();
    return now.weekday - 1;
  }

  DateTime _getSelectedDate() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return start.add(Duration(days: selectedDayIndex));
  }

  List<CalendarDayOption> _buildDays(List<CalendarEvent> allEvents) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      final hasPlannedEvent = allEvents.any(
        (e) =>
            e.startTime.year == date.year &&
            e.startTime.month == date.month &&
            e.startTime.day == date.day,
      );

      return CalendarDayOption(
        label: labels[index],
        dayNumber: date.day,
        isToday:
            date.day == now.day &&
            date.month == now.month &&
            date.year == now.year,
        hasPlannedEvent: hasPlannedEvent,
      );
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Doctor':
        return const Color(0xff5e6aff);
      case 'Rehab':
        return const Color(0xff4caf50);
      case 'Medications':
        return const Color(0xffff9800);
      case 'Meals':
        return const Color(0xffe91e63);
      default:
        return const Color(0xff9e9e9e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        StreamBuilder<List<CalendarEvent>>(
          stream: _calendarService.getUserEvents(),
          builder: (context, snapshot) {
            final allEvents = snapshot.data ?? [];
            final days = _buildDays(allEvents);
            final selectedDate = _getSelectedDate();

            var visibleEvents = allEvents.where((e) {
              return e.startTime.year == selectedDate.year &&
                  e.startTime.month == selectedDate.month &&
                  e.startTime.day == selectedDate.day;
            }).toList();

            visibleEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

            if (selectedFilter != 'All') {
              visibleEvents = visibleEvents
                  .where((e) => e.category == selectedFilter)
                  .toList();
            }

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 88 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CalendarViewToggle(
                      selectedMode: selectedMode,
                      onModeChanged: (mode) =>
                          setState(() => selectedMode = mode),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CalendarDayPicker(
                      days: days,
                      selectedIndex: selectedDayIndex,
                      onDaySelected: (index) =>
                          setState(() => selectedDayIndex = index),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CalendarFilterChips(
                        filters: _calendarFilters,
                        selectedFilter: selectedFilter,
                        onFilterSelected: (filter) =>
                            setState(() => selectedFilter = filter),
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
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${visibleEvents.length} planned',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (visibleEvents.isEmpty)
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
                                subtitle: event.description.isNotEmpty
                                    ? event.description
                                    : 'Brak opisu',
                                timeLabel:
                                    '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                                category: event.category,
                                accentColor: _getCategoryColor(event.category),
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
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16 + bottomInset,
          child: FloatingActionButton.extended(
            heroTag: 'calendar_add_event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEventScreen(selectedDate: _getSelectedDate()),
                ),
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
