import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/business_analytics_service.dart';
import 'business_data_entry_screen.dart';

class BusinessAnalyticsScreen extends StatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  State<BusinessAnalyticsScreen> createState() =>
      _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends State<BusinessAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String _selectedTimeframe = 'Quarterly';
  int _selectedYear = DateTime.now().year;
  int _selectedTabIndex = 0;
  int _selectedMonth = DateTime.now().month;

  final List<String> _timeframes = ['Quarterly', 'Yearly'];
  final List<int> _availableYears =
      List.generate(5, (index) => DateTime.now().year - index);
  final List<String> _tabTitles = ['Overview', 'Revenue', 'Customers'];
  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAnalyticsData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      // Use Firebase service with year-specific filtering
      final data = await BusinessAnalyticsService.generateBusinessAnalytics(
        year: _selectedYear,
      );

      // Use real data if available, otherwise fall back to year-specific mock data
      final finalData = data ?? _getDefaultAnalyticsData();

      setState(() {
        _analyticsData = finalData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load analytics for $_selectedYear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Provide year-specific analytics data when no real data exists
  Map<String, dynamic> _getDefaultAnalyticsData() {
    // Check if this is the current year or has sample data
    final currentYear = DateTime.now().year;
    final isCurrentYear = _selectedYear == currentYear;
    final isRecentYear = _selectedYear >=
        currentYear - 2; // Show sample data for current and last 2 years

    if (!isRecentYear) {
      // Return zero data for older years
      return _getZeroAnalyticsData();
    }

    // Adjust sample data based on year
    final yearDiff = currentYear - _selectedYear;
    final multiplier = isCurrentYear
        ? 1.0
        : (1.0 - (yearDiff * 0.15)); // Reduce by 15% per year back

    return {
      'revenue': {
        'monthly': [
          (8500 * multiplier).roundToDouble(),
          (9200 * multiplier).roundToDouble(),
          (8800 * multiplier).roundToDouble(),
          (11200 * multiplier).roundToDouble(),
          (12800 * multiplier).roundToDouble(),
          (15600 * multiplier).roundToDouble(),
          (16800 * multiplier).roundToDouble(),
          (18200 * multiplier).roundToDouble(),
          (16500 * multiplier).roundToDouble(),
          (17800 * multiplier).roundToDouble(),
          (19200 * multiplier).roundToDouble(),
          (21500 * multiplier).roundToDouble()
        ],
        'yearly': (196100.0 * multiplier),
        'growth_rate': isCurrentYear ? 15.2 : (15.2 * multiplier),
        'projected_next_6_months': isCurrentYear
            ? [22800.0, 24100.0, 25500.0, 26900.0, 28400.0, 30000.0]
            : [], // Only show projections for current year
      },
      'expenses': {
        'monthly': [
          (6200 * multiplier).roundToDouble(),
          (6800 * multiplier).roundToDouble(),
          (6400 * multiplier).roundToDouble(),
          (8100 * multiplier).roundToDouble(),
          (9200 * multiplier).roundToDouble(),
          (11000 * multiplier).roundToDouble(),
          (11800 * multiplier).roundToDouble(),
          (12600 * multiplier).roundToDouble(),
          (11900 * multiplier).roundToDouble(),
          (12400 * multiplier).roundToDouble(),
          (13100 * multiplier).roundToDouble(),
          (14200 * multiplier).roundToDouble()
        ],
        'categories': {
          'Marketing': (45000 * multiplier).roundToDouble(),
          'Operations': (38000 * multiplier).roundToDouble(),
          'Salaries': (95000 * multiplier).roundToDouble(),
          'Rent': (24000 * multiplier).roundToDouble(),
          'Utilities': (8100 * multiplier).roundToDouble(),
        },
      },
      'customers': {
        'monthly': [
          (45 * multiplier).round(),
          (52 * multiplier).round(),
          (48 * multiplier).round(),
          (63 * multiplier).round(),
          (71 * multiplier).round(),
          (89 * multiplier).round(),
          (95 * multiplier).round(),
          (102 * multiplier).round(),
          (87 * multiplier).round(),
          (93 * multiplier).round(),
          (108 * multiplier).round(),
          (115 * multiplier).round()
        ],
        'total': (968 * multiplier).round(),
        'retention_rate': isCurrentYear ? 85.5 : (85.5 * multiplier),
        'acquisition_cost': isCurrentYear ? 89.50 : (89.50 / multiplier),
      },
      'performance': {
        'profit_margin': isCurrentYear ? 25.8 : (25.8 * multiplier),
        'roi': isCurrentYear ? 135.2 : (135.2 * multiplier),
        'monthly_growth': [
          12.5 * (isCurrentYear ? 1.0 : multiplier),
          8.7 * (isCurrentYear ? 1.0 : multiplier),
          -4.3 * (isCurrentYear ? 1.0 : multiplier),
          27.3 * (isCurrentYear ? 1.0 : multiplier),
          14.3 * (isCurrentYear ? 1.0 : multiplier),
          21.9 * (isCurrentYear ? 1.0 : multiplier),
          7.7 * (isCurrentYear ? 1.0 : multiplier),
          8.3 * (isCurrentYear ? 1.0 : multiplier),
          -9.3 * (isCurrentYear ? 1.0 : multiplier),
          7.9 * (isCurrentYear ? 1.0 : multiplier),
          7.9 * (isCurrentYear ? 1.0 : multiplier),
          12.0 * (isCurrentYear ? 1.0 : multiplier)
        ],
        'cash_flow_trend': isRecentYear ? 'positive' : 'neutral',
        'burn_rate': (8500.0 * multiplier),
        'runway_months': isCurrentYear ? 18 : (18 * multiplier).round(),
      },
      'health': {
        'score': 0.0,
      },
      'business_info': {
        'name': 'Your Business ($_selectedYear)',
        'industry': 'General',
        'type': 'Startup',
      },
    };
  }

  // Provide zero analytics data for years without data
  Map<String, dynamic> _getZeroAnalyticsData() {
    return {
      'revenue': {
        'monthly': List.filled(12, 0),
        'yearly': 0.0,
        'growth_rate': 0.0,
        'projected_next_6_months': [],
      },
      'expenses': {
        'monthly': List.filled(12, 0),
        'categories': {
          'Marketing': 0,
          'Operations': 0,
          'Salaries': 0,
          'Rent': 0,
          'Utilities': 0,
        },
      },
      'customers': {
        'monthly': List.filled(12, 0),
        'total': 0,
        'retention_rate': 0.0,
        'acquisition_cost': 0.0,
      },
      'performance': {
        'profit_margin': 0.0,
        'roi': 0.0,
        'monthly_growth': List.filled(12, 0.0),
        'cash_flow_trend': 'neutral',
        'burn_rate': 0.0,
        'runway_months': 0,
      },
      'health': {
        'score': 0.0,
      },
      'business_info': {
        'name': 'No Data ($_selectedYear)',
        'industry': 'General',
        'type': 'No Data',
      },
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      appBar: _buildAppBar(),
      drawer: _buildSideMenu(),
      body: _isLoading ? _buildLoadingState() : _buildAnalyticsDashboard(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Business Analytics',
        style: ModernTheme.h3.copyWith(
          color: ModernTheme.primaryColor,
          fontSize: 24,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: ModernTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: ModernTheme.modernShadow,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              icon: const Icon(Icons.calendar_today,
                  color: ModernTheme.primaryColor, size: 18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              items: _availableYears.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: ModernTheme.body1.copyWith(
                      color: ModernTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
                _loadAnalyticsData();
              },
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: ModernTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: ModernTheme.modernShadow,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimeframe,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: ModernTheme.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              items: _timeframes.map((timeframe) {
                return DropdownMenuItem(
                  value: timeframe,
                  child: Text(
                    timeframe,
                    style: ModernTheme.body1.copyWith(
                      color: ModernTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimeframe = value!;
                });
                _loadAnalyticsData();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ModernTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: ModernTheme.modernShadow,
            ),
            child: const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing your business data...',
            style: ModernTheme.body1.copyWith(
              color: ModernTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    if (_analyticsData == null) {
      return _buildEmptyDataState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildTabNavigation(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernTheme.primaryColor.withOpacity(0.1),
                    ModernTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ModernTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 60,
                color: ModernTheme.primaryColor.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'No Business Data Yet',
              style: ModernTheme.h2.copyWith(
                color: ModernTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Start building meaningful analytics by adding your real business data. Track revenue, expenses, customers, and performance metrics.',
              style: ModernTheme.body1.copyWith(
                color: ModernTheme.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Benefits list
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ModernTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ModernTheme.primaryColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'What you can track:',
                    style: ModernTheme.h4.copyWith(
                      color: ModernTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                      Icons.trending_up, 'Revenue & Growth Trends'),
                  _buildBenefitItem(Icons.receipt_long, 'Expense Categories'),
                  _buildBenefitItem(Icons.people, 'Customer Metrics'),
                  _buildBenefitItem(Icons.speed, 'Performance KPIs'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Call to action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusinessDataEntryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_business, color: Colors.white),
                    label: const Text(
                      'Add Business Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Show tutorial or guide
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Analytics guide coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.help_outline,
                      color: ModernTheme.primaryColor,
                    ),
                    label: const Text(
                      'Learn How',
                      style: TextStyle(
                        color: ModernTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ModernTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ModernTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: ModernTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: ModernTheme.body2.copyWith(
                color: ModernTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Row(
        children: _tabTitles.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ModernTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: ModernTheme.body1.copyWith(
                    color:
                        isSelected ? Colors.white : ModernTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildRevenueTab();
      case 2:
        return _buildCustomersTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final customers = _analyticsData!['customers'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Overview',
          style: ModernTheme.h4.copyWith(
            fontSize: 20,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 20),

        // Key Metrics Cards
        _buildMetricsGrid([
          _buildMetricCard(
            'Total Revenue',
            '\$${(revenue['yearly'] ?? 0.0).toStringAsFixed(0)}',
            Icons.trending_up,
            ModernTheme.freshGreen,
            '+${(revenue['growth_rate'] ?? 0.0).toStringAsFixed(1)}%',
          ),
          _buildMetricCard(
            'Total Customers',
            '${customers['total'] ?? 0}',
            Icons.people,
            ModernTheme.primaryColor,
            'Total customers',
          ),
          _buildMetricCard(
            'Revenue Trends',
            '\$${(revenue['yearly'] ?? 0.0).toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            ModernTheme.sunsetOrange,
            'Annual revenue',
          ),
          _buildMetricCard(
            'Monthly Growth',
            '${((_analyticsData!['revenue'] ?? {})['growth_rate'] ?? 0.0).toStringAsFixed(1)}%',
            Icons.trending_up,
            ModernTheme.freshGreen,
            'Growth rate',
          ),
        ]),

        const SizedBox(height: 24),

        // Revenue Trend Chart
        _buildSectionTitle('Revenue Trend'),
        const SizedBox(height: 16),
        _buildRevenueChart(),

        const SizedBox(height: 24),

        // Quick Insights
        _buildQuickInsights(),
      ],
    );
  }

  Widget _buildRevenueTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Revenue vs Expenses Analysis'),
        const SizedBox(height: 20),
        _buildFinancialMetrics(),
        const SizedBox(height: 20),
        _buildRevenueChart(),
        const SizedBox(height: 24),
        _buildExpenseBreakdown(),
      ],
    );
  }

  Widget _buildFinancialMetrics() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final expenses = _analyticsData!['expenses'] ?? {};

    // Calculate totals
    final revenueMonthly = List<double>.from(revenue['monthly'] ?? []);
    final expenseMonthly = List<double>.from(expenses['monthly'] ?? []);

    final totalRevenue = revenueMonthly.fold(0.0, (sum, val) => sum + val);
    final totalExpenses = expenseMonthly.fold(0.0, (sum, val) => sum + val);
    final netProfit = totalRevenue - totalExpenses;
    final profitMargin =
        totalRevenue > 0 ? (netProfit / totalRevenue * 100) : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Revenue',
            '\$${totalRevenue.toStringAsFixed(0)}',
            Icons.trending_up,
            ModernTheme.primaryColor,
            'Income earned',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Expenses',
            '\$${totalExpenses.toStringAsFixed(0)}',
            Icons.trending_down,
            ModernTheme.sunsetOrange,
            'Money spent',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Net Profit',
            '\$${netProfit.toStringAsFixed(0)}',
            netProfit >= 0 ? Icons.add_circle : Icons.remove_circle,
            netProfit >= 0 ? ModernTheme.freshGreen : Colors.red,
            '${profitMargin.toStringAsFixed(1)}% margin',
          ),
        ),
      ],
    );
  }

  Widget _buildCustomersTab() {
    final customers = _analyticsData!['customers'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Customer Analytics'),
        const SizedBox(height: 20),
        _buildMetricsGrid([
          _buildMetricCard(
            'Total Customers',
            '${customers['total'] ?? 0}',
            Icons.people,
            ModernTheme.primaryColor,
            'Active users',
          ),
          _buildMetricCard(
            'Period Average',
            _calculatePeriodAverage(customers['monthly']),
            Icons.favorite,
            ModernTheme.freshGreen,
            'Customer acquisition',
          ),
          _buildMetricCard(
            'Revenue/Customer',
            '\$${_calculateRevenuePerCustomer()}',
            Icons.monetization_on,
            ModernTheme.sunsetOrange,
            'Average revenue per customer',
          ),
          _buildMetricCard(
            'Retention Trend',
            _getCustomerRetentionTrend(),
            Icons.trending_up,
            ModernTheme.primaryColor,
            'Customer retention pattern',
          ),
        ]),
        const SizedBox(height: 24),
        _buildCustomerGrowthChart(),
      ],
    );
  }

  /// Business trajectory chart showing revenue and expense trends

  /// Forecast section with 6-month projections

  /// Export button for analytics data

  Widget _buildMetricsGrid(List<Widget> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.8, // Increased from 2.4 to give even more height
      children: metrics,
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced from 10
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added to minimize height
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4), // Reduced from 5
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16), // Reduced from 18
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4), // Reduced from 6
          Text(
            value,
            style: ModernTheme.h4.copyWith(
              fontSize: 15, // Reduced from 16
              color: ModernTheme.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.0, // Added to reduce line height
            ),
          ),
          const SizedBox(height: 1), // Reduced from 2
          Text(
            title,
            style: ModernTheme.body2.copyWith(
              fontSize: 10, // Reduced from 11
              color: ModernTheme.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.0, // Added to reduce line height
            ),
          ),
          const SizedBox(height: 1), // Kept at 1
          Text(
            subtitle,
            style: ModernTheme.body2.copyWith(
              fontSize: 8, // Reduced from 9
              color: color,
              fontWeight: FontWeight.w500,
              height: 1.0, // Added to reduce line height
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: ModernTheme.h4.copyWith(
        fontSize: 18,
        color: ModernTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRevenueChart() {
    // Safely get revenue and expense data with fallback to empty list
    final revenueData = _analyticsData != null &&
            _analyticsData!['revenue'] != null &&
            _analyticsData!['revenue']['monthly'] != null
        ? List<double>.from(_analyticsData!['revenue']['monthly'])
        : List.filled(12, 0.0);

    final expenseData = _analyticsData != null &&
            _analyticsData!['expenses'] != null &&
            _analyticsData!['expenses']['monthly'] != null
        ? List<double>.from(_analyticsData!['expenses']['monthly'])
        : List.filled(12, 0.0);

    // Get data based on selected timeframe
    final List<double> displayRevenueData;
    final List<double> displayExpenseData;
    final List<String> monthLabels;

    if (_selectedTimeframe == 'Yearly') {
      // Show all 12 months
      displayRevenueData = revenueData.length >= 12
          ? revenueData.take(12).toList()
          : revenueData;
      displayExpenseData = expenseData.length >= 12
          ? expenseData.take(12).toList()
          : expenseData;
      monthLabels = [
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
    } else {
      // Quarterly - show only 3 months (current quarter)
      final currentMonth = DateTime.now().month;
      final quarterStart = ((currentMonth - 1) ~/ 3) * 3;
      displayRevenueData = revenueData.length > quarterStart + 2
          ? revenueData.skip(quarterStart).take(3).toList()
          : revenueData.take(3).toList();
      displayExpenseData = expenseData.length > quarterStart + 2
          ? expenseData.skip(quarterStart).take(3).toList()
          : expenseData.take(3).toList();

      final quarterMonths = [
        ['Jan', 'Feb', 'Mar'],
        ['Apr', 'May', 'Jun'],
        ['Jul', 'Aug', 'Sep'],
        ['Oct', 'Nov', 'Dec']
      ];
      monthLabels = quarterMonths[quarterStart ~/ 3];
    }

    // Calculate dynamic Y-axis maximum from both revenue and expense data
    final maxRevenue = displayRevenueData.isEmpty
        ? 100.0
        : displayRevenueData.reduce((a, b) => a > b ? a : b);
    final maxExpense = displayExpenseData.isEmpty
        ? 100.0
        : displayExpenseData.reduce((a, b) => a > b ? a : b);
    final maxValue = maxRevenue > maxExpense ? maxRevenue : maxExpense;

    // Ensure minimum value to prevent zero intervals
    final safeMaxValue = maxValue <= 0 ? 100.0 : maxValue;
    final dynamicMaxY = safeMaxValue * 1.2; // Add 20% padding at top

    // Calculate Y-axis interval for better scaling (ensure it's never zero)
    final yInterval = dynamicMaxY / 5; // Show 5 intervals

    // Debug output
    print('🔍 Chart Debug: displayRevenueData: $displayRevenueData');
    print('🔍 Chart Debug: displayExpenseData: $displayExpenseData');
    print('🔍 Chart Debug: maxValue: $maxValue, safeMaxValue: $safeMaxValue');
    print('🔍 Chart Debug: dynamicMaxY: $dynamicMaxY, yInterval: $yInterval');

    return Container(
      height: 300, // Increased height for dual line chart
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue vs Expenses',
                style: ModernTheme.h4.copyWith(
                  color: ModernTheme.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                _selectedTimeframe,
                style: ModernTheme.body2.copyWith(
                  color: ModernTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Revenue', ModernTheme.primaryColor),
              const SizedBox(width: 20),
              _buildLegendItem('Expenses', ModernTheme.sunsetOrange),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: yInterval,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: ModernTheme.textSecondary.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: ModernTheme.textSecondary.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < monthLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthLabels[index],
                              style: ModernTheme.body2.copyWith(
                                fontSize: 12,
                                color: ModernTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 60,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == 0) {
                          return Text(
                            '\$0',
                            style: ModernTheme.body2.copyWith(
                              fontSize: 10,
                              color: ModernTheme.textSecondary,
                            ),
                          );
                        }

                        if (value >= 1000000) {
                          return Text(
                            '\$${(value / 1000000).toStringAsFixed(1)}M',
                            style: ModernTheme.body2.copyWith(
                              fontSize: 10,
                              color: ModernTheme.textSecondary,
                            ),
                          );
                        } else if (value >= 1000) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}K',
                            style: ModernTheme.body2.copyWith(
                              fontSize: 10,
                              color: ModernTheme.textSecondary,
                            ),
                          );
                        } else {
                          return Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: ModernTheme.body2.copyWith(
                              fontSize: 10,
                              color: ModernTheme.textSecondary,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                        color: ModernTheme.textSecondary.withOpacity(0.2)),
                    left: BorderSide(
                        color: ModernTheme.textSecondary.withOpacity(0.2)),
                  ),
                ),
                minX: 0,
                maxX: (displayRevenueData.length - 1).toDouble(),
                minY: 0,
                maxY: dynamicMaxY,
                lineBarsData: [
                  // Revenue line
                  LineChartBarData(
                    spots: displayRevenueData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    gradient: LinearGradient(
                      colors: [
                        ModernTheme.primaryColor,
                        ModernTheme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: ModernTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ModernTheme.primaryColor.withOpacity(0.2),
                          ModernTheme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                  // Expenses line
                  LineChartBarData(
                    spots: displayExpenseData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    gradient: LinearGradient(
                      colors: [
                        ModernTheme.sunsetOrange,
                        ModernTheme.sunsetOrange.withOpacity(0.8),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: ModernTheme.sunsetOrange,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show:
                          false, // Don't show area under expenses line to avoid overlap
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerGrowthChart() {
    // Safely get customer data with fallback to empty list
    final customerData = _analyticsData != null &&
            _analyticsData!['customers'] != null &&
            _analyticsData!['customers']['monthly'] != null
        ? _analyticsData!['customers']['monthly']
        : List.filled(12, 0);
    final customersData = List<int>.from(customerData);

    // Calculate dynamic Y-axis values
    final maxCustomers = customersData.isEmpty
        ? 100.0
        : customersData.reduce((a, b) => a > b ? a : b).toDouble();
    final minCustomers = customersData.isEmpty
        ? 0.0
        : customersData.reduce((a, b) => a < b ? a : b).toDouble();

    // Add 20% padding to max value and ensure minimum range
    final maxY = (maxCustomers * 1.2).clamp(100.0, double.infinity);
    final minY = (minCustomers * 0.8).clamp(0.0, maxCustomers * 0.8);

    // Calculate interval for Y-axis labels
    final range = maxY - minY;
    final interval = range / 5; // Show 5 intervals

    print('📊 [Customer Chart] Min: $minY, Max: $maxY, Interval: $interval');

    return Container(
      height: 250, // Increased height for better visibility
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customers by Month',
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: minY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: ModernTheme.primaryColor,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      const months = [
                        'January',
                        'February',
                        'March',
                        'April',
                        'May',
                        'June',
                        'July',
                        'August',
                        'September',
                        'October',
                        'November',
                        'December'
                      ];
                      return BarTooltipItem(
                        '${months[groupIndex]}\n${rod.toY.round()} customers',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval > 0 ? interval : 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: ModernTheme.textSecondary.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                      color: ModernTheme.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: ModernTheme.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: interval > 0 ? interval : 20,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.round().toString(),
                          style: ModernTheme.body2.copyWith(
                            fontSize: 10,
                            color: ModernTheme.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
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
                        if (value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: ModernTheme.body2.copyWith(
                                fontSize: 10,
                                color: ModernTheme.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barGroups: customersData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            ModernTheme.primaryColor,
                            ModernTheme.primaryColor.withOpacity(0.6),
                          ],
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Expense Breakdown',
                style: ModernTheme.h4.copyWith(
                  fontSize: 16,
                  color: ModernTheme.textPrimary,
                ),
              ),
              _buildMonthSelector(),
            ],
          ),
          const SizedBox(height: 16),
          _buildMonthlyExpenseData(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ModernTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonth,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: ModernTheme.primaryColor,
            size: 18,
          ),
          style: ModernTheme.body2.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ModernTheme.primaryColor,
          ),
          items: List.generate(12, (index) {
            final monthIndex = index + 1;
            return DropdownMenuItem<int>(
              value: monthIndex,
              child: Text(
                _monthNames[index],
                style: ModernTheme.body2.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedMonth = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthlyExpenseData() {
    // Get monthly expense data for the selected month
    final monthlyExpenses = _getMonthlyExpenseData(_selectedMonth);

    if (monthlyExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: ModernTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No expense data for ${_monthNames[_selectedMonth - 1]}',
              style: ModernTheme.body2.copyWith(
                color: ModernTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final totalMonthlyExpenses =
        monthlyExpenses.values.fold(0.0, (sum, value) => sum + value);

    return Column(
      children: [
        // Monthly total
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: ModernTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ModernTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthNames[_selectedMonth - 1]} $_selectedYear Total:',
                style: ModernTheme.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
              Text(
                '\$${totalMonthlyExpenses.toStringAsFixed(2)}',
                style: ModernTheme.body1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ModernTheme.primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        // Expense categories
        ...monthlyExpenses.entries.map((entry) {
          final percentage = totalMonthlyExpenses > 0
              ? (entry.value / totalMonthlyExpenses * 100)
              : 0.0;
          final categoryColor = _getCategoryColor(entry.key);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Category icon and name
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key.toString().toUpperCase(),
                          style: ModernTheme.body2.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ModernTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: ModernTheme.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Amount and percentage
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: ModernTheme.body2.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ModernTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: ModernTheme.body2.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ModernTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickInsights() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final customers = _analyticsData!['customers'] ?? {};
    final expenses = _analyticsData!['expenses'] ?? {};

    // Generate insights based on real data
    List<String> insights = [];

    if (revenue['yearly'] != null && revenue['yearly'] > 0) {
      final yearlyRevenue = (revenue['yearly'] as num?)?.toDouble() ?? 0.0;
      insights.add(
          'Revenue tracking is active with \$${yearlyRevenue.toStringAsFixed(0)} annually');
    }

    if (customers['total'] != null && customers['total'] > 0) {
      insights.add(
          'Customer base has grown to ${customers['total']} active customers');
    }

    if (expenses['categories'] != null &&
        (expenses['categories'] as Map).isNotEmpty) {
      insights.add(
          'Expense tracking is set up across ${(expenses['categories'] as Map).length} categories');
    }

    if (insights.isEmpty) {
      insights.addAll([
        'Start by adding your business revenue data',
        'Track customer acquisition and growth',
        'Monitor expense categories for better insights'
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: ModernTheme.goldenYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Business Insights',
                style: ModernTheme.h4.copyWith(
                  fontSize: 16,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.take(3).map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: const BoxDecoration(
                      color: ModernTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: ModernTheme.body2.copyWith(
                        fontSize: 14,
                        color: ModernTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Drawer(
      backgroundColor: ModernTheme.backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernTheme.primaryColor.withOpacity(0.05),
              ModernTheme.backgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                    Color(0xFF60A5FA),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernTheme.primaryColor.withOpacity(0.3),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analytics Hub',
                      style: ModernTheme.h3.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your business data',
                      style: ModernTheme.body2.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildMenuItem(
                      Icons.dashboard,
                      'Analytics Dashboard',
                      'View current screen',
                      () {
                        Navigator.pop(context);
                      },
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      Icons.data_usage,
                      'Manage Business Data',
                      'Add your real business metrics',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessDataEntryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      Icons.refresh,
                      'Refresh Analytics',
                      'Update your data',
                      () {
                        Navigator.pop(context);
                        _loadAnalyticsData();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      Icons.settings,
                      'Analytics Settings',
                      'Configure preferences',
                      () {
                        Navigator.pop(context);
                        // You can implement analytics settings here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics settings coming soon!'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Divider(color: ModernTheme.textSecondary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      Icons.arrow_back,
                      'Back to Dashboard',
                      'Return to main screen',
                      () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? ModernTheme.primaryColor.withOpacity(0.1)
              : ModernTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: ModernTheme.primaryColor.withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? ModernTheme.primaryColor
                    : ModernTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : ModernTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ModernTheme.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? ModernTheme.primaryColor
                          : ModernTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: ModernTheme.body2.copyWith(
                      color: ModernTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: ModernTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for real data analysis
  String _calculatePeriodAverage(dynamic monthlyData) {
    if (monthlyData == null) return '0';
    try {
      final data = List<num>.from(monthlyData);
      if (data.isEmpty) return '0';
      final sum =
          data.fold(0.0, (prev, element) => prev + (element.toDouble()));
      return (sum / data.length).toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }

  String _calculateRevenuePerCustomer() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final customers = _analyticsData!['customers'] ?? {};

    try {
      final revenueData = List<num>.from(revenue['monthly'] ?? []);
      final customerData = List<num>.from(customers['monthly'] ?? []);

      double totalRevenue =
          revenueData.fold(0.0, (sum, val) => sum + val.toDouble());
      double totalCustomerMonths =
          customerData.fold(0.0, (sum, val) => sum + val.toDouble());

      if (totalCustomerMonths == 0) return '0';
      return (totalRevenue / totalCustomerMonths).toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }

  String _getCustomerRetentionTrend() {
    final customers = _analyticsData!['customers'] ?? {};
    final customerMonthly = List<int>.from(customers['monthly'] ?? []);

    if (customerMonthly.length < 2) return 'Tracking';

    int gains = 0;
    int losses = 0;

    for (int i = 1; i < customerMonthly.length; i++) {
      int change = customerMonthly[i] - customerMonthly[i - 1];
      if (change > 0) gains++;
      if (change < 0) losses++;
    }

    if (gains > losses) return 'Improving';
    if (losses > gains) return 'Declining';
    return 'Stable';
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: ModernTheme.body2.copyWith(
            color: ModernTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Map<String, double> _getMonthlyExpenseData(int month) {
    // Get real user expense data from analytics data
    if (_analyticsData == null || _analyticsData!['expenses'] == null) {
      // No real data exists - return empty map
      return {};
    }

    final Map<String, dynamic> expensesData =
        _analyticsData!['expenses'] as Map<String, dynamic>;
    final Map<String, dynamic> categories =
        expensesData['categories'] as Map<String, dynamic>? ?? {};
    final List<dynamic> monthlyTotals =
        expensesData['monthly'] as List<dynamic>? ?? [];

    // Check if there's data for the selected month
    if (monthlyTotals.isEmpty || month > monthlyTotals.length) {
      return {};
    }

    final double monthlyTotal = (monthlyTotals[month - 1] ?? 0.0).toDouble();

    // If no expenses for this month, return empty
    if (monthlyTotal <= 0 || categories.isEmpty) {
      return {};
    }

    // Convert categories to the expected format
    final Map<String, double> monthlyExpenses = {};
    categories.forEach((category, amount) {
      final double expenseAmount = (amount ?? 0.0).toDouble();
      if (expenseAmount > 0) {
        monthlyExpenses[category.toString()] = expenseAmount;
      }
    });

    return monthlyExpenses;
  }

  Color _getCategoryColor(String category) {
    // Generate consistent colors for user-entered category names
    final List<Color> categoryColors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFFC107), // Amber
      const Color(0xFF673AB7), // Deep Purple
    ];

    // Use hash code to consistently assign colors to categories
    final colorIndex =
        category.toLowerCase().hashCode.abs() % categoryColors.length;
    return categoryColors[colorIndex];
  }
}
