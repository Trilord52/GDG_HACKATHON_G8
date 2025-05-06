import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/login_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/login_event.dart';

class SecurityDashboard extends StatefulWidget {
  const SecurityDashboard({super.key});

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  final MapController _mapController = MapController();
  final List<LatLng> _activeIncidents = [];
  final List<LatLng> _patrolRoute = [];
  bool _isPatrolling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshIncidents,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<LoginBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(
                  8.885324392473517,
                  38.80978558253636,
                ),
                initialZoom: 13.0,
                onTap: _handleMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers:
                      _activeIncidents
                          .map(
                            (location) => Marker(
                              point: location,
                              child: const Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          )
                          .toList(),
                ),
                if (_isPatrolling)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _patrolRoute,
                        color: Colors.blue,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _togglePatrol,
                      icon: Icon(
                        _isPatrolling ? Icons.stop : Icons.directions_run,
                      ),
                      label: Text(
                        _isPatrolling ? 'Stop Patrol' : 'Start Patrol',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isPatrolling ? Colors.red : Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _acknowledgeIncident,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Acknowledge'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Active Incidents: ${_activeIncidents.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_isPatrolling) {
      setState(() {
        _patrolRoute.add(point);
      });
    }
  }

  void _togglePatrol() {
    setState(() {
      _isPatrolling = !_isPatrolling;
      if (!_isPatrolling) {
        _patrolRoute.clear();
      }
    });
  }

  void _acknowledgeIncident() {
    if (_activeIncidents.isNotEmpty) {
      setState(() {
        _activeIncidents.removeAt(0);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incident acknowledged')));
    }
  }

  void _refreshIncidents() {
    // TODO: Implement API call to refresh incidents
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Refreshing incidents...')));
  }
}
