import 'package:flutter/material.dart';
import 'screens/common/auth_screen.dart';
import 'screens/farmer/dashboard_screen.dart';
import 'screens/vet/vet_dashboard_screen.dart';

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
      // AuthScreen is now correctly imported and used
      home: const AuthScreen(), 
      routes: {
        // NOTE: You will need to ensure dashboard_screen.dart and 
        // vet_dashboard_screen.dart also exist and define the correct classes.
        '/farmer': (context) => const FarmerDashboardScreen(),
        '/vet': (context) => const VetDashboardScreen(),
      },
    );
  }
}
