import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../mapa_screen.dart';
import 'health_detail/health_detail_pages.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: HomePageContent()));
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key, this.onOpenFindHelp});

  final VoidCallback? onOpenFindHelp;

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    
    // Pobieramy czcionkę obsługującą polskie znaki
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Raport Zdrowia - MyBetterness',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Podsumowanie parametrów życiowych:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _pdfRow('Waga', '72.4 kg'),
              _pdfRow('Glukoza', '98 mg/dL'),
              _pdfRow('Ciśnienie', '120/78 mmHg'),
              _pdfRow('Nawodnienie', '1.6 / 2.0 L'),
              pw.SizedBox(height: 20),
              pw.Text('Dodatkowe sygnały:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _pdfRow('SpO2', '98%'),
              _pdfRow('Tętno', '72 bpm'),
              _pdfRow('Sen', '7 h 20 m'),
              _pdfRow('Leki dzisiaj', '3 / 3 przyjęte'),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 40),
                child: pw.Text(
                  'Wygenerowano: ${DateTime.now().toString().split('.')[0]}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Raport_Zdrowia_MyBetterness.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    Expanded(
                      child: _HelpBlueTileButton(
                        label: 'Znajdź pomoc',
                        onTap: onOpenFindHelp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HelpBlueTileButton(
                        label: 'Mapa',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Parametry i samopoczucie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff222222),
                ),
              ),
              IconButton(
                onPressed: () => _generatePdf(context),
                icon: const Icon(Icons.picture_as_pdf, color: Color(0xff2f6df6)),
                tooltip: 'Pobierz raport PDF',
              ),
            ],
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
                  onOpenDetail: () => openWeightDetail(context),
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
                  onOpenDetail: () => openGlucoseDetail(context),
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
                  onOpenDetail: () => openBloodPressureDetail(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HydrationCard(
                  currentLiters: 1.6,
                  goalLiters: 2.0,
                  onOpenDetail: () => openHydrationDetail(context),
                ),
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
              children: [
                _InfoRow(
                  icon: Icons.air_outlined,
                  iconColor: const Color(0xff4caf50),
                  label: 'SpO₂',
                  value: '98%',
                  onOpenDetail: () => openSpo2Detail(context),
                ),
                const Divider(height: 22),
                _InfoRow(
                  icon: Icons.favorite_border,
                  iconColor: const Color(0xffff9800),
                  label: 'Tętno',
                  value: '72 bpm',
                  onOpenDetail: () => openHeartRateDetail(context),
                ),
                const Divider(height: 22),
                _InfoRow(
                  icon: Icons.bedtime_outlined,
                  iconColor: const Color(0xff9c27b0),
                  label: 'Sen',
                  value: '7 h 20 m',
                  onOpenDetail: () => openSleepDetail(context),
                ),
                const Divider(height: 22),
                _InfoRow(
                  icon: Icons.medication_outlined,
                  iconColor: const Color(0xff2f6df6),
                  label: 'Leki dziś',
                  value: '3 / 3 przyjęte',
                  onOpenDetail: () => openMedicationsDetail(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpBlueTileButton extends StatelessWidget {
  const _HelpBlueTileButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff2f6df6),
                fontWeight: FontWeight.w800,
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ),
        ),
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
    required this.onOpenDetail,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String unit;
  final String hint;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onOpenDetail,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius,
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
                          color: const Color(
                            0xff222222,
                          ).withValues(alpha: 0.55),
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
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _MetricCornerPlusBadge(accent: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  const _HydrationCard({
    required this.currentLiters,
    required this.goalLiters,
    required this.onOpenDetail,
  });

  final double currentLiters;
  final double goalLiters;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final progress = (currentLiters / goalLiters).clamp(0.0, 1.0);
    const accent = Color(0xff4caf50);
    final radius = BorderRadius.circular(24);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onOpenDetail,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius,
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
                        child: const Icon(
                          Icons.water_drop_outlined,
                          size: 22,
                          color: accent,
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
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _MetricCornerPlusBadge(accent: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCornerPlusBadge extends StatelessWidget {
  const _MetricCornerPlusBadge({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.add_rounded, size: 20, color: Color(0xff222222)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onOpenDetail,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpenDetail,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(width: 4),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: Color(0xff222222),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
