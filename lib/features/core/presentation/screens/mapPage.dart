import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_campus/features/core/presentation/screens/HomePage.dart';
import 'package:safe_campus/features/core/presentation/screens/liveTracker.dart';
import 'package:safe_campus/features/core/presentation/screens/safetyMap.dart';

class MapPage extends StatefulWidget {
  final List<Map<String, String>> contacts; // Receive contacts from HomePage

  const MapPage({super.key, required this.contacts});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _safetyMapKey = GlobalKey<SafetyMapState>();
  final _liveTrackerKey = GlobalKey<LiveTrackerState>(); // Key for LiveTracker

  void _onUserCurrentLocation() {
    // Switch to LiveTracker tab (index 0) and ensure location is updated
    DefaultTabController.of(context).animateTo(0);
    // Since LiveTracker doesn't have a map, we just ensure the location is updated
    if (_liveTrackerKey.currentState?.getCurrentLocation() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to get current location")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Updated to 3 tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Map",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: "Live Location"),
              Tab(text: "Safety Map"),
              Tab(text: "Alerts"),
            ],
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.report),
                onPressed: () {
                  DefaultTabController.of(context).index = 1; // Switch to SafetyMap tab (index 1)
                  _safetyMapKey.currentState?.reportIncident();
                },
                tooltip: "Report Incident",
              ),
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  DefaultTabController.of(context).index = 1; // Switch to SafetyMap tab (index 1)
                  _safetyMapKey.currentState?.shareRoute();
                },
                tooltip: "Share Route",
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            LiveTracker(key: _liveTrackerKey), // Use the key for LiveTracker
            SafetyMap(
              key: _safetyMapKey,
              onReportIncident: () => _safetyMapKey.currentState?.reportIncident(),
              onShareRoute: () => _safetyMapKey.currentState?.shareRoute(),
              onUserCurrentLocation: () => _safetyMapKey.currentState?.userCurrentLocation(),
              contacts: widget.contacts, // Pass contacts to SafetyMap
            ),
            Container(), // Placeholder for Alerts tab
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            elevation: 0,
            onPressed: _onUserCurrentLocation,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}