import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LiveTracker extends StatefulWidget {
  const LiveTracker({Key? key}) : super(key: key);

  @override
  State<LiveTracker> createState() => LiveTrackerState();
}

class LiveTrackerState extends State<LiveTracker> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _currentLocation;
  bool _isTracking = false;
  Timer? _trackingTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
    }
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
    });

    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        });
      }
    });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });
    _trackingTimer?.cancel();
  }

  LatLng? getCurrentLocation() {
    return _currentLocation;
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? LatLng(0, 0),
            initialZoom: 15,
            onTap: (_, __) => _mapController.move(_currentLocation!, 15),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.safe_campus',
            ),
            if (_currentLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: _isTracking ? _stopTracking : _startTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTracking ? Colors.red : Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                const SizedBox(width: 8),
                Text(
                  _isTracking ? "Stop Tracking" : "Start Tracking",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}