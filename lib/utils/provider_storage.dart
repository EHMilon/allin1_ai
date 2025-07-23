import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:shared_preferences/shared_preferences.dart';

const _kProvidersKey = 'ai_providers';

class ProviderStorage {
  /// Loads the stored list, or null if not yet stored.
  static Future<List<Map<String, dynamic>>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kProvidersKey);
      if (jsonString == null) return null;
      final List<dynamic> data = jsonDecode(jsonString);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      // If there's any error loading, return null to use defaults
      return null;
    }
  }

  /// Saves the list of providers.
  static Future<void> save(List<Map<String, dynamic>> providers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(providers);
      await prefs.setString(_kProvidersKey, jsonString);
    } catch (e) {
      // Handle save errors gracefully
      debugPrint('Error saving providers: $e');
    }
  }

  /// Clears all stored providers (useful for reset functionality)
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kProvidersKey);
    } catch (e) {
      debugPrint('Error clearing providers: $e');
    }
  }
}
