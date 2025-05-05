import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/auth_bloc.dart';
import 'package:safe_campus/features/core/presentation/screens/admin/risk_zone_management.dart';
import 'package:safe_campus/features/core/presentation/screens/admin/incident_reports.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated || 
            (state.user.role != 'admin' && state.user.role != 'campus_security')) {
          return Scaffold(
            body: Center(
              child: Text(
                'Access Denied',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Admin Dashboard',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Risk Zones',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Incident Reports',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                RiskZoneManagement(),
                IncidentReports(),
              ],
            ),
          ),
        );
      },
    );
  }
} 