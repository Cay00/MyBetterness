import 'package:flutter/material.dart';

import '../components/calendar/calendar_filter_chips.dart';
import '../models/calendar_event.dart';
import '../services/firebase/calendar_service.dart';
import '../theme/app_theme.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventScreen({super.key, required this.selectedDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calendarService = CalendarService();
  bool _isLoading = false;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  String _selectedCategory = 'Lekarz';

  final List<String> _categories = [
    'Lekarz',
    'Rehabilitacja',
    'Leki',
    'Posiłki',
    'Inne',
  ];

  static const Color _bodyText = Color(0xff222222);
  static const Color _borderColor = Color(0xffcbd8eb);
  static const Color _accentRed = Color(0xffef3d3d);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: _bodyText,
      ),
      hintStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: _bodyText.withValues(alpha: 0.45),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _bodyText, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() => _endTime = picked);
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final newEvent = CalendarEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        category: _selectedCategory,
      );

      await _calendarService.addEvent(newEvent);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nie udało się zapisać: $e',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.textDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _bodyText,
        ),
      ),
    );
  }

  Widget _selectTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: _bodyText, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _bodyText.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _bodyText.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _bodyText,
        elevation: 4,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Dodaj wydarzenie',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _bodyText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dodaj wpis do kalendarza opieki.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _bodyText.withValues(alpha: 0.65),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Tytuł'),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _bodyText,
                ),
                decoration: _fieldDecoration('Nazwa wydarzenia'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Podaj tytuł'
                        : null,
              ),
              const SizedBox(height: 20),
              _sectionLabel('Termin'),
              _selectTile(
                label: 'Data',
                value: _formatDate(_selectedDate),
                icon: Icons.calendar_month_rounded,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _selectTile(
                      label: 'Początek',
                      value: _startTime.format(context),
                      icon: Icons.schedule_rounded,
                      onTap: _pickStartTime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _selectTile(
                      label: 'Koniec',
                      value: _endTime.format(context),
                      icon: Icons.schedule_rounded,
                      onTap: _pickEndTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionLabel('Opis'),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _bodyText,
                ),
                decoration: _fieldDecoration(
                  'Notatki',
                  hint: 'Opcjonalne szczegóły',
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              _sectionLabel('Kategoria'),
              CalendarFilterChips(
                filters: _categories,
                selectedFilter: _selectedCategory,
                onFilterSelected: (filter) =>
                    setState(() => _selectedCategory = filter),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: FilledButton.styleFrom(
                    backgroundColor: _accentRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _accentRed.withValues(alpha: 0.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Zapisz wydarzenie',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
