import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class FundingService {
  static const String _fundingDataKey = 'funding_data';
  static const String _applicationsKey = 'funding_applications';
  static const String _trackingKey = 'funding_tracking';

  // Get funding suggestions based on business profile
  static Future<List<Map<String, dynamic>>> getFundingSuggestions({
    required String businessStage,
    required String industry,
    required double fundingAmount,
    required String businessType,
    required String location,
  }) async {
    try {
      final allFundingOptions = await _getAllFundingOptions();
      final suggestions = <Map<String, dynamic>>[];

      for (var option in allFundingOptions) {
        double matchScore = _calculateFundingMatchScore(
          option: option,
          businessStage: businessStage,
          industry: industry,
          fundingAmount: fundingAmount,
          businessType: businessType,
          location: location,
        );

        if (matchScore >= 0.5) { // 50% match threshold
          suggestions.add({
            ...option,
            'match_score': matchScore,
            'match_reasons': _getFundingMatchReasons(option, businessStage, industry, fundingAmount),
          });
        }
      }

      // Sort by match score
      suggestions.sort((a, b) => (b['match_score'] as double).compareTo(a['match_score'] as double));

      return suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting funding suggestions: $e');
      }
      return [];
    }
  }

  // Calculate funding match score
  static double _calculateFundingMatchScore({
    required Map<String, dynamic> option,
    required String businessStage,
    required String industry,
    required double fundingAmount,
    required String businessType,
    required String location,
  }) {
    double score = 0.0;
    int factors = 0;

    // Business stage match (30% weight)
    if (option['target_stages'].contains(businessStage)) {
      score += 0.3;
    }
    factors++;

    // Industry match (25% weight)
    if (option['industries'].contains(industry) || option['industries'].contains('All')) {
      score += 0.25;
    }
    factors++;

    // Funding amount match (20% weight)
    final minAmount = option['min_amount'] as double;
    final maxAmount = option['max_amount'] as double;
    if (fundingAmount >= minAmount && fundingAmount <= maxAmount) {
      score += 0.2;
    } else if (fundingAmount < minAmount) {
      score += 0.1; // Partial match if slightly under
    }
    factors++;

    // Business type match (15% weight)
    if (option['business_types'].contains(businessType) || option['business_types'].contains('All')) {
      score += 0.15;
    }
    factors++;

    // Location match (10% weight)
    if (option['locations'].contains(location) || option['locations'].contains('Global')) {
      score += 0.1;
    }
    factors++;

    return factors > 0 ? score : 0.0;
  }

  // Get funding match reasons
  static List<String> _getFundingMatchReasons(
    Map<String, dynamic> option,
    String businessStage,
    String industry,
    double fundingAmount,
  ) {
    final reasons = <String>[];

    if (option['target_stages'].contains(businessStage)) {
      reasons.add('Targets $businessStage stage businesses');
    }

    if (option['industries'].contains(industry)) {
      reasons.add('Focuses on $industry industry');
    }

    final minAmount = option['min_amount'] as double;
    final maxAmount = option['max_amount'] as double;
    if (fundingAmount >= minAmount && fundingAmount <= maxAmount) {
      reasons.add('Funding range matches your needs');
    }

    if (option['locations'].contains('Global')) {
      reasons.add('Available globally');
    }

    return reasons;
  }

  // Get all funding options
  static Future<List<Map<String, dynamic>>> _getAllFundingOptions() async {
    // In a real app, this would fetch from a database or API
    return _getMockFundingOptions();
  }

  // Get mock funding options
  static List<Map<String, dynamic>> _getMockFundingOptions() {
    return [
      // Venture Capital
      {
        'id': 'vc_1',
        'name': 'TechVentures Capital',
        'type': 'Venture Capital',
        'description': 'Early-stage VC focused on technology startups',
        'min_amount': 500000.0,
        'max_amount': 10000000.0,
        'target_stages': ['Seed', 'Series A', 'Series B'],
        'industries': ['Technology', 'AI', 'SaaS', 'Fintech'],
        'business_types': ['Startup', 'Scale-up'],
        'locations': ['North America', 'Europe'],
        'equity_required': true,
        'equity_range': '10-25%',
        'requirements': [
          'Strong founding team',
          'Proven product-market fit',
          'Scalable business model',
          'Clear growth strategy'
        ],
        'application_deadline': '2024-12-31',
        'website': 'https://techventures.com',
        'contact_email': 'investments@techventures.com',
        'success_rate': '15%',
        'avg_processing_time': '3-6 months',
      },
      {
        'id': 'vc_2',
        'name': 'HealthTech Ventures',
        'type': 'Venture Capital',
        'description': 'Healthcare and medical technology focused VC',
        'min_amount': 1000000.0,
        'max_amount': 15000000.0,
        'target_stages': ['Series A', 'Series B', 'Series C'],
        'industries': ['Healthcare', 'MedTech', 'Biotech'],
        'business_types': ['Startup', 'Scale-up'],
        'locations': ['Global'],
        'equity_required': true,
        'equity_range': '15-30%',
        'requirements': [
          'FDA approval pathway',
          'Clinical validation',
          'Regulatory expertise',
          'Market opportunity >\$1B'
        ],
        'application_deadline': '2024-11-30',
        'website': 'https://healthtechventures.com',
        'contact_email': 'info@healthtechventures.com',
        'success_rate': '12%',
        'avg_processing_time': '4-8 months',
      },
      // Angel Investors
      {
        'id': 'angel_1',
        'name': 'Angel Network Silicon Valley',
        'type': 'Angel Investors',
        'description': 'Network of experienced angel investors',
        'min_amount': 25000.0,
        'max_amount': 500000.0,
        'target_stages': ['Pre-seed', 'Seed'],
        'industries': ['Technology', 'AI', 'SaaS', 'E-commerce'],
        'business_types': ['Startup'],
        'locations': ['Silicon Valley', 'San Francisco'],
        'equity_required': true,
        'equity_range': '5-15%',
        'requirements': [
          'Innovative idea',
          'Strong founding team',
          'Market validation',
          'Clear business plan'
        ],
        'application_deadline': '2024-12-15',
        'website': 'https://angelsv.com',
        'contact_email': 'apply@angelsv.com',
        'success_rate': '8%',
        'avg_processing_time': '1-3 months',
      },
      // Government Grants
      {
        'id': 'grant_1',
        'name': 'Small Business Innovation Research (SBIR)',
        'type': 'Government Grant',
        'description': 'Federal grant program for small businesses',
        'min_amount': 50000.0,
        'max_amount': 1500000.0,
        'target_stages': ['Early Stage', 'R&D'],
        'industries': ['Technology', 'Healthcare', 'Energy', 'Defense'],
        'business_types': ['Startup', 'Small Business'],
        'locations': ['United States'],
        'equity_required': false,
        'equity_range': '0%',
        'requirements': [
          'US-based company',
          'Less than 500 employees',
          'Innovative technology',
          'Commercial potential'
        ],
        'application_deadline': '2024-10-31',
        'website': 'https://sbir.gov',
        'contact_email': 'sbir@nsf.gov',
        'success_rate': '20%',
        'avg_processing_time': '6-12 months',
      },
      {
        'id': 'grant_2',
        'name': 'European Innovation Council (EIC)',
        'type': 'Government Grant',
        'description': 'EU funding for breakthrough innovations',
        'min_amount': 100000.0,
        'max_amount': 2500000.0,
        'target_stages': ['Early Stage', 'Growth Stage'],
        'industries': ['Technology', 'Healthcare', 'Energy', 'Environment'],
        'business_types': ['Startup', 'SME'],
        'locations': ['Europe'],
        'equity_required': false,
        'equity_range': '0%',
        'requirements': [
          'EU-based company',
          'Breakthrough innovation',
          'High growth potential',
          'International market focus'
        ],
        'application_deadline': '2024-09-30',
        'website': 'https://eic.ec.europa.eu',
        'contact_email': 'info@eic.ec.europa.eu',
        'success_rate': '18%',
        'avg_processing_time': '4-8 months',
      },
      // Crowdfunding
      {
        'id': 'crowd_1',
        'name': 'Kickstarter',
        'type': 'Crowdfunding',
        'description': 'Reward-based crowdfunding platform',
        'min_amount': 1000.0,
        'max_amount': 1000000.0,
        'target_stages': ['Pre-seed', 'Seed'],
        'industries': ['All'],
        'business_types': ['Startup', 'Creative Project'],
        'locations': ['Global'],
        'equity_required': false,
        'equity_range': '0%',
        'requirements': [
          'Creative project or product',
          'Compelling story',
          'Reward tiers',
          'Marketing campaign'
        ],
        'application_deadline': 'Ongoing',
        'website': 'https://kickstarter.com',
        'contact_email': 'help@kickstarter.com',
        'success_rate': '35%',
        'avg_processing_time': '1-2 months',
      },
      {
        'id': 'crowd_2',
        'name': 'SeedInvest',
        'type': 'Equity Crowdfunding',
        'description': 'Equity-based crowdfunding platform',
        'min_amount': 100000.0,
        'max_amount': 5000000.0,
        'target_stages': ['Seed', 'Series A'],
        'industries': ['Technology', 'Healthcare', 'Consumer'],
        'business_types': ['Startup'],
        'locations': ['United States'],
        'equity_required': true,
        'equity_range': '5-20%',
        'requirements': [
          'US-based company',
          'Accredited investors',
          'SEC compliance',
          'Financial projections'
        ],
        'application_deadline': 'Ongoing',
        'website': 'https://seedinvest.com',
        'contact_email': 'info@seedinvest.com',
        'success_rate': '25%',
        'avg_processing_time': '2-4 months',
      },
      // Accelerators
      {
        'id': 'accel_1',
        'name': 'Y Combinator',
        'type': 'Accelerator',
        'description': 'World-renowned startup accelerator',
        'min_amount': 125000.0,
        'max_amount': 500000.0,
        'target_stages': ['Pre-seed', 'Seed'],
        'industries': ['Technology', 'AI', 'SaaS', 'Consumer'],
        'business_types': ['Startup'],
        'locations': ['Global'],
        'equity_required': true,
        'equity_range': '7%',
        'requirements': [
          'Strong founding team',
          'Scalable idea',
          'Full-time commitment',
          '3-month program'
        ],
        'application_deadline': '2024-08-15',
        'website': 'https://ycombinator.com',
        'contact_email': 'apply@ycombinator.com',
        'success_rate': '2%',
        'avg_processing_time': '1-2 months',
      },
      {
        'id': 'accel_2',
        'name': 'Techstars',
        'type': 'Accelerator',
        'description': 'Global startup accelerator network',
        'min_amount': 20000.0,
        'max_amount': 120000.0,
        'target_stages': ['Pre-seed', 'Seed'],
        'industries': ['Technology', 'AI', 'Healthcare', 'Fintech'],
        'business_types': ['Startup'],
        'locations': ['Global'],
        'equity_required': true,
        'equity_range': '6%',
        'requirements': [
          'Innovative technology',
          'Strong team',
          'Market opportunity',
          '3-month program'
        ],
        'application_deadline': '2024-09-30',
        'website': 'https://techstars.com',
        'contact_email': 'info@techstars.com',
        'success_rate': '3%',
        'avg_processing_time': '1-2 months',
      },
    ];
  }

  // Apply for funding
  static Future<bool> applyForFunding(String fundingId, Map<String, dynamic> applicationData) async {
    try {
      final application = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'funding_id': fundingId,
        'application_data': applicationData,
        'status': 'submitted',
        'submitted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _saveFundingApplication(application);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error applying for funding: $e');
      }
      return false;
    }
  }

  // Get funding applications
  static Future<List<Map<String, dynamic>>> getFundingApplications() async {
    final applicationsJson = await StorageService.getString(_applicationsKey);
    if (applicationsJson != null) {
      final List<dynamic> applicationsList = json.decode(applicationsJson);
      return applicationsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Update application status
  static Future<void> updateApplicationStatus(String applicationId, String status) async {
    final applications = await getFundingApplications();
    final index = applications.indexWhere((app) => app['id'] == applicationId);
    if (index != -1) {
      applications[index]['status'] = status;
      applications[index]['updated_at'] = DateTime.now().toIso8601String();
      await StorageService.setString(_applicationsKey, json.encode(applications));
    }
  }

  // Save funding application
  static Future<void> _saveFundingApplication(Map<String, dynamic> application) async {
    final applications = await getFundingApplications();
    applications.add(application);
    await StorageService.setString(_applicationsKey, json.encode(applications));
  }

  // Get financial tracking data
  static Future<Map<String, dynamic>> getFinancialTracking() async {
    final trackingJson = await StorageService.getString(_trackingKey);
    if (trackingJson != null) {
      return Map<String, dynamic>.from(json.decode(trackingJson));
    }
    return _getMockFinancialTracking();
  }

  // Get mock financial tracking data
  static Map<String, dynamic> _getMockFinancialTracking() {
    return {
      'current_cash': 150000.0,
      'monthly_burn_rate': 25000.0,
      'runway_months': 6.0,
      'monthly_revenue': 15000.0,
      'growth_rate': 0.15,
      'projected_revenue': {
        'month_1': 15000.0,
        'month_2': 17250.0,
        'month_3': 19837.5,
        'month_4': 22813.13,
        'month_5': 26235.1,
        'month_6': 30170.36,
      },
      'expenses': {
        'salaries': 12000.0,
        'marketing': 5000.0,
        'operations': 3000.0,
        'other': 5000.0,
      },
      'funding_goals': {
        'immediate': 100000.0,
        '6_months': 500000.0,
        '12_months': 2000000.0,
      },
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Update financial tracking
  static Future<void> updateFinancialTracking(Map<String, dynamic> data) async {
    final tracking = await getFinancialTracking();
    tracking.addAll(data);
    tracking['last_updated'] = DateTime.now().toIso8601String();
    await StorageService.setString(_trackingKey, json.encode(tracking));
  }

  // Get funding statistics
  static Future<Map<String, dynamic>> getFundingStatistics() async {
    final applications = await getFundingApplications();
    final tracking = await getFinancialTracking();
    
    return {
      'total_applications': applications.length,
      'pending_applications': applications.where((app) => app['status'] == 'submitted').length,
      'approved_applications': applications.where((app) => app['status'] == 'approved').length,
      'rejected_applications': applications.where((app) => app['status'] == 'rejected').length,
      'current_cash': tracking['current_cash'],
      'runway_months': tracking['runway_months'],
      'monthly_burn_rate': tracking['monthly_burn_rate'],
      'funding_raised': _calculateTotalFundingRaised(applications),
    };
  }

  // Calculate total funding raised
  static double _calculateTotalFundingRaised(List<Map<String, dynamic>> applications) {
    double total = 0.0;
    for (var app in applications) {
      if (app['status'] == 'approved' && app['amount_raised'] != null) {
        total += (app['amount_raised'] as num).toDouble();
      }
    }
    return total;
  }

  // Get funding recommendations
  static Future<List<String>> getFundingRecommendations() async {
    final tracking = await getFinancialTracking();
    final runway = tracking['runway_months'] as double;
    final burnRate = tracking['monthly_burn_rate'] as double;
    
    final recommendations = <String>[];
    
    if (runway < 3) {
      recommendations.add('URGENT: You have less than 3 months of runway. Start fundraising immediately.');
    } else if (runway < 6) {
      recommendations.add('Start fundraising process within the next month to secure funding before runway ends.');
    }
    
    if (burnRate > 50000) {
      recommendations.add('Consider reducing burn rate to extend runway and improve funding prospects.');
    }
    
    recommendations.add('Diversify funding sources - consider grants, crowdfunding, and strategic partnerships.');
    recommendations.add('Prepare detailed financial projections and pitch deck for investors.');
    
    return recommendations;
  }
}
