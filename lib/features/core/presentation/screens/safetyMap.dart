import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:safe_campus/features/core/presentation/screens/components/contact_form_bottom_sheet.dart';
import 'package:safe_campus/features/core/presentation/screens/components/contact_list.dart';
import 'package:uuid/uuid.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:safe_campus/features/core/presentation/screens/HomePage.dart';

// Enum for tracking states
enum TrackingState { stopped, paused, active }

class SafetyMap extends StatefulWidget {
  final VoidCallback onReportIncident;
  final VoidCallback onShareRoute;
  final VoidCallback onUserCurrentLocation;
  final List<Map<String, String>> contacts;
  final Function(List<Map<String, String>>) onContactsUpdated;

  const SafetyMap({
    super.key,
    required this.onReportIncident,
    required this.onShareRoute,
    required this.onUserCurrentLocation,
    required this.contacts,
    required this.onContactsUpdated,
  });

  @override
  State<SafetyMap> createState() => SafetyMapState();
}

class SafetyMapState extends State<SafetyMap> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _currentLocation;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = "Location service is disabled.";
          _isLoading = false;
        });
        return;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _errorMessage = "Location permission denied.";
          _isLoading = false;
        });
        return;
      }
    }

    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error getting location: $e";
        _isLoading = false;
      });
    }
  }

  void userCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to get current location")),
      );
    }
  }

  void shareRoute() {
    if (_currentLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Route sharing started")),
      );
      widget.onShareRoute();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to share route: Current location not available")),
      );
    }
  }

  void reportIncident() {
    if (_currentLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incident reporting started")),
      );
      widget.onReportIncident();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to report incident: Current location not available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: GoogleFonts.poppins(),
          textAlign: TextAlign.center,
        ),
      );
    }

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
          top: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'location',
                onPressed: userCurrentLocation,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}