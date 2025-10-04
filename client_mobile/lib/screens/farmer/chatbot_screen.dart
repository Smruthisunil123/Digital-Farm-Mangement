import 'package:flutter/material.dart';

// Placeholder for the Farmer's Chatbot interface.
class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Assistant Chatbot'),
        backgroundColor: Colors.indigo,
      ),
      body: const Center(
        child: Text(
          'Chatbot UI goes here!',
          style: TextStyle(fontSize: 20, color: Colors.indigo),
        ),
      ),
    );
  }
}
