import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;

  User? get user => _user;

  // ✅ FIX: Changed return type from Future<void> to Future<User>
  Future<User> login(String email, String password) async {
    try {
      final responseData = await _apiService.postData('users/login', {
        'email': email,
        'password': password,
      });

      _user = User.fromJson(responseData['user']);
      notifyListeners();
      
      // ✅ FIX: Added the return statement
      return _user!;
      
    } catch (e) {
      print('[AuthService] An error occurred during login: $e');
      rethrow;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}