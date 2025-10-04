import 'package:flutter/material.dart';

class VetDashboardScreen extends StatelessWidget {
  const VetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vet Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Manage Appointments"),
              onPressed: () {},
            ),
            ElevatedButton(
              child: const Text("New Prescription"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
