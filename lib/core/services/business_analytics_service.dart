import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessAnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'business_analytics';

  // Business Analytics Data Model
  static Map<String, dynamic> _mockAnalyticsData = {
    'businessId': 'default_business',
    'lastUpdated': DateTime.now().toIso8601String(),
    'revenue': {
      'monthly': [
        15000,
        18000,
        22000,
        19000,
        25000,
        28000,
        32000,
        35000,
        38000,
        42000,
        45000,
        48000
      ],
      'quarterly': [55000, 72000, 115000, 135000],
      'yearly': 377000,
      'growth_rate': 12.5,
    },
    'expenses': {
      'monthly': [
        8000,
        9500,
        11000,
        10500,
        12000,
        13500,
        15000,
        16000,
        17500,
        19000,
        20000,
        21000
      ],
      'categories': {
        'marketing': 8500,
        'operations': 12000,
        'salaries': 25000,
        'technology': 4500,
        'legal': 2000,
        'other': 3000
      }
    },
    'customers': {
      'total': 1250,
      'new_monthly': [45, 62, 78, 55, 89, 102, 125, 138, 156, 172, 189, 205],
      'retention_rate': 85.5,
      'churn_rate': 14.5,
      'lifetime_value': 850.0,
      'acquisition_cost': 125.0,
    },
    'performance_metrics': {
      'roi': 185.5,
      'profit_margin': 31.2,
      'burn_rate': 8500,
      'runway_months': 14,
      'market_share': 2.8,
      'nps_score': 72,
    },
    'market_analysis': {
      'competitor_count': 12,
      'market_size': 2500000,
      'growth_potential': 'High',
      'threat_level': 'Medium',
      'opportunity_score': 8.2,
    },
    'financial_health': {
      'score': 8.5,
      'cash_flow_status': 'Positive',
      'debt_to_equity': 0.3,
      'quick_ratio': 1.8,
      'current_ratio': 2.1,
    },
    'predictions': {
      'next_quarter_revenue': 52000,
      'yearly_growth_forecast': 15.8,
      'risk_assessment': 'Low',
      'recommended_actions': [
        'Increase marketing budget by 20%',
        'Focus on customer retention programs',
        'Explore new market segments',
        'Optimize operational costs'
      ]
    }
  };

  // Generate comprehensive business analytics
  static Future<Map<String, dynamic>> generateBusinessAnalytics({
    String? businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      businessId ??= 'default_business';
      startDate ??= DateTime.now().subtract(const Duration(days: 365));
      endDate ??= DateTime.now();

      // Try to fetch from Firebase first
      final doc =
          await _firestore.collection(_collection).doc(businessId).get();

      if (doc.exists) {
        final data = doc.data()!;
        // Update with real-time calculations
        return _enhanceAnalyticsData(data);
      } else {
        // Generate mock data for demo
        final analytics =
            _generateMockAnalytics(businessId, startDate, endDate);

        // Save to Firebase for future use
        await _saveAnalytics(businessId, analytics);

        return analytics;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating analytics: $e');
      }
      return _mockAnalyticsData;
    }
  }

  // Calculate real-time metrics
  static Map<String, dynamic> _enhanceAnalyticsData(Map<String, dynamic> data) {
    // Calculate derived metrics
    final revenue = data['revenue'] ?? {};
    final expenses = data['expenses'] ?? {};

    if (revenue['monthly'] is List && expenses['monthly'] is List) {
      final revenueList = List<double>.from(revenue['monthly']);
      final expensesList = List<double>.from(expenses['monthly']);

      // Calculate profit margins
      final profits = <double>[];
      for (int i = 0; i < revenueList.length && i < expensesList.length; i++) {
        profits.add(revenueList[i] - expensesList[i]);
      }

      data['profits'] = {
        'monthly': profits,
        'total': profits.fold(0.0, (sum, profit) => sum + profit),
        'average_margin': profits.isNotEmpty
            ? (profits.fold(0.0, (sum, profit) => sum + profit) /
                    profits.length) /
                (revenueList.fold(0.0, (sum, rev) => sum + rev) /
                    revenueList.length) *
                100
            : 0.0,
      };
    }

    return data;
  }

  // Generate mock analytics data
  static Map<String, dynamic> _generateMockAnalytics(
      String businessId, DateTime startDate, DateTime endDate) {
    final random = Random();
    final months = _getMonthsBetween(startDate, endDate);

    // Generate realistic revenue data with growth trend
    final monthlyRevenue = <double>[];
    double baseRevenue = 10000 + random.nextDouble() * 5000;

    for (int i = 0; i < months; i++) {
      baseRevenue *= (1 + (0.05 + random.nextDouble() * 0.1)); // 5-15% growth
      monthlyRevenue.add(baseRevenue);
    }

    // Generate corresponding expenses (60-80% of revenue)
    final monthlyExpenses = monthlyRevenue.map((revenue) {
      final ratio = 0.6 + random.nextDouble() * 0.2;
      return revenue * ratio;
    }).toList();

    return {
      'businessId': businessId,
      'lastUpdated': DateTime.now().toIso8601String(),
      'revenue': {
        'monthly': monthlyRevenue,
        'yearly': monthlyRevenue.fold(0.0, (sum, rev) => sum + rev),
        'growth_rate': _calculateGrowthRate(monthlyRevenue),
      },
      'expenses': {
        'monthly': monthlyExpenses,
        'categories': _generateExpenseCategories(monthlyExpenses.last),
      },
      'customers': _generateCustomerMetrics(random),
      'performance_metrics':
          _generatePerformanceMetrics(monthlyRevenue, monthlyExpenses, random),
      'market_analysis': _generateMarketAnalysis(random),
      'financial_health':
          _generateFinancialHealth(monthlyRevenue, monthlyExpenses, random),
      'predictions': _generatePredictions(monthlyRevenue, random),
    };
  }

  // Helper methods for generating realistic data
  static int _getMonthsBetween(DateTime start, DateTime end) {
    return ((end.year - start.year) * 12 + end.month - start.month)
        .clamp(1, 12);
  }

  static double _calculateGrowthRate(List<double> values) {
    if (values.length < 2) return 0.0;
    final first = values.first;
    final last = values.last;
    return ((last - first) / first) * 100;
  }

  static Map<String, dynamic> _generateExpenseCategories(double totalExpense) {
    return {
      'marketing': totalExpense * 0.15,
      'operations': totalExpense * 0.25,
      'salaries': totalExpense * 0.40,
      'technology': totalExpense * 0.10,
      'legal': totalExpense * 0.05,
      'other': totalExpense * 0.05,
    };
  }

  static Map<String, dynamic> _generateCustomerMetrics(Random random) {
    final totalCustomers = 500 + random.nextInt(1000);
    return {
      'total': totalCustomers,
      'new_monthly': List.generate(12, (i) => 20 + random.nextInt(50)),
      'retention_rate': 75.0 + random.nextDouble() * 20,
      'churn_rate': 5.0 + random.nextDouble() * 15,
      'lifetime_value': 500.0 + random.nextDouble() * 500,
      'acquisition_cost': 50.0 + random.nextDouble() * 150,
    };
  }

  static Map<String, dynamic> _generatePerformanceMetrics(
      List<double> revenue, List<double> expenses, Random random) {
    final totalRevenue = revenue.fold(0.0, (sum, rev) => sum + rev);
    final totalExpenses = expenses.fold(0.0, (sum, exp) => sum + exp);
    final profit = totalRevenue - totalExpenses;

    return {
      'roi': (profit / totalExpenses) * 100,
      'profit_margin': (profit / totalRevenue) * 100,
      'burn_rate': expenses.last,
      'runway_months': 6 + random.nextInt(24),
      'market_share': 1.0 + random.nextDouble() * 5.0,
      'nps_score': 50 + random.nextInt(40),
    };
  }

  static Map<String, dynamic> _generateMarketAnalysis(Random random) {
    return {
      'competitor_count': 5 + random.nextInt(20),
      'market_size': 1000000 + random.nextInt(5000000),
      'growth_potential': ['High', 'Medium', 'Low'][random.nextInt(3)],
      'threat_level': ['Low', 'Medium', 'High'][random.nextInt(3)],
      'opportunity_score': 5.0 + random.nextDouble() * 5.0,
    };
  }

  static Map<String, dynamic> _generateFinancialHealth(
      List<double> revenue, List<double> expenses, Random random) {
    return {
      'score': 6.0 + random.nextDouble() * 4.0,
      'cash_flow_status':
          revenue.last > expenses.last ? 'Positive' : 'Negative',
      'debt_to_equity': random.nextDouble() * 0.5,
      'quick_ratio': 1.0 + random.nextDouble() * 2.0,
      'current_ratio': 1.5 + random.nextDouble() * 2.0,
    };
  }

  static Map<String, dynamic> _generatePredictions(
      List<double> revenue, Random random) {
    final avgGrowth = _calculateGrowthRate(revenue) / 100;
    return {
      'next_quarter_revenue': revenue.last * 3 * (1 + avgGrowth),
      'yearly_growth_forecast': (avgGrowth * 100).clamp(5.0, 25.0),
      'risk_assessment': ['Low', 'Medium', 'High'][random.nextInt(3)],
      'recommended_actions': [
        'Optimize conversion funnel',
        'Expand to new markets',
        'Improve customer retention',
        'Reduce operational costs',
        'Invest in technology',
      ],
    };
  }

  // Save analytics to Firebase
  static Future<void> _saveAnalytics(
      String businessId, Map<String, dynamic> analytics) async {
    try {
      await _firestore.collection(_collection).doc(businessId).set(analytics);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving analytics: $e');
      }
    }
  }

  // Get analytics summary
  static Future<Map<String, dynamic>> getAnalyticsSummary(
      String businessId) async {
    final analytics = await generateBusinessAnalytics(businessId: businessId);

    return {
      'total_revenue': analytics['revenue']['yearly'],
      'profit_margin': analytics['performance_metrics']['profit_margin'],
      'customer_count': analytics['customers']['total'],
      'growth_rate': analytics['revenue']['growth_rate'],
      'health_score': analytics['financial_health']['score'],
      'risk_level': analytics['predictions']['risk_assessment'],
    };
  }

  // Get specific metrics for charts
  static Future<List<Map<String, dynamic>>> getRevenueChartData(
      String businessId) async {
    final analytics = await generateBusinessAnalytics(businessId: businessId);
    final monthlyRevenue = List<double>.from(analytics['revenue']['monthly']);

    return List.generate(monthlyRevenue.length, (index) {
      return {
        'month': index + 1,
        'revenue': monthlyRevenue[index],
        'label': _getMonthLabel(index),
      };
    });
  }

  static String _getMonthLabel(int index) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[index % 12];
  }

  // Update business metrics
  static Future<void> updateBusinessMetrics({
    required String businessId,
    Map<String, dynamic>? revenueData,
    Map<String, dynamic>? expenseData,
    Map<String, dynamic>? customerData,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(businessId);
      final updateData = <String, dynamic>{
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      if (revenueData != null) updateData['revenue'] = revenueData;
      if (expenseData != null) updateData['expenses'] = expenseData;
      if (customerData != null) updateData['customers'] = customerData;

      await docRef.update(updateData);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating metrics: $e');
      }
    }
  }
}
