import 'package:flutter/material.dart';

import 'medications/add_medication_screen.dart';
import 'medications/default_sample_medications.dart';
import 'medications/medication_detail_screen.dart';
import 'medications/medication_entry.dart';
import 'theme/app_theme.dart';

const Color _ink = Color(0xff222222);
const Color _border = Color(0xffcbd8eb);

/// Lista leków — wyłącznie UI (pamięć lokalna, bez Firestore).
class Screen3Page extends StatefulWidget {
  const Screen3Page({super.key});

  @override
  State<Screen3Page> createState() => _Screen3PageState();
}

class _Screen3PageState extends State<Screen3Page> {
  final List<MedicationEntry> _items =
      List<MedicationEntry>.from(defaultSampleMedications());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final list = _items;

    return ColoredBox(
      color: AppTheme.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          list.isEmpty
              ? ListView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 88 + bottomInset),
                  children: [
                    const Text(
                      'Twoje leki',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dodaj preparaty, które przyjmujesz — zobaczysz tu dawkę i harmonogram. '
                      'Lista jest na razie tylko w tej sesji aplikacji.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _ink.withValues(alpha: 0.65),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 48,
                            color: _ink.withValues(alpha: 0.25),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Brak pozycji na liście',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ink.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dotknij czerwonego przycisku „Dodaj lek”.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _ink.withValues(alpha: 0.55),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 88 + bottomInset),
                  itemCount: list.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Twoje leki',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${list.length} na liście',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _ink.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Dawki i godziny przyjmowania.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _ink.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final med = list[index - 1];
                    return _MedicationTile(
                      medication: med,
                      onTap: () async {
                        final removed = await Navigator.of(context)
                            .push<bool>(
                          MaterialPageRoute(
                            builder: (_) =>
                                MedicationDetailScreen(medication: med),
                          ),
                        );
                        if (removed == true && mounted) {
                          setState(() {
                            _items.removeWhere((e) => e.id == med.id);
                          });
                        }
                      },
                    );
                  },
                ),
          Positioned(
            right: 16,
            bottom: 16 + bottomInset,
            child: FloatingActionButton.extended(
              heroTag: 'screen3_add_medication',
              onPressed: () async {
                final entry = await Navigator.of(context).push<MedicationEntry>(
                  MaterialPageRoute(
                    builder: (_) => const AddMedicationScreen(),
                  ),
                );
                if (entry != null && mounted) {
                  setState(() => _items.add(entry));
                }
              },
              backgroundColor: const Color(0xffef3d3d),
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.add),
              label: const Text(
                'Dodaj lek',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.medication,
    required this.onTap,
  });

  final MedicationEntry medication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = medication.imageUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: hasUrl
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _thumbFallback(),
                          )
                        : _thumbFallback(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.strengthPackageLabel.isEmpty
                            ? medication.name
                            : '${medication.name} · ${medication.strengthPackageLabel}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        medication.dose.isEmpty ? '—' : medication.dose,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.scheduleLabel} · ${medication.slotTimesLabel}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _ink.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _ink.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbFallback() {
    return ColoredBox(
      color: AppTheme.primary.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.medication_outlined,
          size: 36,
          color: _ink.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
