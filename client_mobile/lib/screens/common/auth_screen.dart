import 'package:flutter/material.dart';

// NOTE: This is a placeholder file to resolve the 'uri_does_not_exist' and 
// 'creation_with_non_type' errors reported in main.dart.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome to Farmer-Vet App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 30),
              // Placeholder for sign-in/registration buttons
              ElevatedButton(
                onPressed: () {
                  // Simulate a successful login and navigate to a dashboard
                  // For now, let's navigate to the farmer dashboard route defined in main.dart
                  Navigator.of(context).pushReplacementNamed('/farmer');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Start Session (Login Placeholder)',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
