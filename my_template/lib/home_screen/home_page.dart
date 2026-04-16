import 'package:flutter/material.dart';
import '../map_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: HomePageContent()));
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dzień dobry',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xff222222),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Oto podsumowanie Twojego zdrowia na dziś.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xff222222).withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xffef3d3d),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '✱ SOS — POGOTOWIE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xff2f6df6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Poproś o pomoc',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Potrzebujesz wsparcia w codziennych sprawach?\nKtoś może Ci pomóc.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Znajdź pomoc',
                        style: TextStyle(
                          color: Color(0xff2f6df6),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              // MAPA TUTAJ
                              builder: (_) => const MapScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            218,
                            253,
                            253,
                            253,
                          ),
                          foregroundColor: const Color(0xff2f6df6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Otwórz Mapę'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Parametry i samopoczucie',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff222222),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HealthMetricCard(
                  icon: Icons.monitor_weight_outlined,
                  accent: const Color(0xff5e6aff),
                  label: 'Waga',
                  value: '72.4',
                  unit: 'kg',
                  hint: 'Stabilnie vs ub. tydzień',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HealthMetricCard(
                  icon: Icons.bloodtype_outlined,
                  accent: const Color(0xffe91e63),
                  label: 'Glukoza',
                  value: '98',
                  unit: 'mg/dL',
                  hint: 'Na czczo · rano',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HealthMetricCard(
                  icon: Icons.favorite_outline,
                  accent: const Color(0xffef3d3d),
                  label: 'Ciśnienie',
                  value: '120/78',
                  unit: 'mmHg',
                  hint: 'W spoczynku',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HydrationCard(currentLiters: 1.6, goalLiters: 2.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Więcej sygnałów',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff222222),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: const [
                _InfoRow(
                  icon: Icons.air_outlined,
                  iconColor: Color(0xff4caf50),
                  label: 'SpO₂',
                  value: '98%',
                ),
                Divider(height: 22),
                _InfoRow(
                  icon: Icons.favorite_border,
                  iconColor: Color(0xffff9800),
                  label: 'Tętno',
                  value: '72 bpm',
                ),
                Divider(height: 22),
                _InfoRow(
                  icon: Icons.bedtime_outlined,
                  iconColor: Color(0xff9c27b0),
                  label: 'Sleep',
                  value: '7 h 20 m',
                ),
                Divider(height: 22),
                _InfoRow(
                  icon: Icons.medication_outlined,
                  iconColor: Color(0xff2f6df6),
                  label: 'Leki dziś',
                  value: '3 / 3 przyjęte',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffeff4ff),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xff2f6df6),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Podane wartości są przykładowe. Podłącz urządzenie lub uzupełnij wpisy, aby spersonalizować ten ekran.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff222222).withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMetricCard extends StatelessWidget {
  const _HealthMetricCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.unit,
    required this.hint,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String unit;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: accent),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff222222),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff222222),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff222222).withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xff222222).withValues(alpha: 0.5),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  const _HydrationCard({required this.currentLiters, required this.goalLiters});

  final double currentLiters;
  final double goalLiters;

  @override
  Widget build(BuildContext context) {
    final progress = (currentLiters / goalLiters).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff4caf50).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  size: 22,
                  color: Color(0xff4caf50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Nawodnienie',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff222222),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${currentLiters.toStringAsFixed(1)} / ${goalLiters.toStringAsFixed(1)} L',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff222222),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xffe8eef5),
              color: const Color(0xff4caf50),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xff222222),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xff222222),
          ),
        ),
      ],
    );
  }
}
