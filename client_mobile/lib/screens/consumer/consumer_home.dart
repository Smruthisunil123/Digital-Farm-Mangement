import 'package:flutter/material.dart';

class ConsumerHome extends StatefulWidget {
  const ConsumerHome({super.key});

  @override
  State<ConsumerHome> createState() => _ConsumerHomeState();
}

class _ConsumerHomeState extends State<ConsumerHome> {
  // This is the DUMMY ID your app will "read"
  final String _dummyBatchId = "BATCH-992-ORG";
  
  final TextEditingController _batchIdController = TextEditingController();
  bool _isScanning = false;

  // ---------------------------------------------------------
  // MOCK SCAN LOGIC
  // ---------------------------------------------------------
  void _startMockScan() async {
    setState(() {
      _isScanning = true;
      // Clear text field to simulate reading fresh
      _batchIdController.clear(); 
    });

    // 1. Simulate camera delay (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      // 2. The scanner "finds" the dummy ID
      _batchIdController.text = _dummyBatchId; 
    });

    // 3. Show success message briefly
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("QR Code Detected: $_dummyBatchId"),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 1000),
      ),
    );

    // 4. Wait a moment then navigate to results
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductResultScreen(batchId: _dummyBatchId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      appBar: AppBar(
        title: const Text("Consumer Verification"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // --- THE "PRODUCT LABEL" CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text("SCAN THIS LABEL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                    const SizedBox(height: 20),
                    
                    // QR Code Image
                    Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=$_dummyBatchId',
                      height: 160,
                      width: 160,
                      errorBuilder: (ctx, err, _) => const Icon(Icons.qr_code_2, size: 160),
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    // VISIBLE BATCH ID (The "Sticker")
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        _dummyBatchId, 
                        style: const TextStyle(
                          fontFamily: 'Courier', // Monospace font looks like a printed code
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text("Product Batch ID", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // --- SCAN BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startMockScan,
                  icon: _isScanning ? const SizedBox.shrink() : const Icon(Icons.camera_alt),
                  label: _isScanning 
                      ? const Text("Reading QR Code...", style: TextStyle(fontSize: 16))
                      : const Text("Start Camera Scan", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              
              // Divider
              Row(children: [
                Expanded(child: Divider(color: Colors.grey[300])), 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("MANUAL ENTRY", style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                ), 
                Expanded(child: Divider(color: Colors.grey[300]))
              ]),
              
              const SizedBox(height: 20),

              // --- MANUAL TEXT FIELD ---
              TextField(
                controller: _batchIdController,
                decoration: InputDecoration(
                  labelText: "Type Batch ID",
                  hintText: _dummyBatchId, // Hint shows the dummy ID too
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_circle_right, color: Colors.orange, size: 32),
                    onPressed: () {
                      if(_batchIdController.text.isNotEmpty) {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ProductResultScreen(batchId: _batchIdController.text)));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// RESULT SCREEN (Stays mostly the same)
// ---------------------------------------------------------
class ProductResultScreen extends StatelessWidget {
  final String batchId;
  const ProductResultScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Verification Result"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Success Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[50],
              ),
              child: const Icon(Icons.verified_user, size: 60, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Text("Verified Safe", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Text("Batch ID: $batchId", style: TextStyle(color: Colors.grey[600], fontSize: 18, fontFamily: 'Courier')),
            
            const SizedBox(height: 40),

            // Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16), 
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
              ),
              child: const Column(
                children: [
                  _DetailRow(icon: Icons.agriculture, title: "Farm Name", value: "Green Valley Organics"),
                  Divider(height: 30),
                  _DetailRow(icon: Icons.location_on, title: "Origin", value: "Karnataka, District 4"),
                  Divider(height: 30),
                  _DetailRow(icon: Icons.calendar_today, title: "Harvest Date", value: "2023-10-28"),
                  Divider(height: 30),
                  _DetailRow(icon: Icons.science, title: "Antibiotic Residue", value: "PASSED (None Detected)"),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, 
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context), 
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.orange)),
                child: const Text("Scan Another Product", style: TextStyle(color: Colors.orange)),
              )
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _DetailRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.green[700], size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        )
      ],
    );
  }
}