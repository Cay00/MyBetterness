import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _fallbackCenter = LatLng(51.1079, 17.0385);
  final MapController _mapController = MapController();
  bool _isLoading = true;
  LatLng _center = _fallbackCenter;
  List<Marker> _pharmacyMarkers = const [];
  String? _errorMessage;
  bool _usedFallback = false;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Aptek'),
        backgroundColor: const Color(0xff2f6df6),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              MarkerLayer(markers: _pharmacyMarkers),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (!_isLoading && _errorMessage != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _usedFallback = false;
    });

    try {
      final position = await _getCurrentPosition();
      final center = LatLng(position.latitude, position.longitude);
      final markers = await _fetchPharmacies(center);

      if (!mounted) {
        return;
      }

      setState(() {
        _center = center;
        _pharmacyMarkers = markers;
      });

      _mapController.move(center, 13);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _center = _fallbackCenter;
        _pharmacyMarkers = const [];
        _errorMessage =
            'Nie udało się pobrać lokalizacji. Pokazuję apteki dla domyślnego obszaru.';
        _usedFallback = true;
      });
      _mapController.move(_fallbackCenter, 13);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location denied');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  Future<List<Marker>> _fetchPharmacies(LatLng center) async {
    final query =
        '[out:json][timeout:25];(node["amenity"="pharmacy"](around:3000,${center.latitude},${center.longitude});way["amenity"="pharmacy"](around:3000,${center.latitude},${center.longitude});relation["amenity"="pharmacy"](around:3000,${center.latitude},${center.longitude}););out center;';

    final response = await http
        .post(
          Uri.parse('https://overpass-api.de/api/interpreter'),
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Overpass error ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();

    final markers = <Marker>[];
    for (final item in elements) {
      final lat = _readLat(item);
      final lon = _readLon(item);
      if (lat == null || lon == null) {
        continue;
      }

      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 30,
          height: 30,
          child: const Icon(
            Icons.local_pharmacy,
            color: Colors.green,
            size: 30,
          ),
        ),
      );
    }

    return markers;
  }

  double? _readLat(Map<String, dynamic> item) {
    final direct = item['lat'];
    if (direct is num) {
      return direct.toDouble();
    }
    final center = item['center'];
    if (center is Map<String, dynamic> && center['lat'] is num) {
      return (center['lat'] as num).toDouble();
    }
    return null;
  }

  double? _readLon(Map<String, dynamic> item) {
    final direct = item['lon'];
    if (direct is num) {
      return direct.toDouble();
    }
    final center = item['center'];
    if (center is Map<String, dynamic> && center['lon'] is num) {
      return (center['lon'] as num).toDouble();
    }
    return null;
  }
}
