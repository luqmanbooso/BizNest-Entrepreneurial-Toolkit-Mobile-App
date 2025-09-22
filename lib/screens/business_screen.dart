import 'package:flutter/material.dart';
import '../core/services/openrouter_ai_service.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Store generated business plans
  final List<BusinessPlanHistory> _businessPlanHistory = [];

  final List<BusinessTool> _tools = [
    BusinessTool(
      title: 'AI Business Plan Generator',
      description: 'Create comprehensive business plans with AI assistance',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF2563EB),
    ),
    BusinessTool(
      title: 'Market Research',
      description: 'Analyze market trends and competition',
      icon: Icons.analytics_rounded,
      color: const Color(0xFF8B5CF6),
    ),
    BusinessTool(
      title: 'SWOT Analysis',
      description: 'Identify strengths, weaknesses, opportunities, and threats',
      icon: Icons.assessment_rounded,
      color: const Color(0xFF10B981),
    ),
    BusinessTool(
      title: 'Business Model Canvas',
      description: 'Design and validate your business model',
      icon: Icons.dashboard_rounded,
      color: const Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                    _buildQuickStats(),
                    const SizedBox(height: 32),
                    _buildToolsList(),
                    const SizedBox(height: 32),
                    _buildBusinessPlanHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Build and grow your business',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Start Your Business Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Access professional-grade tools to plan, analyze, and scale your business effectively.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showBusinessPlanGenerator(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Expanded(child: _buildStatCard('1000+', 'Plans Created', Icons.description, const Color(0xFF10B981))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('98%', 'Success Rate', Icons.trending_up, const Color(0xFF3B82F6))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('24/7', 'Support', Icons.support_agent, const Color(0xFF8B5CF6))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildToolsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Tools',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _tools.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildToolCard(_tools[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BusinessTool tool) {
    return GestureDetector(
      onTap: () => _openTool(tool),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tool.color.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tool.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(tool.icon, color: tool.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tool.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: tool.color,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessPlanHistory() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF2563EB), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Business Plan History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                '${_businessPlanHistory.length} plan${_businessPlanHistory.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_businessPlanHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No Business Plans Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Generate your first business plan using the AI Business Plan Generator above!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(
              _businessPlanHistory.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBusinessPlanHistoryCard(_businessPlanHistory[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessPlanHistoryCard(BusinessPlanHistory plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.companyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.industry,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDate(plan.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showBusinessPlanResult(plan.businessPlan);
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Plan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteBusinessPlan(plan.id),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _deleteBusinessPlan(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business Plan'),
        content: const Text('Are you sure you want to delete this business plan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _businessPlanHistory.removeWhere((plan) => plan.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Business plan deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addToBusinessPlanHistory({
    required String companyName,
    required String industry,
    required String businessPlan,
  }) {
    print('📚 _addToBusinessPlanHistory called');
    print('   Company Name: $companyName');
    print('   Industry: $industry');
    print('   Business Plan Length: ${businessPlan.length} characters');
    
    final newPlan = BusinessPlanHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: companyName,
      industry: industry,
      businessPlan: businessPlan,
      createdAt: DateTime.now(),
    );
    
    print('   Created new BusinessPlanHistory with ID: ${newPlan.id}');
    
    setState(() {
      _businessPlanHistory.insert(0, newPlan); // Add to beginning of list
      print('   Added to history. Total plans: ${_businessPlanHistory.length}');
    });
  }

  void _openTool(BusinessTool tool) {
    switch (tool.title) {
      case 'AI Business Plan Generator':
        _showBusinessPlanGenerator();
        break;
      case 'Market Research Analyzer':
        _showMarketResearch();
        break;
      case 'SWOT Analysis Builder':
        _showSWOTAnalysis();
        break;
      case 'Business Model Canvas':
        _showBusinessModelCanvas();
        break;
      case 'Pitch Deck Builder':
        _showPitchDeckBuilder();
        break;
      case 'Legal Document Generator':
        _showLegalDocumentGenerator();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tool.title} will be available soon!'),
            backgroundColor: tool.color,
          ),
        );
    }
  }

  void _showBusinessPlanGenerator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusinessPlanGenerator(
        onBusinessPlanGenerated: (companyName, industry, businessPlan) {
          _addToBusinessPlanHistory(
            companyName: companyName,
            industry: industry,
            businessPlan: businessPlan,
          );
          _showBusinessPlanResult(businessPlan);
        },
      ),
    );
  }

  void _showMarketResearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MarketResearchTool(),
    );
  }

  void _showSWOTAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SWOTAnalysisTool(),
    );
  }

  void _showBusinessModelCanvas() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BusinessModelCanvasTool(),
    );
  }

  void _showPitchDeckBuilder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pitch Deck Builder will be available soon!'),
        backgroundColor: Color(0xFF06B6D4),
      ),
    );
  }

  void _showLegalDocumentGenerator() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Legal Document Generator will be available soon!'),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
  }

  void _showBusinessPlanResult(String businessPlan) {
    print('🎯 _showBusinessPlanResult called');
    print('   Business plan length: ${businessPlan.length} characters');
    print('   First 100 characters: ${businessPlan.length > 100 ? businessPlan.substring(0, 100) + "..." : businessPlan}');
    
    showDialog(
      context: context,
      builder: (context) {
        print('✅ Building business plan result dialog');
        return Dialog(
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Business Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        print('🚪 Closing business plan result dialog');
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      businessPlan,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share functionality coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text(
                          'Share',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement download functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Download functionality coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text(
                          'Download',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BusinessTool {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  BusinessTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class BusinessPlanHistory {
  final String id;
  final String companyName;
  final String industry;
  final String businessPlan;
  final DateTime createdAt;

  BusinessPlanHistory({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.businessPlan,
    required this.createdAt,
  });
}

// Business Plan Generator Tool
class BusinessPlanGenerator extends StatefulWidget {
  final Function(String companyName, String industry, String businessPlan)? onBusinessPlanGenerated;
  
  const BusinessPlanGenerator({
    super.key,
    this.onBusinessPlanGenerated,
  });

  @override
  State<BusinessPlanGenerator> createState() => _BusinessPlanGeneratorState();
}

class _BusinessPlanGeneratorState extends State<BusinessPlanGenerator> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetMarketController = TextEditingController();
  final _fundingGoalController = TextEditingController();
  final _revenueProjectionController = TextEditingController();
  final _timelineController = TextEditingController();
  
  int _currentStep = 0;
  bool _isGenerating = false;
  
  final List<String> _steps = [
    'Company Info',
    'Market Analysis',
    'Financial Goals',
    'Generate Plan',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildProgressSteps(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: _buildCurrentStep(),
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          const Text(
            'AI Business Plan Generator',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: _steps.asMap().entries.map((entry) {
          final index = entry.key;
          final isActive = _currentStep >= index;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (index < _steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep > index ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCompanyInfoStep();
      case 1:
        return _buildMarketAnalysisStep();
      case 2:
        return _buildFinancialStep();
      case 3:
        return _buildGenerateStep();
      default:
        return Container();
    }
  }

  Widget _buildCompanyInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about your company and business idea',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              hintText: 'Enter your company name',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter company name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _industryController,
            decoration: const InputDecoration(
              labelText: 'Industry',
              hintText: 'e.g., Technology, Healthcare, Retail',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter industry' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Business Description',
              hintText: 'Describe your business idea',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter description' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketAnalysisStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _targetMarketController,
            decoration: const InputDecoration(
              labelText: 'Target Market',
              hintText: 'Describe your ideal customers',
              prefixIcon: Icon(Icons.people),
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please describe target market' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your financial targets and projections',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fundingGoalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Funding Goal',
              hintText: 'e.g., 100000',
              prefixIcon: Icon(Icons.attach_money),
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter funding goal' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _revenueProjectionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Year 1 Revenue Projection',
              hintText: 'e.g., 250000',
              prefixIcon: Icon(Icons.trending_up),
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter revenue projection' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _timelineController,
            decoration: const InputDecoration(
              labelText: 'Business Timeline',
              hintText: 'e.g., 12 months, 2 years',
              prefixIcon: Icon(Icons.schedule),
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter timeline' : null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb, color: Color(0xFF2563EB)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI will use these financial goals to create realistic projections and funding strategies in your business plan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
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

  Widget _buildGenerateStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Business Plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          if (_isGenerating)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating your business plan...'),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Ready to Generate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Company: ${_companyNameController.text}\nIndustry: ${_industryController.text}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: Text(_currentStep == _steps.length - 1 ? 'Generate' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else {
      _generatePlan();
    }
  }

  void _generatePlan() async {
    print('🔄 _generatePlan called - Starting generation process...');
    
    if (!mounted) {
      print('❌ Widget not mounted, aborting...');
      return;
    }
    
    setState(() {
      _isGenerating = true;
      print('✅ Set _isGenerating = true');
    });
    
    try {
      print('📝 Validating form data...');
      print('   Company Name: "${_companyNameController.text.trim()}"');
      print('   Industry: "${_industryController.text.trim()}"');
      
      // Validate form data
      if (_companyNameController.text.trim().isEmpty) {
        throw Exception('Company name is required');
      }
      if (_industryController.text.trim().isEmpty) {
        throw Exception('Industry is required');
      }
      
      print('✅ Form validation passed. Preparing API call...');
      
      final requestData = {
        'businessName': _companyNameController.text.trim(),
        'businessType': 'Startup',
        'industry': _industryController.text.trim(),
        'targetMarket': _targetMarketController.text.trim().isEmpty 
            ? 'General market' 
            : _targetMarketController.text.trim(),
        'businessModel': 'B2B/B2C',
        'fundingGoal': _fundingGoalController.text.trim().isEmpty 
            ? '100000' 
            : _fundingGoalController.text.trim(),
        'timeline': _timelineController.text.trim().isEmpty 
            ? '12 months' 
            : _timelineController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? 'A startup in the ${_industryController.text.trim()} industry' 
            : _descriptionController.text.trim(),
      };
      
      print('🚀 Calling OpenRouter AI with data: $requestData');
      
      // Generate business plan using OpenRouter AI
      final businessPlan = await OpenRouterAIService.generateBusinessPlan(
        businessName: requestData['businessName']!,
        businessType: requestData['businessType']!,
        industry: requestData['industry']!,
        targetMarket: requestData['targetMarket']!,
        businessModel: requestData['businessModel']!,
        fundingGoal: requestData['fundingGoal']!,
        timeline: requestData['timeline']!,
        description: requestData['description']!,
      );
      
      print('✅ AI service returned successfully!');
      print('   Business plan length: ${businessPlan.length} characters');
      print('   First 100 chars: ${businessPlan.length > 100 ? businessPlan.substring(0, 100) + "..." : businessPlan}');
      
      if (!mounted) {
        print('❌ Widget unmounted after API call, aborting...');
        return;
      }
      
      print('🔄 Setting _isGenerating = false and closing dialog...');
      setState(() => _isGenerating = false);
      
      // Close the generator dialog
      Navigator.of(context).pop();
      print('✅ Dialog closed');
      
      print('🔍 Calling parent callback to save business plan...');
      
      // Use the callback to notify parent
      if (widget.onBusinessPlanGenerated != null) {
        print('✅ Found callback, calling with business plan data...');
        
        widget.onBusinessPlanGenerated!(
          _companyNameController.text.trim(),
          _industryController.text.trim(),
          businessPlan,
        );
        
        print('✅ Callback executed successfully!');
        print('🎉 Business plan generation completed successfully!');
        
        // Close the modal after successful generation
        if (mounted) {
          print('🔚 Closing business plan generator modal...');
          Navigator.of(context).pop();
        }
      } else {
        print('❌ No callback provided');
        throw Exception('No callback provided to save business plan');
      }
    } catch (e, stackTrace) {
      print('❌ Error during business plan generation:');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      
      if (!mounted) {
        print('❌ Widget unmounted during error handling');
        return;
      }
      
      setState(() => _isGenerating = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating business plan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _targetMarketController.dispose();
    _fundingGoalController.dispose();
    _revenueProjectionController.dispose();
    _timelineController.dispose();
    super.dispose();
  }
}

// Market Research Tool
class MarketResearchTool extends StatefulWidget {
  const MarketResearchTool({super.key});

  @override
  State<MarketResearchTool> createState() => _MarketResearchToolState();
}

class _MarketResearchToolState extends State<MarketResearchTool> {
  final _formKey = GlobalKey<FormState>();
  final _industryController = TextEditingController();
  final _targetMarketController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Market Research',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Market Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get AI-powered insights about your market',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _industryController,
                      decoration: const InputDecoration(
                        labelText: 'Industry',
                        hintText: 'e.g., Technology, Healthcare, Retail',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter industry' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetMarketController,
                      decoration: const InputDecoration(
                        labelText: 'Target Market',
                        hintText: 'Describe your target customers',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please describe target market' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., United States, Europe, Global',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter location' : null,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateMarketAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Generate Market Analysis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateMarketAnalysis() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isGenerating = true);
    
    try {
      final analysis = await OpenRouterAIService.generateMarketAnalysis(
        industry: _industryController.text,
        targetMarket: _targetMarketController.text,
        location: _locationController.text,
      );
      
      if (mounted) {
        setState(() => _isGenerating = false);
        Navigator.pop(context);
        _showAnalysisResult('Market Analysis', analysis);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating analysis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAnalysisResult(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _industryController.dispose();
    _targetMarketController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

// SWOT Analysis Tool
class SWOTAnalysisTool extends StatefulWidget {
  const SWOTAnalysisTool({super.key});

  @override
  State<SWOTAnalysisTool> createState() => _SWOTAnalysisToolState();
}

class _SWOTAnalysisToolState extends State<SWOTAnalysisTool> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _businessModelController = TextEditingController();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assessment_rounded, color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SWOT Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SWOT Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Analyze your business strengths, weaknesses, opportunities, and threats',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        hintText: 'Enter your business name',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter business name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _industryController,
                      decoration: const InputDecoration(
                        labelText: 'Industry',
                        hintText: 'e.g., Technology, Healthcare, Retail',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter industry' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _businessModelController,
                      decoration: const InputDecoration(
                        labelText: 'Business Model',
                        hintText: 'e.g., B2B, B2C, Subscription, Marketplace',
                        prefixIcon: Icon(Icons.business_center),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter business model' : null,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateSWOTAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Generate SWOT Analysis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateSWOTAnalysis() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isGenerating = true);
    
    try {
      final swotData = await OpenRouterAIService.generateSWOTAnalysis(
        businessName: _businessNameController.text,
        industry: _industryController.text,
        businessModel: _businessModelController.text,
      );
      
      if (mounted) {
        setState(() => _isGenerating = false);
        Navigator.pop(context);
        _showSWOTResult(swotData);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating SWOT analysis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSWOTResult(Map<String, String> swotData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.assessment, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  const Text(
                    'SWOT Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildSWOTQuadrant('Strengths', swotData['strengths'] ?? '', const Color(0xFF10B981))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSWOTQuadrant('Weaknesses', swotData['weaknesses'] ?? '', const Color(0xFFEF4444))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildSWOTQuadrant('Opportunities', swotData['opportunities'] ?? '', const Color(0xFF3B82F6))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSWOTQuadrant('Threats', swotData['threats'] ?? '', const Color(0xFFF59E0B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSWOTQuadrant(String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _industryController.dispose();
    _businessModelController.dispose();
    super.dispose();
  }
}

// Business Model Canvas Tool
class BusinessModelCanvasTool extends StatelessWidget {
  const BusinessModelCanvasTool({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.dashboard_rounded, color: Color(0xFFF59E0B)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Business Model Canvas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction, size: 64, color: Color(0xFF64748B)),
                  SizedBox(height: 16),
                  Text(
                    'Coming Soon!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Business Model Canvas tool is under development',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
