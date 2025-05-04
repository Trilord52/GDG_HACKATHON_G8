import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:safe_campus/features/core/presentation/screens/safetyMap.dart';

class LiveTracker extends StatefulWidget {
  const LiveTracker({super.key});

  @override
  State<LiveTracker> createState() => LiveTrackerState();
}

class LiveTrackerState extends State<LiveTracker> with AutomaticKeepAliveClientMixin {
  final Location _location = Location();
  final uuid = Uuid();
  LocationData? _currentLocation;
  bool _isLoading = true;
  String? _shareToken;
  bool _isActive = false;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _generalLocation; // To store the reverse-geocoded location
  String? _errorMessage; // To store error messages for display

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if this tab is active (LiveTracker is at index 0 in map_page.dart)
    final newIsActive = DefaultTabController.of(context).index == 0;
    if (_isActive != newIsActive) {
      setState(() {
        _isActive = newIsActive;
      });
      if (_isActive) {
        _startLocationUpdates();
      } else {
        _stopLocationUpdates();
      }
    }
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check and request location service
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Location service is disabled.";
        });
        return;
      }
    }

    // Check and request location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Location permission denied.";
        });
        return;
      }
    }

    // Start listening for location updates immediately
    _startLocationUpdates();

    // Fetch initial location
    try {
      LocationData? initialLocation = await _location.getLocation().timeout(Duration(seconds: 10));
      if (initialLocation.latitude != null && initialLocation.longitude != null) {
        setState(() {
          _currentLocation = initialLocation;
          _isLoading = false;
          _errorMessage = null;
        });
        _fetchGeneralLocation(initialLocation.latitude!, initialLocation.longitude!);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to get initial location.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error getting initial location: $e";
      });
    }
  }

  void _startLocationUpdates() {
    if (_locationSubscription != null) return; // Already listening
    _locationSubscription = _location.onLocationChanged.listen((LocationData locationData) {
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          _currentLocation = locationData;
          _isLoading = false;
          _errorMessage = null;
        });
        // Fetch general location for the new coordinates
        if (locationData.latitude != null && locationData.longitude != null) {
          _fetchGeneralLocation(locationData.latitude!, locationData.longitude!);
        }
      }
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _fetchGeneralLocation(double latitude, double longitude) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String displayName = data['display_name'] ?? 'Unknown location';
        // Extract a more concise location (e.g., city or area)
        List<String> addressParts = displayName.split(', ');
        String generalLocation = addressParts.length > 2
            ? "${addressParts[0]}, ${addressParts[addressParts.length - 2]}" // e.g., "San Francisco, California"
            : displayName;
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            _generalLocation = generalLocation;
          });
        }
      } else {
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            _generalLocation = "Unable to fetch location name";
          });
        }
      }
    } catch (e) {
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          _generalLocation = "Error fetching location name: $e";
        });
      }
    }
  }

  void _shareRoute() {
    if (_currentLocation == null) {
      _showSnackBar("Unable to share location: Current location not available");
      return;
    }

    setState(() {
      _shareToken = uuid.v4();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Share Your Location"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Share this token with a friend to track your walk in real-time:"),
            const SizedBox(height: 8),
            SelectableText(
              _shareToken ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Your current location will be shared in real-time."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );

    // Simulate sending token to backend for real-time tracking
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Method to allow external widgets (e.g., map_page.dart) to request the current location
  LocationData? getCurrentLocation() {
    return _currentLocation;
  }

  @override
  void dispose() {
    _stopLocationUpdates(); // Ensure subscription is canceled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Tracker",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_currentLocation == null)
            Center(
              child: Column(
                children: [
                  const Text(
                    "Unable to get current location",
                    style: TextStyle(fontSize: 16),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            )
          else ...[
            const Text(
              "Current Location:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Latitude: ${_currentLocation!.latitude}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Longitude: ${_currentLocation!.longitude}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (_generalLocation != null)
              Text(
                "Location: $_generalLocation",
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              )
            else
              const Text(
                "Fetching location name...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            if (_shareToken != null) ...[
              Text(
                "Shared Token: $_shareToken",
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _shareRoute,
              icon: const Icon(Icons.share),
              label: const Text("Share My Walk"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}