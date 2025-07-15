import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _cookiePrefix = 'ai_cookies_';
  
  static Future<void> saveCookies(String providerName, List<iaw.Cookie> cookies) async {
    final prefs = await SharedPreferences.getInstance();
    final cookieStrings = cookies.map((cookie) => cookie.toString()).toList();
    await prefs.setStringList('$_cookiePrefix$providerName', cookieStrings);
  }
  
  static Future<List<iaw.Cookie>> loadCookies(String providerName) async {
    final prefs = await SharedPreferences.getInstance();
    final cookieStrings = prefs.getStringList('$_cookiePrefix$providerName') ?? [];
    
    List<iaw.Cookie> cookies = [];
    for (String cookieString in cookieStrings) {
      try {
        // Parse cookie string back to Cookie object
        // This is a simplified parser - you might need a more robust one
        final parts = cookieString.split(';');
        if (parts.isNotEmpty) {
          final nameValue = parts[0].split('=');
          if (nameValue.length == 2) {
            cookies.add(iaw.Cookie(
              name: nameValue[0].trim(),
              value: nameValue[1].trim(),
            ));
          }
        }
      } catch (e) {
        debugPrint('Error parsing cookie: $e');
      }
    }
    
    return cookies;
  }
  
  static Future<void> clearCookies(String providerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cookiePrefix$providerName');
  }
  
  static Future<void> clearAllCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cookiePrefix));
    for (String key in keys) {
      await prefs.remove(key);
    }
  }
}