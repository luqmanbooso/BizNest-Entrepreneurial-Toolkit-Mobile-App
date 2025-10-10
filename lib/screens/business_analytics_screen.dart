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
  String _selectedTimeframe = 'Monthly';
  int _selectedTabIndex = 0;

  final List<String> _timeframes = ['Monthly', 'Quarterly', 'Yearly'];
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
        _analyticsData = data;
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
                      Icons.trending_up, 'Monthly Revenue & Growth'),
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
                    icon: Icon(
                      Icons.help_outline,
                      color: ModernTheme.primaryColor,
                    ),
                    label: Text(
                      'Learn How',
                      style: TextStyle(
                        color: ModernTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ModernTheme.primaryColor),
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
            '\$${(revenue['yearly'] as double).toStringAsFixed(0)}',
            Icons.trending_up,
            ModernTheme.freshGreen,
            '+${revenue['growth_rate'].toStringAsFixed(1)}%',
          ),
          _buildMetricCard(
            'Total Customers',
            '${customers['total'] ?? 0}',
            Icons.people,
            ModernTheme.primaryColor,
            'Total customers',
          ),
          _buildMetricCard(
            'Monthly Revenue',
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
            'Monthly Average',
            '${_calculateMonthlyAverage(customers['monthly'])}',
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
    final revenue = _analyticsData!['revenue'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Performance Metrics'),
        const SizedBox(height: 20),
        _buildMetricsGrid([
          _buildMetricCard(
            'Revenue',
            '\$${(revenue['yearly'] ?? 0.0).toStringAsFixed(0)}',
            Icons.assessment,
            ModernTheme.freshGreen,
            'Annual revenue',
          ),
          _buildMetricCard(
            'Business Health',
            'Active',
            Icons.pie_chart,
            ModernTheme.primaryColor,
            'Business status',
          ),
          _buildMetricCard(
            'Performance',
            'Growing',
            Icons.star,
            ModernTheme.goldenYellow,
            'Business growth',
          ),
          _buildMetricCard(
            'Activity',
            'Tracking',
            Icons.schedule,
            ModernTheme.freshGreen,
            'Data collection',
          ),
        ]),
        const SizedBox(height: 24),
        _buildPerformanceInsights(),
      ],
    );
  }

  Widget _buildMetricsGrid(List<Widget> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: ModernTheme.h4.copyWith(
              fontSize: 18,
              color: ModernTheme.textPrimary,
              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: ModernTheme.body2.copyWith(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
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
    final monthlyRevenue =
        List<double>.from(_analyticsData!['revenue']['monthly']);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: ModernTheme.textSecondary.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 2,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const months = [
                    'J',
                    'F',
                    'M',
                    'A',
                    'M',
                    'J',
                    'J',
                    'A',
                    'S',
                    'O',
                    'N',
                    'D'
                  ];
                  if (value.toInt() < months.length) {
                    return Text(
                      months[value.toInt()],
                      style: ModernTheme.body2.copyWith(
                        fontSize: 12,
                        color: ModernTheme.textSecondary,
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
                interval: 10000,
                reservedSize: 50,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(0)}K',
                    style: ModernTheme.body2.copyWith(
                      fontSize: 10,
                      color: ModernTheme.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: monthlyRevenue.length.toDouble() - 1,
          minY: 0,
          maxY: monthlyRevenue.reduce((a, b) => a > b ? a : b) * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: monthlyRevenue.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  ModernTheme.primaryColor,
                  ModernTheme.primaryColor.withOpacity(0.3),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
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
                    ModernTheme.primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerGrowthChart() {
    final customerData =
        _analyticsData!['customers']['monthly'] ?? List.filled(12, 0);
    final monthlyCustomers = List<int>.from(customerData);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              monthlyCustomers.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: ModernTheme.primaryColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()} customers',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const months = [
                    'J',
                    'F',
                    'M',
                    'A',
                    'M',
                    'J',
                    'J',
                    'A',
                    'S',
                    'O',
                    'N',
                    'D'
                  ];
                  if (value.toInt() < months.length) {
                    return Text(
                      months[value.toInt()],
                      style: ModernTheme.body2.copyWith(
                        fontSize: 12,
                        color: ModernTheme.textSecondary,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          barGroups: monthlyCustomers.asMap().entries.map((entry) {
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
                      ModernTheme.primaryColor.withOpacity(0.3),
                    ],
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    final expenses =
        _analyticsData!['expenses']['categories'] as Map<String, dynamic>;

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
            final percentage = (entry.value / total * 100);

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
      insights.add(
          'Revenue tracking is active with \$${(revenue['yearly'] as double).toStringAsFixed(0)} annually');
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
            Icon(
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
  String _calculateMonthlyAverage(dynamic monthlyData) {
    if (monthlyData == null) return '0';
    final data = List<int>.from(monthlyData);
    if (data.isEmpty) return '0';
    final sum = data.fold(0, (prev, element) => prev + element);
    return (sum / data.length).toStringAsFixed(0);
  }

  String _calculateRevenuePerCustomer() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final customers = _analyticsData!['customers'] ?? {};

    final revenueMonthly = List<double>.from(revenue['monthly'] ?? []);
    final customerMonthly = List<int>.from(customers['monthly'] ?? []);

    double totalRevenue = revenueMonthly.fold(0.0, (sum, val) => sum + val);
    int totalCustomerMonths = customerMonthly.fold(0, (sum, val) => sum + val);

    if (totalCustomerMonths == 0) return '0';
    return (totalRevenue / totalCustomerMonths).toStringAsFixed(0);
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

  Widget _buildPerformanceInsights() {
    final revenue = _analyticsData!['revenue'] ?? {};
    final customers = _analyticsData!['customers'] ?? {};

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
              Icon(
                Icons.insights,
                color: ModernTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Insights',
                style: ModernTheme.h3.copyWith(
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Based on your real business data:',
            style: ModernTheme.body1.copyWith(
              color: ModernTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (revenue['yearly'] != null && revenue['yearly'] > 0) ...[
            _buildInsightItem(
              'Revenue is being tracked with annual total of \$${(revenue['yearly'] as double).toStringAsFixed(0)}',
              Icons.trending_up,
              ModernTheme.freshGreen,
            ),
          ],
          if (customers['total'] != null && customers['total'] > 0) ...[
            _buildInsightItem(
              'Customer base shows ${customers['total']} active customers',
              Icons.people,
              ModernTheme.primaryColor,
            ),
          ],
          if (revenue['yearly'] != null &&
              revenue['yearly'] > 0 &&
              customers['total'] != null &&
              customers['total'] > 0) ...[
            _buildInsightItem(
              'Average revenue per customer: \$${_calculateRevenuePerCustomer()}',
              Icons.analytics,
              ModernTheme.freshGreen,
            ),
            _buildInsightItem(
              'Customer retention trend: ${_getCustomerRetentionTrend()}',
              Icons.favorite,
              ModernTheme.primaryColor,
            ),
          ],
          _buildInsightItem(
            'Continue adding business data for more detailed insights',
            Icons.add_chart,
            ModernTheme.sunsetOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: ModernTheme.body2.copyWith(
                color: ModernTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
