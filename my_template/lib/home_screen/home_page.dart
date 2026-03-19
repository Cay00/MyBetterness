import 'package:flutter/material.dart';
import '../components/calendar/calendar_day_picker.dart';
import '../components/calendar/calendar_event_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 208, 232, 255),
      body: SafeArea(
        child: Padding(padding: EdgeInsets.all(20), child: HomePageContent()),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});
  List<CalendarDayOption> _getDays() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      return CalendarDayOption(
        label: labels[index],
        dayNumber: date.day,
        isToday: date.day == now.day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDays();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Good Morning, User!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff12243d),
            ),
          ),
          const Text(
            "Ready for your care tasks today.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xffef3d3d),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '✱ SOS EMERGENCY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff2f6df6),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Need support with daily tasks?\nSomeone can help you.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Find Help',
                    style: TextStyle(
                      color: Color(0xff2f6df6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Care Calendar",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff12243d),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2f6df6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Daily",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Monthly",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              int idx = entry.key;
              var day = entry.value;
              bool isSelected = idx == 3;
              return Column(
                children: [
                  Text(
                    day.label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xff2f6df6) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      //upda
                      color: isSelected
                          ? const Color(0xff2f6df6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "${day.dayNumber}",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xff12243d),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xff2f6df6),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xff2f6df6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "1:30 AM - 7:00 PM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "URGENT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const CalendarEventCard(
            title: "Medication Plan",
            subtitle: "12:00 - 7:30 AM",
            timeLabel: "",
            category: "",
            accentColor: Colors.transparent,
          ),
          const SizedBox(height: 12),
          const CalendarEventCard(
            title: "Rehab Session",
            subtitle: "Physical Therapy - Dr. Soan",
            timeLabel: "4:00 PM",
            category: "Health",
            accentColor: Colors.blue,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Recent Vitals",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "See details",
                      style: TextStyle(
                        color: Color(0xff2f6df6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xfff1f1f1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.bar_chart,
                      size: 50,
                      color: Color(0xff2f6df6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
