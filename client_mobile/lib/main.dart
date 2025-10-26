import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Service Imports ---
import 'services/auth_service.dart';

// --- Screen Imports ---
import 'screens/common/auth_screen.dart';
import 'screens/vet/vet_dashboard_screen.dart';
import 'screens/farmer/dashboard_screen.dart';
import 'screens/vet/prescription_form.dart';
import 'screens/farmer/ocr_scan_screen.dart';
import 'screens/farmer/chatbot_screen.dart';
import 'screens/vet/appointments_screen.dart';
// Use aliases to prevent class name conflicts
import 'screens/vet/prescription_history_screen.dart' as vet_history;
import 'screens/farmer/prescription_history_screen.dart' as farmer_history;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Farm Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // The 'home' property correctly handles the initial screen logic.
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.user != null) {
            if (authService.user!.role.toLowerCase().contains('vet')) {
              return const VetDashboardScreen();
            } else {
              return const FarmerDashboardScreen();
            }
          }
          return const AuthScreen();
        },
      ),
      // All other routes are defined for navigation.
      routes: {
        // ✅ THE FIX: The redundant '/' route has been removed.
        '/vet': (context) => const VetDashboardScreen(),
        '/farmer': (context) => const FarmerDashboardScreen(),
        '/prescription': (context) => PrescriptionFormScreen(),
        '/history': (context) => vet_history.VetPrescriptionHistoryScreen(),
        '/farmer/history': (context) => farmer_history.FarmerPrescriptionHistoryScreen(),
        '/farmer/ocr': (context) => OcrScanScreen(),
        '/farmer/chatbot': (context) => const ChatbotScreen(),
        '/appointments':(context) => AppointmentsScreen(),
      },
    );
  }
}