import 'package:flutter/material.dart';

class CalendarMonthPlaceholder extends StatelessWidget {
  const CalendarMonthPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const days = [
      '', '', '', '', '', '1', '2',
      '3', '4', '5', '6', '7', '8', '9',
      '10', '11', '12', '13', '14', '15', '16',
      '17', '18', '19', '20', '21', '22', '23',
      '24', '25', '26', '27', '28', '29', '30',
      '31', '', '', '', '', '', '',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'March 2026',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xff222222),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff222222),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final isHighlighted = day == '18';

              return Container(
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? const Color(0xff2f6df6)
                      : const Color(0xfff4f7fb),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: day.isEmpty
                          ? Colors.transparent
                          : isHighlighted
                          ? Colors.white
                          : const Color(0xff222222),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffeef4ff),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Monthly view placeholder. Event logic can be added later.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff222222),
              ),
            ),
          ),
        ],
      ),
    );
  }
}