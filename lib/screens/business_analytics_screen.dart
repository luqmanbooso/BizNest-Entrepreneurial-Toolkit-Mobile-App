import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/services/business_analytics_service.dart';
import '../core/theme/modern_theme.dart';

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
      return const Center(
        child: Text('No analytics data available'),
      );
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
    final revenue = _analyticsData!['revenue'];
    final customers = _analyticsData!['customers'];
    final performance = _analyticsData!['performance_metrics'];
    final health = _analyticsData!['financial_health'];

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
            '${customers['total']}',
            Icons.people,
            ModernTheme.primaryColor,
            '${customers['retention_rate'].toStringAsFixed(1)}% retention',
          ),
          _buildMetricCard(
            'Profit Margin',
            '${performance['profit_margin'].toStringAsFixed(1)}%',
            Icons.account_balance_wallet,
            ModernTheme.sunsetOrange,
            'ROI: ${performance['roi'].toStringAsFixed(1)}%',
          ),
          _buildMetricCard(
            'Health Score',
            '${health['score'].toStringAsFixed(1)}/10',
            Icons.health_and_safety,
            health['score'] > 7
                ? ModernTheme.freshGreen
                : ModernTheme.sunsetOrange,
            health['cash_flow_status'],
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
    final customers = _analyticsData!['customers'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Customer Analytics'),
        const SizedBox(height: 20),
        _buildMetricsGrid([
          _buildMetricCard(
            'Total Customers',
            '${customers['total']}',
            Icons.people,
            ModernTheme.primaryColor,
            'Active users',
          ),
          _buildMetricCard(
            'Retention Rate',
            '${customers['retention_rate'].toStringAsFixed(1)}%',
            Icons.favorite,
            ModernTheme.freshGreen,
            'Customer loyalty',
          ),
          _buildMetricCard(
            'Lifetime Value',
            '\$${customers['lifetime_value'].toStringAsFixed(0)}',
            Icons.monetization_on,
            ModernTheme.sunsetOrange,
            'Average LTV',
          ),
          _buildMetricCard(
            'Acquisition Cost',
            '\$${customers['acquisition_cost'].toStringAsFixed(0)}',
            Icons.trending_down,
            ModernTheme.errorRed,
            'Cost per customer',
          ),
        ]),
        const SizedBox(height: 24),
        _buildCustomerGrowthChart(),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    final performance = _analyticsData!['performance_metrics'];
    final predictions = _analyticsData!['predictions'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Performance Metrics'),
        const SizedBox(height: 20),
        _buildMetricsGrid([
          _buildMetricCard(
            'ROI',
            '${performance['roi'].toStringAsFixed(1)}%',
            Icons.assessment,
            ModernTheme.freshGreen,
            'Return on investment',
          ),
          _buildMetricCard(
            'Market Share',
            '${performance['market_share'].toStringAsFixed(1)}%',
            Icons.pie_chart,
            ModernTheme.primaryColor,
            'Industry position',
          ),
          _buildMetricCard(
            'NPS Score',
            '${performance['nps_score']}',
            Icons.star,
            ModernTheme.goldenYellow,
            'Customer satisfaction',
          ),
          _buildMetricCard(
            'Runway',
            '${performance['runway_months']} months',
            Icons.schedule,
            performance['runway_months'] > 12
                ? ModernTheme.freshGreen
                : ModernTheme.errorRed,
            'Financial runway',
          ),
        ]),
        const SizedBox(height: 24),
        _buildPredictionsCard(predictions),
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
    final monthlyCustomers =
        List<int>.from(_analyticsData!['customers']['new_monthly']);

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
    final predictions = _analyticsData!['predictions'];
    final actions = List<String>.from(predictions['recommended_actions']);

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
                'Quick Insights',
                style: ModernTheme.h4.copyWith(
                  fontSize: 16,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...actions.take(3).map((action) {
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
                      action,
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

  Widget _buildPredictionsCard(Map<String, dynamic> predictions) {
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
                Icons.trending_up,
                color: ModernTheme.freshGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Future Predictions',
                style: ModernTheme.h4.copyWith(
                  fontSize: 16,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPredictionItem(
            'Next Quarter Revenue',
            '\$${(predictions['next_quarter_revenue'] as double).toStringAsFixed(0)}',
            Icons.attach_money,
          ),
          _buildPredictionItem(
            'Growth Forecast',
            '${predictions['yearly_growth_forecast'].toStringAsFixed(1)}%',
            Icons.trending_up,
          ),
          _buildPredictionItem(
            'Risk Level',
            predictions['risk_assessment'],
            Icons.security,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: ModernTheme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: ModernTheme.body2.copyWith(
                fontSize: 14,
                color: ModernTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: ModernTheme.body1.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
