import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class VetMedicationHistoryItem {
  final String medicationName;
  final String dosage;
  final String animalTagId;
  final DateTime prescribedOn;

  VetMedicationHistoryItem({
    required this.medicationName,
    required this.dosage,
    required this.animalTagId,
    required this.prescribedOn,
  });
}

class VetPrescriptionHistoryScreen extends StatefulWidget {
  const VetPrescriptionHistoryScreen({super.key});
  @override
  State<VetPrescriptionHistoryScreen> createState() => _VetPrescriptionHistoryScreenState();
}

class _VetPrescriptionHistoryScreenState extends State<VetPrescriptionHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<VetMedicationHistoryItem>> _historyFuture;
  final String _farmerIdForQuery = "farmer123";

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchAndProcessHistory();
  }

  Future<List<VetMedicationHistoryItem>> _fetchAndProcessHistory() async {
    final List<dynamic> prescriptions = await _apiService.getData('prescriptions/history?farmerId=$_farmerIdForQuery');
    final List<VetMedicationHistoryItem> allMedications = [];

    for (var prescriptionDoc in prescriptions) {
      final prescribedOn = (prescriptionDoc['createdAt'] as Map<String, dynamic>).isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch((prescriptionDoc['createdAt']['_seconds'] as int) * 1000)
          : DateTime.now();
      final animalTagId = prescriptionDoc['animalTagId'] ?? 'N/A';

      // ✅ THE FIX: Check if 'medications' exists and is a list.
      if (prescriptionDoc['medications'] != null && prescriptionDoc['medications'] is List) {
        // This is the NEW data format
        for (var med in prescriptionDoc['medications']) {
          allMedications.add(VetMedicationHistoryItem(
            medicationName: med['medicationName'] ?? 'N/A',
            dosage: med['dosage'] ?? 'N/A',
            animalTagId: animalTagId,
            prescribedOn: prescribedOn,
          ));
        }
      } else {
        // This is the OLD data format, handle it gracefully
        allMedications.add(VetMedicationHistoryItem(
          medicationName: prescriptionDoc['medicationName'] ?? 'Old Prescription',
          dosage: prescriptionDoc['dosage'] ?? 'N/A',
          animalTagId: animalTagId,
          prescribedOn: prescribedOn,
        ));
      }
    }
    allMedications.sort((a, b) => b.prescribedOn.compareTo(a.prescribedOn));
    return allMedications;
  }

  @override
  Widget build(BuildContext context) {
    // The build method is correct and does not need to change.
    return Scaffold(
      appBar: AppBar(
        title: Text("History for Farmer $_farmerIdForQuery"),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<VetMedicationHistoryItem>>(
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
                  leading: const Icon(Icons.receipt_long, color: Colors.indigo, size: 40),
                  title: Text(
                    '${item.medicationName} (for Animal: ${item.animalTagId})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dosage: ${item.dosage}\nPrescribed on: ${DateFormat.yMMMd().format(item.prescribedOn)}',
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