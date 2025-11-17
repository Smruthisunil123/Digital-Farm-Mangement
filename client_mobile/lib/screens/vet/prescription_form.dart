import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// A model to hold the data for a single medication
class MedicationEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  bool morning = false;
  bool afternoon = false;
  bool night = false;

  // Helper to dispose of controllers
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
  }
}

class PrescriptionFormScreen extends StatefulWidget {
  const PrescriptionFormScreen({super.key});

  @override
  State<PrescriptionFormScreen> createState() => _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState extends State<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _farmerIdController = TextEditingController();
  final TextEditingController _animalTagController = TextEditingController();
  final TextEditingController _withdrawalDaysController = TextEditingController();
  // ✅ NEW: Controller for the Diagnosis field
  final TextEditingController _diagnosisController = TextEditingController();

  // We now manage a list of medication entries
  List<MedicationEntry> _medications = [MedicationEntry()];
  bool _isLoading = false;

  @override
  void dispose() {
    _farmerIdController.dispose();
    _animalTagController.dispose();
    _withdrawalDaysController.dispose();
    _diagnosisController.dispose(); // ✅ Dispose the new controller
    for (var med in _medications) {
      med.dispose();
    }
    super.dispose();
  }

  void _addMedication() {
    setState(() {
      _medications.add(MedicationEntry());
    });
  }

  void _removeMedication(int index) {
    if (_medications.length > 1) {
      setState(() {
        _medications[index].dispose();
        _medications.removeAt(index);
      });
    }
  }

  Future<void> _submitPrescription() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Convert our UI data into a JSON-friendly format for the server
      List<Map<String, dynamic>> medicationsJson = _medications.map((med) {
        List<String> frequency = [];
        if (med.morning) frequency.add('morning');
        if (med.afternoon) frequency.add('afternoon');
        if (med.night) frequency.add('night');
        return {
          "medicationName": med.nameController.text.trim(),
          "dosage": med.dosageController.text.trim(),
          "frequency": frequency, // Send as an array of strings
        };
      }).toList();

      final body = {
        "vetId": "vet_placeholder_id",
        "farmerId": _farmerIdController.text.trim(),
        "animalTagId": _animalTagController.text.trim(),
        "diagnosis": _diagnosisController.text.trim(), // ✅ Send the diagnosis
        "withdrawalDays": int.tryParse(_withdrawalDaysController.text.trim()) ?? 0,
        "medications": medicationsJson, // The main data is now an array
      };

      await _apiService.postData('prescriptions/add', body);
      
      if (!mounted) return;
      // ✅ THE FIX: Corrected the typo from M(context) to (context)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription submitted successfully!'), backgroundColor: Colors.green),
      );
      _formKey.currentState!.reset();
      _diagnosisController.clear(); // ✅ Clear the diagnosis field
      setState(() => _medications = [MedicationEntry()]);

    } catch (e) {
      print('Prescription Submission Failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString().split(":").last}'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
        backgroundColor: Colors.indigo,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            TextFormField(
              controller: _farmerIdController,
              decoration: const InputDecoration(labelText: 'Farmer ID (Required)'),
              validator: (value) => value!.isEmpty ? 'Enter Farmer ID' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _animalTagController,
              decoration: const InputDecoration(labelText: 'Animal Tag ID / Batch No.'),
              validator: (value) => value!.isEmpty ? 'Enter Animal ID' : null,
            ),
            const SizedBox(height: 12),
            // ✅ ADDED: The new diagnosis text field
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(labelText: 'Diagnosis (e.g., Mastitis)'),
              validator: (value) => value!.isEmpty ? 'Enter a diagnosis' : null,
            ),
            const SizedBox(height: 24),
            const Text('Medications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Divider(),
            
            // Dynamically build the list of medication fields
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                return _buildMedicationEntry(index);
              },
            ),
            
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Another Medication"),
              onPressed: _addMedication,
            ),
            const Divider(),
            
            const SizedBox(height: 12),
            TextFormField(
              controller: _withdrawalDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Withdrawal Days (e.g., 7 days)'),
              validator: (value) => value!.isEmpty ? 'Enter valid days' : null,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPrescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT PRESCRIPTION', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationEntry(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Medicine #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_medications.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => _removeMedication(index),
                  ),
              ],
            ),
            TextFormField(
              controller: _medications[index].nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
              validator: (value) => value!.isEmpty ? 'Enter Medication Name' : null,
            ),
            TextFormField(
              controller: _medications[index].dosageController,
              decoration: const InputDecoration(labelText: 'Dosage / Instructions'),
              validator: (value) => value!.isEmpty ? 'Enter Dosage' : null,
            ),
            const SizedBox(height: 10),
            const Text('Frequency:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFrequencyCheckbox(index, 'Morning', _medications[index].morning, (val) => setState(() => _medications[index].morning = val!)),
                _buildFrequencyCheckbox(index, 'Afternoon', _medications[index].afternoon, (val) => setState(() => _medications[index].afternoon = val!)),
                _buildFrequencyCheckbox(index, 'Night', _medications[index].night, (val) => setState(() => _medications[index].night = val!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyCheckbox(int index, String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(title),
      ],
    );
  }
}