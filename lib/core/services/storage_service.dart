import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final Map<String, dynamic> _memoryFallback = {};
  static SharedPreferences? _prefs;
  static bool _initialized = false;

  // Initialize storage service
  static Future<void> init() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      if (kDebugMode) {
        print('Storage service initialized (shared_preferences)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Storage init error: $e');
      }
      // Fall back to in-memory map so app still works
      _initialized = true;
    }
  }

  // String operations
  static Future<String?> getString(String key) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.getString(key);
    return _memoryFallback[key] as String?;
  }

  static Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.setString(key, value);
    _memoryFallback[key] = value;
    return true;
  }

  // Boolean operations
  static Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.getBool(key);
    return _memoryFallback[key] as bool?;
  }

  static Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.setBool(key, value);
    _memoryFallback[key] = value;
    return true;
  }

  // Integer operations
  static Future<int?> getInt(String key) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.getInt(key);
    return _memoryFallback[key] as int?;
  }

  static Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.setInt(key, value);
    _memoryFallback[key] = value;
    return true;
  }

  // Double operations
  static Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.getDouble(key);
    return _memoryFallback[key] as double?;
  }

  static Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.setDouble(key, value);
    _memoryFallback[key] = value;
    return true;
  }

  // List operations
  static Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.getStringList(key);
    final value = _memoryFallback[key];
    if (value is List) return value.cast<String>();
    return null;
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.setStringList(key, value);
    _memoryFallback[key] = value;
    return true;
  }

  // JSON operations
  static Future<Map<String, dynamic>?> getJson(String key) async {
    await _ensureInitialized();
    final value = _prefs != null ? _prefs!.getString(key) : _memoryFallback[key] as String?;
    if (value != null) {
      try {
        return json.decode(value) as Map<String, dynamic>;
      } catch (e) {
        if (kDebugMode) {
          print('JSON decode error for key $key: $e');
        }
      }
    }
    return null;
  }

  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    try {
      final encoded = json.encode(value);
      if (_prefs != null) return _prefs!.setString(key, encoded);
      _memoryFallback[key] = encoded;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('JSON encode error for key $key: $e');
      }
      return false;
    }
  }

  // Remove operations
  static Future<bool> remove(String key) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.remove(key);
    _memoryFallback.remove(key);
    return true;
  }

  static Future<bool> clear() async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.clear();
    _memoryFallback.clear();
    return true;
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.containsKey(key);
    return _memoryFallback.containsKey(key);
  }

  // Get all keys
  static Future<Set<String>> getKeys() async {
    await _ensureInitialized();
    if (_prefs != null) return _prefs!.getKeys();
    return _memoryFallback.keys.toSet();
  }

  // Private methods
  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  // User preferences
  static Future<bool> getNotificationsEnabled() async {
    return await getBool('notifications_enabled') ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await setBool('notifications_enabled', enabled);
  }

  static Future<bool> getBiometricsEnabled() async {
    return await getBool('biometrics_enabled') ?? false;
  }

  static Future<void> setBiometricsEnabled(bool enabled) async {
    await setBool('biometrics_enabled', enabled);
  }

  static Future<String> getThemeMode() async {
    return await getString('theme_mode') ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    await setString('theme_mode', mode);
  }

  static Future<String> getLanguage() async {
    return await getString('language') ?? 'en';
  }

  static Future<void> setLanguage(String language) async {
    await setString('language', language);
  }

  // App state
  static Future<bool> isFirstLaunch() async {
    return !(await getBool('has_launched') ?? false);
  }

  static Future<void> setHasLaunched() async {
    await setBool('has_launched', true);
  }

  static Future<bool> hasCompletedOnboarding() async {
    return await getBool('onboarding_completed') ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    await setBool('onboarding_completed', true);
  }

  // Cache management
  static Future<void> clearCache() async {
    final keysToKeep = {
      'auth_token',
      'refresh_token',
      'user_data',
      'has_launched',
      'onboarding_completed',
      'notifications_enabled',
      'biometrics_enabled',
      'theme_mode',
      'language',
    };

    final allKeys = await getKeys();
    for (final key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await remove(key);
      }
    }
  }
}
