import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RiskZone {
  final String id;
  final LatLng location;
  final String description;
  final String severity;
  final String type;
  final String source;
  final DateTime createdAt;

  RiskZone({
    required this.id,
    required this.location,
    required this.description,
    required this.severity,
    required this.type,
    required this.source,
    required this.createdAt,
  });
}

class RiskZoneManagement extends StatefulWidget {
  const RiskZoneManagement({super.key});

  @override
  State<RiskZoneManagement> createState() => _RiskZoneManagementState();
}

class _RiskZoneManagementState extends State<RiskZoneManagement> {
  final MapController _mapController = MapController();
  final List<RiskZone> _riskZones = [];
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedSeverity = 'Low';
  String _selectedType = 'Suspicious Activity';
  LatLng? _selectedLocation;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddRiskZoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Risk Zone',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  labelStyle: GoogleFonts.poppins(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: InputDecoration(
                  labelText: 'Severity',
                  border: OutlineInputBorder(),
                  labelStyle: GoogleFonts.poppins(),
                ),
                items: ['Low', 'Medium', 'High']
                    .map((severity) => DropdownMenuItem(
                          value: severity,
                          child: Text(
                            severity,
                            style: GoogleFonts.poppins(),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeverity = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                  labelStyle: GoogleFonts.poppins(),
                ),
                items: [
                  'Suspicious Activity',
                  'Low Visibility',
                  'Poor Lighting',
                  'Other'
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: GoogleFonts.poppins(),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedLocation != null && _descriptionController.text.isNotEmpty) {
                final newZone = RiskZone(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  location: _selectedLocation!,
                  description: _descriptionController.text,
                  severity: _selectedSeverity,
                  type: _selectedType,
                  source: 'Admin',
                  createdAt: DateTime.now(),
                );
                setState(() {
                  _riskZones.add(newZone);
                });
                _descriptionController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Risk zone added successfully',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please select a location and provide a description',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Add',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(37.7749, -122.4194),
              initialZoom: 15,
              onTap: (_, point) {
                setState(() {
                  _selectedLocation = point;
                });
                _showAddRiskZoneDialog();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.safecampus',
              ),
              MarkerLayer(
                markers: _riskZones
                    .map((zone) => Marker(
                          point: zone.location,
                          width: 30,
                          height: 30,
                          child: Icon(
                            Icons.warning,
                            color: _getSeverityColor(zone.severity),
                            size: 30,
                          ),
                        ))
                    .toList(),
              ),
              CircleLayer(
                circles: _riskZones
                    .map((zone) => CircleMarker(
                          point: zone.location,
                          radius: 100,
                          color: _getSeverityColor(zone.severity).withOpacity(0.2),
                          borderColor: _getSeverityColor(zone.severity).withOpacity(0.5),
                          borderStrokeWidth: 2,
                        ))
                    .toList(),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _mapController.move(
                  LatLng(37.7749, -122.4194),
                  15,
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRiskZoneDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Low':
        return Colors.yellow;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 