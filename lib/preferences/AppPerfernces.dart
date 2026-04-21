   import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_app/model/TechnicianProfile_Model.dart';

class Appperfernces {
  static const String _tokenKey = "auth_token";
  static const String _profileKey = "technician_profile";
  static const String _loginKey = "is_logged_in";
  static const String _fcmtokenkey ="fcmtoken";
    static const String _userServiceIdKey = "user_service_id";
    static const String _techIdKey = "technician_id";
    static const _lastSeenKey = "last_seen_notification_time";
    static Future<void> clearLastSeenNotificationTime(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("last_seen_$userId");
}
 /// ✅ SAVE TIME
  static Future<void> saveLastSeenNotificationTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenKey, time.toIso8601String());
  }

  /// ✅ GET TIME
  static Future<DateTime?> getLastSeenNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSeenKey);

    if (value == null) return null;

    return DateTime.tryParse(value);
  }
  // ==== TOKEN ====
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }


// ==== TECHNICIAN ID ====
static Future<void> saveTechId(String techId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_techIdKey, techId);
}

static Future<String?> getTechId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_techIdKey);
}

static Future<void> clearTechId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_techIdKey);
}
    // ==== USER SERVICE ID ====
  static Future<void> saveuserServiceId(String userServiceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userServiceIdKey, userServiceId);
  }

  static Future<String?> getuserServiceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userServiceIdKey);
  }

  static Future<void> clearUserServiceId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_userServiceIdKey);
}
// === FCM TOKEN ===
static Future<void> saveFcmToken(String fcmToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_fcmtokenkey, fcmToken);
}

static Future<String?> getFcmToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_fcmtokenkey);
}

    // ================== LOGIN FLAG ==================
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  // === PROFILE ===
  static Future<void> saveProfiledata(TechnicianProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(profile);
    await prefs.setString(_profileKey, profileJson);
  }

  static Future<TechnicianProfile?> getProfiledata() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_profileKey);

    if (profileString == null) return null;

    final Map<String, dynamic> jsonMap = json.decode(profileString);
    return TechnicianProfile.fromJson(jsonMap);
  }


  static Future<void> clearAll() async { 
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

  }
}
