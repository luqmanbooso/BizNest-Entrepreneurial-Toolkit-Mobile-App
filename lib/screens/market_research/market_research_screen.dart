import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../../utils/modern_theme.dart';
import '../../utils/advanced_animations.dart';

class MarketResearchScreen extends StatefulWidget {
  @override
  _MarketResearchScreenState createState() => _MarketResearchScreenState();
}

class _MarketResearchScreenState extends State<MarketResearchScreen> {
  final List<ResearchData> _marketData = [
    ResearchData(
      title: 'Market Size',
      value: '\$45.2B',
      change: '+12.5%',
      isPositive: true,
    ),
    ResearchData(
      title: 'Growth Rate',
      value: '8.3%',
      change: '+2.1%',
      isPositive: true,
    ),
    ResearchData(
      title: 'Competition',
      value: '247',
      change: '+15',
      isPositive: false,
    ),
    ResearchData(
      title: 'Opportunity',
      value: 'High',
      change: 'Trending',
      isPositive: true,
    ),
  ];

  final List<Competitor> _competitors = [
    Competitor(
      name: 'TechCorp Inc.',
      marketShare: 0.35,
      strength: 'Technology',
      weakness: 'Customer Service',
      score: 8.5,
    ),
    Competitor(
      name: 'InnovatePro',
      marketShare: 0.28,
      strength: 'Innovation',
      weakness: 'Pricing',
      score: 7.8,
    ),
    Competitor(
      name: 'StartupXYZ',
      marketShare: 0.18,
      strength: 'Marketing',
      weakness: 'Product Quality',
      score: 6.9,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveAnimation(
        waveColor: AppTheme.accentColor,
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
                        _buildMarketOverview(),
                        const SizedBox(height: 30),
                        _buildResearchTools(),
                        const SizedBox(height: 30),
                        _buildCompetitorAnalysis(),
                        const SizedBox(height: 30),
                        _buildTrendAnalysis(),
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
                        Icons.refresh_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ShimmerEffect(
                  child: const Text(
                    'Market\nResearch',
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

  Widget _buildMarketOverview() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: ModernCard(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor, AppTheme.tertiaryColor],
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
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Market Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Updated',
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children:
                  _marketData.map((data) => _buildDataCard(data)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(ResearchData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                data.isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16,
                color: data.isPositive
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
              ),
              const SizedBox(width: 4),
              Text(
                data.change,
                style: TextStyle(
                  fontSize: 10,
                  color: data.isPositive
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResearchTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 400),
          child: const Text(
            'Research Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildToolCard(
              'Survey Builder',
              'Create customer surveys',
              Icons.quiz_rounded,
              AppTheme.primaryGradient,
              () => _openSurveyBuilder(),
              0,
            ),
            _buildToolCard(
              'Trend Analysis',
              'Market trend insights',
              Icons.show_chart_rounded,
              AppTheme.accentGradient,
              () => _openTrendAnalysis(),
              1,
            ),
            _buildToolCard(
              'SWOT Analysis',
              'Strengths & weaknesses',
              Icons.balance_rounded,
              AppTheme.successGradient,
              () => _openSWOTAnalysis(),
              2,
            ),
            _buildToolCard(
              'Industry Reports',
              'Download reports',
              Icons.article_rounded,
              LinearGradient(
                colors: [AppTheme.warningColor, AppTheme.tertiaryColor],
              ),
              () => _openReports(),
              3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCard(
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
    int index,
  ) {
    return FadeInUp(
      delay: Duration(milliseconds: 600 + (index * 100)),
      child: GestureDetector(
        onTap: onTap,
        child: ModernCard(
          gradient: gradient,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitorAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 800),
          child: Row(
            children: [
              const Text(
                'Competitor Analysis',
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
        ...List.generate(_competitors.length, (index) {
          return FadeInUp(
            delay: Duration(milliseconds: 1000 + (index * 100)),
            child: _buildCompetitorCard(_competitors[index]),
          );
        }),
      ],
    );
  }

  Widget _buildCompetitorCard(Competitor competitor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ModernCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                competitor.name[0],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        competitor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              _getScoreColor(competitor.score).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${competitor.score}/10',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getScoreColor(competitor.score),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Market Share: ${(competitor.marketShare * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Strength',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              competitor.strength,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weakness',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              competitor.weakness,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
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

  Color _getScoreColor(double score) {
    if (score >= 8.0) return AppTheme.successColor;
    if (score >= 6.0) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Widget _buildTrendAnalysis() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1300),
      child: ModernCard(
        gradient: LinearGradient(
          colors: [AppTheme.infoColor, AppTheme.primaryColor],
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
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Market Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AI and automation are driving significant growth in your target market. Consider positioning your product to leverage these trends for competitive advantage.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _viewDetailedTrends(),
              icon: const Icon(Icons.analytics_rounded, size: 16),
              label: const Text('View Detailed Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.infoColor,
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

  Widget _buildModernFAB() {
    return ModernFAB(
      onPressed: () => _generateReport(),
      icon: Icons.assessment_rounded,
      gradient: AppTheme.accentGradient,
    );
  }

  void _openSurveyBuilder() {
    Get.snackbar(
      'Survey Builder',
      'Opening customer survey creation tool...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _openTrendAnalysis() {
    Get.snackbar(
      'Trend Analysis',
      'Loading market trend insights...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }

  void _openSWOTAnalysis() {
    Get.snackbar(
      'SWOT Analysis',
      'Opening SWOT analysis framework...',
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _openReports() {
    Get.snackbar(
      'Industry Reports',
      'Accessing industry research reports...',
      backgroundColor: AppTheme.warningColor,
      colorText: Colors.white,
    );
  }

  void _viewDetailedTrends() {
    Get.snackbar(
      'Detailed Trends',
      'Loading comprehensive trend analysis...',
      backgroundColor: AppTheme.infoColor,
      colorText: Colors.white,
    );
  }

  void _generateReport() {
    Get.snackbar(
      'Generate Report',
      'Creating market research report...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }
}

class ResearchData {
  final String title;
  final String value;
  final String change;
  final bool isPositive;

  ResearchData({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });
}

class Competitor {
  final String name;
  final double marketShare;
  final String strength;
  final String weakness;
  final double score;

  Competitor({
    required this.name,
    required this.marketShare,
    required this.strength,
    required this.weakness,
    required this.score,
  });
}
