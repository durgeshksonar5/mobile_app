import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive local preferences storage (user profile cache, offline bids mirror).
class PreferencesService {
  static const String _keyAuthUser = 'auth_user';
  static const String _keyMyBids = 'my_bids';

  Future<void> saveUser(Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthUser, jsonEncode(userMap));
  }

  Future<void> saveUserProfile(Map<String, dynamic> userMap) async =>
      saveUser(userMap);

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyAuthUser);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async => getUser();

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthUser);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> saveLocalBid(Map<String, dynamic> bidMap) async {
    final prefs = await SharedPreferences.getInstance();
    final bids = await getLocalBids();
    bids.insert(0, bidMap);
    await prefs.setString(_keyMyBids, jsonEncode(bids));
  }

  Future<List<Map<String, dynamic>>> getLocalBids() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyMyBids);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearLocalBids() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMyBids);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
