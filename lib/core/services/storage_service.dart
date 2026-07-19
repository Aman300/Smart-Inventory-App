import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _hostKey = 'api_host';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Auth Token operations
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // Host configuration operations
  Future<void> saveHost(String host) async {
    await _prefs.setString(_hostKey, host);
  }

  String getHost() {
    return _prefs.getString(_hostKey) ?? '72.60.97.186';
  }
}
