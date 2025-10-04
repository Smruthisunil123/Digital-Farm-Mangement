import 'package:flutter/material.dart';

// Placeholder for the Farmer's medication scanning interface.
class MedicationScanScreen extends StatelessWidget {
  const MedicationScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Scanner'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text(
          'Camera/Scanning UI goes here!',
          style: TextStyle(fontSize: 20, color: Colors.orange),
        ),
      ),
    );
  }
}
