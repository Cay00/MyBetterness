import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = true;
  List<Marker> _pharmacyMarkers = [];

  @override
  void initState() {
    super.initState();
    _fetchPharmacies();
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
            options: const MapOptions(
              initialCenter: LatLng(51.11, 17.03),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: _pharmacyMarkers),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _fetchPharmacies() async {
    const query =
        '[out:json];node["amenity"="pharmacy"](51.05,16.90,51.15,17.15);out body;';
    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final elements = data['elements'] as List<dynamic>? ?? [];
        final markers = elements
            .whereType<Map<String, dynamic>>()
            .where((e) => e['lat'] != null && e['lon'] != null)
            .map(
              (e) => Marker(
                point: LatLng(
                  (e['lat'] as num).toDouble(),
                  (e['lon'] as num).toDouble(),
                ),
                width: 30,
                height: 30,
                child: const Icon(
                  Icons.local_pharmacy,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            )
            .toList();

        if (!mounted) {
          return;
        }

        setState(() {
          _pharmacyMarkers = markers;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
