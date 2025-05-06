import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_campus/features/core/presentation/bloc/add_contacts_cubit/contact_cubit.dart';
import 'package:safe_campus/features/core/presentation/bloc/add_contacts_cubit/contact_state.dart';
import 'package:safe_campus/features/core/data/models/contacts_model.dart';
import 'package:safe_campus/features/core/presentation/screens/sos_cubit/sos_cubit.dart';
import 'components/report_incident_bottom_sheet.dart';
import 'components/share_route_bottom_sheet.dart';
import 'components/contact_form_bottom_sheet.dart';
import 'package:safe_campus/features/core/presentation/screens/mapPage.dart';
import 'package:safe_campus/features/core/presentation/screens/components/contact_list.dart';
import 'dart:async';
import 'admin_page.dart';
import 'security_page.dart';
import 'adm_sec_login_page.dart';
import 'dart:developer' as developer;
import 'package:safe_campus/features/core/presentation/bloc/NavigationCubit.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, String>> initialContacts; // Accept initial contacts
  final Function(List<Map<String, String>>)
  onContactsUpdated; // Callback to update contacts

  const HomePage({
    super.key,
    required this.initialContacts,
    required this.onContactsUpdated,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> recentActivities = [];
  List<Map<String, String>> contacts = [
    {
      'name': 'John Doe',
      'phone': '+251 912 345 678',
      'email': 'john.doe@example.com',
    },
    {
      'name': 'Jane Smith',
      'phone': '+251 911 234 567',
      'email': 'jane.smith@example.com',
    },
  ];
  List<Map<String, String>> incidents = [
    {
      'name': 'Low visibility area',
      'description': 'Poor lighting near the main gate\nType: general\nSeverity: medium',
      'type': 'incident',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)).toString(),
    },
    {
      'name': 'Construction work',
      'description': 'Ongoing construction near Block A\nType: construction\nSeverity: low',
      'type': 'incident',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)).toString(),
    },
  ];
  bool showAllActivities = false;

  Timer? _sosPulseTimer;

  @override
  void initState() {
    super.initState();
    // Initialize recent activities with both incidents and contacts
    recentActivities = [
      ...incidents.map((incident) => {
        'name': incident['name'] ?? '',
        'description': 'Type: ${incident['description']?.split('\n')[0]}\nSeverity: ${incident['description']?.split('\n')[1]}',
        'type': 'incident',
        'timestamp': incident['timestamp'] ?? DateTime.now().toString(),
      }),
      ...contacts.map((contact) => {
        'name': contact['name'] ?? '',
        'description': 'Phone: ${contact['phone']}\nEmail: ${contact['email']}',
        'type': 'contact',
        'timestamp': DateTime.now().toString(),
      }),
    ];
  }

  @override
  void dispose() {
    _sosPulseTimer?.cancel();
    super.dispose();
  }

  void _stopSOSMode() {
    context.read<SosCubit>().offEmergencyMode();
    _sosPulseTimer?.cancel();
  }

  void openReportIncidentSheet() async {
    final picker = ImagePicker();
    String selectedType = 'general';
    String selectedSeverity = 'medium';
    XFile? _selectedMedia;
    TextEditingController descriptionController = TextEditingController();
    
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
                Text(
                  "Report Incident",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Describe the incident",
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: "Incident Type",
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    labelText: "Severity Level",
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await picker.pickImage(source: ImageSource.gallery);
                    if (result != null) {
                      setState(() {
                        _selectedMedia = result;
                      });
                    }
                  },
                  icon: Icon(Icons.attach_file),
                  label: Text("Attach Media"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF65558F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_selectedMedia != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "Media selected: ${_selectedMedia!.name}",
                      style: GoogleFonts.poppins(color: Colors.green),
                    ),
                  ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            incidents.insert(0, {
                              'name': 'Incident Report',
                              'description': '${descriptionController.text}\nType: $selectedType\nSeverity: $selectedSeverity',
                              'type': 'incident',
                              'timestamp': DateTime.now().toString(),
                            });
                            recentActivities.insert(0, {
                              'name': 'Incident Report',
                              'description': '${descriptionController.text}\nType: $selectedType\nSeverity: $selectedSeverity',
                              'type': 'incident',
                              'timestamp': DateTime.now().toString(),
                            });
                          });
                          Fluttertoast.showToast(
                            msg: "Incident reported successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF65558F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          "Submit",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openShareRouteSheet() {
    context.read<NavigationCubit>().updateIndex(1); // Navigate to map page (index 1)
  }

  void openManageContactsSheet() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContactFormBottomSheet(
        onSave: (name, phone, email) {
          Navigator.of(context).pop({
            'name': name,
            'description': 'Phone: $phone\nEmail: $email',
            'type': 'contact',
            'timestamp': DateTime.now().toString(),
          });
        },
      ),
    );

    if (result != null && mounted) {
      setState(() {
        // Add to contacts array
        contacts.add({
          'name': result['name'] ?? '',
          'phone': result['description']?.split('\n')[0].replaceAll('Phone: ', '') ?? '',
          'email': result['description']?.split('\n')[1].replaceAll('Email: ', '') ?? '',
        });
        
        // Add to recent activities
        recentActivities.insert(0, result);
        
        // Notify parent of contact update
        widget.onContactsUpdated(contacts);
      });
    }
  }

  void deleteContact(int index) {
    setState(() {
      List<Map<String, String>> updatedContacts = List.from(
        widget.initialContacts,
      );
      updatedContacts.removeAt(index);
      widget.onContactsUpdated(updatedContacts);
    });
  }

  void openDialogeBox(isEmergencyMode) {
    if (isEmergencyMode) {
      _stopSOSMode();
      return;
    }
  }

  void _showActivityDetails(Map<String, String> activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          activity['name'] ?? '',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity['type'] == 'incident') ...[
              Text(
                'Type: ${activity['description']?.split('\n')[0].replaceAll('Type: ', '') ?? ''}',
                style: GoogleFonts.poppins(),
              ),
              SizedBox(height: 8),
              Text(
                'Severity: ${activity['description']?.split('\n')[1].replaceAll('Severity: ', '') ?? ''}',
                style: GoogleFonts.poppins(),
              ),
            ] else ...[
              Text(
                'Phone: ${activity['description']?.split('\n')[0].replaceAll('Phone: ', '') ?? ''}',
                style: GoogleFonts.poppins(),
              ),
              SizedBox(height: 8),
              Text(
                'Email: ${activity['description']?.split('\n')[1].replaceAll('Email: ', '') ?? ''}',
                style: GoogleFonts.poppins(),
              ),
            ],
            SizedBox(height: 16),
            Text(
              'Reported ${_formatTimestamp(activity['timestamp'] ?? '')}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: Color(0xFF65558F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRoundedIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFF6F2FF), Color(0xFFEDE7F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecentActivities() {
    final activitiesToShow = showAllActivities ? recentActivities : recentActivities.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Activities",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            if (recentActivities.length > 3)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    showAllActivities = !showAllActivities;
                  });
                },
                icon: Icon(
                  showAllActivities ? Icons.expand_less : Icons.expand_more,
                  color: Colors.deepPurple,
                ),
                label: Text(
                  showAllActivities ? "Show Less" : "Show More",
                  style: GoogleFonts.poppins(
                    color: Colors.deepPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentActivities.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "No recent activities",
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            constraints: BoxConstraints(
              maxHeight: showAllActivities ? double.infinity : 300,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activitiesToShow.length,
              itemBuilder: (context, index) {
                final activity = activitiesToShow[index];
                return GestureDetector(
                  onTap: () => _showActivityDetails(activity),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: activity['type'] == 'contact' 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activity['type'] == 'contact' ? Icons.person_add : Icons.warning,
                          color: activity['type'] == 'contact' ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        activity['name'] ?? '',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['description'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatTimestamp(activity['timestamp'] ?? ''),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: activity['type'] == 'contact' 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity['type'] == 'contact' ? 'Contact' : 'Incident',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: activity['type'] == 'contact' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
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

  void _navigateToAdminPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminPage()),
    );
  }

  void _navigateToSecurityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecurityPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<SosCubit, SosState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor:
              state.isEmergencyMode
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                // Quarter-circle background
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 210,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8DEF8), // 78% opacity of B7AFE7
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(358),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20), // Space under status bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "SafeCampus",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/ICON.PNG',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        child: Column(
                          children: [
                            // Share and Report buttons
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF1EBFF),
                                          Color(0xFFEDEBFF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: openShareRouteSheet,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.share, size: 40),
                                          SizedBox(height: 8),
                                          Text(
                                            "Share my routes",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF1EBFF),
                                          Color(0xFFEDEBFF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: openReportIncidentSheet,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.assignment, size: 40),
                                          SizedBox(height: 8),
                                          Text(
                                            "Report incidents",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Trusted Contacts Section
                            buildTrustedContacts(),

                            const SizedBox(height: 20),

                            // Recent Activities Section
                            buildRecentActivities(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.isEmergencyMode)
                  Positioned.fill(
                    child: Container(
                      color: Colors.red.withOpacity(0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.0, end: 1.5),
                              duration: const Duration(milliseconds: 1000),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "SOS",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _stopSOSMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Cancel Emergency",
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                          'assets/images/profile.png',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Welcome, User',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Safety Map'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MapPage(
                             /* contacts: widget.initialContacts,
                              onContactsUpdated: widget.onContactsUpdated,*/
                            ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Security Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToSecurityPage();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Admin Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAdminPage();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add settings navigation here
                  },
                ),
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTrustedContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Trusted Contacts",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: openManageContactsSheet,
              tooltip: "Add Contact",
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (contacts.isEmpty)
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 36,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Text(
                  "No contacts added yet",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: openManageContactsSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Add Contact",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: contacts.map((contact) => Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name'] ?? '',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        contact['phone'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        contacts.remove(contact);
                        widget.onContactsUpdated(contacts);
                      });
                    },
                  ),
                ],
              ),
            )).toList(),
          ),
      ],
    );
  }
}
