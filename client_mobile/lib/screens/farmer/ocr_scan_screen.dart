import 'dart:convert';
import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

/// A screen for the farmer to scan medicine labels using the device camera.
class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  // We store the image data in memory as bytes, which works on all platforms
  Uint8List? _imageBytes;
  String _ocrResult = '';

  // Function to open the camera, take a picture, and process it
  Future<void> _takePictureAndScan() async {
    // 1. Pick an image using the camera
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Compress image to reduce upload size
    );

    if (image == null) return; // User cancelled the camera

    // ✅ THE FIX: Read the image data into memory as a byte list (Uint8List)
    final bytes = await image.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _isLoading = true;
      _ocrResult = 'Processing image...';
    });

    try {
      // 2. Convert image bytes to a base64 encoded string
      String base64Image = base64Encode(bytes);

      // 3. Send the base64 string to the server
      final response = await _apiService.postData('prescriptions/scan/ocr', {'image': base64Image});
      
      if(mounted) {
        setState(() {
          _ocrResult = response['text'] ?? 'No text could be extracted from the image.';
        });
      }

    } catch (e) {
      print("OCR Scan Failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error processing image. Please try again.'), backgroundColor: Colors.red),
        );
        setState(() {
          _ocrResult = '';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medicine Label'),
        backgroundColor: Colors.green.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Box
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black12,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _imageBytes == null
                  ? const Center(child: Icon(Icons.image_search, size: 60, color: Colors.grey))
                  // ✅ THE FIX: Use the web-compatible Image.memory widget to display the preview
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
            const SizedBox(height: 24),

            // Scan Button
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
            const SizedBox(height: 24),

            // Results Area
            const Text('Extracted Text:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: SelectableText( // Use SelectableText to allow copying
                          _ocrResult.isEmpty ? 'Scan a medicine label to see the text here.' : _ocrResult,
                          style: TextStyle(fontSize: 16, color: _ocrResult.isEmpty ? Colors.grey : Colors.black),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ```eof

// ### **Summary of the Fix**

// 1.  **Storing Image Data:** Instead of trying to use a `File` object (which doesn't work on the web), we now read the image data directly into memory as a list of bytes (`Uint8List`).
// 2.  **Displaying the Image:** We now use the `Image.memory()` widget to display the preview. This widget is specifically designed to work on all platforms, including the web.

// After you replace the code in `ocr_scan_screen.dart` and save the file, your app will hot-reload, and the OCR feature will be fully functional on the web.