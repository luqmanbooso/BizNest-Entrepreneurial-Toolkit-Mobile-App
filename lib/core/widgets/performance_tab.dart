import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/business_analytics_service.dart';
import '../theme/modern_theme.dart';

class PerformanceTab extends StatefulWidget {
  final String businessId;

  const PerformanceTab({
    super.key,
    required this.businessId,
  });

  @override
  State<PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<PerformanceTab> {
  List<Map<String, dynamic>>? _performanceData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  Future<void> _fetchPerformanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data =
          await BusinessAnalyticsService.getPerformanceData(widget.businessId);
      setState(() {
        _performanceData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading performance data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchPerformanceData,
      color: ModernTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_performanceData == null || _performanceData!.isEmpty)
              _buildEmptyState()
            else ...[
              _buildProfitChart(),
              const SizedBox(height: 24),
              _buildInsightsCard(),
              const SizedBox(height: 24),
              _buildNextQuarterForecast(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.trending_up,
          color: ModernTheme.primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profit Performance',
                style: ModernTheme.h3.copyWith(
                  color: ModernTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Monthly profit trends and insights',
                style: ModernTheme.body2.copyWith(
                  color: ModernTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: ModernTheme.primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading performance data...',
              style: ModernTheme.body1.copyWith(
                color: ModernTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
        border: Border.all(
          color: ModernTheme.errorRed.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: ModernTheme.errorRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Data',
              style: ModernTheme.h4.copyWith(
                color: ModernTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: ModernTheme.body2.copyWith(
                color: ModernTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchPerformanceData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insert_chart_outlined,
              color: ModernTheme.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'No Performance Data Yet',
              style: ModernTheme.h4.copyWith(
                color: ModernTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by adding revenue and expense data to see your profit performance trends.',
              style: ModernTheme.body1.copyWith(
                color: ModernTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/business-data-entry');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Business Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitChart() {
    if (_performanceData == null || _performanceData!.isEmpty) {
      return const SizedBox();
    }

    // Prepare chart data
    final spots = <FlSpot>[];
    for (int i = 0; i < _performanceData!.length; i++) {
      final profit =
          (_performanceData![i]['profit'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), profit));
    }

    // Calculate min and max for better chart scaling
    double minY = spots.isEmpty
        ? 0
        : spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.isEmpty
        ? 100
        : spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    // Add padding to min/max
    final padding = (maxY - minY) * 0.1;
    minY = minY - padding;
    maxY = maxY + padding;

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
              const Icon(
                Icons.show_chart,
                color: ModernTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Monthly Profit Trend',
                style: ModernTheme.h4.copyWith(
                  color: ModernTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: (maxY - minY) / 5,
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
                        _formatCurrency(value),
                        style: ModernTheme.caption.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _performanceData!.length) {
                          final data = _performanceData![index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${_getMonthName(data['month'])}\n${data['year']}',
                              style: ModernTheme.caption.copyWith(fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
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
                    color: ModernTheme.textSecondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: ModernTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isProfit = spot.y >= 0;
                        return FlDotCirclePainter(
                          radius: 4,
                          color: isProfit
                              ? ModernTheme.freshGreen
                              : ModernTheme.errorRed,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ModernTheme.primaryColor.withOpacity(0.3),
                          ModernTheme.primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < _performanceData!.length) {
                          final data = _performanceData![index];
                          return LineTooltipItem(
                            '${_getMonthName(data['month'])} ${data['year']}\n'
                            'Revenue: ${_formatCurrency(data['revenue'])}\n'
                            'Expenses: ${_formatCurrency(data['expenses'])}\n'
                            'Profit: ${_formatCurrency(data['profit'])}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }
                        return null;
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

  Widget _buildInsightsCard() {
    if (_performanceData == null || _performanceData!.length < 2) {
      return const SizedBox();
    }

    // Get latest and previous month data
    final latestData = _performanceData!.last;
    final previousData = _performanceData![_performanceData!.length - 2];

    final latestProfit = (latestData['profit'] as num?)?.toDouble() ?? 0.0;
    final previousProfit = (previousData['profit'] as num?)?.toDouble() ?? 0.0;

    // Calculate growth percentage
    double growthPercentage = 0.0;
    if (previousProfit != 0) {
      growthPercentage =
          ((latestProfit - previousProfit) / previousProfit.abs()) * 100;
    } else if (latestProfit > 0) {
      growthPercentage = 100.0; // New profit from zero
    }

    final isPositiveGrowth = growthPercentage > 0;
    final isProfit = latestProfit >= 0;

    String insightMessage;
    Color insightColor;
    IconData insightIcon;

    if (isPositiveGrowth && isProfit) {
      insightMessage =
          'Profit up ${growthPercentage.abs().toStringAsFixed(1)}% this month!';
      insightColor = ModernTheme.freshGreen;
      insightIcon = Icons.trending_up;
    } else if (isPositiveGrowth && !isProfit) {
      insightMessage =
          'Losses reduced by ${growthPercentage.abs().toStringAsFixed(1)}%. Progress!';
      insightColor = ModernTheme.goldenYellow;
      insightIcon = Icons.trending_up;
    } else if (!isPositiveGrowth && isProfit) {
      insightMessage =
          'Profit down ${growthPercentage.abs().toStringAsFixed(1)}%. Review expenses.';
      insightColor = ModernTheme.sunsetOrange;
      insightIcon = Icons.trending_down;
    } else {
      insightMessage =
          'Losses increased by ${growthPercentage.abs().toStringAsFixed(1)}%. Action needed.';
      insightColor = ModernTheme.errorRed;
      insightIcon = Icons.trending_down;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
        border: Border.all(
          color: insightColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: ModernTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Insights',
                style: ModernTheme.h4.copyWith(
                  color: ModernTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main insight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: insightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  insightIcon,
                  color: insightColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insightMessage,
                    style: ModernTheme.h4.copyWith(
                      color: insightColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detailed metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Current Month',
                  _formatCurrency(latestProfit),
                  '${_getMonthName(latestData['month'])} ${latestData['year']}',
                  isProfit ? ModernTheme.freshGreen : ModernTheme.errorRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Previous Month',
                  _formatCurrency(previousProfit),
                  '${_getMonthName(previousData['month'])} ${previousData['year']}',
                  ModernTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      String label, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ModernTheme.caption.copyWith(
              color: ModernTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ModernTheme.h4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: ModernTheme.caption.copyWith(
              color: ModernTheme.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return '\$0';

    if (amount.abs() >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  Widget _buildNextQuarterForecast() {
    if (_performanceData == null || _performanceData!.length < 2) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ModernTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ModernTheme.modernShadow,
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
                  Icons.auto_graph,
                  color: ModernTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next Quarter Forecast',
                  style: ModernTheme.h4.copyWith(
                    color: ModernTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernTheme.goldenYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: ModernTheme.goldenYellow,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Not enough data to generate forecast. Add more monthly data to see predictions.',
                      style: ModernTheme.body1.copyWith(
                        color: ModernTheme.textPrimary,
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

    // Get the last two quarters of data for calculations
    final currentData = _performanceData!.last;
    final previousData = _performanceData![_performanceData!.length - 2];

    // Extract values with safe casting
    final currentRevenue = (currentData['revenue'] as num?)?.toDouble() ?? 0.0;
    final previousRevenue =
        (previousData['revenue'] as num?)?.toDouble() ?? 0.0;
    final currentExpenses =
        (currentData['expenses'] as num?)?.toDouble() ?? 0.0;
    final previousExpenses =
        (previousData['expenses'] as num?)?.toDouble() ?? 0.0;
    final currentCustomers =
        (currentData['customers'] as num?)?.toDouble() ?? 0.0;
    final previousCustomers =
        (previousData['customers'] as num?)?.toDouble() ?? 0.0;

    // Calculate growth rates
    final revenueGrowthRate = previousRevenue != 0
        ? (currentRevenue - previousRevenue) / previousRevenue
        : 0.0;
    final expenseGrowthRate = previousExpenses != 0
        ? (currentExpenses - previousExpenses) / previousExpenses
        : 0.0;
    final customerGrowthRate = previousCustomers != 0
        ? (currentCustomers - previousCustomers) / previousCustomers
        : 0.0;

    // Calculate next quarter predictions
    final nextQuarterRevenue = currentRevenue * (1 + revenueGrowthRate);
    final nextQuarterExpenses = currentExpenses * (1 + expenseGrowthRate);
    final nextQuarterCustomers = currentCustomers * (1 + customerGrowthRate);
    final nextQuarterProfit = nextQuarterRevenue - nextQuarterExpenses;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
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
                Icons.auto_graph,
                color: ModernTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Next Quarter Forecast',
                style: ModernTheme.h4.copyWith(
                  color: ModernTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Forecast metrics grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildForecastMetric(
                      'Revenue',
                      nextQuarterRevenue,
                      revenueGrowthRate * 100,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildForecastMetric(
                      'Expenses',
                      nextQuarterExpenses,
                      expenseGrowthRate * 100,
                      Icons.money_off,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildForecastMetric(
                      'Customers',
                      nextQuarterCustomers,
                      customerGrowthRate * 100,
                      Icons.people,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildForecastMetric(
                      'Profit',
                      nextQuarterProfit,
                      ((nextQuarterProfit -
                                  (currentRevenue - currentExpenses)) /
                              (currentRevenue - currentExpenses).abs()) *
                          100,
                      Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernTheme.textSecondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: ModernTheme.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Forecast based on recent growth trends. Actual results may vary.',
                    style: ModernTheme.caption.copyWith(
                      color: ModernTheme.textSecondary,
                      fontSize: 11,
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

  Widget _buildForecastMetric(
      String label, double value, double growthPercentage, IconData icon) {
    final isPositiveGrowth = growthPercentage >= 0;
    final growthColor =
        isPositiveGrowth ? ModernTheme.freshGreen : ModernTheme.errorRed;
    final growthIcon =
        isPositiveGrowth ? Icons.arrow_upward : Icons.arrow_downward;

    // Format value based on the metric type
    String formattedValue;
    if (label == 'Customers') {
      formattedValue = value.toStringAsFixed(0);
    } else {
      formattedValue = _formatCurrency(value);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ModernTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: ModernTheme.body2.copyWith(
                    color: ModernTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formattedValue,
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                growthIcon,
                color: growthColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositiveGrowth ? '+' : ''}${growthPercentage.toStringAsFixed(1)}%',
                style: ModernTheme.caption.copyWith(
                  color: growthColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'growth',
                style: ModernTheme.caption.copyWith(
                  color: ModernTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
