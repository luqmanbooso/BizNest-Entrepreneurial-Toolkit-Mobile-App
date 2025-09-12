import 'dart:convert';
import 'package:flutter/foundation.dart';

class StorageService {
  static final Map<String, dynamic> _storage = {};
  static bool _initialized = false;

  // Initialize storage service
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // In a real app, you would use shared_preferences or secure_storage
      // For this demo, we'll use in-memory storage
      _initialized = true;

      if (kDebugMode) {
        print('Storage service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Storage init error: $e');
      }
    }
  }

  // String operations
  static Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _storage[key] as String?;
  }

  static Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    _storage[key] = value;
    return true;
  }

  // Boolean operations
  static Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _storage[key] as bool?;
  }

  static Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    _storage[key] = value;
    return true;
  }

  // Integer operations
  static Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _storage[key] as int?;
  }

  static Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    _storage[key] = value;
    return true;
  }

  // Double operations
  static Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _storage[key] as double?;
  }

  static Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    _storage[key] = value;
    return true;
  }

  // List operations
  static Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    final value = _storage[key];
    if (value is List) {
      return value.cast<String>();
    }
    return null;
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    _storage[key] = value;
    return true;
  }

  // JSON operations
  static Future<Map<String, dynamic>?> getJson(String key) async {
    await _ensureInitialized();
    final value = _storage[key] as String?;
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
      _storage[key] = json.encode(value);
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
    _storage.remove(key);
    return true;
  }

  static Future<bool> clear() async {
    await _ensureInitialized();
    _storage.clear();
    return true;
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _storage.containsKey(key);
  }

  // Get all keys
  static Future<Set<String>> getKeys() async {
    await _ensureInitialized();
    return _storage.keys.toSet();
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
