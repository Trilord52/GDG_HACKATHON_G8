import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _riskZones = [];
  List<Map<String, dynamic>> _incidentReports = [];
  String _selectedFilter = 'all';
  bool _showAddZoneForm = false;
  final TextEditingController _zoneNameController = TextEditingController();
  final TextEditingController _zoneDescriptionController = TextEditingController();
  String _selectedSeverity = 'low';
  String _selectedType = 'general';

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

  void _showAddZoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Risk Zone', style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _zoneNameController,
                decoration: InputDecoration(
                  labelText: 'Zone Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _zoneDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: InputDecoration(
                  labelText: 'Severity',
                  border: OutlineInputBorder(),
                ),
                items: ['low', 'medium', 'high'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSeverity = newValue!;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['general', 'crime', 'accident', 'construction'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_zoneNameController.text.isNotEmpty && _currentLocation != null) {
                setState(() {
                  _riskZones.add({
                    'name': _zoneNameController.text,
                    'description': _zoneDescriptionController.text,
                    'location': _currentLocation,
                    'severity': _selectedSeverity,
                    'type': _selectedType,
                    'timestamp': DateTime.now(),
                  });
                });
                _zoneNameController.clear();
                _zoneDescriptionController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Add Zone'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddZoneDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'all',
                child: Text('All Zones'),
              ),
              PopupMenuItem(
                value: 'high',
                child: Text('High Severity'),
              ),
              PopupMenuItem(
                value: 'medium',
                child: Text('Medium Severity'),
              ),
              PopupMenuItem(
                value: 'low',
                child: Text('Low Severity'),
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
                initialCenter: _currentLocation ?? LatLng(0, 0),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safe_campus',
                ),
                MarkerLayer(
                  markers: _riskZones.where((zone) {
                    if (_selectedFilter == 'all') return true;
                    return zone['severity'] == _selectedFilter;
                  }).map((zone) {
                    final location = zone['location'] as LatLng;
                    Color markerColor;
                    switch (zone['severity']) {
                      case 'high':
                        markerColor = Colors.red;
                        break;
                      case 'medium':
                        markerColor = Colors.orange;
                        break;
                      default:
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
                  }).toList(),
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
                  'Risk Zones',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _riskZones.length,
                    itemBuilder: (context, index) {
                      final zone = _riskZones[index];
                      return ListTile(
                        leading: Icon(
                          Icons.warning,
                          color: zone['severity'] == 'high'
                              ? Colors.red
                              : zone['severity'] == 'medium'
                                  ? Colors.orange
                                  : Colors.yellow,
                        ),
                        title: Text(zone['name']),
                        subtitle: Text(zone['description']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _riskZones.removeAt(index);
                            });
                          },
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
    );
  }

  @override
  void dispose() {
    _zoneNameController.dispose();
    _zoneDescriptionController.dispose();
    super.dispose();
  }
} 