import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/widgets/biznest_logo.dart';
import '../core/widgets/modern_animations.dart';
import '../core/services/ai_business_plan_service.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardAnimation;

  final List<BusinessTool> _tools = [
    BusinessTool(
      title: 'AI Business Plan Generator',
      description: 'Create comprehensive business plans with AI assistance',
      icon: Icons.auto_awesome_rounded,
      color: ModernTheme.primaryBlue,
      features: [
        'Executive Summary',
        'Market Analysis',
        'Financial Projections',
        'SWOT Analysis'
      ],
    ),
    BusinessTool(
      title: 'Market Research Analyzer',
      description: 'Analyze market trends and competition',
      icon: Icons.analytics_rounded,
      color: ModernTheme.secondaryPurple,
      features: [
        'Industry Analysis',
        'Competitor Research',
        'Target Market',
        'Trend Analysis'
      ],
    ),
    BusinessTool(
      title: 'SWOT Analysis Builder',
      description: 'Identify strengths, weaknesses, opportunities, and threats',
      icon: Icons.assessment_rounded,
      color: ModernTheme.accentGreen,
      features: [
        'Internal Analysis',
        'External Analysis',
        'Strategic Planning',
        'Risk Assessment'
      ],
    ),
    BusinessTool(
      title: 'Business Model Canvas',
      description: 'Design and validate your business model',
      icon: Icons.dashboard_rounded,
      color: ModernTheme.warningOrange,
      features: [
        'Value Proposition',
        'Customer Segments',
        'Revenue Streams',
        'Key Partnerships'
      ],
    ),
    BusinessTool(
      title: 'Pitch Deck Builder',
      description: 'Create compelling investor presentations',
      icon: Icons.slideshow_rounded,
      color: ModernTheme.infoCyan,
      features: [
        'Professional Templates',
        'AI Content Generation',
        'Visual Design',
        'Export Options'
      ],
    ),
    BusinessTool(
      title: 'Legal Document Generator',
      description: 'Generate essential business documents',
      icon: Icons.gavel_rounded,
      color: ModernTheme.errorRed,
      features: ['Contracts', 'Terms of Service', 'Privacy Policy', 'NDAs'],
    ),
  ];

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
                                Icons.search_rounded,
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
                              'Business Tools',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: ModernTheme.textPrimary,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Powerful tools to build and grow your business',
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

                    // Featured Tool
                    AnimatedBuilder(
                      animation: _cardAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardAnimation.value,
                          child: FadeTransition(
                            opacity: _cardAnimation,
                            child: _buildFeaturedTool(),
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
                            'All Tools',
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

  Widget _buildFeaturedTool() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ModernTheme.primaryBlue, ModernTheme.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: ModernTheme.elevatedShadow,
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
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'AI Business Plan Generator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create comprehensive, professional business plans in minutes with our AI-powered generator.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MorphingButton(
                  text: 'Start Building',
                  onPressed: () => _showBusinessPlanGenerator(),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                  ),
                  textColor: ModernTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BusinessTool tool) {
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

  void _openTool(BusinessTool tool) {
    if (tool.title == 'AI Business Plan Generator') {
      _showBusinessPlanGenerator();
    } else {
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

  void _showBusinessPlanGenerator() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: BusinessPlanGenerator(
              scrollController: scrollController,
            ),
          );
        },
      ),
    );
  }
}

class BusinessTool {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  BusinessTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}

class BusinessPlanGenerator extends StatefulWidget {
  final ScrollController scrollController;

  const BusinessPlanGenerator({
    super.key,
    required this.scrollController,
  });

  @override
  State<BusinessPlanGenerator> createState() => _BusinessPlanGeneratorState();
}

class _BusinessPlanGeneratorState extends State<BusinessPlanGenerator>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetMarketController = TextEditingController();
  final _revenueModelController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isGenerating = false;
  int _currentStep = 0;

  Map<String, String> _businessData = {};

  final List<String> _steps = [
    'Company Information',
    'Market Analysis',
    'Financial Projections',
    'Generate Plan',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _targetMarketController.dispose();
    _revenueModelController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ModernTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: ModernTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Business Plan Generator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ModernTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Create a comprehensive business plan',
                      style: TextStyle(
                        fontSize: 14,
                        color: ModernTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),

        // Progress Steps
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: _steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = _currentStep == index;
              final isCompleted = _currentStep > index;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? ModernTheme.primaryBlue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    if (index < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? ModernTheme.primaryBlue
                              : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 32),

        // Form Content
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) _buildCompanyInfoStep(),
                    if (_currentStep == 1) _buildMarketAnalysisStep(),
                    if (_currentStep == 2) _buildFinancialProjectionsStep(),
                    if (_currentStep == 3) _buildGenerateStep(),

                    const SizedBox(height: 32),

                    // Navigation Buttons
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(
                                    color: ModernTheme.primaryBlue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Previous',
                                style: TextStyle(
                                  color: ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        Expanded(
                          flex: _currentStep == 0 ? 1 : 2,
                          child: ElevatedButton(
                            onPressed: _isGenerating ? null : _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ModernTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isGenerating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    _currentStep == _steps.length - 1
                                        ? 'Generate Plan'
                                        : 'Next',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us about your company and business idea',
          style: TextStyle(
            fontSize: 14,
            color: ModernTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _companyNameController,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            hintText: 'Enter your company name',
            prefixIcon: Icon(Icons.business_rounded),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your company name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _industryController,
          decoration: const InputDecoration(
            labelText: 'Industry',
            hintText: 'e.g., Technology, Healthcare, Retail',
            prefixIcon: Icon(Icons.category_rounded),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your industry';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Business Description',
            hintText: 'Describe your business idea and what makes it unique',
            prefixIcon: Icon(Icons.description_rounded),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a business description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMarketAnalysisStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Analysis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Define your target market and competitive landscape',
          style: TextStyle(
            fontSize: 14,
            color: ModernTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _targetMarketController,
          decoration: const InputDecoration(
            labelText: 'Target Market',
            hintText: 'Describe your ideal customers',
            prefixIcon: Icon(Icons.people_rounded),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please describe your target market';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _revenueModelController,
          decoration: const InputDecoration(
            labelText: 'Revenue Model',
            hintText: 'How will you make money?',
            prefixIcon: Icon(Icons.attach_money_rounded),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please describe your revenue model';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFinancialProjectionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Projections',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Set your financial goals and projections',
          style: TextStyle(
            fontSize: 14,
            color: ModernTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Financial inputs would go here
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ModernTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ModernTheme.primaryBlue.withOpacity(0.2),
            ),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: ModernTheme.primaryBlue,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Financial Projections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'AI will generate realistic financial projections based on your industry and business model.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Generate Your Business Plan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Review your information and generate your comprehensive business plan',
          style: TextStyle(
            fontSize: 14,
            color: ModernTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Summary of inputs
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ModernTheme.primaryBlue.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryItem('Company', _companyNameController.text),
              _buildSummaryItem('Industry', _industryController.text),
              _buildSummaryItem('Description', _descriptionController.text),
              _buildSummaryItem('Target Market', _targetMarketController.text),
              _buildSummaryItem('Revenue Model', _revenueModelController.text),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ModernTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: ModernTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      _generateBusinessPlan();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _generateBusinessPlan() async {
    setState(() {
      _isGenerating = true;
    });

    // Collect form data
    _businessData = {
      'businessName': _companyNameController.text,
      'businessType': 'Startup',
      'industry': _industryController.text,
      'targetMarket': _targetMarketController.text,
      'businessModel': _revenueModelController.text,
      'fundingGoal': '100000',
      'timeline': '12 months',
      'description': _descriptionController.text,
    };

    try {
      // Use the real AI Business Plan service
      final businessPlan = await AIBusinessPlanService.generateBusinessPlan(
        businessName: _businessData['businessName'] ?? 'My Business',
        businessType: _businessData['businessType'] ?? 'Startup',
        industry: _businessData['industry'] ?? 'Technology',
        targetMarket: _businessData['targetMarket'] ?? 'General Market',
        businessModel: _businessData['businessModel'] ?? 'B2B',
        fundingGoal: _businessData['fundingGoal'] ?? '100000',
        timeline: _businessData['timeline'] ?? '12 months',
        description:
            _businessData['description'] ?? 'Innovative business solution',
      );

      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        Navigator.pop(context);
        _showBusinessPlanResults(businessPlan);
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating business plan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showBusinessPlanResults(Map<String, dynamic> businessPlan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business Plan Generated!'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Executive Summary',
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  businessPlan['executive_summary'] ?? 'No summary available',
                  style: ModernTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Market Analysis',
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  businessPlan['market_analysis'] ?? 'No analysis available',
                  style: ModernTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Export business plan
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}
