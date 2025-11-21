import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _govtIdController = TextEditingController();

  String _role = 'farmer'; // Default role
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _apiService.postData('users/register', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'name': _nameController.text.trim(),
        'role': _role,
        'govtId': _govtIdController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please login.')));
      Navigator.pop(context); // Go back to login
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: Colors.green.shade800),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController, 
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 15),
              
              // ✅ NEW FIELD: Government ID
              TextFormField(
                controller: _govtIdController, 
                decoration: const InputDecoration(labelText: 'Government Farmer ID / Kissan ID', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter Govt ID' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController, 
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => v!.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController, 
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), 
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Password must be 6+ chars' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                  DropdownMenuItem(value: 'vet', child: Text('Veterinarian')),
                  DropdownMenuItem(value: 'dealer', child: Text('Dealer / Buyer')),
                  DropdownMenuItem(value: 'authority', child: Text('Authority (FSSAI)')),
                ],
                onChanged: (val) => setState(() => _role = val!),
                decoration: const InputDecoration(labelText: 'I am a...', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _register, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIGN UP', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}