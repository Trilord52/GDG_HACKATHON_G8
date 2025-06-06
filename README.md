# Safe Campus 🚨

**🏆 AASTU GDSC Hackathon 3rd Place Overall & 1st in Flutter Development**

A mobile application developed for **Addis Ababa Science and Technology University (AASTU)** to enhance campus safety through real-time location tracking, incident reporting, and emergency alerts.

Safe Campus bridges communication gaps by allowing users to:
- Share routes
- Manage trusted contacts
- Receive incident notifications nearby

Fostering a **safer campus environment**.

---

## 🏅 Achievements
- 🥉 **3rd Place Overall** at AASTU GDSC Hackathon
- 🥇 **1st Place in Flutter Development**

---

## 🧭 Project Structure



├── android/                   # Android-specific configurations

├── ios/                       # iOS-specific configurations

├── lib/                       # Main Flutter source code

│   ├── features/              # Feature-based organization

│   │   ├── core/              # Core app screens

│   │   │   ├── presentation/

│   │   │   │   ├── screens/

│   │   │   │   │   ├── home.dart        # Home screen with SOS button

│   │   │   │   │   ├── homepage.dart    # Dashboard with contacts & activities

│   │   │   │   │   ├── map_page.dart    # Tabbed map interface

│   │   │   │   │   ├── live_tracker.dart # Real-time location tracking

│   │   │   │   │   └── safety_map.dart  # Map with route sharing & incidents

│   │   │   │   └── components/          # Reusable UI components

│   │   │   │       ├── contact_list.dart

│   │   │   │       └── bottom_sheets.dart

│   │   └── other_features/    # Placeholder for future features

│   └── main.dart              # App entry point

├── assets/                    # Static assets (images, icons)

│   ├── images/

│   │   └── happy_ppl.png

├── test/                      # Unit and widget tests

├── .gitignore

├── pubspec.yaml               # Dependencies

└── README.md                  # You're here! 📖


---

## 📌 Project Objectives

**Main Goal:**  
Build a mobile app to improve campus safety by enabling:
- Real-time location tracking
- Incident reporting
- Emergency communication

### Core Features:
- ✅ Real-time location tracking with shareable tokens (`live_tracker.dart`)
- ✅ Interactive map with route sharing and incident markers (`safety_map.dart`)
- ✅ Anonymous incident reporting with optional media (photo/video)
- ✅ Trusted contact management for emergency location sharing (`homepage.dart`)
- ✅ SOS button for quick emergency alerts (`home.dart`)
- ✅ Nearby incident notifications based on proximity

---


🌟 Key Features
📍 Real-Time Location Tracking
Share live location with trusted contacts via a unique token.

View current location (latitude, longitude, and general area) in the Live Tracker tab.

🗺️ Interactive Safety Map
View your location on an OpenStreetMap interface.

Search destinations and get routes.

Report incidents anonymously with optional media.

Get alerts for nearby incidents within 0.5 km.

👥 Trusted Contacts Management
Add/manage trusted contacts who can access your live location in emergencies.

Accessible from the dashboard and map viewer sidebar.

🚨 SOS Emergency Button
Instantly trigger an emergency alert to notify trusted contacts.

---

🧪 Usage Guide

Launch the App

The app opens to the Home screen with the SOS button.

Navigate the Features

Home Screen: Use the SOS button or navigate to the dashboard.

Dashboard: View trusted contacts and recent activities.

Map Page: Switch between:

Live Tracker: Share your live location.

Safety Map: Report incidents and share routes.

Share Location

Go to Live Tracker tab.

Tap "Share My Walk".

Share the token with your trusted contacts.

Report an Incident

Navigate to Safety Map.

Tap the Report button.

Fill in the description and optionally attach media.

Submit anonymously.

🔧 Technical Highlights
Location Services: Uses geolocator for real-time updates and permission handling.

Mapping: Integrates flutter_map with OpenStreetMap.

State Management: Combines flutter_bloc and provider for efficient state control.

API Integration: Uses http for:

Geocoding (via Nominatim)

Route fetching (via OSRM)

Dependency Management: Resolved conflicts between flutter_map_location_marker and geolocator.
---

📈 Contribution Summary
Feature Implementation:
☑️ Real-time location tracking and sharing
☑️ Safety map with route fetching and incident reporting
☑️ Trusted contacts and emergency alerts
☑️ Modular UI components (bottom sheets, contact lists)
Technical Contributions:
☑️ Dependency resolution for flutter_map_location_marker and geolocator
☑️ Gradle build fixes (daemon issues, timeouts)
☑️ Code refactoring to use geolocator exclusively
Project Milestones:
☑️ AASTU GDSC Hackathon submission
☑️ Achieved 3rd place overall and 1st in Flutter development 🥉🏆
---
🙌 Acknowledgments
Built as part of the AASTU GDSC Hackathon. Special thanks to the organizing team, mentors, and our team for their dedication in creating a safer campus environment! 🌟
