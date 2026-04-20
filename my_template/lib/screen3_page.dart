import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:io';

class Screen3Page extends StatefulWidget {
  const Screen3Page({super.key});

  @override
  State<Screen3Page> createState() => _Screen3PageState();
}

class _Screen3PageState extends State<Screen3Page> {
  int _steps = 0;
  double _calories = 0;
  Duration _screenTime = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Uprawnienia
      await _requestPermissions();
      
      // 2. Dane zdrowotne i statystyki równolegle, aby było szybciej
      await Future.wait([
        _fetchHealthData(),
        _fetchUsageStats(),
      ]);
    } catch (e) {
      debugPrint("Główny błąd pobierania danych: $e");
    } finally {
      // ZAWSZE wyłączamy ładowanie, nawet jak coś pójdzie nie tak
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.activityRecognition.request();
      if (Platform.isAndroid) {
        bool? isPermissionGranted = await UsageStats.checkUsagePermission();
        if (isPermissionGranted == false) {
          // Nie używamy await tutaj, bo otwarcie ustawień może "zawiesić" funkcję
          UsageStats.grantUsagePermission();
        }
      }
    } catch (e) {
      debugPrint("Błąd uprawnień: $e");
    }
  }

  Future<void> _fetchHealthData() async {
    try {
      Health health = Health();
      final types = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
      
      bool requested = await health.requestAuthorization(types);
      if (requested) {
        DateTime now = DateTime.now();
        DateTime midnight = DateTime(now.year, now.month, now.day);
        
        int? steps = await health.getTotalStepsInInterval(midnight, now);
        
        List<HealthDataPoint> data = await health.getHealthDataFromTypes(
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
          startTime: midnight,
          endTime: now,
        );
        
        double calories = 0;
        for (var p in data) {
          final value = p.value;
          if (value is NumericHealthValue) {
            calories += value.numericValue.toDouble();
          }
        }

        if (mounted) {
          setState(() {
            _steps = steps ?? 0;
            _calories = calories;
          });
        }
      }
    } catch (e) {
      debugPrint("Błąd pobierania danych zdrowotnych: $e");
    }
  }

  Future<void> _fetchUsageStats() async {
    if (Platform.isAndroid) {
      try {
        DateTime now = DateTime.now();
        DateTime midnight = DateTime(now.year, now.month, now.day);
        
        List<UsageInfo> usageStats = await UsageStats.queryUsageStats(midnight, now);
        
        int totalTimeMs = 0;
        for (var info in usageStats) {
          totalTimeMs += int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
        }

        if (mounted) {
          setState(() {
            _screenTime = Duration(milliseconds: totalTimeMs);
          });
        }
      } catch (e) {
        debugPrint("Błąd pobierania statystyk użycia: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8faff),
      body: _isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Pobieranie danych...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Twoja aktywność',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  _buildActivityCard(
                    title: 'Kroki',
                    value: '$_steps',
                    unit: 'dzisiaj',
                    icon: Icons.directions_walk,
                    color: Colors.blue,
                    progress: (_steps / 10000).clamp(0.0, 1.0),
                    target: 'Cel: 10 000',
                  ),
                  const SizedBox(height: 16),
                  _buildActivityCard(
                    title: 'Spalone kalorie',
                    value: _calories.toStringAsFixed(0),
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    progress: (_calories / 500).clamp(0.0, 1.0),
                    target: 'Cel: 500 kcal',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Higiena cyfrowa',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  _buildUsageCard(
                    title: 'Czas przed ekranem',
                    duration: _screenTime,
                    icon: Icons.phonelink_setup,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.purple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _screenTime.inHours > 4 
                              ? 'Spędzasz sporo czasu przed telefonem. Pamiętaj o przerwach dla oczu!' 
                              : 'Twój czas przed ekranem jest w normie. Tak trzymać!',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
    required String target,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Text(unit, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(target, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildUsageCard({
    required String title,
    required Duration duration,
    required IconData icon,
    required Color color,
  }) {
    String timeStr = '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(timeStr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}
