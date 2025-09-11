import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../../utils/modern_theme.dart';
import '../../utils/advanced_animations.dart';

class BusinessPlanScreen extends StatefulWidget {
  @override
  _BusinessPlanScreenState createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {
  int _currentStep = 0;
  
  final List<PlanSection> _planSections = [
    PlanSection(
      title: 'Executive Summary',
      description: 'Overview of your business concept and goals',
      progress: 0.8,
      isCompleted: false,
    ),
    PlanSection(
      title: 'Market Analysis',
      description: 'Research your target market and competitors',
      progress: 0.6,
      isCompleted: false,
    ),
    PlanSection(
      title: 'Products & Services',
      description: 'Detail what you\'re offering to customers',
      progress: 0.4,
      isCompleted: false,
    ),
    PlanSection(
      title: 'Marketing Strategy',
      description: 'How you\'ll reach and attract customers',
      progress: 0.2,
      isCompleted: false,
    ),
    PlanSection(
      title: 'Financial Projections',
      description: 'Revenue forecasts and funding requirements',
      progress: 0.0,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleAnimation(
        particleCount: 25,
        particleColor: AppTheme.accentColor.withOpacity(0.4),
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
                        _buildProgressOverview(),
                        const SizedBox(height: 30),
                        _buildPlanSections(),
                        const SizedBox(height: 30),
                        _buildAIAssistant(),
                        const SizedBox(height: 30),
                        _buildTemplates(),
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
                        Icons.download_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ShimmerEffect(
                  child: const Text(
                    'Business\nPlan Builder',
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

  Widget _buildProgressOverview() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
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
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Plan Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '40%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildProgressStat('Sections', '2/5'),
                _buildProgressStat('Words', '1,247'),
                _buildProgressStat('Pages', '4'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withOpacity(0.3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '2 of 5 sections completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 400),
          child: const Text(
            'Plan Sections',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(_planSections.length, (index) {
          return FadeInUp(
            delay: Duration(milliseconds: 600 + (index * 100)),
            child: _buildSectionCard(_planSections[index], index),
          );
        }),
      ],
    );
  }

  Widget _buildSectionCard(PlanSection section, int index) {
    final isActive = index == _currentStep;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentStep = index;
          });
          _editSection(section);
        },
        child: ModernCard(
          gradient: isActive ? AppTheme.primaryGradient : null,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: section.isCompleted 
                          ? AppTheme.successColor 
                          : (isActive ? Colors.white.withOpacity(0.2) : AppTheme.accentColor.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      section.isCompleted ? Icons.check_rounded : Icons.edit_rounded,
                      color: section.isCompleted 
                          ? Colors.white 
                          : (isActive ? Colors.white : AppTheme.accentColor),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.white70 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isActive ? Colors.white70 : const Color(0xFF94A3B8),
                  ),
                ],
              ),
              if (section.progress > 0) ...[
                const SizedBox(height: 16),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isActive 
                        ? Colors.white.withOpacity(0.3) 
                        : const Color(0xFFE2E8F0),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: section.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isActive ? Colors.white : AppTheme.accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(section.progress * 100).toInt()}% complete',
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIAssistant() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1000),
      child: ModernCard(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.tertiaryColor],
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
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI Business Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Get AI-powered suggestions for your business plan. Our assistant can help with market research, financial projections, and strategic planning.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openAIAssistant(),
              icon: const Icon(Icons.chat_bubble_rounded, size: 16),
              label: const Text('Chat with AI Assistant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
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

  Widget _buildTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 1200),
          child: Row(
            children: [
              const Text(
                'Business Plan Templates',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeInUp(
          delay: const Duration(milliseconds: 1400),
          child: Row(
            children: [
              Expanded(
                child: _buildTemplateCard(
                  'Tech Startup',
                  'Perfect for SaaS and tech companies',
                  AppTheme.primaryGradient,
                  Icons.computer_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTemplateCard(
                  'E-commerce',
                  'Retail and online store businesses',
                  AppTheme.successGradient,
                  Icons.shopping_cart_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(String title, String description, Gradient gradient, IconData icon) {
    return ModernCard(
      gradient: gradient,
      child: Column(
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
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernFAB() {
    return ModernFAB(
      onPressed: () => _exportPlan(),
      icon: Icons.download_rounded,
      gradient: AppTheme.accentGradient,
    );
  }

  void _editSection(PlanSection section) {
    Get.snackbar(
      'Edit Section',
      'Opening ${section.title} editor...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }

  void _openAIAssistant() {
    Get.snackbar(
      'AI Assistant',
      'Starting AI business planning session...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _exportPlan() {
    Get.snackbar(
      'Export Plan',
      'Generating PDF business plan...',
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }
}

class PlanSection {
  final String title;
  final String description;
  final double progress;
  final bool isCompleted;

  PlanSection({
    required this.title,
    required this.description,
    required this.progress,
    required this.isCompleted,
  });
}
