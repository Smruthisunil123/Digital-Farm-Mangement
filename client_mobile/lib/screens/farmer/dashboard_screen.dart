import 'package:flutter/material.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farmer Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("View Medicine History"),
              onPressed: () {},
            ),
            ElevatedButton(
              child: const Text("Scan Medicine (OCR)"),
              onPressed: () {},
            ),
            ElevatedButton(
              child: const Text("Chatbot Help"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

