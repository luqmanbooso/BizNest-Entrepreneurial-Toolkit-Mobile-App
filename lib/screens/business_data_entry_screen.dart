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

  // Individual expense controllers
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _expenseMonthController = TextEditingController();
  final _expenseYearController = TextEditingController();

  // Expense data
  DateTime? _selectedExpenseDate;
  final List<Map<String, dynamic>> _individualExpenses = [];

  bool _isLoading = false;
  String? _businessId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    _expenseMonthController.dispose();
    _expenseYearController.dispose();
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusinessProfileTab(),
          _buildRevenueTab(),
          _buildExpensesTab(),
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
            'Monthly Expenses',
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          // Date Selection Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: ModernTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Month & Year',
                  style: ModernTheme.h4.copyWith(
                    color: ModernTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _expenseMonthController,
                        label: 'Month (1-12)',
                        hint: 'e.g., 11',
                        icon: Icons.calendar_month,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _expenseYearController,
                        label: 'Year',
                        hint: 'e.g., 2025',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _selectExpenseDate,
                  icon: const Icon(Icons.date_range),
                  label: Text(_selectedExpenseDate != null
                      ? 'Selected: ${_getFormattedDate(_selectedExpenseDate!)}'
                      : 'Pick Date from Calendar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primaryColor.withOpacity(0.1),
                    foregroundColor: ModernTheme.primaryColor,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Individual Expense Entry Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: ModernTheme.sunsetOrange.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Individual Expense',
                  style: ModernTheme.h4.copyWith(
                    color: ModernTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _expenseNameController,
                  label: 'Expense Name',
                  hint: 'e.g., Office Rent, Marketing Campaign',
                  icon: Icons.label,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _expenseAmountController,
                  label: 'Amount (\$)',
                  hint: 'e.g., 1500',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  'Add Expense',
                  Icons.add,
                  () => _addIndividualExpense(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Added Expenses List
          if (_individualExpenses.isNotEmpty) ...[
            Text(
              'Added Expenses',
              style: ModernTheme.h4.copyWith(
                color: ModernTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: ModernTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: ModernTheme.freshGreen.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  ..._individualExpenses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final expense = entry.value;
                    return _buildExpenseListItem(expense, index);
                  }),
                  if (_individualExpenses.isNotEmpty) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: ModernTheme.h4.copyWith(
                              color: ModernTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_calculateTotalExpenses().toStringAsFixed(2)}',
                            style: ModernTheme.h4.copyWith(
                              color: ModernTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Save All Expenses Button
          if (_individualExpenses.isNotEmpty) ...[
            _buildActionButton(
              'Save All Expenses',
              Icons.save,
              () => _saveMonthlyExpenses(),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Clear All',
              Icons.clear_all,
              () => _clearAllExpenses(),
              color: ModernTheme.errorRed,
            ),
          ],
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

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed,
      {Color? color}) {
    final buttonColor = color ?? ModernTheme.primaryColor;
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
          backgroundColor: buttonColor,
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

  // Date and expense management methods
  Future<void> _selectExpenseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpenseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select Expense Month',
    );

    if (picked != null) {
      setState(() {
        _selectedExpenseDate = picked;
        _expenseMonthController.text = picked.month.toString();
        _expenseYearController.text = picked.year.toString();
      });
    }
  }

  String _getFormattedDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  void _addIndividualExpense() {
    if (_expenseNameController.text.isEmpty) {
      _showSnackBar('Please enter expense name', isError: true);
      return;
    }

    if (_expenseAmountController.text.isEmpty) {
      _showSnackBar('Please enter expense amount', isError: true);
      return;
    }

    final amount = double.tryParse(_expenseAmountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    setState(() {
      _individualExpenses.add({
        'name': _expenseNameController.text,
        'amount': amount,
        'timestamp': DateTime.now(),
      });
    });

    // Clear the input fields
    _expenseNameController.clear();
    _expenseAmountController.clear();

    _showSnackBar('Expense added successfully!');
  }

  Widget _buildExpenseListItem(Map<String, dynamic> expense, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ModernTheme.primaryColor.withOpacity(0.1),
          child: const Icon(
            Icons.receipt_long,
            color: ModernTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          expense['name'],
          style: ModernTheme.body1.copyWith(
            color: ModernTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Added: ${_getFormattedTime(expense['timestamp'])}',
          style: ModernTheme.body2.copyWith(
            color: ModernTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${(expense['amount'] ?? 0.0).toStringAsFixed(2)}',
              style: ModernTheme.body1.copyWith(
                color: ModernTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeExpense(index),
              icon: const Icon(
                Icons.delete_outline,
                color: ModernTheme.errorRed,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _removeExpense(int index) {
    setState(() {
      _individualExpenses.removeAt(index);
    });
    _showSnackBar('Expense removed');
  }

  double _calculateTotalExpenses() {
    return _individualExpenses.fold(
        0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
  }

  Future<void> _saveMonthlyExpenses() async {
    if (_individualExpenses.isEmpty) {
      _showSnackBar('No expenses to save', isError: true);
      return;
    }

    if (_expenseMonthController.text.isEmpty ||
        _expenseYearController.text.isEmpty) {
      _showSnackBar('Please select month and year', isError: true);
      return;
    }

    final month = int.tryParse(_expenseMonthController.text);
    final year = int.tryParse(_expenseYearController.text);

    if (month == null || month < 1 || month > 12) {
      _showSnackBar('Please enter a valid month (1-12)', isError: true);
      return;
    }

    if (year == null || year < 2020 || year > 2030) {
      _showSnackBar('Please enter a valid year', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create expense categories map from individual expenses
      final Map<String, double> expenseCategories = {};

      for (var expense in _individualExpenses) {
        final name = expense['name'].toString().toLowerCase();
        expenseCategories[name] = expense['amount'] ?? 0.0;
      }

      await BusinessAnalyticsService.addExpenseData(
        businessId: _businessId!,
        categoryExpenses: expenseCategories,
        month: month,
        year: year,
      );

      _showSnackBar('Monthly expenses saved successfully!');
      _clearAllExpenses();
    } catch (e) {
      _showSnackBar('Error saving expenses: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearAllExpenses() {
    setState(() {
      _individualExpenses.clear();
      _expenseNameController.clear();
      _expenseAmountController.clear();
      _expenseMonthController.clear();
      _expenseYearController.clear();
      _selectedExpenseDate = null;
    });
  }
}
