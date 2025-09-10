import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';

class BusinessPlanScreen extends StatefulWidget {
  const BusinessPlanScreen({super.key});

  @override
  _BusinessPlanScreenState createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final int _currentStep = 0;

  final List<BusinessPlanSection> _sections = [
    BusinessPlanSection(
      'Executive Summary',
      'Overview of your business concept',
      Icons.summarize,
      AppTheme.primaryColor,
      75,
    ),
    BusinessPlanSection(
      'Market Analysis',
      'Research your target market',
      Icons.analytics,
      AppTheme.accentColor,
      60,
    ),
    BusinessPlanSection(
      'Organization',
      'Management and company structure',
      Icons.business,
      AppTheme.successColor,
      40,
    ),
    BusinessPlanSection(
      'Products & Services',
      'What you\'re offering to customers',
      Icons.inventory,
      AppTheme.warningColor,
      80,
    ),
    BusinessPlanSection(
      'Marketing & Sales',
      'How you\'ll reach customers',
      Icons.campaign,
      AppTheme.infoColor,
      30,
    ),
    BusinessPlanSection(
      'Financial Projections',
      'Revenue, costs, and funding needs',
      Icons.attach_money,
      AppTheme.errorColor,
      90,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () => _showTemplates(),
            icon: const Icon(Icons.template_outlined),
          ),
          IconButton(
            onPressed: () => _exportPlan(),
            icon: const Icon(Icons.download),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Build Plan'),
            Tab(text: 'Templates'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [_buildPlanBuilder(), _buildTemplates()],
        ),
      ),
    );
  }

  Widget _buildPlanBuilder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: _buildProgressHeader()),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSectionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    final completedSections = _sections.where((s) => s.progress >= 70).length;
    final totalProgress =
        _sections.fold<double>(0, (sum, s) => sum + s.progress) /
        _sections.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your Business Plan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${totalProgress.round()}% Complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$completedSections of ${_sections.length} sections completed',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalProgress / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressMetric(
                  'Sections',
                  '$completedSections/${_sections.length}',
                ),
              ),
              Expanded(child: _buildProgressMetric('Est. Time', '2-4 hours')),
              Expanded(child: _buildProgressMetric('Last Updated', 'Today')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSectionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Plan Sections',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(_sections.length, (index) {
          return FadeInUp(
            delay: Duration(milliseconds: 400 + (index * 100)),
            child: _buildSectionCard(_sections[index], index),
          );
        }),
      ],
    );
  }

  Widget _buildSectionCard(BusinessPlanSection section, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: section.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: section.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(section.icon, color: section.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        section.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(section.progress).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${section.progress}%',

                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(section.progress),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              value: section.progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(section.color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewSection(section),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: section.color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('View', style: TextStyle(color: section.color)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editSection(section),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: section.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildTemplates() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: const Text(
              'Business Plan Templates',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Choose from professional templates to get started quickly',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildTemplateCard(
              'Tech Startup Template',
              'Perfect for technology and software companies',
              'SaaS, Mobile Apps, AI/ML',
              AppTheme.primaryColor,
              true,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildTemplateCard(
              'E-commerce Business',
              'For online retail and marketplace businesses',
              'Retail, Marketplace, Dropshipping',
              AppTheme.accentColor,
              true,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: _buildTemplateCard(
              'Service Business',
              'For consulting and service-based companies',
              'Consulting, Agency, Professional Services',
              AppTheme.successColor,
              false,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: _buildTemplateCard(
              'Restaurant & Food',
              'For restaurants, cafes, and food businesses',
              'Restaurant, Food Truck, Catering',
              AppTheme.warningColor,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    String title,
    String description,
    String categories,
    Color color,
    bool isFree,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFree ? AppTheme.successColor : AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFree ? 'FREE' : 'PRO',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Best for: $categories',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _useTemplate(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Use Template',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(double progress) {
    if (progress >= 70) return AppTheme.successColor;
    if (progress >= 40) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  void _showTemplates() {
    Get.snackbar(
      'Templates',
      'Opening template gallery...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _exportPlan() {
    Get.snackbar(
      'Export Plan',
      'Preparing your business plan for download...',
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _viewSection(BusinessPlanSection section) {
    Get.snackbar(
      'View Section',
      'Opening ${section.title}...',
      backgroundColor: section.color,
      colorText: Colors.white,
    );
  }

  void _editSection(BusinessPlanSection section) {
    Get.snackbar(
      'Edit Section',
      'Editing ${section.title}...',
      backgroundColor: section.color,
      colorText: Colors.white,
    );
  }

  void _useTemplate(String templateName) {
    Get.snackbar(
      'Template Selected',
      'Creating business plan from $templateName...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }
}

class BusinessPlanSection {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double progress;

  BusinessPlanSection(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.progress,
  );
}
