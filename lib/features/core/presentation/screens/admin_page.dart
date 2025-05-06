import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/login_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/login_event.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _riskZones = [
    {
      'name': 'Risk Zone 1',
      'description': 'Description of Risk Zone 1',
      'location': LatLng(8.885324392473517, 38.80978558253636),
      'severity': 'high',
      'type': 'crime',
      'timestamp': DateTime.now(),
    },
    {
      'name': 'Risk Zone 2',
      'description': 'Description of Risk Zone 2',
      'location': LatLng(8.883959103994254, 38.812550110237076),
      'severity': 'medium',
      'type': 'accident',
      'timestamp': DateTime.now(),},
  ];
  List<Map<String, dynamic>> _incidentReports = [];
  String _selectedFilter = 'all';
  final TextEditingController _zoneNameController = TextEditingController();
  final TextEditingController _zoneDescriptionController =
      TextEditingController();
  String _selectedSeverity = 'low';
  String _selectedType = 'general';
  Map<String, dynamic>? _selectedZone;
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
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

  void _showAddZoneDialog() {
    final dialogMapController = MapController();
    LatLng? selectedLocation;
    String severity = _selectedSeverity;
    String type = _selectedType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Risk Zone', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        mapController: dialogMapController,
                        options: MapOptions(
                          initialCenter:
                              _currentLocation ??
                              LatLng(
                                8.885324392473517,
                                38.80978558253636,
                              ),
                          initialZoom: 15,
                          onTap: (tapPosition, point) {
                            setDialogState(() {
                              selectedLocation = point;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.safe_campus',
                          ),
                          if (selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedLocation!,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap on the map to select location',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (selectedLocation != null) ...[
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Latitude',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                          text: selectedLocation!.latitude.toString(),
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Latitude copied to clipboard'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        selectedLocation!.latitude.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Longitude',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                          text: selectedLocation!.longitude.toString(),
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Longitude copied to clipboard'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        selectedLocation!.longitude.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 10),
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
                    value: severity,
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
                      setDialogState(() {
                        severity = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'general',
                      'crime',
                      'accident',
                      'construction',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        type = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _zoneNameController.clear();
                _zoneDescriptionController.clear();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_zoneNameController.text.isNotEmpty &&
                    selectedLocation != null) {
                  setState(() {
                    _riskZones.add({
                      'name': _zoneNameController.text,
                      'description': _zoneDescriptionController.text,
                      'location': selectedLocation,
                      'severity': severity,
                      'type': type,
                      'timestamp': DateTime.now(),
                    });
                  });
                  _zoneNameController.clear();
                  _zoneDescriptionController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please select a location and enter a zone name',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add Zone'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddZoneDialog),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(value: 'all', child: Text('All Zones')),
                  PopupMenuItem(value: 'high', child: Text('High Severity')),
                  PopupMenuItem(
                    value: 'medium',
                    child: Text('Medium Severity'),
                  ),
                  PopupMenuItem(value: 'low', child: Text('Low Severity')),
                ],
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<LoginBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentLocation ??
                        LatLng(8.885324392473517, 38.80978558253636),
                    initialZoom: 15,
                    onTap: (_, __) {
                      setState(() {
                        _selectedZone = null;
                      });
                    },
                    onMapReady: () {
                      _mapController.mapEventStream.listen((event) {
                        if (event is MapEventMoveEnd) {
                          setState(() {
                            _currentZoom = event.camera.zoom;
                          });
                        }
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.safe_campus',
                    ),
                    CircleLayer(
                      circles:
                          _riskZones
                              .where((zone) {
                                if (_selectedFilter == 'all') return true;
                                return zone['severity'] == _selectedFilter;
                              })
                              .map((zone) {
                                final location = zone['location'] as LatLng;
                                Color circleColor;
                                switch (zone['severity']) {
                                  case 'high':
                                    circleColor = Colors.red;
                                    break;
                                  case 'medium':
                                    circleColor = Colors.orange;
                                    break;
                                  default:
                                    circleColor = Colors.yellow;
                                }

                                // Calculate radius based on zoom level
                                // Base radius is 50 meters, adjust based on zoom
                                final baseRadius = 100;
                                final zoomFactor =
                                    _currentZoom /
                                    15.0; // Normalize to base zoom
                                final adjustedRadius = baseRadius / zoomFactor;

                                return CircleMarker(
                                  point: location,
                                  radius: adjustedRadius,
                                  color: circleColor.withOpacity(0.05),
                                  borderColor: circleColor.withOpacity(0.2),
                                  borderStrokeWidth: 1,
                                  useRadiusInMeter: true,
                                );
                              })
                              .toList(),
                    ),
                    // Add a second circle layer for the blur effect
                    CircleLayer(
                      circles:
                          _riskZones
                              .where((zone) {
                                if (_selectedFilter == 'all') return true;
                                return zone['severity'] == _selectedFilter;
                              })
                              .map((zone) {
                                final location = zone['location'] as LatLng;
                                Color circleColor;
                                switch (zone['severity']) {
                                  case 'high':
                                    circleColor = Colors.red;
                                    break;
                                  case 'medium':
                                    circleColor = Colors.orange;
                                    break;
                                  default:
                                    circleColor = Colors.yellow;
                                }

                                // Calculate radius based on zoom level
                                final baseRadius = 50.0;
                                final zoomFactor = _currentZoom / 15.0;
                                final adjustedRadius = baseRadius / zoomFactor;

                                return CircleMarker(
                                  point: location,
                                  radius:
                                      adjustedRadius *
                                      1.2, // Slightly larger for blur effect
                                  color: circleColor.withOpacity(0.1),
                                  borderColor: circleColor.withOpacity(0.2),
                                  borderStrokeWidth: 0.5,
                                  useRadiusInMeter: true,
                                );
                              })
                              .toList(),
                    ),
                    MarkerLayer(
                      markers:
                          _riskZones
                              .where((zone) {
                                if (_selectedFilter == 'all') return true;
                                return zone['severity'] == _selectedFilter;
                              })
                              .map((zone) {
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

                                IconData markerIcon;
                                switch (zone['type']) {
                                  case 'crime':
                                    markerIcon = Icons.security;
                                    break;
                                  case 'accident':
                                    markerIcon = Icons.car_crash;
                                    break;
                                  case 'construction':
                                    markerIcon = Icons.construction;
                                    break;
                                  default:
                                    markerIcon = Icons.warning;
                                }

                                return Marker(
                                  point: location,
                                  width: 40,
                                  height: 60,
                                  rotate: true,
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedZone = zone;
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        // Map pin
                                        Positioned(
                                          left: -8,
                                          child: Icon(
                                            shadows: [
                                              Shadow(
                                                color: const Color.fromARGB(
                                                  136,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                                offset: Offset(3, 3),
                                                blurRadius: 10,
                                              ),
                                            ],
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 53,
                                          ),
                                        ),
                                        Positioned(
                                          left: -8,
                                          child: Icon(
                                            Icons.location_on,
                                            color: markerColor,
                                            size: 50,
                                          ),
                                        ),
                                        // Type icon
                                        Positioned(
                                          top: 8,
                                          left: 7,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              markerIcon,
                                              color: markerColor,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                    ),
                  ],
                ),
              ),
              if (_selectedZone != null)
                Container(
                  constraints: BoxConstraints(
                    minHeight: 140,
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 4,
                          width: 40,
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _selectedZone!['type'] == 'crime'
                                        ? Icons.security
                                        : _selectedZone!['type'] == 'accident'
                                        ? Icons.car_crash
                                        : _selectedZone!['type'] == 'construction'
                                        ? Icons.construction
                                        : Icons.warning,
                                    color: _selectedZone!['severity'] == 'high'
                                        ? Colors.red
                                        : _selectedZone!['severity'] == 'medium'
                                        ? Colors.orange
                                        : Colors.yellow,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedZone!['name'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedZone = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _selectedZone!['description'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedZone!['severity'] == 'high'
                                          ? Colors.red.withOpacity(0.1)
                                          : _selectedZone!['severity'] == 'medium'
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.yellow.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _selectedZone!['severity'].toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedZone!['severity'] == 'high'
                                            ? Colors.red
                                            : _selectedZone!['severity'] == 'medium'
                                            ? Colors.orange
                                            : Colors.yellow,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _selectedZone!['type'].toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Reported ${_formatTimestamp(_selectedZone!['timestamp'].toString())}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                height: 200,
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
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
                              zone['type'] == 'crime'
                                  ? Icons.security
                                  : zone['type'] == 'accident'
                                  ? Icons.car_crash
                                  : zone['type'] == 'construction'
                                  ? Icons.construction
                                  : Icons.warning,
                              color:
                                  zone['severity'] == 'high'
                                      ? Colors.red
                                      : zone['severity'] == 'medium'
                                      ? Colors.orange
                                      : Colors.yellow,
                            ),
                            title: Text(
                              zone['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              zone['description'],
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _riskZones.removeAt(index);
                                  if (_selectedZone == zone) {
                                    _selectedZone = null;
                                  }
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
          Positioned(
            right: 16,
            bottom: 200, // Position above the risk zones list
            child: FloatingActionButton(
              onPressed: () {
                if (_currentLocation != null) {
                  _mapController.move(_currentLocation!, _currentZoom);
                }
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
              elevation: 4,
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
