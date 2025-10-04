class AuthService {
  Future<bool> login(String username, String password) async {
    // Replace with real Firebase/Backend login
    if (username == "farmer" && password == "123") {
      return true;
    } else if (username == "vet" && password == "123") {
      return true;
    }
    return false;
  }
}
