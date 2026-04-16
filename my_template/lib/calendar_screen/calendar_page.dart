import 'package:flutter/material.dart';
import '../components/calendar/calendar_day_picker.dart';
import '../components/calendar/calendar_event_card.dart';
import '../components/calendar/calendar_filter_chips.dart';
import '../components/calendar/calendar_month_view.dart';
import '../components/calendar/calendar_view_toggle.dart';
import 'add_event_screen.dart';
import '../models/calendar_event.dart';
import '../services/firebase/calendar_service.dart';
import '../utils/calendar_category_localization.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarService _calendarService = CalendarService();
  final List<String> _calendarFilters = [
    'Wszystko',
    'Lekarz',
    'Rehabilitacja',
    'Leki',
    'Posiłki',
    'Inne',
  ];

  CalendarViewMode selectedMode = CalendarViewMode.daily;
  int selectedDayIndex = 0;
  late String selectedFilter;

  late DateTime _monthFocused;
  late DateTime _monthSelectedDate;

  @override
  void initState() {
    super.initState();
    selectedFilter = _calendarFilters.first;
    selectedDayIndex = _findInitialDayIndex();
    final n = DateTime.now();
    _monthFocused = DateTime(n.year, n.month);
    _monthSelectedDate = DateTime(n.year, n.month, n.day);
  }

  DateTime get _activeSelectedDate {
    if (selectedMode == CalendarViewMode.daily) {
      return _getSelectedDate();
    }
    return DateTime(
      _monthSelectedDate.year,
      _monthSelectedDate.month,
      _monthSelectedDate.day,
    );
  }

  void _shiftMonth(int delta) {
    setState(() {
      _monthFocused = DateTime(_monthFocused.year, _monthFocused.month + delta);
      final lastDay =
          DateTime(_monthFocused.year, _monthFocused.month + 1, 0).day;
      final day = _monthSelectedDate.day.clamp(1, lastDay);
      _monthSelectedDate =
          DateTime(_monthFocused.year, _monthFocused.month, day);
    });
  }

  /// Siedem kolejnych dni od **wczoraj** (indeks 0 = wczoraj, 1 = dziś, …).
  int _findInitialDayIndex() {
    return 1;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Pierwszy dzień paska w widoku dziennym: wczoraj (00:00).
  DateTime get _dailyStripStart {
    final today = _dateOnly(DateTime.now());
    return today.subtract(const Duration(days: 1));
  }

  DateTime _getSelectedDate() {
    return _dailyStripStart.add(Duration(days: selectedDayIndex));
  }

  List<CalendarDayOption> _buildDays(List<CalendarEvent> allEvents) {
    const weekdayLabels = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
    final now = DateTime.now();
    final start = _dailyStripStart;

    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      final hasPlannedEvent = allEvents.any(
        (e) =>
            e.startTime.year == date.year &&
            e.startTime.month == date.month &&
            e.startTime.day == date.day,
      );

      return CalendarDayOption(
        label: weekdayLabels[date.weekday - 1],
        dayNumber: date.day,
        isToday:
            date.day == now.day &&
            date.month == now.month &&
            date.year == now.year,
        hasPlannedEvent: hasPlannedEvent,
      );
    });
  }

  String _emptySelectedDayMessage(DateTime selectedDate) {
    if (selectedFilter != 'Wszystko') {
      return 'Brak wydarzeń w tej kategorii w wybranym dniu.';
    }
    final today = _dateOnly(DateTime.now());
    final sel = _dateOnly(selectedDate);
    if (sel == today) {
      return 'Brak wydarzeń dzisiaj.';
    }
    return 'Brak wydarzeń tego dnia.';
  }

  /// Wydarzenia po wybranym dniu kalendarzowym (do sekcji „Nadchodzące”).
  List<CalendarEvent> _upcomingEvents(
    List<CalendarEvent> allEvents,
    DateTime selectedDate,
  ) {
    final sel = _dateOnly(selectedDate);
    var list = allEvents.where((e) {
      final d = _dateOnly(e.startTime);
      return d.isAfter(sel);
    }).toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    if (selectedFilter != 'Wszystko') {
      list = list
          .where(
            (e) =>
                polishCalendarCategoryLabel(e.category) == selectedFilter,
          )
          .toList();
    }
    return list.take(5).toList();
  }

  String _eventScheduleLabel(CalendarEvent e) {
    final dd = e.startTime.day.toString().padLeft(2, '0');
    final mm = e.startTime.month.toString().padLeft(2, '0');
    final a =
        '${e.startTime.hour.toString().padLeft(2, '0')}:${e.startTime.minute.toString().padLeft(2, '0')}';
    final b =
        '${e.endTime.hour.toString().padLeft(2, '0')}:${e.endTime.minute.toString().padLeft(2, '0')}';
    return '$dd.$mm · $a–$b';
  }

  Color _getCategoryColor(String category) {
    switch (polishCalendarCategoryLabel(category)) {
      case 'Lekarz':
        return const Color(0xff5e6aff);
      case 'Rehabilitacja':
        return const Color(0xff4caf50);
      case 'Leki':
        return const Color(0xffff9800);
      case 'Posiłki':
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
            final selectedDate = _activeSelectedDate;

            var visibleEvents = allEvents.where((e) {
              return e.startTime.year == selectedDate.year &&
                  e.startTime.month == selectedDate.month &&
                  e.startTime.day == selectedDate.day;
            }).toList();

            visibleEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

            if (selectedFilter != 'Wszystko') {
              visibleEvents = visibleEvents
                  .where(
                    (e) =>
                        polishCalendarCategoryLabel(e.category) ==
                        selectedFilter,
                  )
                  .toList();
            }

            final upcomingEvents = _upcomingEvents(allEvents, selectedDate);

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 88 + bottomInset),
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
                          if (mode == CalendarViewMode.monthly) {
                            final d = _getSelectedDate();
                            _monthFocused = DateTime(d.year, d.month);
                            _monthSelectedDate =
                                DateTime(d.year, d.month, d.day);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedMode == CalendarViewMode.daily) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Ten tydzień',
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
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CalendarMonthView(
                        focusedMonth: _monthFocused,
                        selectedDate: _monthSelectedDate,
                        allEvents: allEvents,
                        onDaySelected: (d) => setState(() {
                          _monthSelectedDate = d;
                          _monthFocused = DateTime(d.year, d.month);
                        }),
                        onPreviousMonth: () => _shiftMonth(-1),
                        onNextMonth: () => _shiftMonth(1),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Filtry',
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
                          'Wydarzenia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${visibleEvents.length} zaplanowanych',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _emptySelectedDayMessage(selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (upcomingEvents.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Nadchodzące',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final event in upcomingEvents) ...[
                              CalendarEventCard(
                                title: event.title,
                                subtitle: event.description.isNotEmpty
                                    ? event.description
                                    : 'Brak opisu',
                                timeLabel: _eventScheduleLabel(event),
                                category: polishCalendarCategoryLabel(
                                  event.category,
                                ),
                                accentColor:
                                    _getCategoryColor(event.category),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ],
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
                              category: polishCalendarCategoryLabel(
                                event.category,
                              ),
                              accentColor: _getCategoryColor(event.category),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
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
                      AddEventScreen(selectedDate: _activeSelectedDate),
                ),
              );
            },
            backgroundColor: const Color(0xffef3d3d),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Dodaj wydarzenie',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
