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
    int? year,
  }) async {
    try {
      businessId ??=
          FirebaseAuth.instance.currentUser?.uid ?? 'default_business';

      // Only fetch from Firebase - no mock data fallback
      final doc =
          await _firestore.collection(_collection).doc(businessId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        // If year is specified, extract data for that specific year
        if (year != null) {
          final yearData = _extractYearSpecificData(data, year);
          if (yearData != null) {
            return _enhanceAnalyticsData(yearData);
          } else {
            // No data for the specified year
            if (kDebugMode) {
              print('No business analytics data found for year $year');
            }
            return null;
          }
        } else {
          // Return enhanced analytics with real data only
          return _enhanceAnalyticsData(data);
        }
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

  /// Extract data for a specific year from the year-based structure
  static Map<String, dynamic>? _extractYearSpecificData(
      Map<String, dynamic> data, int year) {
    final String yearKey = year.toString();
    final revenueByYear = data['revenueByYear'] as Map<String, dynamic>?;
    final customersByYear = data['customersByYear'] as Map<String, dynamic>?;
    final expensesByYear = data['expensesByYear'] as Map<String, dynamic>?;

    // Check if we have data for the specified year
    final yearRevenue = revenueByYear?[yearKey] as Map<String, dynamic>?;
    final yearCustomers = customersByYear?[yearKey] as Map<String, dynamic>?;
    final yearExpenses = expensesByYear?[yearKey] as Map<String, dynamic>?;

    if (yearRevenue == null && yearCustomers == null && yearExpenses == null) {
      return null; // No data for this year
    }

    // Build year-specific data structure
    Map<String, dynamic> yearData = {};

    if (yearRevenue != null) {
      yearData['revenue'] = yearRevenue;
    } else {
      yearData['revenue'] = {
        'monthly': List.filled(12, 0.0),
        'yearly': 0.0,
      };
    }

    if (yearCustomers != null) {
      yearData['customers'] = yearCustomers;
    } else {
      yearData['customers'] = {
        'monthly': List.filled(12, 0),
        'total': 0,
      };
    }

    if (yearExpenses != null) {
      yearData['expenses'] = yearExpenses;
    } else {
      yearData['expenses'] = {
        'monthly': List.filled(12, 0.0),
        'categories': <String, double>{},
      };
    }

    // Copy any other non-year-specific data
    data.forEach((key, value) {
      if (key != 'revenueByYear' &&
          key != 'customersByYear' &&
          key != 'expensesByYear') {
        yearData[key] = value;
      }
    });

    return yearData;
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

      // Initialize year-based structure
      Map<String, dynamic> revenueByYear =
          Map.from(data['revenueByYear'] ?? {});
      Map<String, dynamic> customersByYear =
          Map.from(data['customersByYear'] ?? {});

      String yearKey = year.toString();

      // Initialize yearly data structure if it doesn't exist
      if (!revenueByYear.containsKey(yearKey)) {
        revenueByYear[yearKey] = {
          'monthly': List.filled(12, 0.0),
          'yearly': 0.0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      if (!customersByYear.containsKey(yearKey)) {
        customersByYear[yearKey] = {
          'monthly': List.filled(12, 0),
          'total': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      // Update revenue for the specific year
      Map<String, dynamic> yearRevenue = Map.from(revenueByYear[yearKey]);
      List<dynamic> monthly = List.from(yearRevenue['monthly']);

      if (month >= 1 && month <= 12) {
        monthly[month - 1] = amount;
        yearRevenue['monthly'] = monthly;
        yearRevenue['yearly'] =
            monthly.fold(0.0, (sum, val) => sum + (val as num).toDouble());
        yearRevenue['lastUpdated'] = DateTime.now().toIso8601String();

        revenueByYear[yearKey] = yearRevenue;

        // Update customer count for this month and year if provided
        if (customerCount != null) {
          Map<String, dynamic> yearCustomers =
              Map.from(customersByYear[yearKey]);
          List<dynamic> monthlyCustomers = List.from(yearCustomers['monthly']);

          monthlyCustomers[month - 1] = customerCount;
          yearCustomers['monthly'] = monthlyCustomers;

          // Update total customers to be the highest monthly count for this year
          int maxCustomers =
              monthlyCustomers.fold(0, (max, val) => val > max ? val : max);
          yearCustomers['total'] = maxCustomers;
          yearCustomers['lastUpdated'] = DateTime.now().toIso8601String();

          customersByYear[yearKey] = yearCustomers;
        }
      }

      // Store the updated data
      data['revenueByYear'] = revenueByYear;
      data['customersByYear'] = customersByYear;
      data['lastUpdated'] = DateTime.now().toIso8601String();

      await docRef.set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print(
            '✅ Added monthly revenue: \$$amount for $month/$year${customerCount != null ? ' with $customerCount customers' : ''}');
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

      // Use current year if not specified
      year ??= DateTime.now().year;
      String yearKey = year.toString();

      // Initialize year-based structure for expenses
      Map<String, dynamic> expensesByYear =
          Map.from(data['expensesByYear'] ?? {});

      if (!expensesByYear.containsKey(yearKey)) {
        expensesByYear[yearKey] = {
          'monthly': List.filled(12, 0.0),
          'categories': <String, double>{},
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      Map<String, dynamic> yearExpenses = Map.from(expensesByYear[yearKey]);

      // Update category expenses for the year
      Map<String, dynamic> categories =
          Map.from(yearExpenses['categories'] ?? {});
      categoryExpenses.forEach((category, amount) {
        categories[category] = amount;
      });
      yearExpenses['categories'] = categories;

      // Update monthly expenses if month specified
      if (month != null && month >= 1 && month <= 12) {
        List<dynamic> monthly = List.from(yearExpenses['monthly']);

        double totalMonthlyExpense =
            categoryExpenses.values.fold(0.0, (sum, val) => sum + val);
        monthly[month - 1] = totalMonthlyExpense;
        yearExpenses['monthly'] = monthly;
      }

      yearExpenses['lastUpdated'] = DateTime.now().toIso8601String();
      expensesByYear[yearKey] = yearExpenses;

      data['expensesByYear'] = expensesByYear;
      data['lastUpdated'] = DateTime.now().toIso8601String();

      await docRef.set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print(
            '✅ Added expense data for year $year, categories: ${categoryExpenses.keys.join(", ")}');
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
            '✅ Added monthly customers: $customerCount customers for $month/$year');
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

  /// Get performance data for chart visualization
  /// Fetches revenue and expense data from separate collections and combines them
  static Future<List<Map<String, dynamic>>> getPerformanceData(
      String businessId,
      {int? year}) async {
    try {
      // Create query constraints based on year filter
      Query revenueQuery = _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('revenues');

      Query expenseQuery = _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('expenses');

      // Add year filter if specified
      if (year != null) {
        revenueQuery = revenueQuery.where('year', isEqualTo: year);
        expenseQuery = expenseQuery.where('year', isEqualTo: year);
      }

      // Fetch filtered data
      final revenueSnapshot = await revenueQuery.get();
      final expenseSnapshot = await expenseQuery.get();

      // Create maps for easy lookup by month/year key
      final Map<String, double> revenueMap = {};
      final Map<String, double> expenseMap = {};

      // Process revenue data
      for (var doc in revenueSnapshot.docs) {
        final docData = doc.data();
        if (docData != null) {
          final data = docData as Map<String, dynamic>;
          final month = data['month'] as int?;
          final year = data['year'] as int?;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

          if (month != null && year != null) {
            final key = '$year-${month.toString().padLeft(2, '0')}';
            revenueMap[key] = (revenueMap[key] ?? 0.0) + amount;
          }
        }
      }

      // Process expense data
      for (var doc in expenseSnapshot.docs) {
        final docData = doc.data();
        if (docData != null) {
          final data = docData as Map<String, dynamic>;
          final month = data['month'] as int?;
          final year = data['year'] as int?;

          if (month != null && year != null) {
            final key = '$year-${month.toString().padLeft(2, '0')}';

            // Handle different expense data structures
            double totalExpenses = 0.0;

            // If individual expense amount
            if (data['amount'] != null) {
              totalExpenses = (data['amount'] as num).toDouble();
            }

            // If category expenses map
            if (data['categoryExpenses'] != null) {
              final categoryExpenses =
                  data['categoryExpenses'] as Map<String, dynamic>;
              for (var expense in categoryExpenses.values) {
                totalExpenses += (expense as num?)?.toDouble() ?? 0.0;
              }
            }

            expenseMap[key] = (expenseMap[key] ?? 0.0) + totalExpenses;
          }
        }
      }

      // Combine all unique month/year combinations
      final Set<String> allKeys = {...revenueMap.keys, ...expenseMap.keys};

      // Convert to list of performance data
      final List<Map<String, dynamic>> performanceData = [];

      for (final key in allKeys) {
        final parts = key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        final revenue = revenueMap[key] ?? 0.0;
        final expenses = expenseMap[key] ?? 0.0;
        final profit = revenue - expenses;

        performanceData.add({
          'month': month,
          'year': year,
          'revenue': revenue,
          'expenses': expenses,
          'profit': profit,
        });
      }

      // Sort by year then month
      performanceData.sort((a, b) {
        final yearCompare = (a['year'] as int).compareTo(b['year'] as int);
        if (yearCompare != 0) return yearCompare;
        return (a['month'] as int).compareTo(b['month'] as int);
      });

      if (kDebugMode) {
        print('✅ Fetched performance data: ${performanceData.length} months');
      }

      return performanceData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching performance data: $e');
      }
      return [];
    }
  }
}
