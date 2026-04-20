import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const Color _ink = Color(0xff222222);
const Color _border = Color(0xffcbd8eb);

void _showAddMeasurementPlaceholder(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Zapis nowego pomiaru — do podłączenia z formularzem lub urządzeniem.',
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Wspólny szkielet: nagłówek, karta podsumowania, wykres, legenda stref, lista.
class _DetailShell extends StatelessWidget {
  const _DetailShell({
    required this.title,
    required this.accent,
    required this.icon,
    required this.summary,
    required this.chart,
    required this.legend,
    required this.historyTitle,
    required this.historyItems,
  });

  final String title;
  final Color accent;
  final IconData icon;
  final Widget summary;
  final Widget chart;
  final Widget legend;
  final String historyTitle;
  final List<Widget> historyItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe9eeea),
      appBar: AppBar(
        backgroundColor: const Color(0xffe9eeea),
        foregroundColor: _ink,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: summary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LargeAddMeasurementButton(
              accent: accent,
              label: 'Dodaj pomiar',
              onPressed: () => _showAddMeasurementPlaceholder(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Trend (ostatnie 7 dni)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: chart,
            ),
            const SizedBox(height: 16),
            legend,
            const SizedBox(height: 20),
            Text(
              historyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 10),
            ...historyItems,
          ],
        ),
      ),
    );
  }
}

class _LargeAddMeasurementButton extends StatelessWidget {
  const _LargeAddMeasurementButton({
    required this.accent,
    required this.label,
    required this.onPressed,
  });

  final Color accent;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _ink,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          side: BorderSide(color: accent.withValues(alpha: 0.45), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 26,
                color: accent.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _zoneLegendRow(List<({Color color, String text})> items) {
  return Wrap(
    spacing: 12,
    runSpacing: 8,
    children: items
        .map(
          (e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: e.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                e.text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        )
        .toList(),
  );
}

Widget _historyTile({
  required String primary,
  String? secondary,
  required String badge,
  required Color badgeColor,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _ink,
                ),
              ),
              if (secondary != null && secondary.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    secondary,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _ink.withValues(alpha: 0.55),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: badgeColor,
            ),
          ),
        ),
      ],
    ),
  );
}

LineChartData _lineData({
  required List<FlSpot> spots,
  required Color color,
  required double minY,
  required double maxY,
  List<HorizontalLine>? horizontalLines,
}) {
  return LineChartData(
    minX: 0,
    maxX: (spots.length - 1).toDouble().clamp(0, 100),
    minY: minY,
    maxY: maxY,
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: (maxY - minY) / 4,
      getDrawingHorizontalLine: (v) =>
          FlLine(color: _border.withValues(alpha: 0.6), strokeWidth: 1),
    ),
    titlesData: FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (v, m) => Text(
            v.toInt().toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _ink.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (v, m) {
            final i = v.toInt();
            if (i < 0 || i >= _last7DayLabels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _last7DayLabels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _ink.withValues(alpha: 0.5),
                ),
              ),
            );
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: false),
    extraLinesData: ExtraLinesData(
      horizontalLines: horizontalLines ?? const [],
    ),
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.25,
        color: color,
        barWidth: 3,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.12), const Color(0xfff8fafc)],
          ),
        ),
      ),
    ],
  );
}

const _last7DayLabels = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

List<FlSpot> _spotsFromValues(List<double> values) {
  return List<FlSpot>.generate(
    values.length,
    (i) => FlSpot(i.toDouble(), values[i]),
  );
}

// --- Strony ---

class WeightDetailPage extends StatelessWidget {
  const WeightDetailPage({super.key});

  static const _values = [73.2, 72.9, 72.6, 72.8, 72.5, 72.4, 72.4];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff5e6aff);
    final spots = _spotsFromValues(_values);
    return _DetailShell(
      title: 'Waga',
      accent: accent,
      icon: Icons.monitor_weight_outlined,
      summary: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktualnie',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '72,4 kg',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cel: utrzymanie · trend lekko w dół vs. tydzień temu',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ],
      ),
      chart: SizedBox(
        height: 200,
        child: LineChart(
          _lineData(
            spots: spots,
            color: accent,
            minY: 71,
            maxY: 74,
            horizontalLines: [
              HorizontalLine(
                y: 72,
                color: accent.withValues(alpha: 0.35),
                strokeWidth: 1,
                dashArray: [6, 4],
              ),
            ],
          ),
        ),
      ),
      legend: _zoneLegendRow([
        (color: accent, text: 'Linia pomocnicza: orientacyjny cel 72 kg'),
      ]),
      historyTitle: 'Ostatnie pomiary',
      historyItems: [
        _historyTile(
          primary: 'Dziś, 07:10',
          secondary: '72,4 kg · łazienka',
          badge: 'Stabilnie',
          badgeColor: const Color(0xff2e7d32),
        ),
        _historyTile(
          primary: 'Wczoraj, 07:05',
          secondary: '72,5 kg',
          badge: 'OK',
          badgeColor: const Color(0xff2e7d32),
        ),
        _historyTile(
          primary: '12.04, 07:12',
          secondary: '72,8 kg',
          badge: 'OK',
          badgeColor: const Color(0xff2e7d32),
        ),
      ],
    );
  }
}

class GlucoseDetailPage extends StatelessWidget {
  const GlucoseDetailPage({super.key});

  static const _values = [102.0, 95.0, 88.0, 92.0, 98.0, 91.0, 98.0];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xffe91e63);
    final spots = _spotsFromValues(_values);
    return _DetailShell(
      title: 'Glukoza',
      accent: accent,
      icon: Icons.bloodtype_outlined,
      summary: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ostatni pomiar (na czczo, rano)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '98 mg/dL',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Zakres docelowy na czczo: 70–99 mg/dL (wg typowych widełek). '
            'Poniżej 70 — hipoglikemia, powyżej 125 — warto skonsultować z lekarzem.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: _ink,
            ),
          ),
        ],
      ),
      chart: SizedBox(
        height: 220,
        child: LineChart(
          _lineData(
            spots: spots,
            color: accent,
            minY: 70,
            maxY: 115,
            horizontalLines: [
              HorizontalLine(
                y: 70,
                color: const Color(0xffef5350),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
              HorizontalLine(
                y: 99,
                color: const Color(0xff66bb6a),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
        ),
      ),
      legend: _zoneLegendRow([
        (color: const Color(0xffef5350), text: 'Niski: < 70 mg/dL'),
        (color: const Color(0xff66bb6a), text: 'W normie: 70–99'),
        (color: const Color(0xffffa726), text: 'Podwyższony: ≥ 100'),
      ]),
      historyTitle: 'Historia pomiarów',
      historyItems: [
        _historyTile(
          primary: 'Dziś, 07:30',
          secondary: 'Na czczo · palec',
          badge: 'W normie',
          badgeColor: const Color(0xff2e7d32),
        ),
        _historyTile(
          primary: 'Wczoraj, 07:28',
          secondary: '95 mg/dL',
          badge: 'W normie',
          badgeColor: const Color(0xff2e7d32),
        ),
        _historyTile(
          primary: '16.04, 07:35',
          secondary: '102 mg/dL · lekko podwyższony',
          badge: 'Uwaga',
          badgeColor: const Color(0xffef6c00),
        ),
      ],
    );
  }
}

class BloodPressureDetailPage extends StatelessWidget {
  const BloodPressureDetailPage({super.key});

  static final _sys = [118, 122, 119, 121, 120, 119, 120];
  static final _dia = [76, 80, 78, 79, 77, 76, 78];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xffef3d3d);
    final sysSpots = _spotsFromValues(_sys.map((e) => e.toDouble()).toList());
    final diaSpots = _spotsFromValues(_dia.map((e) => e.toDouble()).toList());
    return _DetailShell(
      title: 'Ciśnienie',
      accent: accent,
      icon: Icons.favorite_outline,
      summary: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ostatni pomiar (spoczynek)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '120/78 mmHg',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cel: < 120/80 mmHg · powyżej 130/85 warto omówić z lekarzem.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: _ink,
            ),
          ),
        ],
      ),
      chart: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 65,
            maxY: 135,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: _border.withValues(alpha: 0.6), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, m) => Text(
                    v.toInt().toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _ink.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= _last7DayLabels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _last7DayLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _ink.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 120,
                  color: accent.withValues(alpha: 0.25),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
                HorizontalLine(
                  y: 80,
                  color: const Color(0xff42a5f5).withValues(alpha: 0.35),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ],
            ),
            lineBarsData: [
              LineChartBarData(
                spots: sysSpots,
                isCurved: true,
                curveSmoothness: 0.2,
                color: accent,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
              LineChartBarData(
                spots: diaSpots,
                isCurved: true,
                curveSmoothness: 0.2,
                color: const Color(0xff42a5f5),
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
      legend: _zoneLegendRow([
        (color: accent, text: 'Skurczowe (górna)'),
        (color: const Color(0xff42a5f5), text: 'Rozkurczowe (dolna)'),
        (
          color: _ink.withValues(alpha: 0.4),
          text: 'Linie: orientacyjnie 120 / 80',
        ),
      ]),
      historyTitle: 'Historia',
      historyItems: [
        _historyTile(
          primary: 'Dziś, 08:00',
          secondary: '120/78 mmHg · ramię · spoczynek',
          badge: 'OK',
          badgeColor: const Color(0xff2e7d32),
        ),
        _historyTile(
          primary: 'Wczoraj, 08:05',
          secondary: '119/76 mmHg',
          badge: 'OK',
          badgeColor: const Color(0xff2e7d32),
        ),
      ],
    );
  }
}

class HydrationDetailPage extends StatelessWidget {
  const HydrationDetailPage({super.key});

  static const _litersPerDay = [1.4, 1.5, 1.7, 1.6, 1.8, 1.5, 1.6];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff4caf50);
    const goal = 2.0;
    final spots = _spotsFromValues(_litersPerDay);
    return _DetailShell(
      title: 'Nawodnienie',
      accent: accent,
      icon: Icons.water_drop_outlined,
      summary: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dziś',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1,6 / ${goal.toStringAsFixed(1)} L',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cel dzienny: ${goal.toStringAsFixed(1)} L · słupki = suma wody z ostatnich dni (przykład).',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: _ink.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
      chart: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: goal * 1.15,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: _border.withValues(alpha: 0.6), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (v, m) => Text(
                    '${v.toStringAsFixed(1)}L',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _ink.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= _last7DayLabels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _last7DayLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _ink.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: goal,
                  color: accent.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(bottom: 4),
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    labelResolver: (d) => 'Cel ${goal.toStringAsFixed(1)} L',
                  ),
                ),
              ],
            ),
            barGroups: List.generate(
              spots.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: spots[i].y,
                    width: 14,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    color: spots[i].y >= goal
                        ? accent.withValues(alpha: 0.55)
                        : accent.withValues(alpha: 0.28),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      legend: _zoneLegendRow([
        (color: accent.withValues(alpha: 0.55), text: 'Osiągnięto cel'),
        (color: accent.withValues(alpha: 0.28), text: 'Poniżej celu'),
      ]),
      historyTitle: 'Wpisy (przykład)',
      historyItems: [
        _historyTile(
          primary: 'Dziś, 14:20',
          secondary: '+250 ml wody',
          badge: '+0,25 L',
          badgeColor: accent,
        ),
        _historyTile(
          primary: 'Dziś, 10:05',
          secondary: 'Herbata 200 ml',
          badge: '+0,2 L',
          badgeColor: accent,
        ),
      ],
    );
  }
}

class Spo2DetailPage extends StatelessWidget {
  const Spo2DetailPage({super.key});

  static const _values = [97.0, 98.0, 99.0, 98.0, 98.0, 97.0, 98.0];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff4caf50);
    final spots = _spotsFromValues(_values);
    return _DetailShell(
      title: 'SpO₂',
      accent: accent,
      icon: Icons.air_outlined,
      summary: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ostatni pomiar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '98%',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Typowo 95–100% jest OK · poniżej 95% — skonsultuj z lekarzem (orientacyjnie).',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: _ink,
            ),
          ),
        ],
      ),
      chart: SizedBox(
        height: 200,
        child: LineChart(
          _lineData(
            spots: spots,
            color: accent,
            minY: 92,
            maxY: 100,
            horizontalLines: [
              HorizontalLine(
                y: 95,
                color: const Color(0xffffa726),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
        ),
      ),
      legend: _zoneLegendRow([
        (color: const Color(0xffffa726), text: 'Próg uwagi: 95%'),
        (color: accent, text: 'Powyżej: zwykle w normie'),
      ]),
      historyTitle: 'Historia',
      historyItems: [
        _historyTile(
          primary: 'Dziś, 09:10',
          secondary: 'Palec · spoczynek',
          badge: 'OK',
          badgeColor: const Color(0xff2e7d32),
        ),
        _historyTile(
          primary: 'Wczoraj, 09:00',
          secondary: '98%',
          badge: 'OK',
          badgeColor: const Color(0xff2e7d32),
        ),
      ],
    );
  }
}

class HeartRateDetailPage extends StatelessWidget {
  const HeartRateDetailPage({super.key});

  static const _values = [68.0, 72.0, 75.0, 70.0, 71.0, 69.0, 72.0];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xffff9800);
    final spots = _spotsFromValues(_values);
    return _DetailShell(
      title: 'Tętno',
      accent: accent,
      icon: Icons.favorite_border,
      summary: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Średnie w spoczynku (ostatnie dni)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '72 bpm',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Spoczynek ok. 60–100 bpm u dorosłych (bardzo orientacyjnie).',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: _ink,
            ),
          ),
        ],
      ),
      chart: SizedBox(
        height: 200,
        child: LineChart(
          _lineData(
            spots: spots,
            color: accent,
            minY: 60,
            maxY: 85,
            horizontalLines: [
              HorizontalLine(
                y: 100,
                color: const Color(0xffef5350).withValues(alpha: 0.4),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
        ),
      ),
      legend: _zoneLegendRow([
        (color: accent, text: 'Trend spoczynkowy'),
        (
          color: const Color(0xffef5350),
          text: 'Linia: górny orientacyjny próg 100 bpm',
        ),
      ]),
      historyTitle: 'Historia',
      historyItems: [
        _historyTile(
          primary: 'Dziś, 08:50',
          secondary: '72 bpm · spoczynek',
          badge: 'W normie',
          badgeColor: const Color(0xff2e7d32),
        ),
        _historyTile(
          primary: 'Wczoraj, 08:45',
          secondary: '71 bpm',
          badge: 'W normie',
          badgeColor: const Color(0xff2e7d32),
        ),
      ],
    );
  }
}

class SleepDetailPage extends StatelessWidget {
  const SleepDetailPage({super.key});

  static const _hours = [6.5, 7.0, 6.8, 7.2, 7.5, 7.0, 7.33];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff9c27b0);
    final spots = _spotsFromValues(_hours);
    return _DetailShell(
      title: 'Sen',
      accent: accent,
      icon: Icons.bedtime_outlined,
      summary: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ostatnia noc',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '7 h 20 m',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cel: ok. 7–9 h · słupek = szacowany czas snu w danej nocy.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: _ink,
            ),
          ),
        ],
      ),
      chart: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: 10,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: _border.withValues(alpha: 0.6), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, m) => Text(
                    '${v.toInt()}h',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _ink.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= _last7DayLabels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _last7DayLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _ink.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 7,
                  color: accent.withValues(alpha: 0.4),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ],
            ),
            barGroups: List.generate(
              spots.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: spots[i].y,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    color: spots[i].y >= 7
                        ? accent.withValues(alpha: 0.52)
                        : accent.withValues(alpha: 0.26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      legend: _zoneLegendRow([
        (
          color: accent.withValues(alpha: 0.52),
          text: '≥ 7 h (orientacyjnie OK)',
        ),
        (color: accent.withValues(alpha: 0.26), text: 'Poniżej 7 h'),
      ]),
      historyTitle: 'Notatki',
      historyItems: [
        _historyTile(
          primary: 'Ostatnia noc',
          secondary: '22:45 – 06:05 · jakość: dobra',
          badge: '7h 20m',
          badgeColor: accent,
        ),
      ],
    );
  }
}

class MedicationsDetailPage extends StatelessWidget {
  const MedicationsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff2f6df6);
    return Scaffold(
      backgroundColor: const Color(0xffe9eeea),
      appBar: AppBar(
        backgroundColor: const Color(0xffe9eeea),
        foregroundColor: _ink,
        elevation: 0,
        title: const Text(
          'Leki',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      color: accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dziś: 3 / 3 przyjęte',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Średnia punktualność w tym tygodniu: ok. 95% (przykład).',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: _ink.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LargeAddMeasurementButton(
              accent: accent,
              label: 'Zapisz przyjęcie',
              onPressed: () => _showAddMeasurementPlaceholder(context),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oś czasu (7 dni)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 10),
            _historyTile(
              primary: 'Dziś',
              secondary:
                  'Rano · 08:00 — Metformina ✓\nPołudnie · 13:00 — Witamina D ✓\nWieczór · 21:00 — Statyna ✓',
              badge: '3/3',
              badgeColor: const Color(0xff2e7d32),
            ),
            _historyTile(
              primary: 'Wczoraj',
              secondary: 'Wszystkie dawki przyjęte',
              badge: '3/3',
              badgeColor: const Color(0xff2e7d32),
            ),
            _historyTile(
              primary: '15.04',
              secondary: 'Pominięto wieczór (przykład)',
              badge: '2/3',
              badgeColor: const Color(0xffef6c00),
            ),
            const SizedBox(height: 20),
            Text(
              'Wykres punktualności to uproszczony podgląd — pełna historia w kalendarzu leków.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openWeightDetail(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const WeightDetailPage()));
}

void openGlucoseDetail(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const GlucoseDetailPage()));
}

void openBloodPressureDetail(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const BloodPressureDetailPage()),
  );
}

void openHydrationDetail(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const HydrationDetailPage()));
}

void openSpo2Detail(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const Spo2DetailPage()));
}

void openHeartRateDetail(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const HeartRateDetailPage()));
}

void openSleepDetail(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const SleepDetailPage()));
}

void openMedicationsDetail(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const MedicationsDetailPage()),
  );
}
