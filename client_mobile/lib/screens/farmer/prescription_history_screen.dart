import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // ✅ Import AuthService
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
  late Future<List<MedicationHistoryItem>> _historyFuture = Future.value([]); // Default empty Future
  
  bool _isLoading = true;
  String? _myRealId; // This will hold the logged-in user's unique ID

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is the place to fetch data that depends on the Context (Provider)
    if (_myRealId == null) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _myRealId = authService.user?.id; // Get the ID from the AuthService
      
      if (_myRealId != null) {
        _historyFuture = _fetchAndProcessHistory(_myRealId!);
      } else {
        _historyFuture = Future.value([]);
      }
      
      // Once we have the Future, set the loading state
      if (_historyFuture != null && mounted) {
        _historyFuture.then((_) => setState(() => _isLoading = false));
      }
    }
  }

  Future<List<MedicationHistoryItem>> _fetchAndProcessHistory(String farmerId) async {
    // ✅ 1. Use the dynamic ID for the API call
    final List<dynamic> prescriptions = await _apiService.getData('prescriptions/history?farmerId=$farmerId');
    final List<MedicationHistoryItem> allMedications = [];

    for (var prescriptionDoc in prescriptions) {
      // Robust Parsing Logic (handling both new and old data formats)
      DateTime prescribedOn = DateTime.now();
      if (prescriptionDoc['createdAt'] != null) {
         if (prescriptionDoc['createdAt'] is Map) {
            prescribedOn = DateTime.fromMillisecondsSinceEpoch((prescriptionDoc['createdAt']['_seconds'] as int) * 1000);
         } else if (prescriptionDoc['createdAt'] is String) {
            prescribedOn = DateTime.parse(prescriptionDoc['createdAt']);
         }
      }
      
      final withdrawalDays = prescriptionDoc['withdrawalDays'] ?? 0;
      final animalTagId = prescriptionDoc['animalTagId'] ?? 'N/A';

      if (prescriptionDoc['medications'] != null && prescriptionDoc['medications'] is List) {
        for (var med in prescriptionDoc['medications']) {
          allMedications.add(MedicationHistoryItem(
            medicationName: med['medicationName'] ?? 'N/A',
            dosage: med['dosage'] ?? 'N/A',
            animalTagId: animalTagId,
            prescribedOn: prescribedOn,
            withdrawalDays: withdrawalDays is int ? withdrawalDays : int.tryParse(withdrawalDays.toString()) ?? 0,
          ));
        }
      } else {
         allMedications.add(MedicationHistoryItem(
            medicationName: prescriptionDoc['medicationName'] ?? 'Old Record',
            dosage: prescriptionDoc['dosage'] ?? 'N/A',
            animalTagId: animalTagId,
            prescribedOn: prescribedOn,
            withdrawalDays: withdrawalDays is int ? withdrawalDays : int.tryParse(withdrawalDays.toString()) ?? 0,
          ));
      }
    }
    
    allMedications.sort((a, b) => b.prescribedOn.compareTo(a.prescribedOn));
    return allMedications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Medicine History"),
        backgroundColor: Colors.green.shade800,
        actions: [
          // Refresh button to re-fetch data based on the dynamic ID
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: _myRealId != null ? () => setState(() => _historyFuture = _fetchAndProcessHistory(_myRealId!)) : null
          ),
        ],
      ),
      body: FutureBuilder<List<MedicationHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (_myRealId == null) {
            return const Center(child: Text('Error: User not authenticated.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No prescription history found for you.'));
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