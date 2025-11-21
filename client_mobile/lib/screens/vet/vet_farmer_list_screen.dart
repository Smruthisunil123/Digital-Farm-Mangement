import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'prescription_history_screen.dart';
import 'prescription_form.dart';

class VetFarmerListScreen extends StatefulWidget {
  // This flag determines if we are picking a farmer for a new Rx or just viewing history
  final bool isCreatingPrescription; 
  
  const VetFarmerListScreen({super.key, this.isCreatingPrescription = false});

  @override
  State<VetFarmerListScreen> createState() => _VetFarmerListScreenState();
}

class _VetFarmerListScreenState extends State<VetFarmerListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _farmersFuture;

  @override
  void initState() {
    super.initState();
    _farmersFuture = _apiService.getData('users/farmers').then((data) {
      // Dart is happy because we are explicitly returning the correct list type
      return data as List<dynamic>; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreatingPrescription ? "Select Farmer for Rx" : "Select Farmer History"),
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
                  // ✅ UPDATED: Show Government ID and Email
                  subtitle: Text("Govt ID: ${farmer['govtId'] ?? 'N/A'}\n${farmer['email']}"),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (widget.isCreatingPrescription) {
                      // Go to Prescription Form with ID Pre-filled
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrescriptionFormScreen(prefilledFarmerId: farmer['id']),
                        ),
                      );
                    } else {
                      // Go to History Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VetPrescriptionHistoryScreen(farmerId: farmer['id']),
                        ),
                      );
                    }
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