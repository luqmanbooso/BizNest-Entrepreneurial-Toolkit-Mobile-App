import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_data_service.dart';
import 'api_service.dart';
import 'firebase_auth_service.dart' as fb;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user data
  static Map<String, dynamic>? _currentUser;
  static String? _currentToken;

  // Authentication state
  static bool get isAuthenticated => _auth.currentUser != null && _currentToken != null;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get currentToken => _currentToken;

  // Initialize auth service
  static Future<void> init() async {
    try {
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          _currentToken = await user.getIdToken();
          await _loadUserData();
        } else {
          _currentToken = null;
          _currentUser = null;
        }
      });

      // Check current user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _currentToken = await currentUser.getIdToken();
        await _loadUserData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth init error: $e');
      }
      await logout();
    }
  }

  // Load user data from Firebase
  static Future<void> _loadUserData() async {
    try {
      final userData = await FirebaseDataService.getJson(_userKey);
      if (userData != null) {
        _currentUser = userData;
      } else {
        // Create user data from Firebase Auth and Firestore
        final user = _auth.currentUser;
        if (user != null) {
          // Try to get name from Firestore first
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final firestoreName = userDoc.data()?['name'];
          
          _currentUser = {
            'id': user.uid,
            'name': firestoreName ?? user.displayName ?? user.email ?? 'User',
            'email': user.email ?? '',
            'avatar': user.photoURL ?? '',
            'role': 'entrepreneur',
            'company': '',
            'is_verified': user.emailVerified,
          };
          await FirebaseDataService.setJson(_userKey, _currentUser!);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    if (_currentToken == null) {
      await init();
    }
    return _currentToken != null && _currentUser != null;
  }

  // Login user
  static Future<AuthResult> login(String email, String password) async {
    try {
      // Try Firebase first
      final fbResult = await fb.FirebaseAuthService.login(email, password);
      if (fbResult.success) {
        await _saveAuthData(
          fbResult.token ?? 'fb_token',
          fbResult.refreshToken ?? 'fb_refresh',
          fbResult.user ?? {},
        );
        return AuthResult.success(message: 'Login successful', user: fbResult.user);
      }

      // Fallback to mock ApiService
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
        'device_type': 'mobile',
        'app_version': '1.0.0',
      }, requiresAuth: false);

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
      // Try Firebase first
      final fbResult = await fb.FirebaseAuthService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      if (fbResult.success) {
        await _saveAuthData(
          fbResult.token ?? 'fb_token',
          fbResult.refreshToken ?? 'fb_refresh',
          fbResult.user ?? {},
        );
        return AuthResult.success(message: 'Registration successful', user: fbResult.user);
      }

      // Fallback to mock ApiService
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'company': company ?? '',
        'role': role ?? 'entrepreneur',
        'device_type': 'mobile',
        'app_version': '1.0.0',
      }, requiresAuth: false);

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
        print('Registration error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Logout user
  static Future<void> logout() async {
    // Since we primarily use Firebase Auth, skip API logout to avoid authentication errors
    // Make logout completely fail-safe
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _auth.signOut();
      }
    } catch (e) {
      // Firebase sign out failed, but continue with clearing local data
      if (kDebugMode) {
        print('Firebase sign out error: $e');
      }
    }

    // Always clear local data, even if Firebase sign out fails
    try {
      await _clearAuthData();
    } catch (e) {
      if (kDebugMode) {
        print('Clear auth data error: $e');
      }
    }
  }

  // Refresh token
  static Future<AuthResult> refreshToken() async {
    try {
      final refreshToken = await FirebaseDataService.getString(_refreshTokenKey);
      if (refreshToken == null) {
        return AuthResult.error(message: 'No refresh token available');
      }

      final response = await ApiService.post('/auth/refresh', {
        'refresh_token': refreshToken,
      }, requiresAuth: false);

      if (response['success']) {
        final newToken = response['data']['token'];
        final newRefreshToken = response['data']['refresh_token'];

        await FirebaseDataService.setString(_tokenKey, newToken);
        await FirebaseDataService.setString(_refreshTokenKey, newRefreshToken);
        _currentToken = newToken;

        return AuthResult.success(
          message: 'Token refreshed successfully',
        );
      } else {
        await logout();
        return AuthResult.error(
          message: 'Token refresh failed. Please login again.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      await logout();
      return AuthResult.error(
        message: 'Token refresh failed. Please login again.',
      );
    }
  }

  // Forgot password
  static Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': email,
      }, requiresAuth: false);

      if (response['success']) {
        return AuthResult.success(
          message: response['message'] ?? 'Password reset email sent',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Failed to send reset email',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Forgot password error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please try again.',
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
      }, requiresAuth: false);

      if (response['success']) {
        return AuthResult.success(
          message: response['message'] ?? 'Password reset successfully',
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
        message: 'Network error. Please try again.',
      );
    }
  }

  // Verify email
  static Future<AuthResult> verifyEmail(String token) async {
    try {
      final response = await ApiService.post('/auth/verify-email', {
        'token': token,
      }, requiresAuth: false);

      if (response['success']) {
        return AuthResult.success(
          message: response['message'] ?? 'Email verified successfully',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Email verification failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Email verification error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please try again.',
      );
    }
  }

  // Update user profile
  static Future<AuthResult> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.error(message: 'No user logged in');
      }

      // Update Firestore user document with all provided updates
      final userUpdates = <String, dynamic>{};

      // Handle name updates (combine firstName and lastName if provided)
      if (updates.containsKey('firstName') && updates.containsKey('lastName')) {
        final fullName = '${updates['firstName']} ${updates['lastName']}';
        userUpdates['name'] = fullName;
        await user.updateDisplayName(fullName);
      } else if (updates.containsKey('name')) {
        userUpdates['name'] = updates['name'];
        await user.updateDisplayName(updates['name']);
      }

      // Add all other updates to Firestore
      updates.forEach((key, value) {
        if (key != 'name' && key != 'firstName' && key != 'lastName') {
          userUpdates[key] = value;
        }
      });

      if (userUpdates.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userUpdates, SetOptions(merge: true));
      }

      // Update local user data
      final updatedUser = {
        ..._currentUser ?? {},
        ...updates,
      };
      _currentUser = updatedUser;
      await FirebaseDataService.setJson(_userKey, updatedUser);

      return AuthResult.success(
        user: updatedUser,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      print('Profile update error: $e');
      return AuthResult.error(
        message: 'Failed to update profile. Please try again.',
      );
    }
  }

  // Change password
  static Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post('/user/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (response['success']) {
        return AuthResult.success(
          message: response['message'] ?? 'Password changed successfully',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Password change failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Password change error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please try again.',
      );
    }
  }

  // Delete account
  static Future<AuthResult> deleteAccount(String password) async {
    try {
      final response = await ApiService.delete('/user/account', data: {
        'password': password,
      });

      if (response['success']) {
        await logout();
        return AuthResult.success(
          message: response['message'] ?? 'Account deleted successfully',
        );
      } else {
        return AuthResult.error(
          message: response['message'] ?? 'Account deletion failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Account deletion error: $e');
      }
      return AuthResult.error(
        message: 'Network error. Please try again.',
      );
    }
  }

  // Save authentication data
  static Future<void> _saveAuthData(
    String token,
    String refreshToken,
    Map<String, dynamic> user,
  ) async {
    _currentToken = token;
    _currentUser = user;

    await Future.wait([
      FirebaseDataService.setString(_tokenKey, token),
      FirebaseDataService.setString(_refreshTokenKey, refreshToken),
      FirebaseDataService.setJson(_userKey, user),
    ]);
  }

  // Clear authentication data
  static Future<void> _clearAuthData() async {
    _currentToken = null;
    _currentUser = null;

    await Future.wait([
      FirebaseDataService.remove(_tokenKey),
      FirebaseDataService.remove(_refreshTokenKey),
      FirebaseDataService.remove(_userKey),
    ]);
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await ApiService.get('/user/profile');
      if (response['success']) {
        _currentUser = response['data'];
        await FirebaseDataService.setJson(_userKey, _currentUser!);
        return _currentUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get profile error: $e');
      }
    }
    return null;
  }

  // Check if email is available
  static Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await ApiService.get('/auth/check-email', queryParams: {
        'email': email,
      });
      return response['success'] && response['data']['available'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Email check error: $e');
      }
      return false;
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>?> getUserStats() async {
    if (!isAuthenticated) return null;

    try {
      final response = await ApiService.get('/user/stats');
      if (response['success']) {
        return response['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get stats error: $e');
      }
    }
    return null;
  }
}

// AuthResult class
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
    required String message,
    Map<String, dynamic>? user,
  }) {
    return AuthResult._(
      success: true,
      message: message,
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

  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, user: $user, error: $error)';
  }
}