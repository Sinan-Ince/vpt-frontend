import 'package:shared_preferences/shared_preferences.dart';

// Girişten sonra kullanıcının userId'sini cihazda kalıcı olarak saklar.
// Backend'de token/session mekanizması yok (sadece e-posta+şifre doğrulaması),
// bu yüzden burada da sadece userId saklanıyor, bir token değil.
class SessionStore {
  static const String _userIdKey = 'userId';

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}
