import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyMap extends StatefulWidget {
  final VoidCallback onReportIncident;
  final VoidCallback onShareRoute;
  final VoidCallback onUserCurrentLocation;

  const SafetyMap({
    super.key,
    required this.onReportIncident,
    required this.onShareRoute,
    required this.onUserCurrentLocation,
  });

  @override
  State<SafetyMap> createState() => SafetyMapState();
}

class SafetyMapState extends State<SafetyMap> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _incidentDescriptionController = TextEditingController();
  bool isLoading = true;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  List<Map<String, dynamic>> _incidentReports = [
    {'location': LatLng(8.885324392473517, 38.80978558253636), 'description': 'Low visibility area', 'type': 'general', 'severity': 'medium'},
    {'location': LatLng(8.887, 38.81), 'description': 'Construction work', 'type': 'general', 'severity': 'low'},
  ];
  String? _shareToken;
  final uuid = Uuid();
  XFile? _selectedMedia;
  bool _isActive = false;
  StreamSubscription<LocationData>? _locationSubscription;
  Map<String, dynamic>? _selectedIncident;
  double _currentZoom = 15.0;
  String? _destinationName;
  Timer? _destinationNameTimer;
  double? _destinationDistance;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _checkForNearbyIncidents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newIsActive = DefaultTabController.of(context).index == 0; // SafetyMap is at index 0
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
    if (!await _checkTheRequestPermission()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (_isActive) {
      _startLocationUpdates();
    }
  }

  void _startLocationUpdates() {
    if (_locationSubscription != null) return; // Already listening
    _locationSubscription = _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          isLoading = false;
        });
        _checkForNearbyIncidents();
      }
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void _toggleTracking() {
    setState(() {
      _isActive = !_isActive;
    });
    if (_isActive) {
      _startLocationUpdates();
    } else {
      _stopLocationUpdates();
    }
  }

  Future<void> fetchCoordinatesPoint(String location) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&addressdetails=1&limit=1");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        await fetchRoute();
      } else {
        errorMessage("Location not found");
      }
    } else {
      errorMessage("Error fetching coordinates");
    }
  }

  Future<void> fetchRoute() async {
    if (_currentLocation == null || _destination == null) {
      errorMessage("Current location or destination not available");
      return;
    }
    final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      errorMessage("Error fetching route");
    }
  }

  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);
    setState(() {
      _route = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
    });
  }

  Future<bool> _checkTheRequestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  void userCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      errorMessage("Unable to get current location");
    }
  }

  void errorMessage(String message) {
    Fluttertoast.showToast  (
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void shareRoute() {
    if (_route.isNotEmpty && _currentLocation != null) {
      setState(() {
        _shareToken = uuid.v4();
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Share Route"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Share this token with a friend to track your route:"),
              SizedBox(height: 8),
              SelectableText(_shareToken ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Your current location and route will be shared in real-time."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        ),
      );
    } else {
      errorMessage("No route to share");
    }
  }

  void reportIncident() async {
    final picker = ImagePicker();
    String selectedType = 'general';
    String selectedSeverity = 'medium';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Report Incident", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                TextField(
                  controller: _incidentDescriptionController,
                  decoration: InputDecoration(
                    labelText: "Describe the incident",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: "Incident Type",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'crime', child: Text('Crime')),
                    DropdownMenuItem(value: 'accident', child: Text('Accident')),
                    DropdownMenuItem(value: 'construction', child: Text('Construction')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSeverity,
                  decoration: InputDecoration(
                    labelText: "Severity",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSeverity = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickedFile = await picker.pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setState(() {
                            _selectedMedia = pickedFile;
                          });
                        }
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text("Photo"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickedFile = await picker.pickVideo(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setState(() {
                            _selectedMedia = pickedFile;
                          });
                        }
                      },
                      icon: Icon(Icons.videocam),
                      label: Text("Video"),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (_selectedMedia != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "Media selected: ${_selectedMedia!.name}",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_incidentDescriptionController.text.isNotEmpty && _currentLocation != null) {
                      setState(() {
                        _incidentReports.add({
                          'location': _currentLocation,
                          'description': _incidentDescriptionController.text,
                          'type': selectedType,
                          'severity': selectedSeverity,
                          'media': _selectedMedia?.path,
                        });
                      });
                      _incidentDescriptionController.clear();
                      setState(() {
                        _selectedMedia = null;
                      });
                      Navigator.pop(context);
                      errorMessage("Incident reported anonymously");
                      _checkForNearbyIncidents();
                    } else {
                      errorMessage("Please provide a description and ensure location is available");
                    }
                  },
                  child: Text("Submit Report"),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkForNearbyIncidents() {
    if (_currentLocation == null) return;
    const double alertRadius = 0.5; // 500 meters
    final distance = Distance();
    for (var incident in _incidentReports) {
      final incidentLocation = incident['location'] as LatLng?;
      if (incidentLocation == null) continue;
      final distanceKm = distance(_currentLocation!, incidentLocation) / 1000;
      if (distanceKm <= alertRadius) {
        Fluttertoast.showToast(
          msg: "Warning: ${incident['description']} nearby!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _updateDestinationName(LatLng location) async {
    // Cancel any existing timer
    _destinationNameTimer?.cancel();

    // Set a new timer to debounce the API calls
    _destinationNameTimer = Timer(const Duration(seconds: 1), () async {
      try {
        final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1'
        ));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'];
          
          // Build location description using specific fields
          List<String> locationParts = [];
          
          if (address['amenity'] != null) {
            locationParts.add(address['amenity']);
          }
          if (address['village'] != null) {
            locationParts.add(address['village']);
          }
          if (address['county'] != null) {
            locationParts.add(address['county']);
          }
          if (address['state_district'] != null) {
            // Extract just the English name if available
            String stateDistrict = address['state_district'];
            if (stateDistrict.contains('Addis Ababa')) {
              stateDistrict = 'Addis Ababa';
            }
            locationParts.add(stateDistrict);
          }

          // Combine the parts into a readable string
          String locationName = locationParts.join(', ');
          
          if (mounted) {
            setState(() {
              _destinationName = locationName.isNotEmpty ? locationName : 'Unknown Location';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _destinationName = 'Location name unavailable';
          });
        }
      }
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double lat1 = point1.latitude * math.pi / 180;
    double lon1 = point1.longitude * math.pi / 180;
    double lat2 = point2.latitude * math.pi / 180;
    double lon2 = point2.longitude * math.pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  String _calculateWalkingTime(double distance) {
    const double averageWalkingSpeed = 5.0; // km/h
    double hours = distance / averageWalkingSpeed;
    int minutes = (hours * 60).round();
    
    if (minutes < 1) {
      return "Less than a minute";
    } else if (minutes < 60) {
      return "$minutes minutes";
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return "$hours hour${hours > 1 ? 's' : ''}";
      } else {
        return "$hours hour${hours > 1 ? 's' : ''} $remainingMinutes minutes";
      }
    }
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _locationController.dispose();
    _incidentDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : _currentLocation == null
            ? const Center(child: Text('Unable to get current location'))
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation!,
                      initialZoom: 15,
                      minZoom: 0,
                      maxZoom: 18,
                      onTap: (_, point) {
                        setState(() {
                          _selectedIncident = null;
                          _destination = point;
                          _updateDestinationName(point);
                          if (_currentLocation != null) {
                            _destinationDistance = _calculateDistance(_currentLocation!, point);
                          }
                          fetchRoute();
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
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.safecampus',
                      ),
                      CurrentLocationLayer(
                        style: LocationMarkerStyle(
                          marker: DefaultLocationMarker(
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          markerSize: Size(40, 40),
                          markerDirection: MarkerDirection.heading,
                        ),
                      ),
                      if (_destination != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _destination!,
                              width: 40,
                              height: 40,
                              rotate: false,
                              child: Icon(
                                Icons.place,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      CircleLayer(
                        circles: _incidentReports.map((incident) {
                          final location = incident['location'] as LatLng;
                          Color circleColor;
                          switch (incident['severity']) {
                            case 'high':
                              circleColor = Colors.red;
                              break;
                            case 'medium':
                              circleColor = Colors.orange;
                              break;
                            default:
                              circleColor = Colors.yellow;
                          }

                          final baseRadius = 100;
                          final zoomFactor = _currentZoom / 15.0;
                          final adjustedRadius = baseRadius / zoomFactor;

                          return CircleMarker(
                            point: location,
                            radius: adjustedRadius,
                            color: circleColor.withOpacity(0.05),
                            borderColor: circleColor.withOpacity(0.2),
                            borderStrokeWidth: 1,
                            useRadiusInMeter: true,
                          );
                        }).toList(),
                      ),
                      CircleLayer(
                        circles: _incidentReports.map((incident) {
                          final location = incident['location'] as LatLng;
                          Color circleColor;
                          switch (incident['severity']) {
                            case 'high':
                              circleColor = Colors.red;
                              break;
                            case 'medium':
                              circleColor = Colors.orange;
                              break;
                            default:
                              circleColor = Colors.yellow;
                          }

                          final baseRadius = 50.0;
                          final zoomFactor = _currentZoom / 15.0;
                          final adjustedRadius = baseRadius / zoomFactor;

                          return CircleMarker(
                            point: location,
                            radius: adjustedRadius * 1.2,
                            color: circleColor.withOpacity(0.1),
                            borderColor: circleColor.withOpacity(0.2),
                            borderStrokeWidth: 0.5,
                            useRadiusInMeter: true,
                          );
                        }).toList(),
                      ),
                      MarkerLayer(
                        markers: _incidentReports.map((incident) {
                          final location = incident['location'] as LatLng;
                          Color markerColor;
                          switch (incident['severity']) {
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
                          switch (incident['type']) {
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
                                  _selectedIncident = incident;
                                });
                              },
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: -8,
                                    child: Icon(
                                      shadows: [
                                        Shadow(
                                          color: const Color.fromARGB(136, 0, 0, 0),
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
                        }).toList(),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Search Destination"),
                            content: TextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                hintText: "Enter destination",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  fetchCoordinatesPoint(_locationController.text);
                                  Navigator.pop(context);
                                },
                                child: Text("Search"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(Icons.search),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: _toggleTracking,
                      backgroundColor: _isActive ? Colors.red : Colors.green,
                      label: Text(
                        _isActive ? 'Danger Mode' : 'Safe Mode',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                      ),
                      icon: Icon(
                        _isActive ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_selectedIncident != null)
                    Positioned(
                      bottom: 80,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 140,
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
                        child: Column(
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
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _selectedIncident!['type'] == 'crime'
                                              ? Icons.security
                                              : _selectedIncident!['type'] == 'accident'
                                              ? Icons.car_crash
                                              : _selectedIncident!['type'] == 'construction'
                                              ? Icons.construction
                                              : Icons.warning,
                                          color: _selectedIncident!['severity'] == 'high'
                                              ? Colors.red
                                              : _selectedIncident!['severity'] == 'medium'
                                              ? Colors.orange
                                              : Colors.yellow,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _selectedIncident!['description'],
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
                                              _selectedIncident = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _selectedIncident!['severity'] == 'high'
                                                ? Colors.red.withOpacity(0.1)
                                                : _selectedIncident!['severity'] == 'medium'
                                                ? Colors.orange.withOpacity(0.1)
                                                : Colors.yellow.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _selectedIncident!['severity'].toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _selectedIncident!['severity'] == 'high'
                                                  ? Colors.red
                                                  : _selectedIncident!['severity'] == 'medium'
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
                                            _selectedIncident!['type'].toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_destination != null && _destinationName != null)
                    Positioned(
                      bottom: _selectedIncident != null ? 240 : 80,
                      left: 16,
                      right: 16,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
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
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.place,
                                          color: Colors.blue,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _destinationName!,
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
                                              _destination = null;
                                              _destinationName = null;
                                              _destinationDistance = null;
                                              _route = [];
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    if (_destinationDistance != null)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.directions_walk,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Distance: ${_destinationDistance!.toStringAsFixed(1)} km",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.timer,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Walking time: ${_calculateWalkingTime(_destinationDistance!)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 12),
                                    if (_route.isNotEmpty)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.directions,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Route calculated",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
  }
}