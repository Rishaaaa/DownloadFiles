import 'package:shared_preferences/shared_preferences.dart';
import 'key_finder_stub.dart';

class MobileKeyFinder implements KeyFinder {
  @override
  String getKeyValue(String key) {
    return "I am from mobile shared preferences";
  }

  @override
  void setKeyValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

KeyFinder getKeyFinder() => MobileKeyFinder();
