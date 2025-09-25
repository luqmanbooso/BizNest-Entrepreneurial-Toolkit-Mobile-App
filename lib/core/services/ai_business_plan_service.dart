import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class AIBusinessPlanService {
  static const String _apiKey = 'your_openrouter_api_key'; // Replace with actual API key
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _model = 'openai/gpt-4';

  // Generate business plan using AI
  static Future<Map<String, dynamic>> generateBusinessPlan({
    required String businessName,
    required String businessType,
    required String industry,
    required String targetMarket,
    required String businessModel,
    required String fundingGoal,
    required String timeline,
    required String description,
  }) async {
    try {
      final prompt = _buildBusinessPlanPrompt(
        businessName: businessName,
        businessType: businessType,
        industry: industry,
        targetMarket: targetMarket,
        businessModel: businessModel,
        fundingGoal: fundingGoal,
        timeline: timeline,
        description: description,
      );

      final response = await _callOpenRouterAPI(prompt);
      
      if (response['success']) {
        final businessPlan = _parseBusinessPlanResponse(response['data']);
        await _saveBusinessPlan(businessPlan);
        return businessPlan;
      } else {
        throw Exception('Failed to generate business plan: ${response['error']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating business plan: $e');
      }
      // Return mock data for demo purposes
      return _getMockBusinessPlan(
        businessName: businessName,
        businessType: businessType,
        industry: industry,
      );
    }
  }

  // Build prompt for AI
  static String _buildBusinessPlanPrompt({
    required String businessName,
    required String businessType,
    required String industry,
    required String targetMarket,
    required String businessModel,
    required String fundingGoal,
    required String timeline,
    required String description,
  }) {
    return '''
Create a comprehensive business plan for "$businessName", a $businessType in the $industry industry.

Business Details:
- Business Name: $businessName
- Type: $businessType
- Industry: $industry
- Target Market: $targetMarket
- Business Model: $businessModel
- Funding Goal: $fundingGoal
- Timeline: $timeline
- Description: $description

Please provide a detailed business plan with the following sections:

1. Executive Summary
2. Company Description
3. Market Analysis
4. Organization & Management
5. Service or Product Line
6. Marketing & Sales Strategy
7. Funding Request
8. Financial Projections
9. Risk Analysis
10. Implementation Timeline

Format the response as JSON with each section as a key-value pair.
''';
  }

  // Call OpenRouter API
  static Future<Map<String, dynamic>> _callOpenRouterAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://biznest.com',
          'X-Title': 'BizNest Business Plan Generator',
        },
        body: json.encode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 4000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        return {
          'success': true,
          'data': content,
        };
      } else {
        return {
          'success': false,
          'error': 'API request failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Parse AI response into structured business plan
  static Map<String, dynamic> _parseBusinessPlanResponse(String response) {
    try {
      // Try to parse as JSON first
      final jsonData = json.decode(response);
      return jsonData;
    } catch (e) {
      // If not JSON, parse as text and structure it
      return _parseTextResponse(response);
    }
  }

  // Parse text response into structured format
  static Map<String, dynamic> _parseTextResponse(String response) {
    final sections = <String, String>{};
    final lines = response.split('\n');
    
    String currentSection = '';
    StringBuffer currentContent = StringBuffer();
    
    for (String line in lines) {
      if (line.trim().isEmpty) continue;
      
      // Check if line is a section header
      if (line.startsWith(RegExp(r'^\d+\.\s+')) || 
          line.startsWith(RegExp(r'^[A-Z][a-z\s]+:'))) {
        // Save previous section
        if (currentSection.isNotEmpty) {
          sections[currentSection] = currentContent.toString().trim();
        }
        
        // Start new section
        currentSection = line.replaceAll(RegExp(r'^\d+\.\s+'), '').replaceAll(':', '').trim();
        currentContent.clear();
      } else {
        currentContent.writeln(line);
      }
    }
    
    // Save last section
    if (currentSection.isNotEmpty) {
      sections[currentSection] = currentContent.toString().trim();
    }
    
    return sections;
  }

  // Get mock business plan for demo
  static Map<String, dynamic> _getMockBusinessPlan({
    required String businessName,
    required String businessType,
    required String industry,
  }) {
    return {
      'business_name': businessName,
      'business_type': businessType,
      'industry': industry,
      'created_at': DateTime.now().toIso8601String(),
      'executive_summary': '''
$businessName is a $businessType in the $industry industry that aims to revolutionize the market through innovative solutions. Our mission is to provide exceptional value to our customers while building a sustainable and profitable business.

Key highlights:
- Strong market opportunity in the $industry sector
- Experienced team with proven track record
- Innovative business model with competitive advantages
- Clear path to profitability within 24 months
- Seeking funding to accelerate growth and market expansion
''',
      'company_description': '''
$businessName was founded with the vision of transforming the $industry landscape through cutting-edge technology and customer-centric solutions. We are committed to delivering high-quality products/services that meet the evolving needs of our target market.

Our core values:
- Innovation and continuous improvement
- Customer satisfaction and loyalty
- Integrity and transparency
- Team collaboration and growth
- Social responsibility and sustainability
''',
      'market_analysis': '''
The $industry market presents significant opportunities for growth and innovation. Key market trends include:

Market Size: The global $industry market is valued at \$X billion and growing at Y% annually.

Target Market: Our primary target market consists of [specific customer segments] who value [key benefits].

Competitive Landscape: While there are established players in the market, there's room for innovation and differentiation.

Market Opportunities:
- Emerging technologies and trends
- Underserved customer segments
- Regulatory changes creating new opportunities
- Growing demand for sustainable solutions
''',
      'organization_management': '''
Leadership Team:
- CEO: [Name] - [Background and experience]
- CTO: [Name] - [Technical expertise]
- CFO: [Name] - [Financial management experience]

Advisory Board:
- Industry experts with relevant experience
- Former executives from successful companies
- Academic advisors with research expertise

Organizational Structure:
- Flat hierarchy promoting innovation
- Cross-functional teams for better collaboration
- Clear reporting lines and accountability
''',
      'product_service_line': '''
Our core offering includes:

Primary Products/Services:
- [Product/Service 1]: [Description and key features]
- [Product/Service 2]: [Description and key features]
- [Product/Service 3]: [Description and key features]

Key Features:
- User-friendly interface and experience
- Scalable and reliable technology
- Comprehensive customer support
- Regular updates and improvements

Competitive Advantages:
- Unique technology or approach
- Superior customer service
- Cost-effective solutions
- Strong brand recognition
''',
      'marketing_sales_strategy': '''
Marketing Strategy:
- Digital marketing and social media presence
- Content marketing and thought leadership
- Partnerships and strategic alliances
- Trade shows and industry events

Sales Strategy:
- Direct sales to enterprise customers
- Online sales platform for smaller customers
- Channel partnerships for broader reach
- Customer success and retention programs

Pricing Strategy:
- Value-based pricing model
- Tiered pricing for different customer segments
- Competitive pricing analysis
- Flexible payment options
''',
      'funding_request': '''
Funding Requirements:
- Total funding needed: \$[Amount]
- Use of funds:
  - Product development: X%
  - Marketing and sales: Y%
  - Operations: Z%
  - Working capital: W%

Funding Sources:
- Venture capital investors
- Angel investors
- Government grants and programs
- Strategic partnerships

Expected Returns:
- Revenue projections and growth targets
- Exit strategy and timeline
- Investor returns and equity structure
''',
      'financial_projections': '''
3-Year Financial Projections:

Year 1:
- Revenue: \$[Amount]
- Expenses: \$[Amount]
- Net Income: \$[Amount]

Year 2:
- Revenue: \$[Amount]
- Expenses: \$[Amount]
- Net Income: \$[Amount]

Year 3:
- Revenue: \$[Amount]
- Expenses: \$[Amount]
- Net Income: \$[Amount]

Key Assumptions:
- Market growth rate
- Customer acquisition costs
- Pricing strategy
- Operational efficiency improvements
''',
      'risk_analysis': '''
Key Risks and Mitigation Strategies:

Market Risks:
- Economic downturns affecting demand
- Mitigation: Diversified customer base and flexible business model

Competitive Risks:
- New entrants or existing competitors
- Mitigation: Strong IP protection and continuous innovation

Operational Risks:
- Key personnel departure
- Mitigation: Strong company culture and retention programs

Financial Risks:
- Cash flow management
- Mitigation: Conservative financial planning and multiple funding sources
''',
      'implementation_timeline': '''
Phase 1 (Months 1-6):
- Product development and testing
- Team building and hiring
- Initial market research and validation

Phase 2 (Months 7-12):
- Market launch and customer acquisition
- Sales and marketing execution
- Operational scaling

Phase 3 (Months 13-24):
- Market expansion and growth
- Product enhancements and new features
- Strategic partnerships and alliances
''',
    };
  }

  // Save business plan
  static Future<void> _saveBusinessPlan(Map<String, dynamic> businessPlan) async {
    final plans = await getSavedBusinessPlans();
    plans.add(businessPlan);
    await StorageService.setString('saved_business_plans', json.encode(plans));
  }

  // Get saved business plans
  static Future<List<Map<String, dynamic>>> getSavedBusinessPlans() async {
    final plansJson = await StorageService.getString('saved_business_plans');
    if (plansJson != null) {
      final List<dynamic> plansList = json.decode(plansJson);
      return plansList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get business plan by ID
  static Future<Map<String, dynamic>?> getBusinessPlan(String id) async {
    final plans = await getSavedBusinessPlans();
    try {
      return plans.firstWhere((plan) => plan['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Update business plan
  static Future<void> updateBusinessPlan(String id, Map<String, dynamic> updates) async {
    final plans = await getSavedBusinessPlans();
    final index = plans.indexWhere((plan) => plan['id'] == id);
    if (index != -1) {
      plans[index] = {...plans[index], ...updates};
      await StorageService.setString('saved_business_plans', json.encode(plans));
    }
  }

  // Delete business plan
  static Future<void> deleteBusinessPlan(String id) async {
    final plans = await getSavedBusinessPlans();
    plans.removeWhere((plan) => plan['id'] == id);
    await StorageService.setString('saved_business_plans', json.encode(plans));
  }

  // Get business plan templates
  static List<Map<String, dynamic>> getBusinessPlanTemplates() {
    return [
      {
        'id': 'tech_startup',
        'name': 'Tech Startup',
        'description': 'Template for technology startups and software companies',
        'sections': [
          'Executive Summary',
          'Product Description',
          'Market Analysis',
          'Technology Stack',
          'Go-to-Market Strategy',
          'Financial Projections',
        ],
        'industry': 'Technology',
      },
      {
        'id': 'retail_business',
        'name': 'Retail Business',
        'description': 'Template for retail and e-commerce businesses',
        'sections': [
          'Executive Summary',
          'Store Concept',
          'Market Research',
          'Inventory Management',
          'Marketing Strategy',
          'Financial Projections',
        ],
        'industry': 'Retail',
      },
      {
        'id': 'service_business',
        'name': 'Service Business',
        'description': 'Template for service-based businesses',
        'sections': [
          'Executive Summary',
          'Service Description',
          'Target Market',
          'Operations Plan',
          'Pricing Strategy',
          'Financial Projections',
        ],
        'industry': 'Services',
      },
    ];
  }

  // Validate business plan data
  static Map<String, String> validateBusinessPlanData(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    if (data['business_name']?.toString().isEmpty ?? true) {
      errors['business_name'] = 'Business name is required';
    }
    
    if (data['industry']?.toString().isEmpty ?? true) {
      errors['industry'] = 'Industry is required';
    }
    
    if (data['target_market']?.toString().isEmpty ?? true) {
      errors['target_market'] = 'Target market is required';
    }
    
    if (data['business_model']?.toString().isEmpty ?? true) {
      errors['business_model'] = 'Business model is required';
    }
    
    return errors;
  }

  // Export business plan to different formats
  static Future<String> exportBusinessPlan(String id, String format) async {
    final plan = await getBusinessPlan(id);
    if (plan == null) throw Exception('Business plan not found');
    
    switch (format.toLowerCase()) {
      case 'pdf':
        return _exportToPDF(plan);
      case 'docx':
        return _exportToDOCX(plan);
      case 'txt':
        return _exportToTXT(plan);
      default:
        throw Exception('Unsupported format: $format');
    }
  }

  // Export to PDF (mock implementation)
  static String _exportToPDF(Map<String, dynamic> plan) {
    // In a real app, this would generate an actual PDF
    return 'PDF export functionality would be implemented here';
  }

  // Export to DOCX (mock implementation)
  static String _exportToDOCX(Map<String, dynamic> plan) {
    // In a real app, this would generate an actual DOCX
    return 'DOCX export functionality would be implemented here';
  }

  // Export to TXT
  static String _exportToTXT(Map<String, dynamic> plan) {
    final buffer = StringBuffer();
    buffer.writeln('BUSINESS PLAN: ${plan['business_name']}');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (var entry in plan.entries) {
      if (entry.key != 'business_name' && entry.value is String) {
        buffer.writeln('${entry.key.toUpperCase()}:');
        buffer.writeln('-' * 30);
        buffer.writeln(entry.value);
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }
}
