import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

// Model for a single prescription
class Prescription {
  final String medicationName;
  final String dosage;
  final DateTime createdAt;
  final int withdrawalDays;

  Prescription({
    required this.medicationName,
    required this.dosage,
    required this.createdAt,
    required this.withdrawalDays,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medicationName: json['medicationName'] ?? 'N/A',
      dosage: json['dosage'] ?? 'N/A',
      createdAt: (json['createdAt'] as Map<String, dynamic>).isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch((json['createdAt']['_seconds'] as int) * 1000)
          : DateTime.now(),
      withdrawalDays: json['withdrawalDays'] ?? 0,
    );
  }
}

class FarmerPrescriptionHistoryScreen extends StatefulWidget {
  const FarmerPrescriptionHistoryScreen({super.key});

  @override
  State<FarmerPrescriptionHistoryScreen> createState() => _FarmerPrescriptionHistoryScreenState();
}

class _FarmerPrescriptionHistoryScreenState extends State<FarmerPrescriptionHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Prescription>> _historyFuture;

  // IMPORTANT: In a real app, you would get the farmer's ID from the logged-in user.
  // We will use a hardcoded ID for testing.
  final String _farmerId = "farmer123";

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<Prescription>> _fetchHistory() async {
    try {
      final List<dynamic> responseData = await _apiService.getData('prescriptions/history?farmerId=$_farmerId');
      return responseData.map((json) => Prescription.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load history: $e')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Medicine History"),
        backgroundColor: Colors.green.shade800,
      ),
      body: FutureBuilder<List<Prescription>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No prescription history found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final history = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.green, size: 40),
                  title: Text(item.medicationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Dosage: ${item.dosage}\nPrescribed on: ${DateFormat.yMMMd().format(item.createdAt)}',
                  ),
                  trailing: Text(
                    'Withdrawal:\n${item.withdrawalDays} days',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
