import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'api_service.dart';

class BusinessIntelligenceService {
  // Generate business insights
  static Future<Map<String, dynamic>> generateInsights() async {
    try {
      // Get user data
      final userData = await _getUserData();
      final businessPlans = await _getBusinessPlans();
      final financialData = await _getFinancialData();
      final networkingData = await _getNetworkingData();
      final learningData = await _getLearningData();

      // Generate insights
      final insights = {
        'overview': _generateOverviewInsights(userData, businessPlans),
        'business_health': _generateBusinessHealthInsights(businessPlans, financialData),
        'growth_opportunities': _generateGrowthOpportunities(businessPlans, networkingData),
        'risk_assessment': _generateRiskAssessment(businessPlans, financialData),
        'recommendations': _generateRecommendations(userData, businessPlans, financialData),
        'market_analysis': _generateMarketAnalysis(businessPlans),
        'financial_forecast': _generateFinancialForecast(financialData),
        'competitor_analysis': _generateCompetitorAnalysis(businessPlans),
        'trends': _generateTrends(businessPlans, learningData),
        'action_items': _generateActionItems(businessPlans, financialData, networkingData),
      };

      // Save insights
      await _saveInsights(insights);

      return insights;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating insights: $e');
      }
      return _getDefaultInsights();
    }
  }

  // Generate overview insights
  static Map<String, dynamic> _generateOverviewInsights(
    Map<String, dynamic> userData,
    List<Map<String, dynamic>> businessPlans,
  ) {
    final totalPlans = businessPlans.length;
    final completedPlans = businessPlans.where((plan) => plan['status'] == 'completed').length;
    final inProgressPlans = businessPlans.where((plan) => plan['status'] == 'in_progress').length;
    
    return {
      'total_business_plans': totalPlans,
      'completed_plans': completedPlans,
      'in_progress_plans': inProgressPlans,
      'completion_rate': totalPlans > 0 ? (completedPlans / totalPlans * 100).round() : 0,
      'user_experience_level': _determineExperienceLevel(userData),
      'business_stage': _determineBusinessStage(businessPlans),
      'key_metrics': {
        'plans_created_this_month': _getPlansCreatedThisMonth(businessPlans),
        'avg_plan_completion_time': _getAvgPlanCompletionTime(businessPlans),
        'most_active_industry': _getMostActiveIndustry(businessPlans),
      },
    };
  }

  // Generate business health insights
  static Map<String, dynamic> _generateBusinessHealthInsights(
    List<Map<String, dynamic>> businessPlans,
    Map<String, dynamic> financialData,
  ) {
    final healthScore = _calculateBusinessHealthScore(businessPlans, financialData);
    final strengths = _identifyStrengths(businessPlans, financialData);
    final weaknesses = _identifyWeaknesses(businessPlans, financialData);
    
    return {
      'health_score': healthScore,
      'health_level': _getHealthLevel(healthScore),
      'strengths': strengths,
      'weaknesses': weaknesses,
      'improvement_areas': _getImprovementAreas(weaknesses),
      'financial_health': _assessFinancialHealth(financialData),
      'plan_quality': _assessPlanQuality(businessPlans),
    };
  }

  // Generate growth opportunities
  static Map<String, dynamic> _generateGrowthOpportunities(
    List<Map<String, dynamic>> businessPlans,
    List<Map<String, dynamic>> networkingData,
  ) {
    final opportunities = <Map<String, dynamic>>[];
    
    // Market expansion opportunities
    opportunities.addAll(_getMarketExpansionOpportunities(businessPlans));
    
    // Partnership opportunities
    opportunities.addAll(_getPartnershipOpportunities(networkingData));
    
    // Technology opportunities
    opportunities.addAll(_getTechnologyOpportunities(businessPlans));
    
    // Funding opportunities
    opportunities.addAll(_getFundingOpportunities(businessPlans));
    
    return {
      'opportunities': opportunities,
      'priority_opportunities': _prioritizeOpportunities(opportunities),
      'growth_potential': _calculateGrowthPotential(opportunities),
      'market_gaps': _identifyMarketGaps(businessPlans),
    };
  }

  // Generate risk assessment
  static Map<String, dynamic> _generateRiskAssessment(
    List<Map<String, dynamic>> businessPlans,
    Map<String, dynamic> financialData,
  ) {
    final risks = <Map<String, dynamic>>[];
    
    // Financial risks
    risks.addAll(_getFinancialRisks(financialData));
    
    // Market risks
    risks.addAll(_getMarketRisks(businessPlans));
    
    // Operational risks
    risks.addAll(_getOperationalRisks(businessPlans));
    
    // Technology risks
    risks.addAll(_getTechnologyRisks(businessPlans));
    
    return {
      'risks': risks,
      'risk_level': _calculateOverallRiskLevel(risks),
      'mitigation_strategies': _getMitigationStrategies(risks),
      'risk_monitoring': _getRiskMonitoringPlan(risks),
    };
  }

  // Generate recommendations
  static Map<String, dynamic> _generateRecommendations(
    Map<String, dynamic> userData,
    List<Map<String, dynamic>> businessPlans,
    Map<String, dynamic> financialData,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Business plan recommendations
    recommendations.addAll(_getBusinessPlanRecommendations(businessPlans));
    
    // Financial recommendations
    recommendations.addAll(_getFinancialRecommendations(financialData));
    
    // Learning recommendations
    recommendations.addAll(_getLearningRecommendations(userData, businessPlans));
    
    // Networking recommendations
    recommendations.addAll(_getNetworkingRecommendations(businessPlans));
    
    return {
      'recommendations': recommendations,
      'priority_recommendations': _prioritizeRecommendations(recommendations),
      'implementation_timeline': _createImplementationTimeline(recommendations),
      'success_metrics': _defineSuccessMetrics(recommendations),
    };
  }

  // Generate market analysis
  static Map<String, dynamic> _generateMarketAnalysis(List<Map<String, dynamic>> businessPlans) {
    final industries = _extractIndustries(businessPlans);
    final marketSizes = _getMarketSizes(industries);
    final growthRates = _getGrowthRates(industries);
    
    return {
      'target_markets': industries,
      'market_sizes': marketSizes,
      'growth_rates': growthRates,
      'market_trends': _getMarketTrends(industries),
      'competitive_landscape': _getCompetitiveLandscape(industries),
      'market_opportunities': _getMarketOpportunities(industries),
    };
  }

  // Generate financial forecast
  static Map<String, dynamic> _generateFinancialForecast(Map<String, dynamic> financialData) {
    final currentRevenue = financialData['current_revenue'] ?? 0;
    final growthRate = financialData['growth_rate'] ?? 0.1;
    final months = 12;
    
    final forecast = <Map<String, dynamic>>[];
    double revenue = currentRevenue.toDouble();
    
    for (int i = 1; i <= months; i++) {
      revenue *= (1 + growthRate);
      forecast.add({
        'month': i,
        'revenue': revenue.round(),
        'growth': (growthRate * 100).round(),
      });
    }
    
    return {
      'forecast': forecast,
      'total_revenue_projection': revenue.round(),
      'growth_rate': (growthRate * 100).round(),
      'break_even_point': _calculateBreakEvenPoint(financialData),
      'investment_requirements': _calculateInvestmentRequirements(financialData),
    };
  }

  // Generate competitor analysis
  static Map<String, dynamic> _generateCompetitorAnalysis(List<Map<String, dynamic>> businessPlans) {
    final industries = _extractIndustries(businessPlans);
    final competitors = _getCompetitors(industries);
    
    return {
      'competitors': competitors,
      'competitive_advantages': _getCompetitiveAdvantages(businessPlans),
      'market_position': _getMarketPosition(competitors),
      'differentiation_strategies': _getDifferentiationStrategies(competitors),
    };
  }

  // Generate trends
  static Map<String, dynamic> _generateTrends(
    List<Map<String, dynamic>> businessPlans,
    List<Map<String, dynamic>> learningData,
  ) {
    return {
      'industry_trends': _getIndustryTrends(businessPlans),
      'technology_trends': _getTechnologyTrends(learningData),
      'market_trends': _getMarketTrends(_extractIndustries(businessPlans)),
      'consumer_trends': _getConsumerTrends(businessPlans),
      'emerging_opportunities': _getEmergingOpportunities(businessPlans, learningData),
    };
  }

  // Generate action items
  static Map<String, dynamic> _generateActionItems(
    List<Map<String, dynamic>> businessPlans,
    Map<String, dynamic> financialData,
    List<Map<String, dynamic>> networkingData,
  ) {
    final actionItems = <Map<String, dynamic>>[];
    
    // Business plan actions
    actionItems.addAll(_getBusinessPlanActions(businessPlans));
    
    // Financial actions
    actionItems.addAll(_getFinancialActions(financialData));
    
    // Networking actions
    actionItems.addAll(_getNetworkingActions(networkingData));
    
    // Learning actions
    actionItems.addAll(_getLearningActions(businessPlans));
    
    return {
      'action_items': actionItems,
      'urgent_actions': _getUrgentActions(actionItems),
      'weekly_goals': _getWeeklyGoals(actionItems),
      'monthly_milestones': _getMonthlyMilestones(actionItems),
    };
  }

  // Helper methods
  static Future<Map<String, dynamic>> _getUserData() async {
    final userJson = await StorageService.getString('user_data');
    if (userJson != null) {
      return Map<String, dynamic>.from(json.decode(userJson));
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> _getBusinessPlans() async {
    final response = await ApiService.get('/business/plans');
    if (response['success']) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  static Future<Map<String, dynamic>> _getFinancialData() async {
    final response = await ApiService.get('/financial/calculations');
    if (response['success']) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> _getNetworkingData() async {
    final response = await ApiService.get('/networking/contacts');
    if (response['success']) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> _getLearningData() async {
    final response = await ApiService.get('/learning/resources');
    if (response['success']) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  static Future<void> _saveInsights(Map<String, dynamic> insights) async {
    await StorageService.setString('business_insights', json.encode(insights));
  }

  static Map<String, dynamic> _getDefaultInsights() {
    return {
      'overview': {'message': 'Unable to generate insights at this time'},
      'business_health': {'message': 'Data not available'},
      'growth_opportunities': {'message': 'Data not available'},
      'risk_assessment': {'message': 'Data not available'},
      'recommendations': {'message': 'Data not available'},
    };
  }

  // Additional helper methods would be implemented here...
  static String _determineExperienceLevel(Map<String, dynamic> userData) {
    // Implementation for determining user experience level
    return 'Intermediate';
  }

  static String _determineBusinessStage(List<Map<String, dynamic>> businessPlans) {
    // Implementation for determining business stage
    return 'Growth';
  }

  static int _getPlansCreatedThisMonth(List<Map<String, dynamic>> businessPlans) {
    // Implementation for counting plans created this month
    return businessPlans.length;
  }

  static int _getAvgPlanCompletionTime(List<Map<String, dynamic>> businessPlans) {
    // Implementation for calculating average completion time
    return 30; // days
  }

  static String _getMostActiveIndustry(List<Map<String, dynamic>> businessPlans) {
    // Implementation for finding most active industry
    return 'Technology';
  }

  static int _calculateBusinessHealthScore(
    List<Map<String, dynamic>> businessPlans,
    Map<String, dynamic> financialData,
  ) {
    // Implementation for calculating business health score
    return 75;
  }

  static String _getHealthLevel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  static List<String> _identifyStrengths(
    List<Map<String, dynamic>> businessPlans,
    Map<String, dynamic> financialData,
  ) {
    return ['Strong financial planning', 'Diverse business portfolio'];
  }

  static List<String> _identifyWeaknesses(
    List<Map<String, dynamic>> businessPlans,
    Map<String, dynamic> financialData,
  ) {
    return ['Limited market research', 'Insufficient risk management'];
  }

  static List<String> _getImprovementAreas(List<String> weaknesses) {
    return weaknesses.map((w) => 'Improve $w').toList();
  }

  static Map<String, dynamic> _assessFinancialHealth(Map<String, dynamic> financialData) {
    return {'score': 70, 'status': 'Stable'};
  }

  static Map<String, dynamic> _assessPlanQuality(List<Map<String, dynamic>> businessPlans) {
    return {'score': 80, 'status': 'High'};
  }

  static List<Map<String, dynamic>> _getMarketExpansionOpportunities(
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'International Expansion',
        'description': 'Expand to European markets',
        'potential': 'High',
        'effort': 'Medium',
      }
    ];
  }

  static List<Map<String, dynamic>> _getPartnershipOpportunities(
    List<Map<String, dynamic>> networkingData,
  ) {
    return [
      {
        'title': 'Strategic Partnership',
        'description': 'Partner with complementary businesses',
        'potential': 'Medium',
        'effort': 'Low',
      }
    ];
  }

  static List<Map<String, dynamic>> _getTechnologyOpportunities(
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'AI Integration',
        'description': 'Implement AI-powered features',
        'potential': 'High',
        'effort': 'High',
      }
    ];
  }

  static List<Map<String, dynamic>> _getFundingOpportunities(
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'Series A Funding',
        'description': 'Seek Series A investment',
        'potential': 'High',
        'effort': 'High',
      }
    ];
  }

  static List<Map<String, dynamic>> _prioritizeOpportunities(
    List<Map<String, dynamic>> opportunities,
  ) {
    return opportunities.take(3).toList();
  }

  static String _calculateGrowthPotential(List<Map<String, dynamic>> opportunities) {
    return 'High';
  }

  static List<String> _identifyMarketGaps(List<Map<String, dynamic>> businessPlans) {
    return ['Sustainability solutions', 'Remote work tools'];
  }

  static List<Map<String, dynamic>> _getFinancialRisks(Map<String, dynamic> financialData) {
    return [
      {
        'type': 'Cash Flow',
        'severity': 'Medium',
        'probability': 'High',
        'description': 'Potential cash flow issues in Q2',
      }
    ];
  }

  static List<Map<String, dynamic>> _getMarketRisks(List<Map<String, dynamic>> businessPlans) {
    return [
      {
        'type': 'Market Saturation',
        'severity': 'High',
        'probability': 'Medium',
        'description': 'Market becoming saturated',
      }
    ];
  }

  static List<Map<String, dynamic>> _getOperationalRisks(List<Map<String, dynamic>> businessPlans) {
    return [
      {
        'type': 'Key Personnel',
        'severity': 'High',
        'probability': 'Low',
        'description': 'Risk of losing key team members',
      }
    ];
  }

  static List<Map<String, dynamic>> _getTechnologyRisks(List<Map<String, dynamic>> businessPlans) {
    return [
      {
        'type': 'Cybersecurity',
        'severity': 'High',
        'probability': 'Medium',
        'description': 'Potential security breaches',
      }
    ];
  }

  static String _calculateOverallRiskLevel(List<Map<String, dynamic>> risks) {
    return 'Medium';
  }

  static List<String> _getMitigationStrategies(List<Map<String, dynamic>> risks) {
    return ['Implement risk monitoring', 'Diversify revenue streams'];
  }

  static Map<String, dynamic> _getRiskMonitoringPlan(List<Map<String, dynamic>> risks) {
    return {'frequency': 'Monthly', 'responsibilities': 'Risk management team'};
  }

  static List<Map<String, dynamic>> _getBusinessPlanRecommendations(
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'Complete Financial Projections',
        'description': 'Add detailed 3-year financial projections',
        'priority': 'High',
        'timeline': '2 weeks',
      }
    ];
  }

  static List<Map<String, dynamic>> _getFinancialRecommendations(
    Map<String, dynamic> financialData,
  ) {
    return [
      {
        'title': 'Improve Cash Flow Management',
        'description': 'Implement better cash flow tracking',
        'priority': 'High',
        'timeline': '1 month',
      }
    ];
  }

  static List<Map<String, dynamic>> _getLearningRecommendations(
    Map<String, dynamic> userData,
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'Take Financial Planning Course',
        'description': 'Improve financial planning skills',
        'priority': 'Medium',
        'timeline': '1 month',
      }
    ];
  }

  static List<Map<String, dynamic>> _getNetworkingRecommendations(
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'Attend Industry Conference',
        'description': 'Network with industry professionals',
        'priority': 'Medium',
        'timeline': '3 months',
      }
    ];
  }

  static List<Map<String, dynamic>> _prioritizeRecommendations(
    List<Map<String, dynamic>> recommendations,
  ) {
    return recommendations.take(5).toList();
  }

  static Map<String, dynamic> _createImplementationTimeline(
    List<Map<String, dynamic>> recommendations,
  ) {
    return {'total_duration': '6 months', 'phases': 3};
  }

  static List<String> _defineSuccessMetrics(
    List<Map<String, dynamic>> recommendations,
  ) {
    return ['Revenue growth', 'Customer acquisition', 'Market share'];
  }

  static List<String> _extractIndustries(List<Map<String, dynamic>> businessPlans) {
    return ['Technology', 'Healthcare', 'Finance'];
  }

  static Map<String, String> _getMarketSizes(List<String> industries) {
    return {
      'Technology': '\$2.5T',
      'Healthcare': '\$1.8T',
      'Finance': '\$1.2T',
    };
  }

  static Map<String, String> _getGrowthRates(List<String> industries) {
    return {
      'Technology': '15%',
      'Healthcare': '8%',
      'Finance': '12%',
    };
  }

  static List<String> _getMarketTrends(List<String> industries) {
    return ['Digital transformation', 'Sustainability', 'AI adoption'];
  }

  static Map<String, dynamic> _getCompetitiveLandscape(List<String> industries) {
    return {'competition_level': 'High', 'barriers_to_entry': 'Medium'};
  }

  static List<String> _getMarketOpportunities(List<String> industries) {
    return ['Emerging markets', 'Niche segments', 'Technology disruption'];
  }

  static int _calculateBreakEvenPoint(Map<String, dynamic> financialData) {
    return 12; // months
  }

  static int _calculateInvestmentRequirements(Map<String, dynamic> financialData) {
    return 500000; // dollars
  }

  static List<Map<String, dynamic>> _getCompetitors(List<String> industries) {
    return [
      {'name': 'Competitor A', 'market_share': '25%'},
      {'name': 'Competitor B', 'market_share': '18%'},
    ];
  }

  static List<String> _getCompetitiveAdvantages(List<Map<String, dynamic>> businessPlans) {
    return ['Innovation', 'Customer service', 'Pricing'];
  }

  static String _getMarketPosition(List<Map<String, dynamic>> competitors) {
    return 'Challenger';
  }

  static List<String> _getDifferentiationStrategies(List<Map<String, dynamic>> competitors) {
    return ['Unique value proposition', 'Superior technology', 'Better customer experience'];
  }

  static List<String> _getIndustryTrends(List<Map<String, dynamic>> businessPlans) {
    return ['AI integration', 'Remote work', 'Sustainability'];
  }

  static List<String> _getTechnologyTrends(List<Map<String, dynamic>> learningData) {
    return ['Machine learning', 'Cloud computing', 'Blockchain'];
  }

  static List<String> _getConsumerTrends(List<Map<String, dynamic>> businessPlans) {
    return ['Personalization', 'Convenience', 'Sustainability'];
  }

  static List<String> _getEmergingOpportunities(
    List<Map<String, dynamic>> businessPlans,
    List<Map<String, dynamic>> learningData,
  ) {
    return ['Metaverse', 'Web3', 'Green technology'];
  }

  static List<Map<String, dynamic>> _getBusinessPlanActions(
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'Update Market Analysis',
        'description': 'Refresh market research data',
        'due_date': '2024-02-15',
        'priority': 'High',
      }
    ];
  }

  static List<Map<String, dynamic>> _getFinancialActions(
    Map<String, dynamic> financialData,
  ) {
    return [
      {
        'title': 'Review Budget',
        'description': 'Monthly budget review',
        'due_date': '2024-02-01',
        'priority': 'Medium',
      }
    ];
  }

  static List<Map<String, dynamic>> _getNetworkingActions(
    List<Map<String, dynamic>> networkingData,
  ) {
    return [
      {
        'title': 'Follow up with contacts',
        'description': 'Reach out to 5 new contacts',
        'due_date': '2024-02-10',
        'priority': 'Medium',
      }
    ];
  }

  static List<Map<String, dynamic>> _getLearningActions(
    List<Map<String, dynamic>> businessPlans,
  ) {
    return [
      {
        'title': 'Complete course module',
        'description': 'Finish current learning module',
        'due_date': '2024-02-05',
        'priority': 'Low',
      }
    ];
  }

  static List<Map<String, dynamic>> _getUrgentActions(
    List<Map<String, dynamic>> actionItems,
  ) {
    return actionItems.where((item) => item['priority'] == 'High').toList();
  }

  static List<Map<String, dynamic>> _getWeeklyGoals(
    List<Map<String, dynamic>> actionItems,
  ) {
    return actionItems.take(3).toList();
  }

  static List<Map<String, dynamic>> _getMonthlyMilestones(
    List<Map<String, dynamic>> actionItems,
  ) {
    return actionItems.where((item) => item['priority'] == 'High').toList();
  }
}
