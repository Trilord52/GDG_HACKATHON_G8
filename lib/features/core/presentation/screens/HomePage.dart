import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/report_incident_bottom_sheet.dart';
import 'components/share_route_bottom_sheet.dart';
import 'components/contact_form_bottom_sheet.dart';
import 'package:safe_campus/features/core/presentation/screens/mapPage.dart';
import 'package:safe_campus/features/core/presentation/screens/components/contact_list.dart';
import 'dart:async';
import 'admin_page.dart';
import 'security_page.dart';
import 'adm_sec_login_page.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, String>> initialContacts; // Accept initial contacts
  final Function(List<Map<String, String>>) onContactsUpdated; // Callback to update contacts

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
  List<Map<String, String>> contacts = [];
  bool showAllActivities = false;
  bool isEmergencyMode = false;
  Timer? _sosPulseTimer;

  @override
  void initState() {
    super.initState();
    contacts = widget.initialContacts;
  }

  @override
  void dispose() {
    _sosPulseTimer?.cancel();
    super.dispose();
  }

  void _startSOSMode() {
    setState(() {
      isEmergencyMode = true;
    });
    _sosPulseTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {});
    });
  }

  void _stopSOSMode() {
    setState(() {
      isEmergencyMode = false;
    });
    _sosPulseTimer?.cancel();
  }

  void openReportIncidentSheet() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReportIncidentBottomSheet(
        onSubmit: (name, description) {
          Navigator.of(context).pop({'name': name, 'description': description});
        },
      ),
    );

    if (result != null && mounted) {
      setState(() {
        recentActivities.insert(0, {
          'name': result['name'] ?? '',
          'description': result['description'] ?? '',
          'timestamp': DateTime.now().toString(),
        });
      });
    }
  }

  void openShareRouteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Share Location",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Let trusted people know where you are in real-time",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.directions_walk, color: Colors.blue, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Track your movement in real-time",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.share, color: Colors.blue, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Share your location with trusted contacts",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.emergency, color: Colors.red, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Emergency mode for quick alert",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      "Later",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            contacts: widget.initialContacts,
                            onContactsUpdated: widget.onContactsUpdated,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      "Start Sharing",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openManageContactsSheet() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContactFormBottomSheet(
        onSave: (name, phone, email) {
          Navigator.of(context).pop({
            'name': name,
            'phone': phone,
            'email': email,
          });
        },
      ),
    );

    if (result != null && mounted) {
      setState(() {
        List<Map<String, String>> updatedContacts = List.from(widget.initialContacts);
        updatedContacts.add(result);
        widget.onContactsUpdated(updatedContacts); // Notify parent of the update
      });
    }
  }

  void deleteContact(int index) {
    setState(() {
      List<Map<String, String>> updatedContacts = List.from(widget.initialContacts);
      updatedContacts.removeAt(index);
      widget.onContactsUpdated(updatedContacts);
    });
  }

  void openDialogeBox() {
    if (isEmergencyMode) {
      _stopSOSMode();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Confirm your request",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        content: SizedBox(
          height: 280,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/alert1.png'),
              Text(
                "The alert will be sent to security personnel and trusted contacts with your location and personal information. Make sure you made the right request before sending alert!",
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startSOSMode();
              // Notify trusted contacts and security
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Emergency alert sent to trusted contacts and security personnel!"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Send Alert",
              style: GoogleFonts.poppins(color: Colors.white),
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
    final activitiesToShow = showAllActivities ? recentActivities : 
        recentActivities.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Activities",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (recentActivities.length > 3)
              TextButton(
                onPressed: () {
                  setState(() {
                    showAllActivities = !showAllActivities;
                  });
                },
                child: Text(
                  showAllActivities ? "Show Less" : "Show More",
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentActivities.isEmpty)
          Center(
            child: Text(
              "No recent activities",
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activitiesToShow.length,
            itemBuilder: (context, index) {
              final activity = activitiesToShow[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: Text(
                    activity['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    activity['description'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    _formatTimestamp(activity['timestamp'] ?? ''),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
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

    return Scaffold(
      backgroundColor: isEmergencyMode ? Colors.red.withOpacity(0.1) : Colors.white,
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
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                              'assets/images/happy_ppl.png',
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
                                    colors: [Color(0xFFF1EBFF), Color(0xFFEDEBFF)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(2, 4),
                                    )
                                  ],
                                ),
                                child: InkWell(
                                  onTap: openShareRouteSheet,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.share, size: 40),
                                      SizedBox(height: 8),
                                      Text("Share my routes", style: TextStyle(fontSize: 14)),
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
                                    colors: [Color(0xFFF1EBFF), Color(0xFFEDEBFF)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(2, 4),
                                    )
                                  ],
                                ),
                                child: InkWell(
                                  onTap: openReportIncidentSheet,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.assignment, size: 40),
                                      SizedBox(height: 8),
                                      Text("Report incidents", style: TextStyle(fontSize: 14)),
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
            if (isEmergencyMode)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialogeBox();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.sos),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile.png'),
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
                    builder: (context) => MapPage(
                      contacts: widget.initialContacts,
                      onContactsUpdated: widget.onContactsUpdated,
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
        if (widget.initialContacts.isEmpty)
          Center(
            child: Column(
              children: [
                const Icon(Icons.people_outline, size: 36, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  "No trusted contacts added",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
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
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ContactList(
            contacts: widget.initialContacts,
            onDelete: deleteContact,
          ),
      ],
    );
  }
}