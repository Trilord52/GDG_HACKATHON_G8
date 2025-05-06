
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_campus/features/core/presentation/screens/HomePage.dart';

import 'package:safe_campus/features/core/presentation/screens/liveTracker.dart';
import 'package:safe_campus/features/core/presentation/screens/safetyMap.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _safetyMapKey = GlobalKey<SafetyMapState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            labelColor: Colors.white, // Set the text color for the selected tab
            unselectedLabelColor: Colors.white70, // Optional: Set the text color for unselected tabs
            tabs: const [
              Tab(text: "Safety Map"),
              Tab(text: "Live Tracker"),
            ],
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.report),
                onPressed: () {
                  DefaultTabController.of(context).index = 0; // Switch to SafetyMap tab (now index 0)
                  _safetyMapKey.currentState?.reportIncident();
                },
                tooltip: "Report Incident",
              ),
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  DefaultTabController.of(context).index = 0; // Switch to SafetyMap tab (now index 0)
                  _safetyMapKey.currentState?.shareRoute();
                },
                tooltip: "Share Route",
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            SafetyMap(
              key: _safetyMapKey,
              onReportIncident: () => _safetyMapKey.currentState?.reportIncident(),
              onShareRoute: () => _safetyMapKey.currentState?.shareRoute(),
              onUserCurrentLocation: () => _safetyMapKey.currentState?.userCurrentLocation(),
            ),
            const LiveTracker(),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            elevation: 0,
            onPressed: () {
              DefaultTabController.of(context).index = 0; // Switch to SafetyMap tab (now index 0)
              _safetyMapKey.currentState?.userCurrentLocation();
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
