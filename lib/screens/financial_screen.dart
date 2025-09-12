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
                  child: const Icon(Icons.calculate, color: ModernTheme.primaryBlue),
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
                  border: Border.all(color: ModernTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.percent_rounded, color: ModernTheme.primaryBlue),
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
