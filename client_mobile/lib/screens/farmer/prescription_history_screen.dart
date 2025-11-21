import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class MedicationHistoryItem {
  final String medicationName;
  final String dosage;
  final String animalTagId;
  final DateTime prescribedOn;
  final int withdrawalDays;

  MedicationHistoryItem({
    required this.medicationName,
    required this.dosage,
    required this.animalTagId,
    required this.prescribedOn,
    required this.withdrawalDays,
  });
}

class FarmerPrescriptionHistoryScreen extends StatefulWidget {
  const FarmerPrescriptionHistoryScreen({super.key});

  @override
  State<FarmerPrescriptionHistoryScreen> createState() => _FarmerPrescriptionHistoryScreenState();
}

class _FarmerPrescriptionHistoryScreenState extends State<FarmerPrescriptionHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<MedicationHistoryItem>> _historyFuture;
  // In a real app, this would come from the logged-in user's ID
  final String _farmerId = "farmer123"; 

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchAndProcessHistory();
  }

  Future<List<MedicationHistoryItem>> _fetchAndProcessHistory() async {
    final List<dynamic> prescriptions = await _apiService.getData('prescriptions/history?farmerId=$_farmerId');
    final List<MedicationHistoryItem> allMedications = [];

    for (var prescriptionDoc in prescriptions) {
      // 1. Parse Date
      final prescribedOn = (prescriptionDoc['createdAt'] as Map<String, dynamic>).isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch((prescriptionDoc['createdAt']['_seconds'] as int) * 1000)
          : DateTime.now();
      
      // 2. Get Top-Level Fields
      final withdrawalDays = prescriptionDoc['withdrawalDays'] ?? 0;
      final animalTagId = prescriptionDoc['animalTagId'] ?? 'N/A';

      // ✅ THE FIX: Check if 'medications' list exists before looping
      if (prescriptionDoc['medications'] != null && prescriptionDoc['medications'] is List) {
        // Handle NEW format (List of medicines)
        for (var med in prescriptionDoc['medications']) {
          allMedications.add(
            MedicationHistoryItem(
              medicationName: med['medicationName'] ?? 'N/A',
              dosage: med['dosage'] ?? 'N/A',
              animalTagId: animalTagId,
              prescribedOn: prescribedOn,
              withdrawalDays: withdrawalDays is int ? withdrawalDays : int.tryParse(withdrawalDays.toString()) ?? 0,
            ),
          );
        }
      } else {
        // Handle OLD format (Single medicine at top level)
        allMedications.add(
          MedicationHistoryItem(
            medicationName: prescriptionDoc['medicationName'] ?? 'Old Record',
            dosage: prescriptionDoc['dosage'] ?? 'N/A',
            animalTagId: animalTagId,
            prescribedOn: prescribedOn,
            withdrawalDays: withdrawalDays is int ? withdrawalDays : int.tryParse(withdrawalDays.toString()) ?? 0,
          ),
        );
      }
    }
    
    // Sort by newest first
    allMedications.sort((a, b) => b.prescribedOn.compareTo(a.prescribedOn));
    return allMedications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Medicine History"),
        backgroundColor: Colors.green.shade800,
      ),
      body: FutureBuilder<List<MedicationHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No prescription history found.'));
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
                  title: Text(
                    '${item.medicationName} (Animal: ${item.animalTagId})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dosage: ${item.dosage}\nDate: ${DateFormat.yMMMd().format(item.prescribedOn)}',
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