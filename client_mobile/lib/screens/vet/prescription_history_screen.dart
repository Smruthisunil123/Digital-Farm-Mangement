import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

// A model to structure our prescription data from the server
class Prescription {
  final String medicationName;
  final String dosage;
  final DateTime createdAt;
  final String farmerId;

  Prescription({
    required this.medicationName,
    required this.dosage,
    required this.createdAt,
    required this.farmerId,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    // Handle Firestore's timestamp format
    final timestamp = json['createdAt'];
    DateTime date;
    if (timestamp != null && timestamp['_seconds'] != null) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
    } else {
      date = DateTime.now();
    }

    return Prescription(
      medicationName: json['medicationName'] ?? 'N/A',
      dosage: json['dosage'] ?? 'N/A',
      createdAt: date,
      farmerId: json['farmerId'] ?? 'Unknown Farmer',
    );
  }
}

class PrescriptionHistoryScreen extends StatefulWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  State<PrescriptionHistoryScreen> createState() => _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Prescription>> _historyFuture;
  // In a real app, you would pass the farmer's ID to this screen.
  // For now, we are hardcoding it to get data for a specific test farmer.
  final String _farmerIdForQuery = "farmer123"; 

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<Prescription>> _fetchHistory() async {
    try {
      // This endpoint calls the GET /prescriptions/history route on your server
      final List<dynamic> responseData = await _apiService.getData('prescriptions/history?farmerId=$_farmerIdForQuery');
      return responseData.map((json) => Prescription.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load prescription history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history: $e')),
        );
      }
      return []; // Return an empty list if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription History'),
        backgroundColor: Colors.indigo,
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
            padding: const EdgeInsets.all(8.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final prescription = history[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.indigo, size: 40),
                  title: Text(
                    prescription.medicationName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dosage: ${prescription.dosage}\n'
                    'Date: ${DateFormat.yMMMd().format(prescription.createdAt)}',
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

