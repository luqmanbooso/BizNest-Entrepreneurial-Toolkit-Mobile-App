import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
  final List<Map<String, dynamic>> _marketResearchHistory = [];
  final List<Map<String, dynamic>> _swotAnalysisHistory = [];
  final List<Map<String, dynamic>> _businessModelCanvasHistory = [];

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
          // Business Plan History Section
          _buildHistorySection(
            title: 'Business Plan History',
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF2563EB),
            count: _businessPlanHistory.length,
            isEmpty: _businessPlanHistory.isEmpty,
            emptyTitle: 'No Business Plans Yet',
            emptyDescription: 'Generate your first business plan using the AI Business Plan Generator!',
            children: _businessPlanHistory.map((plan) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBusinessPlanHistoryCard(plan),
              ),
            ).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Market Research History Section
          _buildHistorySection(
            title: 'Market Research History',
            icon: Icons.analytics_rounded,
            color: const Color(0xFF8B5CF6),
            count: _marketResearchHistory.length,
            isEmpty: _marketResearchHistory.isEmpty,
            emptyTitle: 'No Market Research Yet',
            emptyDescription: 'Analyze your market using the Market Research tool!',
            children: _marketResearchHistory.map((research) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMarketResearchHistoryCard(research),
              ),
            ).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // SWOT Analysis History Section
          _buildHistorySection(
            title: 'SWOT Analysis History',
            icon: Icons.analytics_outlined,
            color: const Color(0xFF10B981),
            count: _swotAnalysisHistory.length,
            isEmpty: _swotAnalysisHistory.isEmpty,
            emptyTitle: 'No SWOT Analyses Yet',
            emptyDescription: 'Analyze your business strengths and weaknesses!',
            children: _swotAnalysisHistory.map((swot) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSWOTHistoryCard(swot),
              ),
            ).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Business Model Canvas History Section
          _buildHistorySection(
            title: 'Business Model Canvas History',
            icon: Icons.view_module_rounded,
            color: const Color(0xFFEF4444),
            count: _businessModelCanvasHistory.length,
            isEmpty: _businessModelCanvasHistory.isEmpty,
            emptyTitle: 'No Business Model Canvases Yet',
            emptyDescription: 'Create your business model using the Canvas Generator!',
            children: _businessModelCanvasHistory.map((canvas) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBusinessModelCanvasHistoryCard(canvas),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessPlanHistoryCard(BusinessPlanHistory plan) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.auto_awesome, color: Colors.white),
          ),
          title: Text(
            plan.companyName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Created: ${_formatDate(plan.createdAt)}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteBusinessPlan(plan.id),
                tooltip: 'Delete Business Plan',
              ),
              const Icon(Icons.expand_more, color: Colors.grey),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan.industry.isNotEmpty) ...[
                    _buildResearchDetailRow('Industry', plan.industry),
                    const SizedBox(height: 8),
                  ],
                  const Text(
                    'Business Plan Preview:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      plan.businessPlan.length > 500
                          ? '${plan.businessPlan.substring(0, 500)}...'
                          : plan.businessPlan,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void _deleteMarketResearch(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Market Research'),
        content: const Text('Are you sure you want to delete this market research? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _marketResearchHistory.removeWhere((research) => research['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Market research deleted')),
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

  void _deleteSWOTAnalysis(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete SWOT Analysis'),
        content: const Text('Are you sure you want to delete this SWOT analysis? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _swotAnalysisHistory.removeWhere((swot) => swot['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SWOT analysis deleted')),
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

  void _deleteBusinessModelCanvas(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business Model Canvas'),
        content: const Text('Are you sure you want to delete this business model canvas? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _businessModelCanvasHistory.removeWhere((canvas) => canvas['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Business model canvas deleted')),
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

  void _addToMarketResearchHistory({
    required String industry,
    required String targetMarket,
    required String location,
    required String analysis,
  }) {
    print('📊 _addToMarketResearchHistory called');
    print('   Industry: $industry');
    print('   Target Market: $targetMarket');
    print('   Location: $location');
    
    final marketResearch = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'industry': industry,
      'targetMarket': targetMarket,
      'location': location,
      'analysis': analysis,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    setState(() {
      _marketResearchHistory.insert(0, marketResearch); // Add to beginning of list
    });
    
    print('   Created new Market Research with ID: ${marketResearch['id']}');
    print('   Added to history. Total analyses: ${_marketResearchHistory.length}');
    print('✅ Market research saved successfully');
  }

  void _showMarketAnalysisResult(String analysis) {
    print('🎯 _showMarketAnalysisResult called');
    print('   Analysis length: ${analysis.length} characters');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
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
                    'Market Analysis',
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
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      analysis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF374151),
                      ),
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
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Save market analysis to file
                        final industry = _marketResearchHistory.isNotEmpty ? _marketResearchHistory.first['industry'] ?? 'Market_Analysis' : 'Market_Analysis';
                        await _saveMarketAnalysis(analysis, industry);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    print('✅ Market analysis result dialog shown');
  }

  void _addToSWOTAnalysisHistory({
    required String businessName,
    required String industry,
    required String businessModel,
    required Map<String, String> swotData,
  }) {
    print('📊 _addToSWOTAnalysisHistory called');
    print('   Business Name: $businessName');
    print('   Industry: $industry');
    print('   Business Model: $businessModel');
    
    final swotAnalysis = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'businessName': businessName,
      'industry': industry,
      'businessModel': businessModel,
      'swotData': swotData,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    setState(() {
      _swotAnalysisHistory.insert(0, swotAnalysis); // Add to beginning of list
    });
    
    print('   Created new SWOT Analysis with ID: ${swotAnalysis['id']}');
    print('   Added to history. Total analyses: ${_swotAnalysisHistory.length}');
    print('✅ SWOT analysis saved successfully');
  }

  void _showSWOTAnalysisResult(Map<String, String> swotData) {
    print('🎯 _showSWOTAnalysisResult called');
    print('   SWOT data keys: ${swotData.keys.join(', ')}');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
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
                      // Strengths Row
                      _buildSWOTCard(
                        'Strengths',
                        swotData['strengths'] ?? 'No data',
                        const Color(0xFF10B981),
                        Icons.trending_up,
                      ),
                      const SizedBox(height: 12),
                      // Weaknesses Row
                      _buildSWOTCard(
                        'Weaknesses',
                        swotData['weaknesses'] ?? 'No data',
                        const Color(0xFFEF4444),
                        Icons.trending_down,
                      ),
                      const SizedBox(height: 12),
                      // Opportunities Row
                      _buildSWOTCard(
                        'Opportunities',
                        swotData['opportunities'] ?? 'No data',
                        const Color(0xFF3B82F6),
                        Icons.lightbulb,
                      ),
                      const SizedBox(height: 12),
                      // Threats Row
                      _buildSWOTCard(
                        'Threats',
                        swotData['threats'] ?? 'No data',
                        const Color(0xFFF59E0B),
                        Icons.warning,
                      ),
                    ],
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
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Save SWOT analysis to file
                        final businessName = _swotAnalysisHistory.isNotEmpty ? _swotAnalysisHistory.first['businessName'] ?? 'SWOT_Analysis' : 'SWOT_Analysis';
                        await _saveSWOTAnalysis(swotData, businessName);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    print('✅ SWOT analysis result dialog shown');
  }

  void _addToBusinessModelCanvasHistory({
    required String businessName,
    required String industry,
    required String businessModel,
    required Map<String, String> canvasData,
  }) {
    print('📊 _addToBusinessModelCanvasHistory called');
    print('   Business Name: $businessName');
    print('   Industry: $industry');
    print('   Business Model: $businessModel');
    
    // For now, we'll store in shared preferences as JSON
    // In a real app, this would go to a database
    final businessModelCanvas = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'businessName': businessName,
      'industry': industry,
      'businessModel': businessModel,
      'canvasData': canvasData,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    setState(() {
      _businessModelCanvasHistory.insert(0, businessModelCanvas); // Add to beginning of list
    });
    
    print('   Created new Business Model Canvas with ID: ${businessModelCanvas['id']}');
    print('   Added to history. Total canvases: ${_businessModelCanvasHistory.length}');
    print('✅ Business Model Canvas saved successfully');
  }

  void _showBusinessModelCanvasResult(Map<String, String> canvasData) {
    print('🎯 _showBusinessModelCanvasResult called');
    print('   Canvas data keys: ${canvasData.keys.join(', ')}');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            minHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.view_module_rounded, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Business Model Canvas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                      // Top Section: Key Partners & Key Activities
                      Row(
                        children: [
                          Expanded(
                            child: _buildCanvasCard(
                              'Key Partners',
                              canvasData['keyPartners'] ?? 'No data',
                              const Color(0xFF10B981),
                              Icons.handshake,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCanvasCard(
                              'Key Activities',
                              canvasData['keyActivities'] ?? 'No data',
                              const Color(0xFF3B82F6),
                              Icons.work,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Distribution & Value Section: Key Resources & Channels
                      Row(
                        children: [
                          Expanded(
                            child: _buildCanvasCard(
                              'Key Resources',
                              canvasData['keyResources'] ?? 'No data',
                              const Color(0xFF06B6D4),
                              Icons.inventory,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCanvasCard(
                              'Channels',
                              canvasData['channels'] ?? 'No data',
                              const Color(0xFF84CC16),
                              Icons.router,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Value Proposition Section (Full Width for Emphasis)
                      _buildCanvasCard(
                        'Value Propositions',
                        canvasData['valuePropositions'] ?? 'No data',
                        const Color(0xFFEF4444),
                        Icons.star,
                      ),
                      const SizedBox(height: 16),
                      
                      // Customer Section: Customer Relationships & Customer Segments
                      Row(
                        children: [
                          Expanded(
                            child: _buildCanvasCard(
                              'Customer Relationships',
                              canvasData['customerRelationships'] ?? 'No data',
                              const Color(0xFFF59E0B),
                              Icons.people,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCanvasCard(
                              'Customer Segments',
                              canvasData['customerSegments'] ?? 'No data',
                              const Color(0xFF8B5CF6),
                              Icons.group,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Financial Section: Cost Structure & Revenue Streams
                      Row(
                        children: [
                          Expanded(
                            child: _buildCanvasCard(
                              'Cost Structure',
                              canvasData['costStructure'] ?? 'No data',
                              const Color(0xFFDC2626),
                              Icons.money_off,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCanvasCard(
                              'Revenue Streams',
                              canvasData['revenueStreams'] ?? 'No data',
                              const Color(0xFF059669),
                              Icons.attach_money,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Save Business Model Canvas to file
                        final businessName = _businessModelCanvasHistory.isNotEmpty ? _businessModelCanvasHistory.first['businessName'] ?? 'Business_Model_Canvas' : 'Business_Model_Canvas';
                        await _saveBusinessModelCanvas(canvasData, businessName);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    print('✅ Business Model Canvas result dialog shown');
  }

  Widget _buildCanvasCard(String title, String content, Color color, IconData icon) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 180,
        maxHeight: 250,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.05),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSWOTCard(String title, String content, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.05),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _openTool(BusinessTool tool) {
    switch (tool.title) {
      case 'AI Business Plan Generator':
        _showBusinessPlanGenerator();
        break;
      case 'Market Research':
        _showMarketResearch();
        break;
      case 'SWOT Analysis':
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
          
          // Close modal first, then show result dialog after a delay
          Navigator.of(context).pop();
          
          // Use Future.delayed to ensure modal is fully closed before showing result
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showBusinessPlanResult(businessPlan, companyName);
            }
          });
        },
      ),
    );
  }

  void _showMarketResearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarketResearchTool(
        onMarketAnalysisGenerated: (industry, targetMarket, location, analysis) {
          _addToMarketResearchHistory(
            industry: industry,
            targetMarket: targetMarket,
            location: location,
            analysis: analysis,
          );
          
          // Close modal first, then show result dialog after a delay
          Navigator.of(context).pop();
          
          // Use Future.delayed to ensure modal is fully closed before showing result
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showMarketAnalysisResult(analysis);
            }
          });
        },
      ),
    );
  }

  void _showSWOTAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SWOTAnalysisTool(
        onSWOTAnalysisGenerated: (businessName, industry, businessModel, swotData) {
          _addToSWOTAnalysisHistory(
            businessName: businessName,
            industry: industry,
            businessModel: businessModel,
            swotData: swotData,
          );
          
          // Close modal first, then show result dialog after a delay
          Navigator.of(context).pop();
          
          // Use Future.delayed to ensure modal is fully closed before showing result
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showSWOTAnalysisResult(swotData);
            }
          });
        },
      ),
    );
  }

  void _showBusinessModelCanvas() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusinessModelCanvasTool(
        onBusinessModelCanvasGenerated: (businessName, industry, businessModel, canvasData) {
          _addToBusinessModelCanvasHistory(
            businessName: businessName,
            industry: industry,
            businessModel: businessModel,
            canvasData: canvasData,
          );
          
          // Close modal first, then show result dialog after a delay
          Navigator.of(context).pop();
          
          // Use Future.delayed to ensure modal is fully closed before showing result
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showBusinessModelCanvasResult(canvasData);
            }
          });
        },
      ),
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

  void _showBusinessPlanResult(String businessPlan, [String? companyName]) {
    print('🎯 _showBusinessPlanResult called');
    print('   Business plan length: ${businessPlan.length} characters');
    print('   First 100 characters: ${businessPlan.length > 100 ? "${businessPlan.substring(0, 100)}..." : businessPlan}');
    
    showDialog(
      context: context,
      builder: (context) {
        print('✅ Building business plan result dialog');
        return Dialog(
          child: Container(
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
                        onPressed: () async {
                          // Save business plan to file
                          await _saveBusinessPlan(businessPlan, companyName ?? 'Business_Plan');
                        },
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text(
                          'Save',
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

  // History Section Builder Methods
  Widget _buildHistorySection({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required bool isEmpty,
    required String emptyTitle,
    required String emptyDescription,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  emptyTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptyDescription,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(children: children),
      ],
    );
  }

  Widget _buildMarketResearchHistoryCard(Map<String, dynamic> research) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.trending_up, color: Colors.white),
          ),
          title: Text(
            research['industry']?.toString() ?? 'Market Research',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Created: ${research['createdAt'] != null ? _formatDate(research['createdAt']) : 'Unknown'}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteMarketResearch(research['id']),
                tooltip: 'Delete Market Research',
              ),
              const Icon(Icons.expand_more, color: Colors.grey),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (research['industry'] != null && research['industry'].toString().isNotEmpty) ...[
                    _buildResearchDetailRow('Industry', research['industry'].toString()),
                    const SizedBox(height: 8),
                  ],
                  if (research['targetMarket'] != null && research['targetMarket'].toString().isNotEmpty) ...[
                    _buildResearchDetailRow('Target Market', research['targetMarket'].toString()),
                    const SizedBox(height: 8),
                  ],
                  if (research['location'] != null && research['location'].toString().isNotEmpty) ...[
                    _buildResearchDetailRow('Location', research['location'].toString()),
                    const SizedBox(height: 8),
                  ],
                  if (research['analysis'] != null && research['analysis'].toString().isNotEmpty) ...[
                    const Text(
                      'Analysis:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        research['analysis'].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSWOTHistoryCard(Map<String, dynamic> swot) {
    final swotData = swot['swotData'] as Map<String, dynamic>? ?? {};
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.analytics, color: Colors.white),
          ),
          title: Text(
            swot['businessName'] ?? 'SWOT Analysis',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Created: ${swot['createdAt'] != null ? _formatDate(swot['createdAt']) : 'Unknown'}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteSWOTAnalysis(swot['id']),
                tooltip: 'Delete SWOT Analysis',
              ),
              const Icon(Icons.expand_more, color: Colors.grey),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (swot['industry'] != null && swot['industry'].toString().isNotEmpty) ...[
                    _buildResearchDetailRow('Industry', swot['industry'].toString()),
                    const SizedBox(height: 8),
                  ],
                  if (swot['businessModel'] != null && swot['businessModel'].toString().isNotEmpty) ...[
                    _buildResearchDetailRow('Business Model', swot['businessModel'].toString()),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'SWOT Analysis:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSWOTQuadrant(
                          'Strengths',
                          swotData['strengths'] ?? 'Not available',
                          Colors.green,
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSWOTQuadrant(
                          'Weaknesses',
                          swotData['weaknesses'] ?? 'Not available',
                          Colors.orange,
                          Icons.trending_down,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSWOTQuadrant(
                          'Opportunities',
                          swotData['opportunities'] ?? 'Not available',
                          Colors.blue,
                          Icons.lightbulb,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSWOTQuadrant(
                          'Threats',
                          swotData['threats'] ?? 'Not available',
                          Colors.red,
                          Icons.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessModelCanvasHistoryCard(Map<String, dynamic> canvas) {
    final canvasData = canvas['canvasData'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.purple,
            child: Icon(Icons.business_center, color: Colors.white),
          ),
          title: Text(
            canvas['businessName'] ?? 'Business Model Canvas',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Created: ${canvas['createdAt'] != null ? _formatDate(canvas['createdAt']) : 'Unknown'}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteBusinessModelCanvas(canvas['id']),
                tooltip: 'Delete this business model canvas',
              ),
              const Icon(Icons.expand_more, color: Colors.grey),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canvas['industry'] != null && canvas['industry'].toString().isNotEmpty) ...[
                    _buildResearchDetailRow('Industry', canvas['industry'].toString()),
                    const SizedBox(height: 8),
                  ],
                  if (canvas['businessModel'] != null && canvas['businessModel'].toString().isNotEmpty) ...[
                    _buildResearchDetailRow('Business Model', canvas['businessModel'].toString()),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Business Model Canvas:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Key Partners',
                          canvasData['keyPartners'] ?? 'Not available',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Key Activities',
                          canvasData['keyActivities'] ?? 'Not available',
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Value Propositions',
                          canvasData['valuePropositions'] ?? 'Not available',
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Customer Relationships',
                          canvasData['customerRelationships'] ?? 'Not available',
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Customer Segments',
                          canvasData['customerSegments'] ?? 'Not available',
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Key Resources',
                          canvasData['keyResources'] ?? 'Not available',
                          Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Channels',
                          canvasData['channels'] ?? 'Not available',
                          Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Cost Structure',
                          canvasData['costStructure'] ?? 'Not available',
                          Colors.brown,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCanvasQuadrant(
                          'Revenue Streams',
                          canvasData['revenueStreams'] ?? 'Not available',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateString) {
    try {
      if (dateString is String) {
        final date = DateTime.parse(dateString);
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } else if (dateString is DateTime) {
        return '${dateString.year}-${dateString.month.toString().padLeft(2, '0')}-${dateString.day.toString().padLeft(2, '0')}';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _saveBusinessPlan(String businessPlan, String companyName) async {
    try {
      // Get the downloads directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access storage directory')),
        );
        return;
      }

      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${companyName.replaceAll(' ', '_')}_business_plan_$timestamp.txt';
      final file = File('${directory.path}/$fileName');

      // Write the business plan to the file
      await file.writeAsString(businessPlan);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business plan saved to: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save business plan')),
      );
    }
  }

  Future<void> _saveMarketAnalysis(String analysis, String industry) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access storage')),
        );
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${industry}_Market_Analysis_$timestamp.txt';
      final file = File('${directory.path}/$fileName');

      // Write the market analysis to the file
      await file.writeAsString(analysis);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Market analysis saved to: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save market analysis')),
      );
    }
  }

  Future<void> _saveSWOTAnalysis(Map<String, String> swotData, String businessName) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access storage')),
        );
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${businessName}_SWOT_Analysis_$timestamp.txt';
      final file = File('${directory.path}/$fileName');

      // Format SWOT data as text
      final swotText = '''
SWOT Analysis for: $businessName

STRENGTHS:
${swotData['strengths'] ?? 'No data'}

WEAKNESSES:
${swotData['weaknesses'] ?? 'No data'}

OPPORTUNITIES:
${swotData['opportunities'] ?? 'No data'}

THREATS:
${swotData['threats'] ?? 'No data'}

Generated on: ${DateTime.now().toString()}
''';

      // Write the SWOT analysis to the file
      await file.writeAsString(swotText);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SWOT analysis saved to: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save SWOT analysis')),
      );
    }
  }

  Future<void> _saveBusinessModelCanvas(Map<String, String> canvasData, String businessName) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access storage')),
        );
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${businessName}_Business_Model_Canvas_$timestamp.txt';
      final file = File('${directory.path}/$fileName');

      // Format canvas data as text
      final canvasText = '''
Business Model Canvas for: $businessName

KEY PARTNERS:
${canvasData['keyPartners'] ?? 'No data'}

KEY ACTIVITIES:
${canvasData['keyActivities'] ?? 'No data'}

KEY RESOURCES:
${canvasData['keyResources'] ?? 'No data'}

VALUE PROPOSITIONS:
${canvasData['valuePropositions'] ?? 'No data'}

CUSTOMER RELATIONSHIPS:
${canvasData['customerRelationships'] ?? 'No data'}

CHANNELS:
${canvasData['channels'] ?? 'No data'}

CUSTOMER SEGMENTS:
${canvasData['customerSegments'] ?? 'No data'}

COST STRUCTURE:
${canvasData['costStructure'] ?? 'No data'}

REVENUE STREAMS:
${canvasData['revenueStreams'] ?? 'No data'}

Generated on: ${DateTime.now().toString()}
''';

      // Write the business model canvas to the file
      await file.writeAsString(canvasText);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business Model Canvas saved to: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save Business Model Canvas')),
      );
    }
  }

  Widget _buildResearchDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSWOTQuadrant(String title, String content, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasQuadrant(String title, String content, Color color) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 9,
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
      print('   First 100 chars: ${businessPlan.length > 100 ? "${businessPlan.substring(0, 100)}..." : businessPlan}');
      
      if (!mounted) {
        print('❌ Widget unmounted after API call, aborting...');
        return;
      }
      
      print('🔄 Setting _isGenerating = false and closing dialog...');
      setState(() => _isGenerating = false);
      
      // Note: Dialog will be closed by parent callback
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
        
        // Note: Modal will be closed by parent callback
        print('🔚 Business plan modal will be closed by parent...');
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
  final Function(String industry, String targetMarket, String location, String analysis)? onMarketAnalysisGenerated;
  
  const MarketResearchTool({
    super.key,
    this.onMarketAnalysisGenerated,
  });

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
    print('🔄 _generateMarketAnalysis called - Starting generation process...');
    
    if (!(_formKey.currentState?.validate() ?? false)) {
      print('❌ Form validation failed');
      return;
    }
    
    print('✅ Form validation passed');
    setState(() => _isGenerating = true);
    print('✅ Set _isGenerating = true');
    
    try {
      print('🚀 Calling OpenRouter AI for Market Analysis...');
      print('   Industry: ${_industryController.text}');
      print('   Target Market: ${_targetMarketController.text}');
      print('   Location: ${_locationController.text}');
      
      final analysis = await OpenRouterAIService.generateMarketAnalysis(
        industry: _industryController.text,
        targetMarket: _targetMarketController.text,
        location: _locationController.text,
      );
      
      print('✅ AI service returned successfully!');
      print('   Analysis length: ${analysis.length} characters');
      print('   First 100 chars: ${analysis.substring(0, analysis.length > 100 ? 100 : analysis.length)}...');
      
      if (mounted) {
        print('🔄 Setting _isGenerating = false and closing dialog...');
        setState(() => _isGenerating = false);
        print('✅ Dialog closed');
        
        print('🔍 Calling parent callback to save market analysis...');
        
        // Use the callback to notify parent
        if (widget.onMarketAnalysisGenerated != null) {
          print('✅ Found callback, calling with market analysis data...');
          
          widget.onMarketAnalysisGenerated!(
            _industryController.text.trim(),
            _targetMarketController.text.trim(),
            _locationController.text.trim(),
            analysis,
          );
          
          print('✅ Callback executed successfully!');
          print('🎉 Market analysis generation completed successfully!');
          
          // Note: Modal will be closed by parent callback
          print('🔚 Market research modal will be closed by parent...');
        } else {
          print('❌ No callback provided');
          throw Exception('No callback provided to save market analysis');
        }
      }
    } catch (e) {
      print('❌ Error during market analysis generation:');
      print('   Error: $e');
      
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
  final Function(String businessName, String industry, String businessModel, Map<String, String> swotData)? onSWOTAnalysisGenerated;
  
  const SWOTAnalysisTool({
    super.key,
    this.onSWOTAnalysisGenerated,
  });

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
    print('🔄 _generateSWOTAnalysis called - Starting generation process...');
    
    if (!(_formKey.currentState?.validate() ?? false)) {
      print('❌ Form validation failed');
      return;
    }
    
    print('✅ Form validation passed');
    setState(() => _isGenerating = true);
    print('✅ Set _isGenerating = true');
    
    try {
      print('🚀 Calling OpenRouter AI for SWOT Analysis...');
      print('   Business Name: ${_businessNameController.text}');
      print('   Industry: ${_industryController.text}');
      print('   Business Model: ${_businessModelController.text}');
      
      final swotData = await OpenRouterAIService.generateSWOTAnalysis(
        businessName: _businessNameController.text,
        industry: _industryController.text,
        businessModel: _businessModelController.text,
      );
      
      print('✅ AI service returned successfully!');
      print('   SWOT data keys: ${swotData.keys.join(', ')}');
      
      if (mounted) {
        print('🔄 Setting _isGenerating = false and closing dialog...');
        setState(() => _isGenerating = false);
        print('✅ Dialog closed');
        
        print('🔍 Calling parent callback to save SWOT analysis...');
        
        // Use the callback to notify parent
        if (widget.onSWOTAnalysisGenerated != null) {
          print('✅ Found callback, calling with SWOT analysis data...');
          
          widget.onSWOTAnalysisGenerated!(
            _businessNameController.text.trim(),
            _industryController.text.trim(),
            _businessModelController.text.trim(),
            swotData,
          );
          
          print('✅ Callback executed successfully!');
          print('🎉 SWOT analysis generation completed successfully!');
          
          // Note: Modal will be closed by parent callback
          print('🔚 SWOT analysis modal will be closed by parent...');
        } else {
          print('❌ No callback provided');
          throw Exception('No callback provided to save SWOT analysis');
        }
      }
    } catch (e) {
      print('❌ Error during SWOT analysis generation:');
      print('   Error: $e');
      
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

  @override
  void dispose() {
    _businessNameController.dispose();
    _industryController.dispose();
    _businessModelController.dispose();
    super.dispose();
  }
}

// Business Model Canvas Tool
class BusinessModelCanvasTool extends StatefulWidget {
  final Function(String businessName, String industry, String businessModel, Map<String, String> canvasData) onBusinessModelCanvasGenerated;

  const BusinessModelCanvasTool({
    super.key,
    required this.onBusinessModelCanvasGenerated,
  });

  @override
  State<BusinessModelCanvasTool> createState() => _BusinessModelCanvasToolState();
}

class _BusinessModelCanvasToolState extends State<BusinessModelCanvasTool> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _businessModelController = TextEditingController();
  final _targetMarketController = TextEditingController();
  final _competitorsController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _industryController.dispose();
    _businessModelController.dispose();
    _targetMarketController.dispose();
    _competitorsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateBusinessModelCanvas() async {
    print('🔄 _generateBusinessModelCanvas called - Starting generation process...');
    print('✅ Set _isGenerating = true');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    print('📝 Validating form data...');
    print('   Business Name: "${_businessNameController.text}"');
    print('   Industry: "${_industryController.text}"');
    print('   Business Model: "${_businessModelController.text}"');
    print('✅ Form validation passed. Preparing API call...');

    try {
      // Create the request data
      final requestData = {
        'businessName': _businessNameController.text,
        'industry': _industryController.text,
        'businessModel': _businessModelController.text,
        'targetMarket': _targetMarketController.text,
        'competitors': _competitorsController.text,
        'description': _descriptionController.text,
      };

      print('🚀 Calling OpenRouter AI with data: $requestData');

      // Generate the business model canvas using AI
      final canvasResponse = await OpenRouterAIService.generateBusinessModelCanvas(
        businessName: _businessNameController.text,
        industry: _industryController.text,
        businessModel: _businessModelController.text,
        targetMarket: _targetMarketController.text,
        competitors: _competitorsController.text,
        description: _descriptionController.text,
      );

      print('✅ AI service returned successfully!');
      print('   Business Model Canvas length: ${canvasResponse.length} characters');
      print('   First 100 chars: ${canvasResponse.length > 100 ? "${canvasResponse.substring(0, 100)}..." : canvasResponse}');

      // Parse the canvas response into structured data
      final canvasData = _parseCanvasResponse(canvasResponse);

      print('🔄 Setting _isGenerating = false and closing dialog...');
      setState(() {
        _isGenerating = false;
      });

      print('✅ Dialog closed');
      print('🔍 Calling parent callback to save business model canvas...');
      print('✅ Found callback, calling with canvas data...');
      
      // Call the callback with the generated data
      widget.onBusinessModelCanvasGenerated(
        _businessNameController.text,
        _industryController.text,
        _businessModelController.text,
        canvasData,
      );

      print('✅ Callback executed successfully!');
      print('🎉 Business Model Canvas generation completed successfully!');
      print('🔚 Business model canvas modal will be closed by parent...');
    } catch (e) {
      print('❌ Error during Business Model Canvas generation: $e');
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating Business Model Canvas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, String> _parseCanvasResponse(String response) {
    // Simple parsing logic - in a real app, you'd want more sophisticated parsing
    final result = {
      'keyPartners': _extractSection(response, 'Key Partners'),
      'keyActivities': _extractSection(response, 'Key Activities'),
      'keyResources': _extractSection(response, 'Key Resources'),
      'valuePropositions': _extractSection(response, 'Value Propositions'),
      'customerRelationships': _extractSection(response, 'Customer Relationships'),
      'channels': _extractSection(response, 'Channels'),
      'customerSegments': _extractSection(response, 'Customer Segments'),
      'costStructure': _extractSection(response, 'Cost Structure'),
      'revenueStreams': _extractSection(response, 'Revenue Streams'),
    };

    return result;
  }

  String _extractSection(String response, String sectionName) {
    // Look for **Section Name** followed by content until the next ** or end
    final pattern = RegExp('\\*\\*$sectionName\\*\\*[:\\s]*([\\s\\S]*?)(?=\\*\\*|\$)', caseSensitive: false);
    final match = pattern.firstMatch(response);

    final result = match?.group(1)?.trim() ?? 'Not specified';

    return result;
  }

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
                  child: const Icon(Icons.view_module_rounded, color: Color(0xFF8B5CF6)),
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Your Business Model Canvas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AI will help you create a comprehensive business model canvas with all 9 building blocks.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Business Name
                    const Text(
                      'Business Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your business name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a business name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Industry
                    const Text(
                      'Industry',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _industryController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Technology, Healthcare, Retail',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the industry';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Business Model
                    const Text(
                      'Business Model',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _businessModelController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., SaaS, E-commerce, Marketplace',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the business model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Target Market
                    const Text(
                      'Target Market',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _targetMarketController,
                      decoration: const InputDecoration(
                        hintText: 'Describe your target customers',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Main Competitors
                    const Text(
                      'Main Competitors',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _competitorsController,
                      decoration: const InputDecoration(
                        hintText: 'List your main competitors',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Business Description
                    const Text(
                      'Business Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Describe your business idea and goals',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a business description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateBusinessModelCanvas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isGenerating
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Generating Canvas...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Generate Business Model Canvas',
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


}
