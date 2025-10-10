import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/business_analytics_service.dart';
import '../core/theme/modern_theme.dart';

class BusinessDataEntryScreen extends StatefulWidget {
  const BusinessDataEntryScreen({super.key});

  @override
  State<BusinessDataEntryScreen> createState() =>
      _BusinessDataEntryScreenState();
}

class _BusinessDataEntryScreenState extends State<BusinessDataEntryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _businessNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _revenueController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _customerCountController = TextEditingController();

  // Expense controllers
  final _marketingController = TextEditingController();
  final _operationsController = TextEditingController();
  final _salariesController = TextEditingController();
  final _rentController = TextEditingController();
  final _utilitiesController = TextEditingController();

  // Customer controllers
  final _totalCustomersController = TextEditingController();
  final _retentionRateController = TextEditingController();
  final _lifetimeValueController = TextEditingController();
  final _acquisitionCostController = TextEditingController();

  // Performance controllers
  final _roiController = TextEditingController();
  final _marketShareController = TextEditingController();
  final _npsScoreController = TextEditingController();
  final _runwayController = TextEditingController();
  final _profitMarginController = TextEditingController();

  bool _isLoading = false;
  String? _businessId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _businessId = FirebaseAuth.instance.currentUser?.uid ?? 'default_business';
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _businessNameController.dispose();
    _industryController.dispose();
    _revenueController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _customerCountController.dispose();
    _marketingController.dispose();
    _operationsController.dispose();
    _salariesController.dispose();
    _rentController.dispose();
    _utilitiesController.dispose();
    _totalCustomersController.dispose();
    _retentionRateController.dispose();
    _lifetimeValueController.dispose();
    _acquisitionCostController.dispose();
    _roiController.dispose();
    _marketShareController.dispose();
    _npsScoreController.dispose();
    _runwayController.dispose();
    _profitMarginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Business Data Entry',
          style: ModernTheme.h3.copyWith(
            color: ModernTheme.primaryColor,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ModernTheme.primaryColor,
          unselectedLabelColor: ModernTheme.textSecondary,
          indicatorColor: ModernTheme.primaryColor,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Revenue'),
            Tab(text: 'Expenses'),
            Tab(text: 'Metrics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusinessProfileTab(),
          _buildRevenueTab(),
          _buildExpensesTab(),
          _buildMetricsTab(),
        ],
      ),
    );
  }

  Widget _buildBusinessProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Profile',
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _businessNameController,
            label: 'Business Name',
            hint: 'Enter your business name',
            icon: Icons.business,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _industryController,
            label: 'Industry',
            hint: 'e.g., Technology, Retail, Healthcare',
            icon: Icons.category,
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            'Create Business Profile',
            Icons.create,
            () => _createBusinessProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Data',
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _monthController,
                  label: 'Month (1-12)',
                  hint: 'e.g., 10',
                  icon: Icons.calendar_month,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _yearController,
                  label: 'Year',
                  hint: 'e.g., 2025',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _revenueController,
            label: 'Revenue Amount (\$)',
            hint: 'e.g., 50000',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _customerCountController,
            label: 'Customer Count (Optional)',
            hint: 'e.g., 250 customers',
            icon: Icons.people,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            'Add Monthly Revenue',
            Icons.add_chart,
            () => _addMonthlyRevenue(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Categories',
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _marketingController,
            label: 'Marketing (\$)',
            hint: 'e.g., 5000',
            icon: Icons.campaign,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _operationsController,
            label: 'Operations (\$)',
            hint: 'e.g., 8000',
            icon: Icons.settings,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _salariesController,
            label: 'Salaries (\$)',
            hint: 'e.g., 15000',
            icon: Icons.people,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _rentController,
            label: 'Rent (\$)',
            hint: 'e.g., 3000',
            icon: Icons.home,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _utilitiesController,
            label: 'Utilities (\$)',
            hint: 'e.g., 500',
            icon: Icons.electrical_services,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            'Save Expense Data',
            Icons.save,
            () => _addExpenseData(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Metrics',
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _totalCustomersController,
                  label: 'Total Customers',
                  hint: 'e.g., 150',
                  icon: Icons.people_alt,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _retentionRateController,
                  label: 'Retention Rate (%)',
                  hint: 'e.g., 85',
                  icon: Icons.favorite,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _roiController,
                  label: 'ROI (%)',
                  hint: 'e.g., 25',
                  icon: Icons.trending_up,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _profitMarginController,
                  label: 'Profit Margin (%)',
                  hint: 'e.g., 15',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _npsScoreController,
                  label: 'NPS Score (0-100)',
                  hint: 'e.g., 70',
                  icon: Icons.star,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _runwayController,
                  label: 'Runway (months)',
                  hint: 'e.g., 18',
                  icon: Icons.schedule,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            'Save Business Metrics',
            Icons.analytics,
            () => _addBusinessMetrics(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ModernTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ModernTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: ModernTheme.body1.copyWith(
            color: ModernTheme.textSecondary,
          ),
          hintStyle: ModernTheme.body2.copyWith(
            color: ModernTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          _isLoading ? 'Saving...' : text,
          style: ModernTheme.body1.copyWith(
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
        ),
      ),
    );
  }

  Future<void> _createBusinessProfile() async {
    if (_businessNameController.text.isEmpty ||
        _industryController.text.isEmpty) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await BusinessAnalyticsService.createBusinessProfile(
        businessId: _businessId!,
        businessName: _businessNameController.text,
        industry: _industryController.text,
        businessType: 'Startup', // Add default business type
        description: 'Business profile created via BizNest app',
      );

      _showSnackBar('Business profile created successfully!');
      _clearControllers([_businessNameController, _industryController]);
    } catch (e) {
      _showSnackBar('Error creating business profile', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMonthlyRevenue() async {
    if (_revenueController.text.isEmpty ||
        _monthController.text.isEmpty ||
        _yearController.text.isEmpty) {
      _showSnackBar('Please fill in all revenue fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse customer count if provided
      int? customerCount;
      if (_customerCountController.text.isNotEmpty) {
        customerCount = int.tryParse(_customerCountController.text);
      }

      await BusinessAnalyticsService.addMonthlyRevenue(
        businessId: _businessId!,
        amount: double.parse(_revenueController.text),
        month: int.parse(_monthController.text),
        year: int.parse(_yearController.text),
        customerCount: customerCount,
      );

      _showSnackBar('Monthly revenue added successfully!');
      _clearControllers([
        _revenueController,
        _monthController,
        _yearController,
        _customerCountController
      ]);
    } catch (e) {
      _showSnackBar('Error adding revenue data', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addExpenseData() async {
    setState(() => _isLoading = true);

    try {
      final expenseCategories = <String, double>{};

      if (_marketingController.text.isNotEmpty) {
        expenseCategories['marketing'] =
            double.parse(_marketingController.text);
      }
      if (_operationsController.text.isNotEmpty) {
        expenseCategories['operations'] =
            double.parse(_operationsController.text);
      }
      if (_salariesController.text.isNotEmpty) {
        expenseCategories['salaries'] = double.parse(_salariesController.text);
      }
      if (_rentController.text.isNotEmpty) {
        expenseCategories['rent'] = double.parse(_rentController.text);
      }
      if (_utilitiesController.text.isNotEmpty) {
        expenseCategories['utilities'] =
            double.parse(_utilitiesController.text);
      }

      if (expenseCategories.isEmpty) {
        _showSnackBar('Please enter at least one expense category',
            isError: true);
        return;
      }

      await BusinessAnalyticsService.addExpenseData(
        businessId: _businessId!,
        categoryExpenses: expenseCategories,
        month: DateTime.now().month,
        year: DateTime.now().year,
      );

      _showSnackBar('Expense data saved successfully!');
      _clearControllers([
        _marketingController,
        _operationsController,
        _salariesController,
        _rentController,
        _utilitiesController
      ]);
    } catch (e) {
      _showSnackBar('Error saving expense data', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBusinessMetrics() async {
    setState(() => _isLoading = true);

    try {
      // Add customer data if provided
      if (_totalCustomersController.text.isNotEmpty) {
        await BusinessAnalyticsService.addCustomerData(
          businessId: _businessId!,
          totalCustomers: int.parse(_totalCustomersController.text),
          monthlyNew: _retentionRateController.text.isNotEmpty
              ? (double.parse(_retentionRateController.text) *
                      int.parse(_totalCustomersController.text) /
                      100)
                  .round()
              : null,
          month: DateTime.now().month,
        );
      }

      // Add performance metrics if provided
      Map<String, double> kpis = {};

      if (_roiController.text.isNotEmpty) {
        kpis['roi'] = double.parse(_roiController.text);
      }
      if (_profitMarginController.text.isNotEmpty) {
        kpis['profit_margin'] = double.parse(_profitMarginController.text);
      }

      Map<String, dynamic> additionalMetrics = {};
      if (_npsScoreController.text.isNotEmpty) {
        additionalMetrics['nps_score'] = int.parse(_npsScoreController.text);
      }
      if (_runwayController.text.isNotEmpty) {
        additionalMetrics['runway_months'] = int.parse(_runwayController.text);
      }

      if (kpis.isNotEmpty) {
        await BusinessAnalyticsService.addPerformanceMetrics(
          businessId: _businessId!,
          kpis: kpis,
          additionalMetrics:
              additionalMetrics.isNotEmpty ? additionalMetrics : null,
        );
      }

      _showSnackBar('Business metrics saved successfully!');
      _clearControllers([
        _totalCustomersController,
        _retentionRateController,
        _roiController,
        _profitMarginController,
        _npsScoreController,
        _runwayController
      ]);
    } catch (e) {
      _showSnackBar('Error saving business metrics', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.clear();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? ModernTheme.errorRed : ModernTheme.freshGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
