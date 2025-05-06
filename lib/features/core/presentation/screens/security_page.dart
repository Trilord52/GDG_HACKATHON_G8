import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _activeIncidents = [];
  List<Map<String, dynamic>> _emergencyAlerts = [];
  String _selectedFilter = 'all';
  bool _isOnDuty = false;

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
        _currentLocation = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });
    }
  }

  void _toggleDutyStatus() {
    setState(() {
      _isOnDuty = !_isOnDuty;
    });
    if (_isOnDuty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You are now on duty')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You are now off duty')));
    }
  }

  void _acknowledgeIncident(int index) {
    setState(() {
      _activeIncidents[index]['status'] = 'acknowledged';
    });
  }

  void _resolveIncident(int index) {
    setState(() {
      _activeIncidents[index]['status'] = 'resolved';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Dashboard', style: GoogleFonts.poppins()),
        actions: [
          Switch(
            value: _isOnDuty,
            onChanged: (value) => _toggleDutyStatus(),
            activeColor: Colors.green,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(value: 'all', child: Text('All Incidents')),
                  PopupMenuItem(
                    value: 'emergency',
                    child: Text('Emergency Alerts'),
                  ),
                  PopupMenuItem(
                    value: 'active',
                    child: Text('Active Incidents'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _currentLocation ??
                    LatLng(8.885324392473517, 38.80978558253636),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safe_campus',
                ),
                MarkerLayer(
                  markers:
                      _activeIncidents
                          .where((incident) {
                            if (_selectedFilter == 'all') return true;
                            if (_selectedFilter == 'emergency') {
                              return incident['type'] == 'emergency';
                            }
                            return incident['status'] == 'active';
                          })
                          .map((incident) {
                            final location = incident['location'] as LatLng;
                            Color markerColor;
                            if (incident['type'] == 'emergency') {
                              markerColor = Colors.red;
                            } else if (incident['status'] == 'acknowledged') {
                              markerColor = Colors.orange;
                            } else {
                              markerColor = Colors.yellow;
                            }
                            return Marker(
                              point: location,
                              child: Icon(
                                Icons.warning,
                                color: markerColor,
                                size: 30,
                              ),
                            );
                          })
                          .toList(),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Incidents',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _activeIncidents.length,
                    itemBuilder: (context, index) {
                      final incident = _activeIncidents[index];
                      return ListTile(
                        leading: Icon(
                          Icons.warning,
                          color:
                              incident['type'] == 'emergency'
                                  ? Colors.red
                                  : incident['status'] == 'acknowledged'
                                  ? Colors.orange
                                  : Colors.yellow,
                        ),
                        title: Text(incident['title']),
                        subtitle: Text(incident['description']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (incident['status'] == 'active')
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () => _acknowledgeIncident(index),
                              ),
                            if (incident['status'] == 'acknowledged')
                              IconButton(
                                icon: Icon(Icons.done_all, color: Colors.blue),
                                onPressed: () => _resolveIncident(index),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) {
            setState(() {
              _activeIncidents.add({
                'title': 'New Incident',
                'description': 'Description of the incident',
                'location': _currentLocation,
                'type': 'general',
                'status': 'active',
                'timestamp': DateTime.now(),
              });
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
