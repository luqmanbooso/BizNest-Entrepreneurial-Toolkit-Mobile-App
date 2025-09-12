import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

  // Current user data
  static Map<String, dynamic>? _currentUser;
  static String? _currentToken;

  // Authentication state
  static bool get isAuthenticated => _currentToken != null;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get currentToken => _currentToken;

  // Initialize auth service
  static Future<void> init() async {
    try {
      _currentToken = await StorageService.getString(_tokenKey);
      final userData = await StorageService.getString(_userKey);

      if (userData != null) {
        _currentUser = json.decode(userData);
      }

      // Validate token if exists
      if (_currentToken != null) {
        final isValid = await _validateToken();
        if (!isValid) {
          await logout();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth init error: $e');
      }
      await logout();
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    if (_currentToken == null) {
      await init();
    }
    return _currentToken != null && _currentUser != null;
  }

  // Login with email and password
  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
        'device_type': 'mobile',
        'app_version': '1.0.0',
      });

      if (response['success']) {
        final token = response['data']['token'];
        final refreshToken = response['data']['refresh_token'];
        final user = response['data']['user'];

        await _saveAuthData(token, refreshToken, user);

        return AuthResult.success(
          user: user,
          message: response['message'] ?? 'Login successful',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Register new user
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? company,
    String? role,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'company': company,
        'role': role,
        'device_type': 'mobile',
        'app_version': '1.0.0',
      });

      if (response['success']) {
        final token = response['data']['token'];
        final refreshToken = response['data']['refresh_token'];
        final user = response['data']['user'];

        await _saveAuthData(token, refreshToken, user);

        return AuthResult.success(
          user: user,
          message: response['message'] ?? 'Registration successful',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Register error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Social login (Google, Apple, etc.)
  static Future<AuthResult> socialLogin({
    required String provider,
    required String token,
  }) async {
    try {
      final response = await ApiService.post('/auth/social', {
        'provider': provider,
        'token': token,
        'device_type': 'mobile',
        'app_version': '1.0.0',
      });

      if (response['success']) {
        final authToken = response['data']['token'];
        final refreshToken = response['data']['refresh_token'];
        final user = response['data']['user'];

        await _saveAuthData(authToken, refreshToken, user);

        return AuthResult.success(
          user: user,
          message: response['message'] ?? 'Login successful',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Social login failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Social login error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      if (_currentToken != null) {
        await ApiService.post('/auth/logout', {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout API error: $e');
      }
    } finally {
      await _clearAuthData();
    }
  }

  // Refresh token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getString(_refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await ApiService.post('/auth/refresh', {
        'refresh_token': refreshToken,
      });

      if (response['success']) {
        final newToken = response['data']['token'];
        final newRefreshToken = response['data']['refresh_token'];

        await StorageService.setString(_tokenKey, newToken);
        await StorageService.setString(_refreshTokenKey, newRefreshToken);

        _currentToken = newToken;
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token error: $e');
      }
    }
    return false;
  }

  // Forgot password
  static Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': email,
      });

      if (response['success']) {
        return AuthResult.success(
          message: response['message'] ?? 'Reset link sent to your email',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Failed to send reset link',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Forgot password error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Reset password
  static Future<AuthResult> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/auth/reset-password', {
        'token': token,
        'password': password,
      });

      if (response['success']) {
        return AuthResult.success(
          message: response['message'] ?? 'Password reset successful',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Password reset failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Update user profile
  static Future<AuthResult> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.put('/user/profile', userData);

      if (response['success']) {
        final updatedUser = response['data']['user'];
        await StorageService.setString(_userKey, json.encode(updatedUser));
        _currentUser = updatedUser;

        return AuthResult.success(
          user: updatedUser,
          message: response['message'] ?? 'Profile updated successfully',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Profile update failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Private methods
  static Future<void> _saveAuthData(
    String token,
    String refreshToken,
    Map<String, dynamic> user,
  ) async {
    await StorageService.setString(_tokenKey, token);
    await StorageService.setString(_refreshTokenKey, refreshToken);
    await StorageService.setString(_userKey, json.encode(user));

    _currentToken = token;
    _currentUser = user;
  }

  static Future<void> _clearAuthData() async {
    await StorageService.remove(_tokenKey);
    await StorageService.remove(_refreshTokenKey);
    await StorageService.remove(_userKey);

    _currentToken = null;
    _currentUser = null;
  }

  static Future<bool> _validateToken() async {
    try {
      final response = await ApiService.get('/auth/validate');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;
  final String? error;

  AuthResult._({
    required this.success,
    required this.message,
    this.user,
    this.error,
  });

  factory AuthResult.success({
    Map<String, dynamic>? user,
    String? message,
  }) {
    return AuthResult._(
      success: true,
      message: message ?? 'Operation successful',
      user: user,
    );
  }

  factory AuthResult.error({
    required String message,
    String? error,
  }) {
    return AuthResult._(
      success: false,
      message: message,
      error: error,
    );
  }
}
