import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/report_incident_bottom_sheet.dart';
import 'components/share_route_bottom_sheet.dart';
import 'components/contact_form_bottom_sheet.dart';
import 'package:safe_campus/features/core/presentation/screens/mapPage.dart';
import 'package:safe_campus/features/core/presentation/screens/components/contact_list.dart';

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
  bool showAllActivities = false; // Only keep toggle for Recent Activities

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

    if (result != null) {
      setState(() {
        recentActivities.add(result);
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
        onSave: (name, phone) {
          Navigator.of(context).pop({'name': name, 'phone': phone});
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Trusted contacts",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "people who can see your location during emergencies",
                                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              widget.initialContacts.isNotEmpty
                                  ? Column(
                                      children: widget.initialContacts
                                          .map((c) => ListTile(
                                                title: Text(c['name'] ?? '', style: GoogleFonts.poppins()),
                                                subtitle: Text(c['phone'] ?? '',
                                                    style: GoogleFonts.poppins(fontSize: 12)),
                                              ))
                                          .toList(),
                                    )
                                  : Center(
                                      child: Column(
                                        children: [
                                          const Icon(Icons.person_add, size: 36, color: Colors.grey),
                                          const SizedBox(height: 10),
                                          Text(
                                            "No trusted contacts added",
                                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(height: 10),
                              Center(
                                child: Container(
                                  width: screenWidth * 0.6,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF1EBFF), Color(0xFFEDEBFF)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(2, 4),
                                      )
                                    ],
                                  ),
                                  child: TextButton.icon(
                                    onPressed: openManageContactsSheet,
                                    icon: const Icon(Icons.manage_accounts, color: Colors.black),
                                    label: Text(
                                      "Manage contacts",
                                      style: GoogleFonts.poppins(color: Colors.black),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Recent Activities Section
                        GestureDetector(
                          onTap: () => setState(() => showAllActivities = !showAllActivities),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Recent Activities",
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "your recent safety actions",
                                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 20),
                                if (showAllActivities)
                                  Column(
                                    children: recentActivities
                                        .map((act) => ListTile(
                                              title: Text(act['name'] ?? '', style: GoogleFonts.poppins()),
                                              subtitle: Text(act['description'] ?? '',
                                                  style: GoogleFonts.poppins(fontSize: 12)),
                                            ))
                                        .toList(),
                                  )
                                else if (recentActivities.isEmpty)
                                  Center(
                                    child: Column(
                                      children: [
                                        const Icon(Icons.history, size: 36, color: Colors.grey),
                                        const SizedBox(height: 10),
                                        Text(
                                          "No data has found",
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
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
    );
  }
}