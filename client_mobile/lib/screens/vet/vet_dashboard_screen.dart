import 'package:flutter/material.dart';

/// The main dashboard for the Veterinarian user, providing access to all features.
class VetDashboardScreen extends StatelessWidget {
  const VetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vet Dashboard"),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false, // Removes the back arrow
        actions: [
          // Adds a logout button for better user experience
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Navigate back to the login screen and clear the navigation stack
              Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Button for creating a new prescription
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_note, size: 28),
                label: const Text("New Prescription"),
                onPressed: () {
                  Navigator.of(context).pushNamed('/prescription');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              
              // ✅ THE CHANGE: This new button navigates to the history screen
              ElevatedButton.icon(
                icon: const Icon(Icons.history, size: 24),
                label: const Text("View Prescription History"),
                onPressed: () {
                  // This tells the app to open the '/history' route
                  Navigator.of(context).pushNamed('/history');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Button for managing appointments
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 24),
                label: const Text("Manage Appointments"),
                onPressed: () {
                  Navigator.of(context).pushNamed('/appointments');
                },
                 style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

