import 'package:flutter/material.dart';

/// The main dashboard for the Farmer user, providing access to key features.
class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Farm Dashboard"),
        backgroundColor: Colors.green.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Navigate back to the login screen and remove all previous routes
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Makes buttons full-width
          children: [
            // Welcome Header
            Text(
              "Welcome, Farmer!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 40),

            // "View Medicine History" Button
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("View Medicine History"),
              onPressed: () {
                Navigator.of(context).pushNamed('/farmer/history');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // "Scan Medicine (OCR)" Button
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Scan Medicine (OCR)"),
              onPressed: () {
                Navigator.of(context).pushNamed('/farmer/ocr');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // "Chatbot Help" Button
            ElevatedButton.icon(
              icon: const Icon(Icons.support_agent),
              label: const Text("Chatbot Help"),
              // ✅ THIS IS THE FIX: This now navigates to the new chatbot screen.
              onPressed: () {
                Navigator.of(context).pushNamed('/farmer/chatbot');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
