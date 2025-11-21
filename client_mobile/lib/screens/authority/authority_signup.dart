import 'package:flutter/material.dart';
import 'authority_dashboard_screen.dart';

class AuthoritySignupScreen extends StatefulWidget {
  const AuthoritySignupScreen({super.key});

  @override
  State<AuthoritySignupScreen> createState() => _AuthoritySignupScreenState();
}

class _AuthoritySignupScreenState extends State<AuthoritySignupScreen> {
  // ✅ PRE-FILLED DUMMY CREDENTIALS
  final _nameController = TextEditingController(text: "Dr. Rajesh Kumar");
  final _emailController = TextEditingController(text: "officer.rajesh@foodsafety.gov.in");
  final _idController = TextEditingController(text: "AUTH-BLOCK-8821");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Official Registration"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Government Oversight Access",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Credentials verify against the Authority Node.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Full Name
            TextFormField(
              controller: _nameController, // Pre-filled
              decoration: const InputDecoration(
                labelText: "Official Full Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            // Department Email
            TextFormField(
              controller: _emailController, // Pre-filled
              decoration: const InputDecoration(
                labelText: "Department Email (.gov)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),

            // Badge ID
            TextFormField(
              controller: _idController, // Pre-filled
              decoration: const InputDecoration(
                labelText: "Badge / Blockchain Key ID",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verifying Blockchain Key...")),
                  );

                  // Navigate to Dashboard
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthorityDashboardScreen(
                          officerName: "Dr. Rajesh Kumar",
                          region: "North District",
                        ),
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("ACCESS DASHBOARD"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}