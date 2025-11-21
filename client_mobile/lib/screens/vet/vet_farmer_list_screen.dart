import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'prescription_history_screen.dart';

class VetFarmerListScreen extends StatefulWidget {
  const VetFarmerListScreen({super.key});

  @override
  State<VetFarmerListScreen> createState() => _VetFarmerListScreenState();
}

class _VetFarmerListScreenState extends State<VetFarmerListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _farmersFuture;

  @override
  void initState() {
    super.initState();
    // This calls the endpoint you created to get all users with role='farmer'
    _farmersFuture = _apiService.getData('users/farmers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Farmer"),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _farmersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No farmers found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final farmer = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    farmer['name'] ?? 'Unknown Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(farmer['email'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to history screen with this specific farmer's ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VetPrescriptionHistoryScreen(
                          farmerId: farmer['id'], // Passes the real ID (e.g., xYz123)
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}