import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_campus/features/core/presentation/bloc/NavigationCubit.dart';
import 'package:safe_campus/features/core/presentation/bloc/panic_alert/panic_alert_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/panic_alert/panic_alert_event.dart';
import 'package:safe_campus/features/core/presentation/bloc/socket/socket_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/socket/socket_event.dart';
import 'package:safe_campus/features/core/presentation/screens/HomePage.dart';
import 'package:safe_campus/features/core/presentation/screens/alertPage.dart';
import 'package:safe_campus/features/core/presentation/screens/mapPage.dart';
import 'package:safe_campus/features/core/presentation/screens/profilePage.dart';
import 'package:safe_campus/features/core/presentation/screens/sos_cubit/sos_cubit.dart';
import 'dart:developer' as developer;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> contacts = []; // Lifted contacts state to Home

  final List<Widget> pages = []; // Will initialize in initState

  @override
  void initState() {
    super.initState();
    // Initialize pages with contacts
    pages.addAll([
      HomePage(
        onContactsUpdated: (updatedContacts) {
          setState(() {
            contacts = updatedContacts;
          });
        },
        initialContacts: contacts,
      ),
      MapPage(
      /*  contacts: contacts,
        onContactsUpdated: (updatedContacts) {
          setState(() {
            contacts = updatedContacts;
          });
        },*/
      ), // Added onContactsUpdated
      Alertpage(),
      Profilepage(),
    ]);
  }

  void openDialogeBox() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Confirm your request",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            content: SizedBox(
              height: 340,
              child: Column(
                
                children: [
                  Image.asset('assets/images/alert1.png'),
                  const SizedBox(height: 10),
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
                  developer.log('SOS button pressed');
              
                  context.read<PanicAlertBloc>().add(TriggerPanicAlert(token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODE4Y2EyM2U1YjE2NDZkNzI5NTdkYzgiLCJyb2xlIjoic3R1ZGVudCIsImVtYWlsIjoiYWxleEBnbWFpbC5jb20iLCJpYXQiOjE3NDY0NTU5MzgsImV4cCI6MTc0NjU0MjMzOH0.seUmXPnTZFLuoRnh4EWN6pvpIlTABmDgiKoU_cytC-E'));

                  _startSOSMode();
                  // Notify trusted contacts and security
                  Fluttertoast.showToast(msg: 'Emergency alert sent to trusted contacts and security personnel!', backgroundColor: Colors.red);
                
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
  Timer? _sosPulseTimer;

  void _startSOSMode() {
 
    context.read<SosCubit>().onEmergencyMode();
    _sosPulseTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
        builder: (context, selectedIndex) {
          return BlocBuilder<SosCubit, SosState>(
            builder: (context, state) {
              return Scaffold(
    
                body: pages[selectedIndex],
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  onPressed: openDialogeBox,
                  backgroundColor: state.isEmergencyMode ? Colors.red: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Text("SOS"),
                ),
                bottomNavigationBar: BottomAppBar(
                  notchMargin: 5,
                  color: const Color.fromARGB(255, 223, 222, 236),
                  height: 80,
                  shape: const CircularNotchedRectangle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      navItem(
                        context,
                        icon: Icons.home,
                        label: "Home",
                        index: 0,
                        selected: selectedIndex,
                      ),
                      navItem(
                        context,
                        icon: Icons.map,
                        label: "Map",
                        index: 1,
                        selected: selectedIndex,
                      ),
                      const SizedBox(width: 40),
                      navItem(
                        context,
                        icon: Icons.notifications,
                        label: "Alerts",
                        index: 2,
                        selected: selectedIndex,
                      ),
                      navItem(
                        context,
                        icon: Icons.person,
                        label: "Profile",
                        index: 3,
                        selected: selectedIndex,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
 
  }
}

Widget navItem(
  BuildContext context, {
  required IconData icon,
  required String label,
  required int index,
  required int selected,
}) {
  final isSelected = selected == index;
  final color =
      isSelected
          ? const Color(0xFF65558F)
          : const Color.fromARGB(255, 124, 124, 124);

  return InkWell(
    onTap: () => context.read<NavigationCubit>().updateIndex(index),
    child: Container(
      width: 60,
      height: 80,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 25, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    ),
  );
}


