import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // We need this to call the API
import 'package:intl/intl.dart'; // For formatting dates nicely

// A model to structure our appointment data
class Appointment {
  final String farmerName;
  final String animalType;
  final DateTime appointmentDate;
  final String reason;
  final String status;

  Appointment({
    required this.farmerName,
    required this.animalType,
    required this.appointmentDate,
    required this.reason,
    required this.status,
  });

  // Factory constructor to parse the JSON from the server
  factory Appointment.fromJson(Map<String, dynamic> json) {
    // This logic handles the specific way Firestore sends timestamp data
    final timestamp = json['appointmentDate'] as Map<String, dynamic>? ?? {};
    final seconds = timestamp['_seconds'] as int? ?? 0;

    return Appointment(
      farmerName: json['farmerName'] as String? ?? 'N/A',
      animalType: json['animalType'] as String? ?? 'N/A',
      appointmentDate: DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
      reason: json['reason'] as String? ?? 'No reason provided',
      status: json['status'] as String? ?? 'Unknown',
    );
  }
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching appointments as soon as the screen loads
    _appointmentsFuture = _fetchAppointments();
  }

  // Function to call the API and parse the data
  Future<List<Appointment>> _fetchAppointments() async {
    try {
      // The endpoint matches the one we created on the server
      final List<dynamic> responseData = await _apiService.getData('appointments');
      if (!mounted) return [];
      return responseData.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load appointments: $e');
      if (!mounted) return [];
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: $e')),
      );
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Appointments'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          // 1. Show a loading spinner while data is fetching
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Show an error message if something went wrong
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // 3. Show a message if there are no appointments
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No appointments found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 4. Display the list of appointments
          final appointments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.indigo, size: 40),
                  title: Text(
                    appointment.farmerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${appointment.animalType} - ${appointment.reason}\n'
                    '${DateFormat.yMMMd().format(appointment.appointmentDate)}',
                  ),
                  trailing: Text(
                    appointment.status,
                    style: TextStyle(
                      color: appointment.status == 'Scheduled' ? Colors.blueAccent : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
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

