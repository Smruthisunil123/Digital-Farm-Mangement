import 'package:flutter/material.dart';

// --- Common Screens ---
import 'screens/common/auth_screen.dart';

// --- Farmer Screens ---
import 'screens/farmer/dashboard_screen.dart';
import 'screens/farmer/prescription_history_screen.dart';
import 'screens/farmer/ocr_scan_screen.dart'; 
import 'screens/farmer/chatbot_screen.dart';

// --- Vet Screens ---
import 'screens/vet/vet_dashboard_screen.dart';
import 'screens/vet/prescription_form.dart';
import 'screens/vet/appointments_screen.dart';
// Note: You have two history screens. Let's alias one to avoid conflicts.
import 'screens/vet/prescription_history_screen.dart' as vet_history;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Farm Management',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // --- Common Routes ---
        // AuthScreen is stateless, so 'const' is okay here.
        '/': (context) => const AuthScreen(),

        // --- Farmer Routes ---
        // FarmerDashboardScreen is stateless, so 'const' is okay here.
        '/farmer': (context) => const FarmerDashboardScreen(),
        // ✅ FIX: Removed 'const' because FarmerPrescriptionHistoryScreen is stateful.
        '/farmer/history': (context) => FarmerPrescriptionHistoryScreen(),
        // ✅ FIX: Removed 'const' because OcrScanScreen is stateful.
        '/farmer/ocr': (context) => OcrScanScreen(),
        '/farmer/chatbot': (context) => const ChatbotScreen(),


        // --- Vet Routes ---
        // VetDashboardScreen is stateless, so 'const' is okay here.
        '/vet': (context) => const VetDashboardScreen(),
        // ✅ FIX: Removed 'const' because PrescriptionFormScreen is stateful.
        '/prescription': (context) => PrescriptionFormScreen(),
        // ✅ FIX: Removed 'const' because AppointmentsScreen is stateful.
        '/appointments': (context) => AppointmentsScreen(),
        // ✅ FIX: Removed 'const' and used the alias for the Vet's history screen.
        '/history': (context) => vet_history.PrescriptionHistoryScreen(),
      },
    );
  }
}