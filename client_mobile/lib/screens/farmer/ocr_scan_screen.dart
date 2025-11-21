import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = false;
  Uint8List? _imageBytes;
  String _statusMessage = 'Scan a medicine label to get voice instructions.';

  Future<void> _takePictureAndScan() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? farmerId = authService.user?.id;
    
    if (farmerId == null) {
      _showError("Authentication error: Please log in again.");
      return;
    }

    setState(() {
      _imageBytes = bytes;
      _isLoading = true;
      _statusMessage = 'Analyzing image and prescription...';
    });

    try {
      String base64Image = base64Encode(bytes);

      final body = {
        'image': base64Image,
        'farmerId': farmerId, // ✅ FIX 2: PASS THE DYNAMIC ID TO THE SERVER
      };

      // ✅ Call the new, powerful endpoint
     final response = await _apiService.postData('prescriptions/scan-and-speak', body);
      
      if (mounted && response['audio'] != null) {
        setState(() => _statusMessage = 'Playing instructions...');
        
        // ✅ Decode the audio and play it
        final audioBytes = base64Decode(response['audio']);
        await _audioPlayer.play(BytesSource(audioBytes));
        
        // Listen for when playback is complete
        _audioPlayer.onPlayerComplete.first.then((_) {
          if (mounted) setState(() => _statusMessage = 'Scan complete. Ready for next scan.');
        });
      } else {
        throw Exception('No audio data received from server.');
      }
    } catch (e) {
      print("Scan-to-Speak Failed: $e");
      _showError("Error: Could not process image. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  void _showError(String message) {
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
     }
  }
    

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Listen'),
        backgroundColor: Colors.green.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black12,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _imageBytes == null
                  ? const Center(child: Icon(Icons.image_search, size: 60, color: Colors.grey))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera & Scan'),
              onPressed: _isLoading ? null : _takePictureAndScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 32),
            // ✅ Status Display Area
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}