import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class IncidentReport {
  final String id;
  final LatLng location;
  final String description;
  final String? mediaPath;
  final String source;
  final DateTime timestamp;

  IncidentReport({
    required this.id,
    required this.location,
    required this.description,
    this.mediaPath,
    required this.source,
    required this.timestamp,
  });
}

class IncidentReports extends StatefulWidget {
  const IncidentReports({super.key});

  @override
  State<IncidentReports> createState() => _IncidentReportsState();
}

class _IncidentReportsState extends State<IncidentReports> {
  final List<IncidentReport> _reports = [];
  String _selectedSource = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredReports = _selectedSource == 'All'
        ? _reports
        : _reports.where((report) => report.source == _selectedSource).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Filter by Source:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedSource,
                  items: ['All', 'User', 'Admin', 'Anonymous']
                      .map((source) => DropdownMenuItem(
                            value: source,
                            child: Text(
                              source,
                              style: GoogleFonts.poppins(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSource = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text(
                      report.description,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${report.source} - ${report.timestamp.toLocal().toString()}',
                      style: GoogleFonts.poppins(),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        _getSourceIcon(report.source),
                        color: Colors.white,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Lat: ${report.location.latitude.toStringAsFixed(6)}, Lng: ${report.location.longitude.toStringAsFixed(6)}',
                              style: GoogleFonts.poppins(),
                            ),
                            const SizedBox(height: 8),
                            if (report.mediaPath != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Media:',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Image.network(
                                    report.mediaPath!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'User':
        return Icons.person;
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Anonymous':
        return Icons.visibility_off;
      default:
        return Icons.report;
    }
  }
} 