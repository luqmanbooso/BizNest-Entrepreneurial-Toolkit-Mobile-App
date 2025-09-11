import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinancialCalculatorScreen extends StatefulWidget {
  const FinancialCalculatorScreen({super.key});

  @override
  State<FinancialCalculatorScreen> createState() =>
      _FinancialCalculatorScreenState();
}

class _FinancialCalculatorScreenState extends State<FinancialCalculatorScreen> {
  final _initialInvestmentController = TextEditingController();
  final _monthlyRevenueController = TextEditingController();
  final _monthlyExpensesController = TextEditingController();
  final _growthRateController = TextEditingController();

  double _projectedRevenue = 0;
  double _projectedProfit = 0;
  double _roi = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 30),
                _buildInputSection(),
                const SizedBox(height: 30),
                _buildResultsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Calculator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Calculate your business financial projections and ROI.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Metrics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            'Initial Investment (\$)',
            _initialInvestmentController,
            Icons.attach_money,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Monthly Revenue (\$)',
            _monthlyRevenueController,
            Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Monthly Expenses (\$)',
            _monthlyExpensesController,
            Icons.trending_down,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Monthly Growth Rate (%)',
            _growthRateController,
            Icons.percent,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculateProjections,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Calculate Projections',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '12-Month Projections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildResultCard(
            'Projected Revenue',
            '\$${_projectedRevenue.toStringAsFixed(2)}',
            Icons.attach_money,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildResultCard(
            'Projected Profit',
            '\$${_projectedProfit.toStringAsFixed(2)}',
            Icons.trending_up,
            const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),
          _buildResultCard(
            'Return on Investment',
            '${_roi.toStringAsFixed(1)}%',
            Icons.percent,
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _calculateProjections() {
    final initialInvestment =
        double.tryParse(_initialInvestmentController.text) ?? 0;
    final monthlyRevenue = double.tryParse(_monthlyRevenueController.text) ?? 0;
    final monthlyExpenses =
        double.tryParse(_monthlyExpensesController.text) ?? 0;
    final growthRate = double.tryParse(_growthRateController.text) ?? 0;

    if (monthlyRevenue > 0 && monthlyExpenses >= 0) {
      double totalRevenue = 0;
      double totalExpenses = 0;
      double currentRevenue = monthlyRevenue;
      double currentExpenses = monthlyExpenses;

      for (int month = 1; month <= 12; month++) {
        totalRevenue += currentRevenue;
        totalExpenses += currentExpenses;

        // Apply growth rate
        currentRevenue *= (1 + growthRate / 100);
        currentExpenses *=
            (1 + (growthRate * 0.7) / 100); // Expenses grow slower
      }

      setState(() {
        _projectedRevenue = totalRevenue;
        _projectedProfit = totalRevenue - totalExpenses;
        _roi = initialInvestment > 0
            ? (_projectedProfit / initialInvestment) * 100
            : 0;
      });

      Get.snackbar(
        'Calculation Complete',
        'Financial projections have been updated',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Input Error',
        'Please enter valid revenue and expense amounts',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _initialInvestmentController.dispose();
    _monthlyRevenueController.dispose();
    _monthlyExpensesController.dispose();
    _growthRateController.dispose();
    super.dispose();
  }
}
