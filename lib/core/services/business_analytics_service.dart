import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessAnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'business_analytics';

  /// Generate comprehensive business analytics from real data only
  static Future<Map<String, dynamic>?> generateBusinessAnalytics({
    String? businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      businessId ??=
          FirebaseAuth.instance.currentUser?.uid ?? 'default_business';

      // Only fetch from Firebase - no mock data fallback
      final doc =
          await _firestore.collection(_collection).doc(businessId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Return enhanced analytics with real data only
        return _enhanceAnalyticsData(data);
      } else {
        // Return null when no real data exists - no mock fallback
        if (kDebugMode) {
          print('No business analytics data found for: $businessId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating business analytics: $e');
      }
      return null;
    }
  }

  /// Enhance analytics data with calculated metrics
  static Map<String, dynamic> _enhanceAnalyticsData(Map<String, dynamic> data) {
    // Calculate derived metrics from real data
    final revenue = data['revenue'] ?? {};
    final expenses = data['expenses'] ?? {};

    // Calculate profits if we have revenue and expense data
    if (revenue['monthly'] != null && expenses['monthly'] != null) {
      final revenueList = List<double>.from(revenue['monthly'] ?? []);
      final expensesList = List<double>.from(expenses['monthly'] ?? []);
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

  /// Create initial business profile
  static Future<void> createBusinessProfile({
    required String businessId,
    required String businessName,
    required String industry,
    required String businessType,
    String? description,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(businessId);

      await docRef.set({
        'business_info': {
          'name': businessName,
          'industry': industry,
          'type': businessType,
          'description': description ?? '',
          'created': DateTime.now().toIso8601String(),
        },
        'revenue': {'monthly': List.filled(12, 0.0), 'yearly': 0.0},
        'expenses': {'monthly': List.filled(12, 0.0), 'categories': {}},
        'customers': {'total': 0, 'monthly': List.filled(12, 0)},
        'performance': {'kpis': {}, 'metrics': {}},
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('✅ Created business profile: $businessName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating business profile: $e');
      }
      rethrow;
    }
  }

  /// Add monthly revenue data with customer count
  static Future<void> addMonthlyRevenue({
    required String businessId,
    required double amount,
    required int month,
    required int year,
    int? customerCount,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(businessId);
      final doc = await docRef.get();

      Map<String, dynamic> data = doc.exists ? doc.data()! : {};
      Map<String, dynamic> revenue = Map.from(data['revenue'] ?? {});
      Map<String, dynamic> customers = Map.from(data['customers'] ?? {});

      List<dynamic> monthly = List.from(revenue['monthly'] ?? []);
      while (monthly.length < 12) {
        monthly.add(0.0);
      }

      if (month >= 1 && month <= 12) {
        monthly[month - 1] = amount;

        // Update customer count for this month if provided
        if (customerCount != null) {
          List<dynamic> monthlyCustomers =
              List.from(customers['monthly'] ?? []);
          while (monthlyCustomers.length < 12) {
            monthlyCustomers.add(0);
          }
          monthlyCustomers[month - 1] = customerCount;
          customers['monthly'] = monthlyCustomers;

          // Update total customers to be the highest monthly count
          int maxCustomers =
              monthlyCustomers.fold(0, (max, val) => val > max ? val : max);
          customers['total'] = maxCustomers;
          customers['lastUpdated'] = DateTime.now().toIso8601String();
        }
      }

      revenue['monthly'] = monthly;
      revenue['yearly'] =
          monthly.fold(0.0, (sum, val) => sum + (val as num).toDouble());
      revenue['lastUpdated'] = DateTime.now().toIso8601String();

      data['revenue'] = revenue;
      data['customers'] = customers;
      data['lastUpdated'] = DateTime.now().toIso8601String();

      await docRef.set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print(
            '✅ Added monthly revenue: \$${amount} for ${month}/${year}${customerCount != null ? ' with $customerCount customers' : ''}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding monthly revenue: $e');
      }
      rethrow;
    }
  }

  /// Add expense data
  static Future<void> addExpenseData({
    required String businessId,
    required Map<String, double> categoryExpenses,
    int? month,
    int? year,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(businessId);
      final doc = await docRef.get();

      Map<String, dynamic> data = doc.exists ? doc.data()! : {};
      Map<String, dynamic> expenses = Map.from(data['expenses'] ?? {});

      // Update category expenses
      Map<String, dynamic> categories = Map.from(expenses['categories'] ?? {});
      categoryExpenses.forEach((category, amount) {
        categories[category] = amount;
      });

      expenses['categories'] = categories;

      // Update monthly expenses if month specified
      if (month != null && month >= 1 && month <= 12) {
        List<dynamic> monthly = List.from(expenses['monthly'] ?? []);
        while (monthly.length < 12) {
          monthly.add(0.0);
        }

        double totalMonthlyExpense =
            categoryExpenses.values.fold(0.0, (sum, val) => sum + val);
        monthly[month - 1] = totalMonthlyExpense;
        expenses['monthly'] = monthly;
      }

      expenses['lastUpdated'] = DateTime.now().toIso8601String();
      data['expenses'] = expenses;
      data['lastUpdated'] = DateTime.now().toIso8601String();

      await docRef.set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print(
            '✅ Added expense data for categories: ${categoryExpenses.keys.join(", ")}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding expense data: $e');
      }
      rethrow;
    }
  }

  /// Add or update customer data for a specific month
  static Future<void> addMonthlyCustomers({
    required String businessId,
    required int customerCount,
    required int month,
    required int year,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(businessId);
      final doc = await docRef.get();

      Map<String, dynamic> data = doc.exists ? doc.data()! : {};
      Map<String, dynamic> customers = Map.from(data['customers'] ?? {});

      List<dynamic> monthly = List.from(customers['monthly'] ?? []);
      while (monthly.length < 12) {
        monthly.add(0);
      }

      if (month >= 1 && month <= 12) {
        monthly[month - 1] = customerCount;
      }

      customers['monthly'] = monthly;
      // Update total customers to be the highest monthly count
      int maxCustomers = monthly.fold(0, (max, val) => val > max ? val : max);
      customers['total'] = maxCustomers;
      customers['lastUpdated'] = DateTime.now().toIso8601String();

      data['customers'] = customers;
      data['lastUpdated'] = DateTime.now().toIso8601String();

      await docRef.set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print(
            '✅ Added monthly customers: $customerCount customers for ${month}/${year}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding monthly customers: $e');
      }
      rethrow;
    }
  }

  /// Add customer data
  static Future<void> addCustomerData({
    required String businessId,
    required int totalCustomers,
    int? monthlyNew,
    int? month,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(businessId);
      final doc = await docRef.get();

      Map<String, dynamic> data = doc.exists ? doc.data()! : {};
      Map<String, dynamic> customers = Map.from(data['customers'] ?? {});

      customers['total'] = totalCustomers;

      if (month != null && monthlyNew != null && month >= 1 && month <= 12) {
        List<dynamic> monthly = List.from(customers['monthly'] ?? []);
        while (monthly.length < 12) {
          monthly.add(0);
        }
        monthly[month - 1] = monthlyNew;
        customers['monthly'] = monthly;
      }

      customers['lastUpdated'] = DateTime.now().toIso8601String();
      data['customers'] = customers;
      data['lastUpdated'] = DateTime.now().toIso8601String();

      await docRef.set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Added customer data: $totalCustomers total customers');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding customer data: $e');
      }
      rethrow;
    }
  }

  /// Add performance metrics
  static Future<void> addPerformanceMetrics({
    required String businessId,
    required Map<String, double> kpis,
    Map<String, dynamic>? additionalMetrics,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(businessId);
      final doc = await docRef.get();

      Map<String, dynamic> data = doc.exists ? doc.data()! : {};
      Map<String, dynamic> performance = Map.from(data['performance'] ?? {});

      performance['kpis'] = kpis;
      if (additionalMetrics != null) {
        performance['metrics'] = additionalMetrics;
      }
      performance['lastUpdated'] = DateTime.now().toIso8601String();

      data['performance'] = performance;
      data['lastUpdated'] = DateTime.now().toIso8601String();

      await docRef.set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Added performance metrics: ${kpis.keys.join(", ")}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding performance metrics: $e');
      }
      rethrow;
    }
  }

  /// Check if business has any real data
  static Future<bool> hasBusinessData(String businessId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(businessId).get();

      if (!doc.exists || doc.data() == null) return false;

      final data = doc.data()!;

      // Check if there's any real data beyond initial structure
      final revenue = data['revenue']?['yearly'] ?? 0.0;
      final customers = data['customers']?['total'] ?? 0;
      final expenses = data['expenses']?['categories'];

      return revenue > 0 ||
          customers > 0 ||
          (expenses != null && expenses.isNotEmpty);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking business data: $e');
      }
      return false;
    }
  }
}
