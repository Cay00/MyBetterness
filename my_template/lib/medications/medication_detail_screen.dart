import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'medication_entry.dart';

const Color _ink = Color(0xff222222);
const Color _border = Color(0xffcbd8eb);

/// Szczegóły leku (UI). Po usunięciu zwraca `true` przez [Navigator.pop].
class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({super.key, required this.medication});

  final MedicationEntry medication;

  @override
  Widget build(BuildContext context) {
    final url = medication.imageUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;
    final packageTrimmed = medication.packageSize?.trim() ?? '';
    final packageDisplay = packageTrimmed.isEmpty ? '—' : packageTrimmed;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 4,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        title: Text(
          medication.name.isEmpty ? 'Lek' : medication.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Usuń z listy',
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xffef3d3d),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Usunąć z listy?'),
                  content: const Text(
                    'Usunięcie dotyczy tylko tej sesji aplikacji (bez zapisu w chmurze).',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Anuluj'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Usuń'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: hasUrl
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            const SizedBox(height: 20),
            _infoCard(
              'Nazwa',
              medication.name.isEmpty ? '—' : medication.name,
            ),
            const SizedBox(height: 12),
            _infoCard(
              'Siła preparatu (mg, g…)',
              medication.formSize.isEmpty ? '—' : medication.formSize,
            ),
            const SizedBox(height: 12),
            _infoCard('Wielkość opakowania', packageDisplay),
            const SizedBox(height: 12),
            _infoCard('Dawka', medication.dose.isEmpty ? '—' : medication.dose),
            const SizedBox(height: 12),
            _infoCard('Dni przyjmowania', medication.scheduleLabel),
            const SizedBox(height: 12),
            _infoCard('Pory dnia', medication.slotTimesLabel),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      color: AppTheme.primary.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: const Icon(
        Icons.medication_outlined,
        size: 72,
        color: Color(0xff2f6df6),
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _ink,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
