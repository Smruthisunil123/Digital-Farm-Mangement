import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // To submit data

/// A form for Veterinarians to submit a new prescription record.
class PrescriptionFormScreen extends StatefulWidget {
  const PrescriptionFormScreen({super.key});

  @override
  State<PrescriptionFormScreen> createState() => _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState extends State<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Form controllers and state
  final TextEditingController _farmerIdController = TextEditingController();
  final TextEditingController _animalTagController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _withdrawalDaysController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _farmerIdController.dispose();
    _animalTagController.dispose();
    _medicationController.dispose();
    _dosageController.dispose();
    _withdrawalDaysController.dispose();
    super.dispose();
  }

  // --- Submission Logic ---
  Future<void> _submitPrescription() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }

    setState(() {
      _isLoading = true;
    });

    try {
      const String dummyVetId = "vet_e45d4ed514f2"; // Placeholder

      final body = {
        "vetId": dummyVetId,
        "farmerId": _farmerIdController.text.trim(),
        "animalTagId": _animalTagController.text.trim(),
        "medicationName": _medicationController.text.trim(),
        "dosage": _dosageController.text.trim(),
        "withdrawalDays": int.tryParse(_withdrawalDaysController.text.trim()) ?? 0,
      };

      await _apiService.postData('prescriptions/add', body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Prescription submitted successfully!'),
            backgroundColor: Colors.green),
      );

      _formKey.currentState!.reset();

    } catch (e) {
      print('Prescription Submission Failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Submission failed: ${e.toString().split(":").last}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                const Text(
                  'Record New Medication',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 20),
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
                TextFormField(
                  controller: _medicationController,
                  decoration: const InputDecoration(labelText: 'Medication Name'),
                  validator: (value) => value!.isEmpty ? 'Enter Medication Name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage / Instructions'),
                  validator: (value) => value!.isEmpty ? 'Enter Dosage' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _withdrawalDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Withdrawal Days (e.g., 7 days)'),
                  validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Enter valid days' : null,
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
                      : const Text(
                          'SUBMIT PRESCRIPTION',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

