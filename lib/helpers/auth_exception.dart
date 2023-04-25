
class AuthException implements Exception {
  String message;
  AuthException(this.message);

  @override
  String toString() {
    return message;
  }
}
