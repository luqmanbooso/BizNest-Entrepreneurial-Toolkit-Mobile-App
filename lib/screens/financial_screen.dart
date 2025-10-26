import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/widgets/biznest_logo.dart';
import 'package:flutter/services.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardAnimation;

  final List<FinancialTool> _tools = [
    FinancialTool(
      title: 'Business Loans',
      description: 'Apply for pre-approved business loans from partner banks',
      icon: Icons.account_balance_rounded,
      color: ModernTheme.teal,
      features: ['Quick Approval', 'Competitive Rates', 'Direct to Banks'],
    ),
    FinancialTool(
      title: 'ROI Calculator',
      description: 'Calculate return on investment for your projects',
      icon: Icons.calculate_rounded,
      color: ModernTheme.primaryBlue,
      features: [
        'Investment Analysis',
        'Profit Calculations',
        'Break-even Analysis'
      ],
    ),
    FinancialTool(
      title: 'Cash Flow Tracker',
      description: 'Monitor your business cash flow in real-time',
      icon: Icons.trending_up_rounded,
      color: ModernTheme.accentGreen,
      features: ['Income Tracking', 'Expense Management', 'Forecasting'],
    ),
    FinancialTool(
      title: 'Budget Planner',
      description: 'Create and manage your business budget',
      icon: Icons.account_balance_wallet_rounded,
      color: ModernTheme.secondaryPurple,
      features: ['Budget Creation', 'Expense Categories', 'Monthly Reports'],
    ),
    FinancialTool(
      title: 'Tax Calculator',
      description: 'Calculate business taxes and deductions',
      icon: Icons.receipt_rounded,
      color: ModernTheme.warningOrange,
      features: ['Tax Estimation', 'Deduction Finder', 'Filing Assistance'],
    ),
  ];

  void _openROICalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: _ROICalculator(scrollController: controller),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _cardController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernTheme.lightGray,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                        child: Row(
                          children: [
                            const BizNestLogo(
                              size: 40,
                              showText: true,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Tools',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: ModernTheme.textPrimary,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Manage your finances and make informed decisions',
                              style: TextStyle(
                                fontSize: 16,
                                color: ModernTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Financial Overview Cards
                    AnimatedBuilder(
                      animation: _cardAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardAnimation.value,
                          child: FadeTransition(
                            opacity: _cardAnimation,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFinancialCard(
                                        'Total Revenue',
                                        '\$24,567',
                                        '+12.5%',
                                        Icons.trending_up_rounded,
                                        ModernTheme.accentGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildFinancialCard(
                                        'Expenses',
                                        '\$18,234',
                                        '+8.2%',
                                        Icons.trending_down_rounded,
                                        ModernTheme.errorRed,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFinancialCard(
                                        'Net Profit',
                                        '\$6,333',
                                        '+18.7%',
                                        Icons.account_balance_rounded,
                                        ModernTheme.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildFinancialCard(
                                        'ROI',
                                        '26.4%',
                                        '+5.2%',
                                        Icons.percent_rounded,
                                        ModernTheme.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // All Tools
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Financial Tools',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: ModernTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._tools.map((tool) => _buildToolCard(tool)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Bottom padding
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
      String title, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernTheme.modernShadow,
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
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
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(FinancialTool tool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openTool(tool),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: ModernTheme.modernShadow,
              border: Border.all(
                color: tool.color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tool.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tool.icon,
                        color: tool.color,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tool.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tool.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ModernTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tool.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tool.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: tool.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTool(FinancialTool tool) {
    if (tool.title == 'Finance Help') {
      _openFinanceHelp();
      return;
    }
    if (tool.title == 'ROI Calculator') {
      _openROICalculator();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tool.title} coming soon!'),
        backgroundColor: tool.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _openFinanceHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BusinessLoansScreen(),
      ),
    );
  }
}

class FinancialTool {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  FinancialTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}

class _ROICalculator extends StatefulWidget {
  final ScrollController scrollController;
  const _ROICalculator({required this.scrollController});

  @override
  State<_ROICalculator> createState() => _ROICalculatorState();
}

class _ROICalculatorState extends State<_ROICalculator> {
  final _investmentController = TextEditingController();
  final _returnController = TextEditingController();
  double? _roi;

  @override
  void dispose() {
    _investmentController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _calculate() {
    final inv = double.tryParse(_investmentController.text) ?? 0;
    final ret = double.tryParse(_returnController.text) ?? 0;
    if (inv <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid investment amount')),
      );
      return;
    }
    setState(() {
      _roi = ((ret - inv) / inv) * 100.0;
      HapticFeedback.lightImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calculate,
                      color: ModernTheme.primaryBlue),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ROI Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _investmentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Initial Investment',
                prefixIcon: Icon(Icons.savings_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _returnController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Final Return',
                prefixIcon: Icon(Icons.trending_up_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate ROI'),
              ),
            ),
            const SizedBox(height: 16),
            if (_roi != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ModernTheme.primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: ModernTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.percent_rounded,
                        color: ModernTheme.primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ROI: ${_roi!.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.textPrimary,
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
}

// Business Loans Screen
class BusinessLoansScreen extends StatefulWidget {
  const BusinessLoansScreen({super.key});

  @override
  State<BusinessLoansScreen> createState() => _BusinessLoansScreenState();
}

class _BusinessLoansScreenState extends State<BusinessLoansScreen> {
  final List<LoanOffer> _loanOffers = [
    LoanOffer(
      bankName: 'FirstBank Business',
      loanType: 'Small Business Loan',
      minAmount: 5000,
      maxAmount: 100000,
      interestRate: 6.5,
      tenure: '1-5 years',
      features: [
        'Quick approval',
        'No collateral required',
        'Flexible repayment'
      ],
      logoIcon: Icons.account_balance,
      color: ModernTheme.primaryBlue,
    ),
    LoanOffer(
      bankName: 'Capital Growth Bank',
      loanType: 'Startup Financing',
      minAmount: 10000,
      maxAmount: 250000,
      interestRate: 7.2,
      tenure: '2-7 years',
      features: ['Startup friendly', 'Business consultation', 'Grace period'],
      logoIcon: Icons.trending_up,
      color: ModernTheme.accentGreen,
    ),
    LoanOffer(
      bankName: 'Enterprise Credit Union',
      loanType: 'Equipment Financing',
      minAmount: 15000,
      maxAmount: 500000,
      interestRate: 5.8,
      tenure: '3-10 years',
      features: ['Asset-backed', 'Tax benefits', 'Low interest'],
      logoIcon: Icons.precision_manufacturing,
      color: ModernTheme.secondaryPurple,
    ),
    LoanOffer(
      bankName: 'MicroFinance Plus',
      loanType: 'Micro Business Loan',
      minAmount: 1000,
      maxAmount: 25000,
      interestRate: 8.5,
      tenure: '6 months-3 years',
      features: [
        'Fast processing',
        'Minimal documentation',
        'For micro enterprises'
      ],
      logoIcon: Icons.payments,
      color: ModernTheme.teal,
    ),
    LoanOffer(
      bankName: 'Commercial Trust Bank',
      loanType: 'Working Capital Loan',
      minAmount: 20000,
      maxAmount: 300000,
      interestRate: 6.9,
      tenure: '1-5 years',
      features: [
        'Cash flow management',
        'Revolving credit',
        'Seasonal support'
      ],
      logoIcon: Icons.sync_alt,
      color: ModernTheme.warningOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.lightGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Business Loans',
          style: TextStyle(
            color: ModernTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: ModernTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernTheme.teal,
                    ModernTheme.teal.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: ModernTheme.modernShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pre-Approved Loans',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Apply directly to partner banks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loan Offers List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _loanOffers.length,
                itemBuilder: (context, index) {
                  return _buildLoanCard(_loanOffers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(LoanOffer loan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernTheme.modernShadow,
        border: Border.all(
          color: loan.color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLoanApplication(loan),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: loan.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        loan.logoIcon,
                        color: loan.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.bankName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ModernTheme.textPrimary,
                            ),
                          ),
                          Text(
                            loan.loanType,
                            style: TextStyle(
                              fontSize: 14,
                              color: loan.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: loan.color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount Range',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${loan.minAmount.toStringAsFixed(0)} - \$${loan.maxAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ModernTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interest Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${loan.interestRate}% p.a.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: loan.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Tenure: ${loan.tenure}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: loan.features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: loan.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 11,
                          color: loan.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLoanApplication(LoanOffer loan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoanApplicationScreen(loan: loan),
      ),
    );
  }
}

// Loan Offer Model
class LoanOffer {
  final String bankName;
  final String loanType;
  final double minAmount;
  final double maxAmount;
  final double interestRate;
  final String tenure;
  final List<String> features;
  final IconData logoIcon;
  final Color color;

  LoanOffer({
    required this.bankName,
    required this.loanType,
    required this.minAmount,
    required this.maxAmount,
    required this.interestRate,
    required this.tenure,
    required this.features,
    required this.logoIcon,
    required this.color,
  });
}

// Loan Application Screen
class LoanApplicationScreen extends StatefulWidget {
  final LoanOffer loan;

  const LoanApplicationScreen({super.key, required this.loan});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _applicantNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _annualRevenueController = TextEditingController();
  final _purposeController = TextEditingController();

  String _selectedTenure = '1 year';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _applicantNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _loanAmountController.dispose();
    _businessTypeController.dispose();
    _annualRevenueController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.lightGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Loan Application',
          style: TextStyle(
            color: ModernTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: ModernTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Loan Info Header
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.loan.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: ModernTheme.modernShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.loan.logoIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.loan.bankName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.loan.loanType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.loan.interestRate}% p.a. • ${widget.loan.tenure}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Application Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        icon: Icons.business,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your business name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _businessTypeController,
                        label: 'Business Type',
                        icon: Icons.category,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your business type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _annualRevenueController,
                        label: 'Annual Revenue (\$)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter annual revenue';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Applicant Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _applicantNameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Loan Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _loanAmountController,
                        label: 'Requested Loan Amount (\$)',
                        icon: Icons.payments,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter loan amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Please enter a valid amount';
                          }
                          if (amount < widget.loan.minAmount ||
                              amount > widget.loan.maxAmount) {
                            return 'Amount must be between \$${widget.loan.minAmount.toStringAsFixed(0)} - \$${widget.loan.maxAmount.toStringAsFixed(0)}';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: ModernTheme.modernShadow,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedTenure,
                          decoration: InputDecoration(
                            labelText: 'Loan Tenure',
                            prefixIcon: Icon(
                              Icons.access_time,
                              color: widget.loan.color,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: [
                            '6 months',
                            '1 year',
                            '2 years',
                            '3 years',
                            '5 years',
                            '7 years',
                            '10 years'
                          ]
                              .map((tenure) => DropdownMenuItem(
                                    value: tenure,
                                    child: Text(tenure),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTenure = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _purposeController,
                        label: 'Loan Purpose',
                        icon: Icons.description,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe the purpose of the loan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.loan.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit Application',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Your application will be sent directly to ${widget.loan.bankName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: widget.loan.color,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ModernTheme.errorRed),
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to bank
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernTheme.accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: ModernTheme.accentGreen,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ModernTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your loan application has been sent to ${widget.loan.bankName}. They will contact you within 2-3 business days.',
              style: const TextStyle(
                fontSize: 14,
                color: ModernTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close application screen
                  Navigator.of(context).pop(); // Close loans screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.loan.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
