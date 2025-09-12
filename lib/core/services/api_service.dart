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

  // PATCH request
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    return _makeRequest('PATCH', endpoint,
        data: data, requiresAuth: requiresAuth);
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    return _makeRequest('DELETE', endpoint, requiresAuth: requiresAuth);
  }

  // Main request method
  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    int retryCount = 0,
  }) async {
    try {
      // Build URL
      final url = _buildUrl(endpoint, queryParams);

      // Prepare headers
      final headers = Map<String, String>.from(_baseHeaders);

      if (requiresAuth) {
        final token = AuthService.currentToken;
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        } else {
          throw ApiException('Authentication required', 401);
        }
      }

      if (kDebugMode) {
        print('🌐 API Request: $method $url');
        if (data != null) {
          print('📤 Request Data: ${json.encode(data)}');
        }
      }

      // Make request (simulated for demo)
      final response = await _simulateRequest(method, endpoint, data);

      if (kDebugMode) {
        print('📥 API Response: ${json.encode(response)}');
      }

      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API Error: $e');
      }

      // Retry logic for network errors
      if (retryCount < 2 && _shouldRetry(e)) {
        await Future.delayed(Duration(seconds: 1 + retryCount));
        return _makeRequest(method, endpoint,
            data: data,
            queryParams: queryParams,
            requiresAuth: requiresAuth,
            retryCount: retryCount + 1);
      }

      throw ApiException('Network error: ${e.toString()}', 500);
    }
  }

  // Build URL with query parameters
  static String _buildUrl(String endpoint, Map<String, String>? queryParams) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams).toString();
    }
    return uri.toString();
  }

  // Simulate API requests (replace with actual HTTP calls)
  static Future<Map<String, dynamic>> _simulateRequest(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500 + 1500));

    // Mock responses based on endpoint
    return _getMockResponse(method, endpoint, data);
  }

  // Mock response generator
  static Map<String, dynamic> _getMockResponse(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) {
    switch (endpoint) {
      // Authentication endpoints
      case '/auth/login':
        return {
          'success': true,
          'data': {
            'token': _generateToken(),
            'refresh_token': _generateToken(),
            'user': {
              'id': '1',
              'name': 'John Entrepreneur',
              'email': data?['email'] ?? 'user@example.com',
              'company': 'TechStartup Inc.',
              'role': 'CEO',
              'avatar':
                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
              'plan': 'premium',
              'created_at': '2024-01-01T00:00:00Z',
            },
          },
          'message': 'Login successful',
        };

      case '/auth/register':
        return {
          'success': true,
          'data': {
            'token': _generateToken(),
            'refresh_token': _generateToken(),
            'user': {
              'id': '2',
              'name': data?['name'] ?? 'New User',
              'email': data?['email'] ?? 'newuser@example.com',
              'company': data?['company'],
              'role': data?['role'],
              'avatar': null,
              'plan': 'free',
              'created_at': DateTime.now().toIso8601String(),
            },
          },
          'message': 'Registration successful',
        };

      case '/auth/validate':
        return {'success': true, 'message': 'Token is valid'};

      case '/auth/refresh':
        return {
          'success': true,
          'data': {
            'token': _generateToken(),
            'refresh_token': _generateToken(),
          },
        };

      case '/auth/forgot-password':
        return {
          'success': true,
          'message': 'Password reset link sent to your email',
        };

      // Business endpoints
      case '/business/plans':
        return {
          'success': true,
          'data': _getBusinessPlansData(),
        };

      case '/business/canvas':
        return {
          'success': true,
          'data': _getCanvasData(),
        };

      case '/financial/calculations':
        return {
          'success': true,
          'data': _getFinancialData(),
        };

      case '/market/research':
        return {
          'success': true,
          'data': _getMarketResearchData(),
        };

      case '/networking/contacts':
        return {
          'success': true,
          'data': _getNetworkingData(),
        };

      case '/learning/resources':
        return {
          'success': true,
          'data': _getLearningResourcesData(),
        };

      case '/funding/opportunities':
        return {
          'success': true,
          'data': _getFundingData(),
        };

      default:
        return {
          'success': true,
          'data': {},
          'message': 'Operation successful',
        };
    }
  }

  // Mock data generators
  static String _generateToken() {
    return 'token_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9000 * (DateTime.now().millisecond / 1000)).round())}';
  }

  static List<Map<String, dynamic>> _getBusinessPlansData() {
    return [
      {
        'id': '1',
        'title': 'AI SaaS Startup',
        'description': 'Revolutionary AI-powered business automation platform',
        'status': 'in_progress',
        'completion': 75,
        'last_updated': '2024-01-20T10:30:00Z',
        'sections': {
          'executive_summary': 'Complete',
          'market_analysis': 'Complete',
          'financial_projections': 'In Progress',
        },
      },
      {
        'id': '2',
        'title': 'E-commerce Platform',
        'description':
            'Next-generation online marketplace for sustainable products',
        'status': 'draft',
        'completion': 45,
        'last_updated': '2024-01-18T14:20:00Z',
        'sections': {
          'executive_summary': 'Complete',
          'market_analysis': 'In Progress',
          'financial_projections': 'Not Started',
        },
      },
    ];
  }

  static Map<String, dynamic> _getCanvasData() {
    return {
      'key_partners': [
        'Tech suppliers',
        'Marketing agencies',
        'Distribution partners'
      ],
      'key_activities': [
        'Software development',
        'Customer support',
        'Marketing'
      ],
      'value_propositions': [
        'Time-saving automation',
        'Cost reduction',
        'Scalability'
      ],
      'customer_relationships': [
        'Self-service',
        'Dedicated support',
        'Community'
      ],
      'customer_segments': ['SMBs', 'Enterprises', 'Startups'],
      'key_resources': ['Development team', 'Technology platform', 'Brand'],
      'channels': ['Direct sales', 'Online marketing', 'Partner network'],
      'cost_structure': ['Development costs', 'Infrastructure', 'Marketing'],
      'revenue_streams': [
        'Subscription fees',
        'Premium features',
        'Consulting'
      ],
    };
  }

  static Map<String, dynamic> _getFinancialData() {
    return {
      'calculations': [
        {
          'id': '1',
          'type': 'roi',
          'name': 'Marketing Campaign ROI',
          'result': 15.5,
          'parameters': {'investment': 10000, 'return': 11550},
          'created_at': '2024-01-20T10:00:00Z',
        },
        {
          'id': '2',
          'type': 'break_even',
          'name': 'Product Break-Even Analysis',
          'result': 1250,
          'parameters': {'fixed_costs': 5000, 'variable_cost': 12, 'price': 16},
          'created_at': '2024-01-19T14:30:00Z',
        },
      ],
      'summary': {
        'total_calculations': 15,
        'avg_roi': 12.8,
        'best_performing': 'Marketing Campaign ROI',
      },
    };
  }

  static Map<String, dynamic> _getMarketResearchData() {
    return {
      'industry_analysis': {
        'market_size': '\$2.5B',
        'growth_rate': '15.2%',
        'key_trends': ['AI adoption', 'Remote work', 'Sustainability'],
        'competitors': [
          {
            'name': 'Competitor A',
            'market_share': '25%',
            'strength': 'Brand recognition'
          },
          {
            'name': 'Competitor B',
            'market_share': '18%',
            'strength': 'Technology'
          },
        ],
      },
      'target_audience': {
        'primary': {
          'age': '25-45',
          'income': '\$50K-\$150K',
          'location': 'Urban'
        },
        'secondary': {
          'age': '35-55',
          'income': '\$75K-\$200K',
          'location': 'Suburban'
        },
      },
    };
  }

  static List<Map<String, dynamic>> _getNetworkingData() {
    return [
      {
        'id': '1',
        'name': 'Sarah Wilson',
        'company': 'VentureTech Capital',
        'role': 'Senior Partner',
        'category': 'investor',
        'contact_info': {
          'email': 'sarah@venturetech.com',
          'linkedin': 'sarah-wilson-vc'
        },
        'notes': 'Met at TechCrunch Disrupt. Interested in AI startups.',
        'last_contact': '2024-01-15T00:00:00Z',
        'relationship_score': 8.5,
      },
      {
        'id': '2',
        'name': 'Michael Chen',
        'company': 'Growth Accelerator',
        'role': 'Startup Mentor',
        'category': 'mentor',
        'contact_info': {
          'email': 'michael@growthaccel.com',
          'phone': '+1-555-0123'
        },
        'notes':
            'Expert in scaling SaaS businesses. Available for monthly calls.',
        'last_contact': '2024-01-12T00:00:00Z',
        'relationship_score': 9.2,
      },
    ];
  }

  static Map<String, dynamic> _getLearningResourcesData() {
    return {
      'courses': [
        {
          'id': '1',
          'title': 'Business Model Innovation',
          'provider': 'Stanford Online',
          'duration': '6 weeks',
          'rating': 4.8,
          'progress': 60,
          'thumbnail':
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        },
        {
          'id': '2',
          'title': 'Financial Planning for Startups',
          'provider': 'Harvard Business School',
          'duration': '4 weeks',
          'rating': 4.9,
          'progress': 25,
          'thumbnail':
              'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400',
        },
      ],
      'articles': [
        {
          'id': '1',
          'title': 'The Future of AI in Business',
          'author': 'Tech Insights',
          'read_time': '8 min',
          'category': 'Technology',
          'thumbnail':
              'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400',
        },
      ],
    };
  }

  static Map<String, dynamic> _getFundingData() {
    return {
      'opportunities': [
        {
          'id': '1',
          'name': 'Tech Innovation Grant',
          'amount': '\$50,000',
          'deadline': '2024-03-15',
          'type': 'grant',
          'eligibility': 'Early-stage tech startups',
          'match_score': 85,
        },
        {
          'id': '2',
          'name': 'Series A Investment',
          'amount': '\$2M - \$5M',
          'deadline': '2024-04-30',
          'type': 'equity',
          'eligibility': 'Proven revenue model',
          'match_score': 72,
        },
      ],
      'applications': [
        {
          'id': '1',
          'opportunity_name': 'Small Business Innovation Research',
          'amount': '\$25,000',
          'status': 'under_review',
          'submitted_date': '2024-01-10',
          'decision_date': '2024-02-15',
        },
      ],
    };
  }

  // Utility methods
  static bool _shouldRetry(dynamic error) {
    // Implement retry logic based on error type
    return false; // Simplified for demo
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? data;

  ApiException(this.message, this.statusCode, [this.data]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
