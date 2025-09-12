import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class MarketResearchService {
  static const String _researchDataKey = 'market_research_data';
  static const String _competitorDataKey = 'competitor_data';
  static const String _industryDataKey = 'industry_data';

  // Get market research data for an industry
  static Future<Map<String, dynamic>> getMarketResearch(String industry) async {
    try {
      // Try to get cached data first
      final cachedData = await _getCachedResearchData(industry);
      if (cachedData != null && _isDataFresh(cachedData)) {
        return cachedData;
      }

      // Fetch fresh data
      final researchData = await _fetchMarketResearchData(industry);
      await _cacheResearchData(industry, researchData);
      
      return researchData;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting market research: $e');
      }
      return _getMockMarketResearch(industry);
    }
  }

  // Get competitor analysis
  static Future<List<Map<String, dynamic>>> getCompetitorAnalysis(String industry) async {
    try {
      final competitors = await _scrapeCompetitorData(industry);
      await _cacheCompetitorData(industry, competitors);
      return competitors;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting competitor analysis: $e');
      }
      return _getMockCompetitors(industry);
    }
  }

  // Get industry trends
  static Future<List<Map<String, dynamic>>> getIndustryTrends(String industry) async {
    try {
      final trends = await _scrapeIndustryTrends(industry);
      await _cacheIndustryData(industry, trends);
      return trends;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting industry trends: $e');
      }
      return _getMockTrends(industry);
    }
  }

  // Scrape competitor data (mock implementation)
  static Future<List<Map<String, dynamic>>> _scrapeCompetitorData(String industry) async {
    // In a real app, this would use web scraping libraries
    // For now, return mock data
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
    
    return _getMockCompetitors(industry);
  }

  // Scrape industry trends (mock implementation)
  static Future<List<Map<String, dynamic>>> _scrapeIndustryTrends(String industry) async {
    // In a real app, this would scrape news sites, reports, etc.
    await Future.delayed(const Duration(seconds: 1));
    
    return _getMockTrends(industry);
  }

  // Fetch market research data
  static Future<Map<String, dynamic>> _fetchMarketResearchData(String industry) async {
    // In a real app, this would call actual market research APIs
    await Future.delayed(const Duration(seconds: 3));
    
    return _getMockMarketResearch(industry);
  }

  // Get mock market research data
  static Map<String, dynamic> _getMockMarketResearch(String industry) {
    return {
      'industry': industry,
      'market_size': _getMarketSize(industry),
      'growth_rate': _getGrowthRate(industry),
      'key_trends': _getKeyTrends(industry),
      'target_demographics': _getTargetDemographics(industry),
      'market_segments': _getMarketSegments(industry),
      'barriers_to_entry': _getBarriersToEntry(industry),
      'opportunities': _getOpportunities(industry),
      'threats': _getThreats(industry),
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Get mock competitors
  static List<Map<String, dynamic>> _getMockCompetitors(String industry) {
    final competitors = <Map<String, dynamic>>[];
    
    switch (industry.toLowerCase()) {
      case 'technology':
        competitors.addAll([
          {
            'name': 'TechCorp Solutions',
            'website': 'https://techcorp.com',
            'market_share': '25%',
            'strengths': ['Strong R&D', 'Global presence', 'Brand recognition'],
            'weaknesses': ['High prices', 'Slow innovation', 'Poor customer service'],
            'revenue': '\$2.5B',
            'employees': 15000,
            'founded': 2010,
            'headquarters': 'San Francisco, CA',
            'key_products': ['Cloud Platform', 'AI Solutions', 'Enterprise Software'],
            'pricing_strategy': 'Premium',
            'target_market': 'Enterprise',
          },
          {
            'name': 'InnovateTech',
            'website': 'https://innovatetech.com',
            'market_share': '18%',
            'strengths': ['Innovation', 'Customer focus', 'Agile development'],
            'weaknesses': ['Limited resources', 'Smaller market presence'],
            'revenue': '\$800M',
            'employees': 2500,
            'founded': 2015,
            'headquarters': 'Austin, TX',
            'key_products': ['Mobile Apps', 'SaaS Platform', 'Analytics Tools'],
            'pricing_strategy': 'Competitive',
            'target_market': 'SMB',
          },
        ]);
        break;
      case 'healthcare':
        competitors.addAll([
          {
            'name': 'HealthTech Pro',
            'website': 'https://healthtechpro.com',
            'market_share': '30%',
            'strengths': ['Regulatory compliance', 'Clinical expertise', 'Partnerships'],
            'weaknesses': ['High costs', 'Complex implementation'],
            'revenue': '\$1.8B',
            'employees': 8000,
            'founded': 2008,
            'headquarters': 'Boston, MA',
            'key_products': ['EMR System', 'Telemedicine', 'Health Analytics'],
            'pricing_strategy': 'Value-based',
            'target_market': 'Hospitals',
          },
        ]);
        break;
      default:
        competitors.addAll([
          {
            'name': 'Industry Leader Inc',
            'website': 'https://industryleader.com',
            'market_share': '20%',
            'strengths': ['Market leadership', 'Brand recognition'],
            'weaknesses': ['Slow to adapt', 'High costs'],
            'revenue': '\$1.2B',
            'employees': 5000,
            'founded': 2012,
            'headquarters': 'New York, NY',
            'key_products': ['Core Product', 'Support Services'],
            'pricing_strategy': 'Premium',
            'target_market': 'Enterprise',
          },
        ]);
    }
    
    return competitors;
  }

  // Get mock trends
  static List<Map<String, dynamic>> _getMockTrends(String industry) {
    return [
      {
        'title': 'Digital Transformation Accelerates',
        'description': 'Companies are rapidly adopting digital technologies to improve efficiency and customer experience.',
        'impact': 'High',
        'timeframe': '2024-2025',
        'source': 'Industry Report 2024',
        'category': 'Technology',
      },
      {
        'title': 'Sustainability Becomes Priority',
        'description': 'Environmental considerations are increasingly important in business decisions.',
        'impact': 'Medium',
        'timeframe': '2024-2026',
        'source': 'Sustainability Survey',
        'category': 'Environment',
      },
      {
        'title': 'Remote Work Continues to Grow',
        'description': 'Hybrid and remote work models are becoming the new standard.',
        'impact': 'High',
        'timeframe': '2024-2025',
        'source': 'Workplace Trends Report',
        'category': 'Workplace',
      },
    ];
  }

  // Helper methods for mock data
  static String _getMarketSize(String industry) {
    switch (industry.toLowerCase()) {
      case 'technology': return '\$5.2T';
      case 'healthcare': return '\$4.3T';
      case 'finance': return '\$3.8T';
      case 'retail': return '\$2.1T';
      default: return '\$1.5T';
    }
  }

  static String _getGrowthRate(String industry) {
    switch (industry.toLowerCase()) {
      case 'technology': return '12.5%';
      case 'healthcare': return '8.2%';
      case 'finance': return '6.8%';
      case 'retail': return '4.1%';
      default: return '5.5%';
    }
  }

  static List<String> _getKeyTrends(String industry) {
    switch (industry.toLowerCase()) {
      case 'technology':
        return ['AI Integration', 'Cloud Computing', 'Cybersecurity', 'IoT'];
      case 'healthcare':
        return ['Telemedicine', 'AI Diagnostics', 'Personalized Medicine', 'Digital Health'];
      case 'finance':
        return ['Fintech', 'Blockchain', 'Digital Banking', 'Cryptocurrency'];
      default:
        return ['Digitalization', 'Automation', 'Sustainability', 'Customer Experience'];
    }
  }

  static Map<String, dynamic> _getTargetDemographics(String industry) {
    return {
      'age_range': '25-55',
      'income_level': '\$50K-\$150K',
      'education': 'Bachelor\'s degree or higher',
      'location': 'Urban and suburban areas',
      'tech_savviness': 'High',
      'buying_behavior': 'Research-driven, value-conscious',
    };
  }

  static List<Map<String, dynamic>> _getMarketSegments(String industry) {
    return [
      {
        'name': 'Enterprise',
        'size': 'Large',
        'characteristics': 'High budget, complex needs, long sales cycles',
        'opportunity': 'High',
      },
      {
        'name': 'SMB',
        'size': 'Medium',
        'characteristics': 'Moderate budget, simpler needs, faster decisions',
        'opportunity': 'Medium',
      },
      {
        'name': 'Startups',
        'size': 'Small',
        'characteristics': 'Limited budget, innovative needs, quick decisions',
        'opportunity': 'High',
      },
    ];
  }

  static List<String> _getBarriersToEntry(String industry) {
    return [
      'High capital requirements',
      'Regulatory compliance',
      'Established competitors',
      'Customer acquisition costs',
      'Technology expertise required',
    ];
  }

  static List<String> _getOpportunities(String industry) {
    return [
      'Emerging market segments',
      'Technology disruption',
      'Regulatory changes',
      'Underserved customer needs',
      'Partnership opportunities',
    ];
  }

  static List<String> _getThreats(String industry) {
    return [
      'Economic downturns',
      'New competitors',
      'Technology changes',
      'Regulatory restrictions',
      'Supply chain disruptions',
    ];
  }

  // Caching methods
  static Future<Map<String, dynamic>?> _getCachedResearchData(String industry) async {
    final dataJson = await StorageService.getString('$_researchDataKey$industry');
    if (dataJson != null) {
      return Map<String, dynamic>.from(json.decode(dataJson));
    }
    return null;
  }

  static Future<void> _cacheResearchData(String industry, Map<String, dynamic> data) async {
    await StorageService.setString('$_researchDataKey$industry', json.encode(data));
  }

  static Future<void> _cacheCompetitorData(String industry, List<Map<String, dynamic>> data) async {
    await StorageService.setString('$_competitorDataKey$industry', json.encode(data));
  }

  static Future<void> _cacheIndustryData(String industry, List<Map<String, dynamic>> data) async {
    await StorageService.setString('$_industryDataKey$industry', json.encode(data));
  }

  static bool _isDataFresh(Map<String, dynamic> data) {
    final lastUpdated = DateTime.parse(data['last_updated']);
    final now = DateTime.now();
    return now.difference(lastUpdated).inHours < 24; // Data is fresh for 24 hours
  }

  // Get saved research data
  static Future<List<Map<String, dynamic>>> getSavedResearchData() async {
    final researchJson = await StorageService.getString('saved_research_data');
    if (researchJson != null) {
      final List<dynamic> researchList = json.decode(researchJson);
      return researchList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Save research data
  static Future<void> saveResearchData(Map<String, dynamic> data) async {
    final saved = await getSavedResearchData();
    saved.add({
      ...data,
      'saved_at': DateTime.now().toIso8601String(),
    });
    await StorageService.setString('saved_research_data', json.encode(saved));
  }

  // Get research insights
  static Future<Map<String, dynamic>> getResearchInsights(String industry) async {
    final research = await getMarketResearch(industry);
    final competitors = await getCompetitorAnalysis(industry);
    final trends = await getIndustryTrends(industry);

    return {
      'market_opportunity': _calculateMarketOpportunity(research),
      'competitive_landscape': _analyzeCompetitiveLandscape(competitors),
      'key_insights': _generateKeyInsights(research, competitors, trends),
      'recommendations': _generateRecommendations(research, competitors, trends),
      'risk_factors': _identifyRiskFactors(research, competitors),
    };
  }

  static String _calculateMarketOpportunity(Map<String, dynamic> research) {
    final marketSize = research['market_size'] as String;
    final growthRate = research['growth_rate'] as String;
    
    if (marketSize.contains('T') && growthRate.contains('10')) {
      return 'Very High - Large market with strong growth potential';
    } else if (marketSize.contains('B') && growthRate.contains('5')) {
      return 'High - Substantial market with good growth';
    } else {
      return 'Medium - Moderate market opportunity';
    }
  }

  static Map<String, dynamic> _analyzeCompetitiveLandscape(List<Map<String, dynamic>> competitors) {
    if (competitors.isEmpty) {
      return {'intensity': 'Low', 'description': 'Limited competition'};
    }

    final totalMarketShare = competitors.fold<double>(0, (sum, comp) {
      final share = double.tryParse(comp['market_share'].toString().replaceAll('%', '')) ?? 0;
      return sum + share;
    });

    String intensity;
    if (totalMarketShare > 80) {
      intensity = 'High';
    } else if (totalMarketShare > 50) {
      intensity = 'Medium';
    } else {
      intensity = 'Low';
    }

    return {
      'intensity': intensity,
      'total_market_share_analyzed': '$totalMarketShare%',
      'competitor_count': competitors.length,
      'description': '$intensity competition with ${competitors.length} major players',
    };
  }

  static List<String> _generateKeyInsights(
    Map<String, dynamic> research,
    List<Map<String, dynamic>> competitors,
    List<Map<String, dynamic>> trends,
  ) {
    final insights = <String>[];

    // Market insights
    insights.add('Market size of ${research['market_size']} with ${research['growth_rate']} growth rate');
    
    // Competitive insights
    if (competitors.isNotEmpty) {
      insights.add('${competitors.length} major competitors with varying market shares');
    }

    // Trend insights
    if (trends.isNotEmpty) {
      insights.add('${trends.length} key trends identified affecting the industry');
    }

    return insights;
  }

  static List<String> _generateRecommendations(
    Map<String, dynamic> research,
    List<Map<String, dynamic>> competitors,
    List<Map<String, dynamic>> trends,
  ) {
    final recommendations = <String>[];

    recommendations.add('Focus on identified market opportunities');
    recommendations.add('Develop competitive advantages over existing players');
    recommendations.add('Stay updated with industry trends and adapt accordingly');
    recommendations.add('Consider partnerships with complementary businesses');

    return recommendations;
  }

  static List<String> _identifyRiskFactors(
    Map<String, dynamic> research,
    List<Map<String, dynamic>> competitors,
  ) {
    final risks = <String>[];

    risks.addAll(research['threats'] as List<dynamic>? ?? []);
    
    if (competitors.length > 5) {
      risks.add('High competition with many established players');
    }

    return risks;
  }
}
