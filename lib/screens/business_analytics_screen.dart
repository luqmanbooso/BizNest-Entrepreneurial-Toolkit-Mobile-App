import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/services/business_analytics_service.dart';
import '../core/theme/modern_theme.dart';
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
  int _selectedTabIndex = 0;

  final List<String> _timeframes = ['Quarterly', 'Yearly'];
  final List<String> _tabTitles = [
    'Overview',
    'Revenue',
    'Customers',
    'Performance'
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
      final data = await BusinessAnalyticsService.generateBusinessAnalytics();
      setState(() {
        _analyticsData = data ?? _getDefaultAnalyticsData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load analytics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Provide default analytics data when no real data exists
  Map<String, dynamic> _getDefaultAnalyticsData() {
    return {
      'revenue': {
        'monthly': [
          8500,
          9200,
          8800,
          11200,
          12800,
          15600,
          16800,
          18200,
          16500,
          17800,
          19200,
          21500
        ], // Sample revenue progression
        'yearly': 196100.0,
        'growth_rate': 15.2,
        'projected_next_6_months': [
          22800,
          24100,
          25500,
          26900,
          28400,
          30000
        ], // Forecast data
      },
      'expenses': {
        'monthly': [
          6200,
          6800,
          6400,
          8100,
          9200,
          11000,
          11800,
          12600,
          11900,
          12400,
          13100,
          14200
        ],
        'categories': {
          'Marketing': 45000,
          'Operations': 38000,
          'Salaries': 95000,
          'Rent': 24000,
          'Utilities': 8100,
        },
      },
      'customers': {
        'monthly': [
          45,
          52,
          48,
          63,
          71,
          89,
          95,
          102,
          87,
          93,
          108,
          115
        ], // Sample customer data
        'total': 968,
        'retention_rate': 85.5,
        'acquisition_cost': 89.50,
      },
      'performance': {
        'profit_margin': 25.8,
        'roi': 135.2,
        'monthly_growth': [
          12.5,
          8.7,
          -4.3,
          27.3,
          14.3,
          21.9,
          7.7,
          8.3,
          -9.3,
          7.9,
          7.9,
          12.0
        ],
        'cash_flow_trend': 'positive',
        'burn_rate': 8500.0,
        'runway_months': 18,
      },
      'health': {
        'score': 0.0,
      },
      'business_info': {
        'name': 'Your Business',
        'industry': 'General',
        'type': 'Startup',
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
      case 3:
        return _buildPerformanceTab();
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
            'Performance',
            'Active',
            Icons.trending_up,
            ModernTheme.freshGreen,
            'Business metrics',
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
        _buildSectionTitle('Revenue Analysis'),
        const SizedBox(height: 20),
        _buildRevenueChart(),
        const SizedBox(height: 24),
        _buildExpenseBreakdown(),
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

  Widget _buildPerformanceTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Business Performance Overview'),
              const SizedBox(height: 20),

              // Performance Summary Cards
              _buildPerformanceSummarySection(isWide),
              const SizedBox(height: 24),

              // Business Trajectory Chart
              _buildTrajectoryChart(),
              const SizedBox(height: 24),

              // Forecast Section
              _buildForecastSection(),
              const SizedBox(height: 16),

              // Export Button
              _buildExportButton(),
            ],
          ),
        );
      },
    );
  }

  /// Performance Summary Section with key metrics and color-coded indicators
  Widget _buildPerformanceSummarySection(bool isWide) {
    final revenue = _analyticsData!['revenue'] ?? {};
    final performance = _analyticsData!['performance'] ?? {};
    final customers = _analyticsData!['customers'] ?? {};

    // Calculate metrics with trend indicators
    final totalRevenue = (revenue['yearly'] as num?)?.toDouble() ?? 0.0;
    final profitMargin =
        (performance['profit_margin'] as num?)?.toDouble() ?? 0.0;
    final monthlyGrowth = (revenue['growth_rate'] as num?)?.toDouble() ?? 0.0;
    final totalCustomers = (customers['total'] as num?)?.toInt() ?? 0;

    final summaryCards = [
      _buildSummaryCard(
        'Total Revenue',
        '\$${_formatNumber(totalRevenue)}',
        Icons.trending_up,
        monthlyGrowth > 0 ? ModernTheme.freshGreen : ModernTheme.sunsetOrange,
        '+${monthlyGrowth.toStringAsFixed(1)}%',
        monthlyGrowth > 0,
      ),
      _buildSummaryCard(
        'Profit Margin',
        '${profitMargin.toStringAsFixed(1)}%',
        Icons.account_balance_wallet,
        profitMargin > 20
            ? ModernTheme.freshGreen
            : profitMargin > 10
                ? ModernTheme.goldenYellow
                : ModernTheme.sunsetOrange,
        profitMargin > 20
            ? 'Excellent'
            : profitMargin > 10
                ? 'Good'
                : 'Needs Improvement',
        profitMargin > 15,
      ),
      _buildSummaryCard(
        'Monthly Growth',
        '${monthlyGrowth > 0 ? '+' : ''}${monthlyGrowth.toStringAsFixed(1)}%',
        monthlyGrowth > 0 ? Icons.arrow_upward : Icons.arrow_downward,
        monthlyGrowth > 0 ? ModernTheme.freshGreen : ModernTheme.sunsetOrange,
        monthlyGrowth > 0 ? 'Growing' : 'Declining',
        monthlyGrowth > 0,
      ),
      _buildSummaryCard(
        'Active Customers',
        _formatNumber(totalCustomers.toDouble()),
        Icons.people,
        ModernTheme.primaryColor,
        '${customers['retention_rate']?.toStringAsFixed(1)}% retention',
        (customers['retention_rate'] ?? 0) > 80,
      ),
    ];

    return isWide
        ? Row(
            children: summaryCards
                .map((card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: card,
                      ),
                    ))
                .toList(),
          )
        : GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: summaryCards,
          );
  }

  /// Enhanced summary card with trend indicators
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernTheme.modernShadow,
        border: const Border(
          left: BorderSide(
            width: 4,
            color: Colors.blue,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive
                    ? ModernTheme.freshGreen
                    : ModernTheme.sunsetOrange,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: ModernTheme.h4.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ModernTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: ModernTheme.body2.copyWith(
              fontSize: 12,
              color: ModernTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive
                  ? ModernTheme.freshGreen.withOpacity(0.1)
                  : ModernTheme.sunsetOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isPositive
                    ? ModernTheme.freshGreen
                    : ModernTheme.sunsetOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Business trajectory chart showing revenue and expense trends
  Widget _buildTrajectoryChart() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final expenses = _analyticsData!['expenses'] ?? {};

    final revenueData = (revenue['monthly'] as List<dynamic>?) ?? [];
    final expenseData = (expenses['monthly'] as List<dynamic>?) ?? [];

    if (revenueData.isEmpty || expenseData.isEmpty) {
      return const Center(child: Text('No trajectory data available'));
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.trending_up,
                  color: ModernTheme.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Business Trajectory',
                style: ModernTheme.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
              const Spacer(),
              _buildChartLegend(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ModernTheme.textSecondary.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: ModernTheme.textSecondary.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${_formatNumber(value)}',
                        style: ModernTheme.caption.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final months = [
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
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: ModernTheme.caption.copyWith(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: ModernTheme.textSecondary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  // Revenue Line
                  LineChartBarData(
                    spots: revenueData.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: ModernTheme.freshGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ModernTheme.freshGreen.withOpacity(0.1),
                    ),
                  ),
                  // Expense Line
                  LineChartBarData(
                    spots: expenseData.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: ModernTheme.sunsetOrange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ModernTheme.sunsetOrange.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isRevenue = spot.barIndex == 0;
                        return LineTooltipItem(
                          '${isRevenue ? 'Revenue' : 'Expenses'}\n\$${_formatNumber(spot.y)}',
                          TextStyle(
                            color: isRevenue
                                ? ModernTheme.freshGreen
                                : ModernTheme.sunsetOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chart legend for trajectory chart
  Widget _buildChartLegend() {
    return Row(
      children: [
        _buildLegendItem('Revenue', ModernTheme.freshGreen),
        const SizedBox(width: 16),
        _buildLegendItem('Expenses', ModernTheme.sunsetOrange),
      ],
    );
  }

  /// Individual legend item
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: ModernTheme.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Forecast section with 6-month projections
  Widget _buildForecastSection() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final forecast = revenue['forecast'] as List<dynamic>? ?? [];

    if (forecast.isEmpty) {
      return const Center(child: Text('No forecast data available'));
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.insights,
                  color: ModernTheme.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                '6-Month Revenue Forecast',
                style: ModernTheme.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernTheme.freshGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI Predicted',
                  style: TextStyle(
                    fontSize: 10,
                    color: ModernTheme.freshGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Forecast chart
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ModernTheme.textSecondary.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${_formatNumber(value)}',
                        style: ModernTheme.caption.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun'
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: ModernTheme.caption.copyWith(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: ModernTheme.textSecondary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: forecast.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: ModernTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    dashArray: [5, 5], // Dashed line for forecast
                    belowBarData: BarAreaData(
                      show: true,
                      color: ModernTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'Forecast\n\$${_formatNumber(spot.y)}',
                          const TextStyle(
                            color: ModernTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Forecast summary
          _buildForecastSummary(forecast),
        ],
      ),
    );
  }

  /// Forecast summary with key insights
  Widget _buildForecastSummary(List<dynamic> forecast) {
    if (forecast.isEmpty) return const SizedBox();

    final firstMonth = (forecast.first as num?)?.toDouble() ?? 0.0;
    final lastMonth = (forecast.last as num?)?.toDouble() ?? 0.0;
    final totalProjected = forecast.fold<double>(
        0.0, (sum, value) => sum + ((value as num?)?.toDouble() ?? 0.0));
    final averageGrowth =
        firstMonth != 0 ? ((lastMonth - firstMonth) / firstMonth * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildForecastMetric(
                  'Projected 6-Month Total',
                  '\$${_formatNumber(totalProjected)}',
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildForecastMetric(
                  'Expected Growth',
                  '${averageGrowth > 0 ? '+' : ''}${averageGrowth.toStringAsFixed(1)}%',
                  averageGrowth > 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernTheme.freshGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb,
                    color: ModernTheme.freshGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on current trends, your business is projected to maintain steady growth over the next 6 months.',
                    style: ModernTheme.caption.copyWith(
                      fontSize: 11,
                      color: ModernTheme.freshGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Individual forecast metric widget
  Widget _buildForecastMetric(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: ModernTheme.primaryColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: ModernTheme.h4.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernTheme.textPrimary,
                ),
              ),
              Text(
                title,
                style: ModernTheme.caption.copyWith(
                  fontSize: 10,
                  color: ModernTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Export button for analytics data
  Widget _buildExportButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement export functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export functionality coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Export Performance Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  /// Helper method to format numbers for display
  String _formatNumber(double? number) {
    if (number == null) return '0';

    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

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
    // Safely get revenue data with fallback to empty list
    final revenueData = _analyticsData != null &&
            _analyticsData!['revenue'] != null &&
            _analyticsData!['revenue']['monthly'] != null
        ? List<double>.from(_analyticsData!['revenue']['monthly'])
        : List.filled(12, 0.0);

    // Get data based on selected timeframe
    final List<double> displayData;
    final List<String> monthLabels;

    if (_selectedTimeframe == 'Yearly') {
      // Show all 12 months
      displayData = revenueData.length >= 12
          ? revenueData.take(12).toList()
          : revenueData;
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
      displayData = revenueData.length > quarterStart + 2
          ? revenueData.skip(quarterStart).take(3).toList()
          : revenueData.take(3).toList();

      final quarterMonths = [
        ['Jan', 'Feb', 'Mar'],
        ['Apr', 'May', 'Jun'],
        ['Jul', 'Aug', 'Sep'],
        ['Oct', 'Nov', 'Dec']
      ];
      monthLabels = quarterMonths[quarterStart ~/ 3];
    }

    // Calculate dynamic Y-axis maximum
    final maxValue = displayData.isEmpty
        ? 100.0
        : displayData.reduce((a, b) => a > b ? a : b);
    // Ensure minimum value to prevent zero intervals
    final safeMaxValue = maxValue <= 0 ? 100.0 : maxValue;
    final dynamicMaxY = safeMaxValue * 1.2; // Add 20% padding at top

    // Calculate Y-axis interval for better scaling (ensure it's never zero)
    final yInterval = dynamicMaxY / 5; // Show 5 intervals

    // Debug output
    print('🔍 Chart Debug: displayData: $displayData');
    print('🔍 Chart Debug: maxValue: $maxValue, safeMaxValue: $safeMaxValue');
    print('🔍 Chart Debug: dynamicMaxY: $dynamicMaxY, yInterval: $yInterval');

    return Container(
      height: 250,
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
                'Revenue Trends',
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
                maxX: (displayData.length - 1).toDouble(),
                minY: 0,
                maxY: dynamicMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: displayData.asMap().entries.map((entry) {
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
                          ModernTheme.primaryColor.withOpacity(0.3),
                          ModernTheme.primaryColor.withOpacity(0.05),
                        ],
                      ),
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
    // Safely get expenses categories with fallback to empty map
    final expenses = _analyticsData != null &&
            _analyticsData!['expenses'] != null &&
            _analyticsData!['expenses']['categories'] != null
        ? _analyticsData!['expenses']['categories'] as Map<String, dynamic>
        : <String, dynamic>{};

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
          Text(
            'Expense Breakdown',
            style: ModernTheme.h4.copyWith(
              fontSize: 16,
              color: ModernTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...expenses.entries.map((entry) {
            final total =
                expenses.values.fold(0.0, (sum, value) => sum + value);
            final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key.toString().toUpperCase(),
                      style: ModernTheme.body2.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ModernTheme.textPrimary,
                      ),
                    ),
                  ),
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
                            color: ModernTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: ModernTheme.body2.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ModernTheme.textSecondary,
                      ),
                      textAlign: TextAlign.end,
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

  /// Performance insights with actionable recommendations
  Widget _buildPerformanceInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.analytics,
                  color: ModernTheme.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Business Insights',
                style: ModernTheme.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ModernTheme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: ModernTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Performance Overview',
                      style: ModernTheme.h4.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ModernTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Review your business metrics above to gain insights into your financial performance, revenue trends, and growth opportunities.',
                  style: ModernTheme.body2.copyWith(
                    color: ModernTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Overall performance score widget
}
