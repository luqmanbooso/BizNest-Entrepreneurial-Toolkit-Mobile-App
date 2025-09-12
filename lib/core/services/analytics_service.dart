import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class AnalyticsService {
  static const String _analyticsKey = 'app_analytics';
  static const String _eventsKey = 'analytics_events';
  
  // Track screen view
  static Future<void> trackScreenView(String screenName, {Map<String, dynamic>? parameters}) async {
    final event = {
      'event_type': 'screen_view',
      'screen_name': screenName,
      'parameters': parameters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _logEvent(event);
    
    if (kDebugMode) {
      print('📊 Screen View: $screenName');
    }
  }

  // Track user action
  static Future<void> trackAction(String action, {Map<String, dynamic>? parameters}) async {
    final event = {
      'event_type': 'action',
      'action': action,
      'parameters': parameters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _logEvent(event);
    
    if (kDebugMode) {
      print('📊 Action: $action');
    }
  }

  // Track business plan creation
  static Future<void> trackBusinessPlanCreated(String planName, String industry) async {
    await trackAction('business_plan_created', parameters: {
      'plan_name': planName,
      'industry': industry,
    });
  }

  // Track business plan completion
  static Future<void> trackBusinessPlanCompleted(String planId, int completionPercentage) async {
    await trackAction('business_plan_completed', parameters: {
      'plan_id': planId,
      'completion_percentage': completionPercentage,
    });
  }

  // Track financial calculation
  static Future<void> trackFinancialCalculation(String calculationType, Map<String, dynamic> parameters) async {
    await trackAction('financial_calculation', parameters: {
      'calculation_type': calculationType,
      ...parameters,
    });
  }

  // Track networking connection
  static Future<void> trackNetworkingConnection(String connectionType, String industry) async {
    await trackAction('networking_connection', parameters: {
      'connection_type': connectionType,
      'industry': industry,
    });
  }

  // Track learning progress
  static Future<void> trackLearningProgress(String courseId, String courseName, int progressPercentage) async {
    await trackAction('learning_progress', parameters: {
      'course_id': courseId,
      'course_name': courseName,
      'progress_percentage': progressPercentage,
    });
  }

  // Track funding application
  static Future<void> trackFundingApplication(String opportunityId, String opportunityName, String amount) async {
    await trackAction('funding_application', parameters: {
      'opportunity_id': opportunityId,
      'opportunity_name': opportunityName,
      'amount': amount,
    });
  }

  // Track user engagement
  static Future<void> trackUserEngagement(String feature, int duration) async {
    await trackAction('user_engagement', parameters: {
      'feature': feature,
      'duration_seconds': duration,
    });
  }

  // Track error
  static Future<void> trackError(String error, String stackTrace, {Map<String, dynamic>? context}) async {
    final event = {
      'event_type': 'error',
      'error': error,
      'stack_trace': stackTrace,
      'context': context ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _logEvent(event);
    
    if (kDebugMode) {
      print('❌ Error tracked: $error');
    }
  }

  // Track performance
  static Future<void> trackPerformance(String operation, int durationMs, {Map<String, dynamic>? metadata}) async {
    await trackAction('performance', parameters: {
      'operation': operation,
      'duration_ms': durationMs,
      'metadata': metadata ?? {},
    });
  }

  // Track user property
  static Future<void> setUserProperty(String key, dynamic value) async {
    final analytics = await _getAnalytics();
    analytics['user_properties'] ??= {};
    analytics['user_properties'][key] = value;
    await _saveAnalytics(analytics);
  }

  // Track user identification
  static Future<void> identifyUser(String userId, {Map<String, dynamic>? traits}) async {
    final analytics = await _getAnalytics();
    analytics['user_id'] = userId;
    analytics['user_traits'] = traits ?? {};
    await _saveAnalytics(analytics);
  }

  // Get analytics data
  static Future<Map<String, dynamic>> getAnalytics() async {
    return await _getAnalytics();
  }

  // Get events
  static Future<List<Map<String, dynamic>>> getEvents() async {
    final eventsJson = await StorageService.getString(_eventsKey);
    if (eventsJson != null) {
      final List<dynamic> eventsList = json.decode(eventsJson);
      return eventsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get user insights
  static Future<Map<String, dynamic>> getUserInsights() async {
    final analytics = await _getAnalytics();
    final events = await getEvents();
    
    // Calculate insights
    final totalSessions = analytics['total_sessions'] ?? 0;
    final totalTime = analytics['total_time_seconds'] ?? 0;
    final businessPlansCreated = events.where((e) => e['action'] == 'business_plan_created').length;
    final financialCalculations = events.where((e) => e['action'] == 'financial_calculation').length;
    final networkingConnections = events.where((e) => e['action'] == 'networking_connection').length;
    final learningProgress = events.where((e) => e['action'] == 'learning_progress').length;
    
    return {
      'total_sessions': totalSessions,
      'total_time_hours': (totalTime / 3600).round(),
      'business_plans_created': businessPlansCreated,
      'financial_calculations': financialCalculations,
      'networking_connections': networkingConnections,
      'learning_progress_events': learningProgress,
      'most_used_feature': _getMostUsedFeature(events),
      'engagement_score': _calculateEngagementScore(analytics, events),
    };
  }

  // Get feature usage statistics
  static Future<Map<String, int>> getFeatureUsageStats() async {
    final events = await getEvents();
    final Map<String, int> usage = {};
    
    for (final event in events) {
      if (event['event_type'] == 'action') {
        final action = event['action'] as String;
        usage[action] = (usage[action] ?? 0) + 1;
      }
    }
    
    return usage;
  }

  // Get screen view statistics
  static Future<Map<String, int>> getScreenViewStats() async {
    final events = await getEvents();
    final Map<String, int> views = {};
    
    for (final event in events) {
      if (event['event_type'] == 'screen_view') {
        final screenName = event['screen_name'] as String;
        views[screenName] = (views[screenName] ?? 0) + 1;
      }
    }
    
    return views;
  }

  // Export analytics data
  static Future<String> exportAnalyticsData() async {
    final analytics = await _getAnalytics();
    final events = await getEvents();
    
    final exportData = {
      'analytics': analytics,
      'events': events,
      'exported_at': DateTime.now().toIso8601String(),
    };
    
    return json.encode(exportData);
  }

  // Clear analytics data
  static Future<void> clearAnalyticsData() async {
    await StorageService.remove(_analyticsKey);
    await StorageService.remove(_eventsKey);
  }

  // Private methods
  static Future<void> _logEvent(Map<String, dynamic> event) async {
    final events = await getEvents();
    events.add(event);
    
    // Keep only last 1000 events
    if (events.length > 1000) {
      events.removeRange(0, events.length - 1000);
    }
    
    await StorageService.setString(_eventsKey, json.encode(events));
    
    // Update analytics
    await _updateAnalytics(event);
  }

  static Future<void> _updateAnalytics(Map<String, dynamic> event) async {
    final analytics = await _getAnalytics();
    
    // Update session data
    if (event['event_type'] == 'screen_view') {
      analytics['total_sessions'] = (analytics['total_sessions'] ?? 0) + 1;
      analytics['last_activity'] = DateTime.now().toIso8601String();
    }
    
    // Update feature usage
    if (event['event_type'] == 'action') {
      final action = event['action'] as String;
      analytics['feature_usage'] ??= {};
      analytics['feature_usage'][action] = (analytics['feature_usage'][action] ?? 0) + 1;
    }
    
    await _saveAnalytics(analytics);
  }

  static Future<Map<String, dynamic>> _getAnalytics() async {
    final analyticsJson = await StorageService.getString(_analyticsKey);
    if (analyticsJson != null) {
      return Map<String, dynamic>.from(json.decode(analyticsJson));
    }
    return {};
  }

  static Future<void> _saveAnalytics(Map<String, dynamic> analytics) async {
    await StorageService.setString(_analyticsKey, json.encode(analytics));
  }

  static String _getMostUsedFeature(List<Map<String, dynamic>> events) {
    final Map<String, int> featureCount = {};
    
    for (final event in events) {
      if (event['event_type'] == 'action') {
        final action = event['action'] as String;
        featureCount[action] = (featureCount[action] ?? 0) + 1;
      }
    }
    
    if (featureCount.isEmpty) return 'None';
    
    return featureCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  static int _calculateEngagementScore(Map<String, dynamic> analytics, List<Map<String, dynamic>> events) {
    final totalSessions = analytics['total_sessions'] ?? 0;
    final totalEvents = events.length;
    final uniqueFeatures = analytics['feature_usage']?.keys.length ?? 0;
    
    // Simple engagement score calculation
    final score = (totalSessions * 10) + (totalEvents * 2) + (uniqueFeatures * 5);
    return score.clamp(0, 100);
  }
}
