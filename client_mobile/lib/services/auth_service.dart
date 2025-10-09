import 'api_service.dart';
import '../models/user.dart'; // Make sure the path to your User model is correct

class AuthService {
  final ApiService _apiService = ApiService();

  /// Attempts to log in a user and returns the full User object if successful.
  Future<User> login(String email, String password) async {
    // 1. Print when the function starts for debugging
    print('[AuthService] Attempting to log in...');

    try {
      // 2. Print the data we are about to send
      print('[AuthService] Calling postData with endpoint: users/login');
      print('[AuthService] Email: $email');

      // 3. Call the CORRECT endpoint with the CORRECT field name ('email')
      final responseData = await _apiService.postData('users/login', {
        'email': email, // The server expects 'email', not 'username'
        'password': password,
      });

      // 4. Print if the API call was successful
      print('[AuthService] API call successful. Response: $responseData');

      // 5. Return the full User object
      // The server response likely has the user object nested under a 'user' key
      return User.fromJson(responseData['user']);

    } catch (e) {
      // 6. Print the exact error if something goes wrong
      print('[AuthService] An error occurred during login: $e');
      // Rethrow the exception to be handled by the UI
      rethrow;
    }
  }

  /// Placeholder for registration logic (calls the backend).
  Future<void> register(Map<String, dynamic> userData) async {
    // Note: The register endpoint might be just 'users/register'
    final endpoint = 'users/register';
    await _apiService.postData(endpoint, userData);
  }
}