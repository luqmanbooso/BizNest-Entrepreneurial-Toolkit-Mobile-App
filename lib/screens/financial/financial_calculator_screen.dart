import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../../utils/modern_theme.dart';
import '../../utils/advanced_animations.dart';

class FinancialCalculatorScreen extends StatefulWidget {
  @override
  _FinancialCalculatorScreenState createState() =>
      _FinancialCalculatorScreenState();
}

class _FinancialCalculatorScreenState extends State<FinancialCalculatorScreen> {
  final _revenueController = TextEditingController();
  final _expensesController = TextEditingController();
  final _initialInvestmentController = TextEditingController();

  double _projectedRevenue = 0.0;
  double _projectedExpenses = 0.0;
  double _projectedProfit = 0.0;
  double _breakEvenMonths = 0.0;

  @override
  void dispose() {
    _revenueController.dispose();
    _expensesController.dispose();
    _initialInvestmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingElementsAnimation(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildCalculatorTools(),
                        const SizedBox(height: 30),
                        _buildInputSection(),
                        const SizedBox(height: 30),
                        _buildResultsSection(),
                        const SizedBox(height: 30),
                        _buildFinancialTips(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildModernFAB(),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: FadeInDown(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFF0F172A),
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calculate_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ShimmerEffect(
                  child: const Text(
                    'Financial\nCalculator',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 200),
          child: const Text(
            'Quick Calculators',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildToolCard(
              'Break-Even\nAnalysis',
              Icons.balance_rounded,
              AppTheme.primaryGradient,
              () => _calculateBreakEven(),
              0,
            ),
            _buildToolCard(
              'ROI\nCalculator',
              Icons.trending_up_rounded,
              AppTheme.accentGradient,
              () => _calculateROI(),
              1,
            ),
            _buildToolCard(
              'Cash Flow\nProjection',
              Icons.water_drop_rounded,
              AppTheme.successGradient,
              () => _projectCashFlow(),
              2,
            ),
            _buildToolCard(
              'Valuation\nEstimator',
              Icons.monetization_on_rounded,
              LinearGradient(
                colors: [AppTheme.warningColor, AppTheme.tertiaryColor],
              ),
              () => _estimateValuation(),
              3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCard(
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
    int index,
  ) {
    return FadeInUp(
      delay: Duration(milliseconds: 400 + (index * 100)),
      child: GestureDetector(
        onTap: onTap,
        child: ModernCard(
          gradient: gradient,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.input_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Financial Inputs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _revenueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Revenue (\$)',
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
              onChanged: (value) => _calculateProjections(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _expensesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Expenses (\$)',
                prefixIcon: Icon(Icons.money_off_rounded),
              ),
              onChanged: (value) => _calculateProjections(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _initialInvestmentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Initial Investment (\$)',
                prefixIcon: Icon(Icons.savings_rounded),
              ),
              onChanged: (value) => _calculateProjections(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: MorphingButton(
                text: 'Calculate Projections',
                onPressed: _calculateProjections,
                gradient: AppTheme.primaryGradient,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1000),
      child: ModernCard(
        gradient: AppTheme.accentGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Financial Projections',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildResultCard('Annual Revenue',
                    '\$${(_projectedRevenue * 12).toStringAsFixed(0)}'),
                _buildResultCard('Annual Expenses',
                    '\$${(_projectedExpenses * 12).toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildResultCard('Annual Profit',
                    '\$${(_projectedProfit * 12).toStringAsFixed(0)}'),
                _buildResultCard('Break-Even',
                    '${_breakEvenMonths.toStringAsFixed(1)} months'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _projectedProfit > 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: _projectedProfit > 0
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _projectedProfit > 0
                          ? 'Your business model shows positive profitability!'
                          : 'Review your costs to improve profitability.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialTips() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1200),
      child: ModernCard(
        gradient: LinearGradient(
          colors: [AppTheme.successColor, AppTheme.accentColor],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Financial Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '• Track your cash flow regularly to avoid liquidity issues\n'
              '• Maintain 3-6 months of operating expenses as emergency fund\n'
              '• Review and optimize your pricing strategy quarterly\n'
              '• Consider multiple revenue streams to reduce risk',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFAB() {
    return ModernFAB(
      onPressed: () => _exportReport(),
      icon: Icons.download_rounded,
      gradient: AppTheme.accentGradient,
    );
  }

  void _calculateProjections() {
    final revenue = double.tryParse(_revenueController.text) ?? 0.0;
    final expenses = double.tryParse(_expensesController.text) ?? 0.0;
    final investment =
        double.tryParse(_initialInvestmentController.text) ?? 0.0;

    setState(() {
      _projectedRevenue = revenue;
      _projectedExpenses = expenses;
      _projectedProfit = revenue - expenses;

      if (_projectedProfit > 0 && investment > 0) {
        _breakEvenMonths = investment / _projectedProfit;
      } else {
        _breakEvenMonths = 0.0;
      }
    });
  }

  void _calculateBreakEven() {
    Get.snackbar(
      'Break-Even Analysis',
      'Opening break-even calculator...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _calculateROI() {
    Get.snackbar(
      'ROI Calculator',
      'Opening return on investment calculator...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }

  void _projectCashFlow() {
    Get.snackbar(
      'Cash Flow Projection',
      'Opening cash flow projection tool...',
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _estimateValuation() {
    Get.snackbar(
      'Valuation Estimator',
      'Opening business valuation calculator...',
      backgroundColor: AppTheme.warningColor,
      colorText: Colors.white,
    );
  }

  void _exportReport() {
    Get.snackbar(
      'Export Report',
      'Generating financial analysis report...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }
}
