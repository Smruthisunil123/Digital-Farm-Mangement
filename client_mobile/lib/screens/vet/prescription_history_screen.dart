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
  // ✅ 1. Accept the farmerId as a parameter
  final String farmerId;
  
  const VetPrescriptionHistoryScreen({super.key, required this.farmerId});

  @override
  State<VetPrescriptionHistoryScreen> createState() => _VetPrescriptionHistoryScreenState();
}

class _VetPrescriptionHistoryScreenState extends State<VetPrescriptionHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<VetMedicationHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchAndProcessHistory();
  }

  Future<List<VetMedicationHistoryItem>> _fetchAndProcessHistory() async {
    // ✅ 2. Use widget.farmerId instead of a hardcoded string
    final List<dynamic> prescriptions = await _apiService.getData('prescriptions/history?farmerId=${widget.farmerId}');
    final List<VetMedicationHistoryItem> allMedications = [];

    for (var prescriptionDoc in prescriptions) {
      // Safe Date Parsing
      DateTime prescribedOn = DateTime.now();
      if (prescriptionDoc['createdAt'] != null) {
         if (prescriptionDoc['createdAt'] is Map) {
            prescribedOn = DateTime.fromMillisecondsSinceEpoch((prescriptionDoc['createdAt']['_seconds'] as int) * 1000);
         } else if (prescriptionDoc['createdAt'] is String) {
            prescribedOn = DateTime.parse(prescriptionDoc['createdAt']);
         }
      }
      
      final animalTagId = prescriptionDoc['animalTagId'] ?? 'N/A';

      // ✅ 3. Robust Check for Old vs New Data
      if (prescriptionDoc['medications'] != null && prescriptionDoc['medications'] is List) {
        // NEW FORMAT
        for (var med in prescriptionDoc['medications']) {
          allMedications.add(
            VetMedicationHistoryItem(
              medicationName: med['medicationName'] ?? 'N/A',
              dosage: med['dosage'] ?? 'N/A',
              animalTagId: animalTagId,
              prescribedOn: prescribedOn,
            ),
          );
        }
      } else {
        // OLD FORMAT
        allMedications.add(
          VetMedicationHistoryItem(
            medicationName: prescriptionDoc['medicationName'] ?? 'Old Record',
            dosage: prescriptionDoc['dosage'] ?? 'N/A',
            animalTagId: animalTagId,
            prescribedOn: prescribedOn,
          ),
        );
      }
    }
    allMedications.sort((a, b) => b.prescribedOn.compareTo(a.prescribedOn));
    return allMedications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ 4. Display the specific farmer's ID in the title
        title: Text("History: ${widget.farmerId}"),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<VetMedicationHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No prescription history found for this farmer.'));
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