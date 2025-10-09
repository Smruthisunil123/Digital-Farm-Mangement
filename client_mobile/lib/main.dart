import 'package:flutter/material.dart';

// Import all your screens
import 'screens/common/auth_screen.dart';
import 'screens/farmer/dashboard_screen.dart';
import 'screens/vet/vet_dashboard_screen.dart';
import 'screens/vet/prescription_form.dart';
// ✅ 1. IMPORT THE NEW APPOINTMENTS SCREEN
import 'screens/vet/appointments_screen.dart'; // Make sure this path is correct
import 'screens/vet/prescription_history_screen.dart';
import 'screens/farmer/prescription_history_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer-Vet App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/farmer': (context) => const FarmerDashboardScreen(),
         '/farmer/history': (context) => const FarmerPrescriptionHistoryScreen(),
         
        '/vet': (context) => const VetDashboardScreen(),
        '/prescription': (context) => const PrescriptionFormScreen(),

        // ✅ 2. ADD THE ROUTE FOR THE APPOINTMENTS SCREEN
        '/appointments': (context) => const AppointmentsScreen(),
         '/history': (context) => const PrescriptionHistoryScreen(),
      },
    );
  }
}

