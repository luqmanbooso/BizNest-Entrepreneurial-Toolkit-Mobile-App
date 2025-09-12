import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = kDebugMode
      ? 'http://localhost:3000/api' // Development
      : 'https://api.biznests.com/v1'; // Production

  static const Duration timeoutDuration = Duration(seconds: 30);

  // HTTP Headers
  static Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': '1.0.0',
        'X-Platform': 'mobile',
      };

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    return _makeRequest('GET', endpoint,
        queryParams: queryParams, requiresAuth: requiresAuth);
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    return _makeRequest('POST', endpoint,
        data: data, requiresAuth: requiresAuth);
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    return _makeRequest('PUT', endpoint,
        data: data, requiresAuth: requiresAuth);
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
  }) async {
    return _makeRequest('DELETE', endpoint,
        data: data, requiresAuth: requiresAuth);
  }

  // Main request handler
  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Handle authentication endpoints with mock data
      if (endpoint.startsWith('/auth/')) {
        return _handleAuthEndpoint(method, endpoint, data);
      }

      // Handle other endpoints
      return _handleOtherEndpoints(method, endpoint, data);

    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
        'error': e.toString(),
      };
    }
  }

  // Handle authentication endpoints
  static Map<String, dynamic> _handleAuthEndpoint(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) {
    switch (endpoint) {
      case '/auth/login':
        return _handleLogin(data);
      case '/auth/register':
        return _handleRegister(data);
      case '/auth/refresh':
        return _handleRefreshToken();
      case '/auth/logout':
        return _handleLogout();
      case '/auth/forgot-password':
        return _handleForgotPassword(data);
      case '/auth/reset-password':
        return _handleResetPassword(data);
      case '/auth/verify-email':
        return _handleVerifyEmail(data);
      default:
        return {
          'success': false,
          'message': 'Endpoint not found',
        };
    }
  }

  // Handle login
  static Map<String, dynamic> _handleLogin(Map<String, dynamic>? data) {
    if (data == null) {
      return {
        'success': false,
        'message': 'Invalid request data',
      };
    }

    final email = data['email']?.toString().toLowerCase();
    final password = data['password']?.toString();

    // Mock validation
    if (email == null || password == null) {
      return {
        'success': false,
        'message': 'Email and password are required',
      };
    }

    // Mock user database
    final mockUsers = {
      'demo@biznest.com': {
        'id': '1',
        'name': 'Demo User',
        'email': 'demo@biznest.com',
        'password': 'demo123', // In real app, this would be hashed
        'role': 'entrepreneur',
        'company': 'Demo Company',
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        'created_at': '2024-01-01T00:00:00Z',
        'is_verified': true,
      },
      'test@biznest.com': {
        'id': '2',
        'name': 'Test User',
        'email': 'test@biznest.com',
        'password': 'test123',
        'role': 'entrepreneur',
        'company': 'Test Startup',
        'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
        'created_at': '2024-01-15T00:00:00Z',
        'is_verified': true,
      },
    };

    final user = mockUsers[email];
    if (user == null || user['password'] != password) {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }

    // Generate mock tokens
    final token = _generateMockToken();
    final refreshToken = _generateMockToken();

    return {
      'success': true,
      'message': 'Login successful',
      'data': {
        'token': token,
        'refresh_token': refreshToken,
        'user': {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'role': user['role'],
          'company': user['company'],
          'avatar': user['avatar'],
          'created_at': user['created_at'],
          'is_verified': user['is_verified'],
        },
      },
    };
  }

  // Handle registration
  static Map<String, dynamic> _handleRegister(Map<String, dynamic>? data) {
    if (data == null) {
      return {
        'success': false,
        'message': 'Invalid request data',
      };
    }

    final name = data['name']?.toString();
    final email = data['email']?.toString().toLowerCase();
    final password = data['password']?.toString();

    // Validation
    if (name == null || email == null || password == null) {
      return {
        'success': false,
        'message': 'Name, email, and password are required',
      };
    }

    if (name.length < 2) {
      return {
        'success': false,
        'message': 'Name must be at least 2 characters',
      };
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return {
        'success': false,
        'message': 'Please enter a valid email address',
      };
    }

    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    // Check if user already exists (mock)
    final existingEmails = ['demo@biznest.com', 'test@biznest.com'];
    if (existingEmails.contains(email)) {
      return {
        'success': false,
        'message': 'An account with this email already exists',
      };
    }

    // Generate mock tokens
    final token = _generateMockToken();
    final refreshToken = _generateMockToken();

    // Create new user
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'role': 'entrepreneur',
      'company': data['company'] ?? '',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      'created_at': DateTime.now().toIso8601String(),
      'is_verified': false,
    };

    return {
      'success': true,
      'message': 'Registration successful',
      'data': {
        'token': token,
        'refresh_token': refreshToken,
        'user': newUser,
      },
    };
  }

  // Handle refresh token
  static Map<String, dynamic> _handleRefreshToken() {
    return {
      'success': true,
      'message': 'Token refreshed successfully',
      'data': {
        'token': _generateMockToken(),
        'refresh_token': _generateMockToken(),
      },
    };
  }

  // Handle logout
  static Map<String, dynamic> _handleLogout() {
    return {
      'success': true,
      'message': 'Logged out successfully',
    };
  }

  // Handle forgot password
  static Map<String, dynamic> _handleForgotPassword(Map<String, dynamic>? data) {
    if (data == null || data['email'] == null) {
      return {
        'success': false,
        'message': 'Email is required',
      };
    }

    return {
      'success': true,
      'message': 'Password reset email sent successfully',
    };
  }

  // Handle reset password
  static Map<String, dynamic> _handleResetPassword(Map<String, dynamic>? data) {
    if (data == null || data['token'] == null || data['password'] == null) {
      return {
        'success': false,
        'message': 'Token and password are required',
      };
    }

    return {
      'success': true,
      'message': 'Password reset successfully',
    };
  }

  // Handle email verification
  static Map<String, dynamic> _handleVerifyEmail(Map<String, dynamic>? data) {
    if (data == null || data['token'] == null) {
      return {
        'success': false,
        'message': 'Verification token is required',
      };
    }

    return {
      'success': true,
      'message': 'Email verified successfully',
    };
  }

  // Handle other endpoints
  static Map<String, dynamic> _handleOtherEndpoints(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) {
    // Mock responses for other endpoints
    switch (endpoint) {
      case '/user/profile':
        return {
          'success': true,
          'data': {
            'id': '1',
            'name': 'Demo User',
            'email': 'demo@biznest.com',
            'role': 'entrepreneur',
            'company': 'Demo Company',
            'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            'created_at': '2024-01-01T00:00:00Z',
            'is_verified': true,
          },
        };
      case '/dashboard/stats':
        return {
          'success': true,
          'data': {
            'total_projects': 5,
            'completed_tasks': 12,
            'pending_tasks': 3,
            'revenue': 25000.0,
            'growth_rate': 15.5,
          },
        };
      case '/business/plans':
        return {
          'success': true,
          'data': [
            {
              'id': '1',
              'title': 'E-commerce Platform',
              'status': 'draft',
              'created_at': '2024-01-15T10:30:00Z',
            },
            {
              'id': '2',
              'title': 'Mobile App',
              'status': 'in_progress',
              'created_at': '2024-01-20T14:45:00Z',
            },
          ],
        };
      default:
        return {
          'success': true,
          'message': 'Mock response for $method $endpoint',
          'data': {},
        };
    }
  }

  // Generate mock JWT token
  static String _generateMockToken() {
    final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
    final payload = base64Url.encode(utf8.encode(json.encode({
      'sub': 'user_id',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000),
    })));
    final signature = base64Url.encode(utf8.encode('mock_signature'));
    
    return '$header.$payload.$signature';
  }

  // Get auth headers
  static Map<String, String> _getAuthHeaders() {
    final headers = Map<String, String>.from(_baseHeaders);
    
    if (AuthService.isAuthenticated) {
      headers['Authorization'] = 'Bearer ${AuthService.currentToken}';
    }
    
    return headers;
  }

  // Upload file
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool requiresAuth = true,
  }) async {
    try {
      // Simulate file upload
      await Future.delayed(const Duration(seconds: 2));
      
      return {
        'success': true,
        'message': 'File uploaded successfully',
        'data': {
          'file_url': 'https://api.biznests.com/uploads/mock_file.jpg',
          'file_id': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'File upload failed',
        'error': e.toString(),
      };
    }
  }

  // WebSocket connection
  static Stream<Map<String, dynamic>> connectWebSocket(String endpoint) {
    final controller = StreamController<Map<String, dynamic>>();
    
    // Simulate WebSocket connection
    Timer.periodic(const Duration(seconds: 5), (timer) {
      controller.add({
        'type': 'ping',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {'message': 'Connection alive'},
      });
    });
    
    return controller.stream;
  }

  // Close WebSocket
  static void closeWebSocket() {
    // Mock implementation
  }
}