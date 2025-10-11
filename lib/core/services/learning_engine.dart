import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_data_service.dart';
import 'quiz_service.dart';

class LearningEngine {

  // Tutorial content based on skill levels
  static final Map<String, List<Map<String, dynamic>>> _tutorials = {
    'novice': [
      {
        'id': 'novice_1',
        'title': 'Introduction to Entrepreneurship',
        'description': 'Master the fundamentals of starting and running a successful business',
        'duration': 25,
        'category': 'fundamentals',
        'difficulty': 'novice',
        'content': {
          'sections': [
            {
              'title': 'What is Entrepreneurship?',
              'content':
                  'Entrepreneurship is the art and science of creating, developing, and managing a business venture with the goal of generating profit while solving real-world problems. Unlike traditional employment, entrepreneurship involves taking calculated risks, making independent decisions, and being accountable for both successes and failures.\n\nKey aspects of entrepreneurship include:\n- Innovation: Creating new products, services, or processes\n- Risk-taking: Willingness to invest time, money, and effort\n- Opportunity recognition: Identifying market gaps and customer needs\n- Resource management: Efficiently allocating limited resources\n- Value creation: Delivering products or services that customers find valuable',
              'type': 'text'
            },
            {
              'title': 'Types of Entrepreneurs',
              'content':
                  'Entrepreneurs come in many forms, each with different motivations and approaches:\n\n1. **Opportunity Entrepreneurs**: Start businesses to pursue market opportunities\n2. **Necessity Entrepreneurs**: Start businesses due to lack of other employment options\n3. **Social Entrepreneurs**: Focus on solving social problems through business\n4. **Serial Entrepreneurs**: Start multiple businesses throughout their career\n5. **Lifestyle Entrepreneurs**: Create businesses that support their desired lifestyle\n6. **Corporate Entrepreneurs (Intrapreneurs)**: Innovate within existing companies\n\nUnderstanding your type helps you choose the right business model and growth strategy.',
              'type': 'text'
            },
            {
              'title': 'The Entrepreneurial Mindset',
              'content':
                  'Successful entrepreneurs share common psychological traits and habits:\n\n**Core Traits:**\n- **Optimism**: Belief in positive outcomes despite challenges\n- **Resilience**: Ability to bounce back from setbacks\n- **Creativity**: Thinking outside the box to solve problems\n- **Adaptability**: Willingness to change course when needed\n- **Self-motivation**: Driving yourself without external supervision\n\n**Key Habits:**\n- **Continuous Learning**: Always seeking new knowledge and skills\n- **Networking**: Building relationships with mentors and peers\n- **Goal Setting**: Setting clear, measurable objectives\n- **Time Management**: Prioritizing tasks and managing resources effectively\n- **Customer Focus**: Always putting customer needs first',
              'type': 'text'
            },
            {
              'title': 'Common Entrepreneurial Challenges',
              'content':
                  'Every entrepreneur faces obstacles. Being prepared helps you overcome them:\n\n**Financial Challenges:**\n- Limited startup capital\n- Cash flow management\n- Pricing products/services\n- Securing funding\n\n**Operational Challenges:**\n- Finding the right team\n- Managing growth\n- Competition\n- Regulatory compliance\n\n**Personal Challenges:**\n- Work-life balance\n- Decision fatigue\n- Imposter syndrome\n- Isolation\n\n**Market Challenges:**\n- Customer acquisition\n- Market validation\n- Scaling operations\n- Economic downturns\n\nRemember: Challenges are opportunities to learn and grow stronger.',
              'type': 'text'
            },
            {
              'title': 'Quiz: Entrepreneurship Fundamentals',
              'content': 'Test your understanding of entrepreneurship basics',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the primary goal of entrepreneurship?',
                  'options': [
                    'To make money quickly',
                    'To create value and solve problems',
                    'To avoid working for others',
                    'To become famous'
                  ],
                  'correct': 1,
                  'explanation': 'Entrepreneurship is fundamentally about creating value for customers while solving real problems, though profit is often a natural outcome.'
                },
                {
                  'question': 'Which trait is NOT typically associated with successful entrepreneurs?',
                  'options': [
                    'Risk-taking',
                    'Creativity',
                    'Fear of failure',
                    'Resilience'
                  ],
                  'correct': 2,
                  'explanation': 'Successful entrepreneurs embrace calculated risks and learn from failures rather than fearing them.'
                },
                {
                  'question': 'What type of entrepreneur focuses on solving social problems?',
                  'options': [
                    'Opportunity entrepreneur',
                    'Necessity entrepreneur',
                    'Social entrepreneur',
                    'Lifestyle entrepreneur'
                  ],
                  'correct': 2,
                  'explanation': 'Social entrepreneurs prioritize social impact alongside or above financial returns.'
                }
              ]
            }
          ]
        },
        'prerequisites': [],
        'badge': 'entrepreneurial_spirit'
      },
      {
        'id': 'novice_2',
        'title': 'Understanding Your Market',
        'description': 'Master market research and customer discovery to build products people want',
        'duration': 35,
        'category': 'market_research',
        'difficulty': 'novice',
        'content': {
          'sections': [
            {
              'title': 'What is Market Research?',
              'content':
                  'Market research is the systematic process of gathering, analyzing, and interpreting information about your target market, customers, and competitors. It\'s the foundation of all successful businesses because it helps you:\n\n- Understand customer needs and pain points\n- Identify market opportunities and gaps\n- Validate business ideas before investing heavily\n- Develop products that customers actually want\n- Create effective marketing strategies\n- Stay ahead of competitors\n\nWithout proper market research, you\'re essentially guessing what customers want, which leads to wasted time, money, and effort.',
              'type': 'text'
            },
            {
              'title': 'Primary vs Secondary Research',
              'content':
                  '**Primary Research:** Data you collect yourself directly from customers\n- Surveys and questionnaires\n- Customer interviews\n- Focus groups\n- Observation studies\n- A/B testing\n\n**Secondary Research:** Data collected by others that you analyze\n- Industry reports\n- Government statistics\n- Competitor analysis\n- Academic studies\n- Market trend reports\n\n**Best Practice:** Start with secondary research to understand the big picture, then use primary research to get specific insights about your target customers.',
              'type': 'text'
            },
            {
              'title': 'Creating Customer Personas',
              'content':
                  '''A customer persona is a detailed profile of your ideal customer based on real data. It's not a generic description but a specific, vivid representation of who your customer is.

**Key Elements of a Persona:**
- **Demographics**: Age, gender, income, education, location
- **Psychographics**: Values, attitudes, lifestyle, interests
- **Goals and Motivations**: What they want to achieve
- **Pain Points**: Problems they face that your product can solve
- **Buying Behavior**: How and why they make purchasing decisions
- **Information Sources**: Where they get information

**Example Persona:**
"Meet Sarah, a 32-year-old marketing manager at a mid-sized tech company. She earns \$75K annually and values work-life balance. Her biggest pain point is spending too much time on repetitive marketing tasks. She wants tools that automate her workflow so she can focus on strategic thinking. She researches solutions on LinkedIn and trusts recommendations from industry peers."''',
              'type': 'text'
            },
            {
              'title': 'Market Sizing and Segmentation',
              'content':
                  '**Market Sizing:** Determining the total potential of your market\n- **Total Addressable Market (TAM)**: Total market demand for your product type\n- **Serviceable Addressable Market (SAM)**: Portion of TAM you can actually serve\n- **Serviceable Obtainable Market (SOM)**: Portion of SAM you can realistically capture\n\n**Market Segmentation:** Dividing your market into smaller groups\n- **Demographic**: Age, gender, income, education\n- **Geographic**: Location, climate, urban/rural\n- **Psychographic**: Lifestyle, values, personality\n- **Behavioral**: Usage rate, loyalty, benefits sought\n\n**Why Segment?** Different customer groups have different needs, and you can\'t serve everyone equally well. Focus on segments where you have the strongest competitive advantage.',
              'type': 'text'
            },
            {
              'title': 'Competitive Analysis',
              'content':
                  'Understanding your competition is crucial for positioning your business effectively.\n\n**Types of Competitors:**\n- **Direct Competitors**: Offer the same product/service as you\n- **Indirect Competitors**: Offer different solutions to the same problem\n- **Potential Competitors**: Could enter your market in the future\n\n**Competitive Analysis Framework:**\n1. **Identify Key Competitors**: 5-10 main competitors\n2. **Analyze Their Strengths**: What do they do well?\n3. **Analyze Their Weaknesses**: Where are their gaps?\n4. **Understand Their Strategy**: Pricing, positioning, marketing\n5. **Find Your Differentiators**: How will you be different/better?\n\n**SWOT Analysis:**\n- **Strengths**: Your advantages\n- **Weaknesses**: Your disadvantages\n- **Opportunities**: Market opportunities\n- **Threats**: External threats\n\nRemember: Competition isn\'t just about copying what others do—it\'s about finding gaps they haven\'t filled.',
              'type': 'text'
            },
            {
              'title': 'Validating Your Business Idea',
              'content':
                  'Before building your product, validate that customers actually want it.\n\n**Validation Methods:**\n- **Problem Interviews**: Talk to potential customers about their problems\n- **Solution Interviews**: Show mockups and get feedback\n- **Landing Page Tests**: Create a simple page describing your solution\n- **Pre-sales**: Sell your product before building it\n- **Minimum Viable Product (MVP)**: Build the smallest version possible\n\n**Key Metrics to Track:**\n- **Problem-Solution Fit**: Do customers recognize the problem?\n- **Product-Market Fit**: Do enough customers want your solution?\n- **Customer Acquisition Cost**: How much does it cost to get a customer?\n- **Lifetime Value**: How much revenue does each customer generate?\n\n**Lean Startup Methodology:** Build → Measure → Learn → Repeat. Don\'t spend months building something no one wants.',
              'type': 'text'
            },
            {
              'title': 'Quiz: Market Research Mastery',
              'content': 'Test your understanding of market research concepts',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the main purpose of market research?',
                  'options': [
                    'To find competitors to copy',
                    'To understand customer needs and validate business ideas',
                    'To create marketing materials',
                    'To set high prices'
                  ],
                  'correct': 1,
                  'explanation': 'Market research helps you understand what customers actually need and want, reducing the risk of building unwanted products.'
                },
                {
                  'question': 'Which of these is an example of primary research?',
                  'options': [
                    'Reading industry reports',
                    'Conducting customer interviews',
                    'Analyzing competitor websites',
                    'Studying government statistics'
                  ],
                  'correct': 1,
                  'explanation': 'Primary research involves collecting data directly from customers through interviews, surveys, or observations.'
                },
                {
                  'question': 'What does TAM stand for in market sizing?',
                  'options': [
                    'Total Available Market',
                    'Target Audience Market',
                    'Total Addressable Market',
                    'Targeted Advertising Market'
                  ],
                  'correct': 2,
                  'explanation': 'TAM (Total Addressable Market) represents the total market demand for a product or service type.'
                },
                {
                  'question': 'Why is competitive analysis important?',
                  'options': [
                    'To copy successful competitors exactly',
                    'To understand market gaps and position your business effectively',
                    'To avoid entering competitive markets',
                    'To focus only on pricing strategies'
                  ],
                  'correct': 1,
                  'explanation': 'Competitive analysis helps you understand what works, what doesn\'t, and how to differentiate your business.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['novice_1'],
        'badge': 'market_insight'
      },
      {
        'id': 'novice_3',
        'title': 'Business Model Canvas',
        'description': 'Learn to design and validate your business model using the Business Model Canvas framework',
        'duration': 30,
        'category': 'business_planning',
        'difficulty': 'novice',
        'content': {
          'sections': [
            {
              'title': 'What is the Business Model Canvas?',
              'content':
                  'The Business Model Canvas (BMC) is a strategic management template for developing new or documenting existing business models. Created by Alexander Osterwalder, it\'s a visual tool that helps entrepreneurs and business leaders:\n\n- **Clarify their business model**: See how all parts fit together\n- **Identify opportunities**: Spot gaps and improvement areas\n- **Communicate ideas**: Share complex business concepts visually\n- **Test assumptions**: Validate each component before investing\n- **Pivot when needed**: Make strategic changes based on learning\n\nThe BMC consists of 9 building blocks that cover the four main areas of a business: customers, offer, infrastructure, and financial viability.',
              'type': 'text'
            },
            {
              'title': 'The 9 Building Blocks',
              'content':
                  '**1. Value Propositions**\nWhat value do you deliver to customers? What problems do you solve?\n\n**2. Customer Segments**\nWho are your customers? Who do you create value for?\n\n**3. Channels**\nHow do you reach your customers? How do you deliver your value proposition?\n\n**4. Customer Relationships**\nWhat type of relationship do you establish with each customer segment?\n\n**5. Revenue Streams**\nHow do you make money? What are customers willing to pay for?\n\n**6. Key Resources**\nWhat resources do you need to create value?\n\n**7. Key Activities**\nWhat activities do you need to perform to deliver your value?\n\n**8. Key Partnerships**\nWho are your partners and suppliers? What resources do they provide?\n\n**9. Cost Structure**\nWhat are the most important costs in your business model?',
              'type': 'text'
            },
            {
              'title': 'Value Propositions Deep Dive',
              'content':
                  'Your value proposition is the heart of your business model. It answers: Why should customers choose you?\n\n**Types of Value Propositions:**\n- **Newness**: Offer something new or innovative\n- **Performance**: Improve performance or quality\n- **Customization**: Tailor products/services to specific needs\n- **Getting the Job Done**: Help customers accomplish tasks\n- **Design**: Make products more attractive or user-friendly\n- **Brand/Status**: Enhance social status or self-image\n- **Price**: Offer lower prices\n- **Cost Reduction**: Help customers reduce costs\n- **Risk Reduction**: Reduce risks for customers\n- **Accessibility**: Make products/services more accessible\n- **Convenience/Usability**: Make things easier to use\n\n**Creating Strong Value Props:**\n1. Understand customer jobs, pains, and gains\n2. Brainstorm how your product/service addresses these\n3. Prioritize the most important value propositions\n4. Test with real customers\n5. Refine based on feedback',
              'type': 'text'
            },
            {
              'title': 'Customer Segments & Relationships',
              'content':
                  '**Customer Segments:**\n- **Mass Market**: Broad customer base with similar needs\n- **Niche Market**: Specific, focused customer group\n- **Segmented**: Multiple customer groups with different needs\n- **Diversified**: Very different customer segments\n- **Multi-sided Platforms**: Multiple interdependent customer groups\n\n**Customer Relationships:**\n- **Personal Assistance**: Human interaction\n- **Dedicated Personal Assistance**: Assigned relationship manager\n- **Self-Service**: Customers serve themselves\n- **Automated Services**: Technology handles interactions\n- **Communities**: User communities and forums\n- **Co-creation**: Customers help create value\n\n**Relationship Building Tips:**\n- Start with the relationships that drive most revenue\n- Match relationship type to customer segment\n- Consider cost-benefit of different relationship types\n- Use technology to scale relationships\n- Focus on customer lifetime value, not just acquisition',
              'type': 'text'
            },
            {
              'title': 'Revenue Streams & Cost Structure',
              'content':
                  '**Revenue Stream Types:**\n- **Asset Sale**: Selling ownership of physical/virtual goods\n- **Usage Fee**: Paying for use of service/product\n- **Subscription Fees**: Recurring payments for ongoing access\n- **Lending/Renting/Leasing**: Temporary access rights\n- **Licensing**: Intellectual property rights\n- **Brokerage Fees**: Commission on transactions\n- **Advertising**: Revenue from advertising\n\n**Cost Structure Types:**\n- **Cost-Driven**: Focus on minimizing costs\n- **Value-Driven**: Focus on value creation\n- **Fixed Costs**: Don\'t vary with output (rent, salaries)\n- **Variable Costs**: Vary with output (materials, commissions)\n- **Economies of Scale**: Costs decrease as volume increases\n- **Economies of Scope**: Costs decrease by leveraging shared resources\n\n**Revenue-Cost Alignment:**\nYour revenue streams must cover your cost structure. Consider:\n- Which revenue streams are most profitable?\n- How do costs change as you scale?\n- What\'s your path to profitability?\n- How can you optimize the revenue-cost relationship?',
              'type': 'text'
            },
            {
              'title': 'Channels & Key Resources',
              'content':
                  '**Distribution Channels:**\n- **Direct Channels**: Company sells directly to customers\n- **Indirect Channels**: Third parties sell your products\n- **Owned Channels**: Company-owned (website, stores)\n- **Partner Channels**: Partner-owned (retailers, distributors)\n\n**Channel Phases:**\n1. **Awareness**: How do customers find you?\n2. **Evaluation**: How do customers learn about your offering?\n3. **Purchase**: How do customers buy?\n4. **Delivery**: How do customers get your product/service?\n5. **After-Sales**: How do you support customers?\n\n**Key Resources:**\n- **Physical**: Buildings, vehicles, machines, inventory\n- **Intellectual**: Brands, proprietary knowledge, patents, copyrights\n- **Human**: Employees, skills, expertise\n- **Financial**: Cash, credit lines, stock options\n\n**Resource Strategy:**\n- Identify resources critical to your value proposition\n- Consider owned vs. rented/leased resources\n- Think about scalability and flexibility\n- Plan for resource acquisition and development',
              'type': 'text'
            },
            {
              'title': 'Key Activities & Partnerships',
              'content':
                  '**Key Activities Categories:**\n- **Production**: Designing, making, delivering products\n- **Problem Solving**: Finding new solutions to customer problems\n- **Platform/Network**: Building and maintaining platforms\n- **Brand Management**: Marketing and brand development\n- **Customer Relationship Management**: Managing customer interactions\n\n**Partnership Types:**\n- **Strategic Alliances**: Joint ventures between non-competitors\n- **Coopetition**: Partnerships with competitors\n- **Joint Buying**: Group purchasing to reduce costs\n- **Joint Development**: Collaborating on new products/services\n- **Licensing**: Using or providing intellectual property\n- **Supplier Partnerships**: Close relationships with suppliers\n\n**Partnership Benefits:**\n- Access to resources you don\'t own\n- Risk sharing\n- Cost optimization\n- Access to new markets\n- Enhanced credibility\n- Accelerated growth\n\n**Partnership Strategy:**\n- Focus on partnerships that support your key activities\n- Choose partners that complement your strengths\n- Define clear roles and responsibilities\n- Establish mutual benefits and accountability',
              'type': 'text'
            },
            {
              'title': 'BMC Workshop: Build Your Canvas',
              'content':
                  'Now it\'s time to apply what you\'ve learned. Follow these steps to create your Business Model Canvas:\n\n**Step 1: Start with Customer Segments**\nWho are your customers? Be specific and detailed.\n\n**Step 2: Define Value Propositions**\nWhat value do you deliver to each customer segment?\n\n**Step 3: Design Customer Relationships**\nHow will you interact with each customer segment?\n\n**Step 4: Create Channels**\nHow will you reach customers and deliver value?\n\n**Step 5: Identify Revenue Streams**\nHow will each customer segment pay you?\n\n**Step 6: Determine Key Resources**\nWhat resources do you need?\n\n**Step 7: List Key Activities**\nWhat activities drive your business model?\n\n**Step 8: Find Key Partnerships**\nWho will help you?\n\n**Step 9: Analyze Cost Structure**\nWhat are your major costs?\n\n**Step 10: Test and Iterate**\nShare your canvas with mentors and customers. Refine based on feedback.',
              'type': 'text'
            },
            {
              'title': 'Quiz: Business Model Mastery',
              'content': 'Test your understanding of the Business Model Canvas',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the Business Model Canvas primarily used for?',
                  'options': [
                    'Creating financial projections',
                    'Designing and documenting business models',
                    'Writing marketing copy',
                    'Managing employee performance'
                  ],
                  'correct': 1,
                  'explanation': 'The BMC is a strategic tool for developing and communicating business models visually.'
                },
                {
                  'question': 'Which building block comes first when creating a BMC?',
                  'options': [
                    'Revenue Streams',
                    'Customer Segments',
                    'Key Resources',
                    'Cost Structure'
                  ],
                  'correct': 1,
                  'explanation': 'Start with Customer Segments to understand who you\'re creating value for.'
                },
                {
                  'question': 'What type of value proposition focuses on making things easier to use?',
                  'options': [
                    'Performance',
                    'Design',
                    'Convenience/Usability',
                    'Cost Reduction'
                  ],
                  'correct': 2,
                  'explanation': 'Convenience/Usability value propositions make products easier or more pleasant to use.'
                },
                {
                  'question': 'Which of these is typically a variable cost?',
                  'options': [
                    'Office rent',
                    'Raw materials',
                    'CEO salary',
                    'Software licenses'
                  ],
                  'correct': 1,
                  'explanation': 'Variable costs change with production volume, like raw materials needed for manufacturing.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['novice_1', 'novice_2'],
        'badge': 'business_modeler'
      }
    ],
    'intermediate': [
      {
        'id': 'intermediate_1',
        'title': 'Advanced Financial Modeling',
        'description': 'Master financial modeling for startups',
        'duration': 45,
        'category': 'financial_management',
        'difficulty': 'intermediate',
        'content': {
          'sections': [
            {
              'title': 'Building Financial Models',
              'content':
                  'Create sophisticated financial models for your startup...',
              'type': 'text'
            },
            {
              'title': 'Valuation Methods',
              'content': 'Learn different startup valuation techniques...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['novice_1', 'novice_2'],
        'badge': 'financial_expert'
      }
    ],
    'advanced': [
      {
        'id': 'advanced_1',
        'title': 'Scaling Your Startup',
        'description': 'Strategies for growing your business',
        'duration': 60,
        'category': 'growth',
        'difficulty': 'advanced',
        'content': {
          'sections': [
            {
              'title': 'Growth Strategies',
              'content': 'Different approaches to scaling your business...',
              'type': 'text'
            },
            {
              'title': 'Team Building',
              'content': 'Building and managing a growing team...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['intermediate_1'],
        'badge': 'scale_master'
      }
    ],
    'expert': [
      {
        'id': 'expert_1',
        'title': 'Mentoring Other Entrepreneurs',
        'description': 'Share your knowledge and experience',
        'duration': 30,
        'category': 'leadership',
        'difficulty': 'expert',
        'content': {
          'sections': [
            {
              'title': 'Effective Mentoring',
              'content':
                  'How to be an effective mentor to other entrepreneurs...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['advanced_1'],
        'badge': 'mentor'
      }
    ]
  };

  // Get personalized tutorials for user
  static Future<List<Map<String, dynamic>>> getPersonalizedTutorials() async {
    try {
      final userLevel = await QuizService.getUserLevel();
      final progress = await getLearningProgress();
      final completedTutorials = progress['completed_tutorials'] as List<dynamic>;

      List<Map<String, dynamic>> availableTutorials = [];

      // Get tutorials for current level and below
      for (String level in [
        'novice',
        'intermediate',
        'advanced'
      ]) {
        if (_isLevelAccessible(level, userLevel)) {
          final levelTutorials = _tutorials[level] ?? [];
          for (var tutorial in levelTutorials) {
            if (!completedTutorials.contains(tutorial['id']) &&
                _arePrerequisitesMet(
                    tutorial['prerequisites'], completedTutorials)) {
              availableTutorials.add(tutorial);
            }
          }
        }
      }

      return availableTutorials;
    } catch (e) {
      // Return default novice tutorials if Firebase fails
      return _tutorials['novice'] ?? [];
    }
  }

  // Check if level is accessible based on user's current level
  static bool _isLevelAccessible(String level, String userLevel) {
    final levelOrder = [
      'novice',
      'intermediate',
      'advanced'
    ];
    final userIndex = levelOrder.indexOf(userLevel);
    final levelIndex = levelOrder.indexOf(level);
    return levelIndex <= userIndex;
  }

  // Check if prerequisites are met
  static bool _arePrerequisitesMet(
      List<dynamic> prerequisites, List<dynamic> completed) {
    for (var prereq in prerequisites) {
      if (!completed.contains(prereq)) {
        return false;
      }
    }
    return true;
  }

  // Start a tutorial
  static Future<void> startTutorial(String tutorialId) async {
    final progress = await getLearningProgress();
    final inProgress = progress['in_progress_tutorials'] as List<dynamic>;

    if (!inProgress.contains(tutorialId)) {
      inProgress.add(tutorialId);
      await _saveLearningProgress(progress);
    }
  }

  // Complete a tutorial
  static Future<TutorialCompletionResult> completeTutorial(
      String tutorialId, Map<String, dynamic> completionData) async {
    try {
      final progress = await getLearningProgress();
      final completed = progress['completed_tutorials'] as List<dynamic>;
      final inProgress = progress['in_progress_tutorials'] as List<dynamic>;

      // Remove from in-progress and add to completed
      inProgress.remove(tutorialId);
      if (!completed.contains(tutorialId)) {
        completed.add(tutorialId);
      }

      // Update streak
      final now = DateTime.now();
      final lastCompletionDate = progress['last_completion_date'] != null
          ? DateTime.parse(progress['last_completion_date'])
          : null;
      
      if (lastCompletionDate == null || 
          now.difference(lastCompletionDate).inDays == 1) {
        // Continue or start streak
        progress['current_streak'] = (progress['current_streak'] ?? 0) + 1;
        if (progress['current_streak'] > (progress['longest_streak'] ?? 0)) {
          progress['longest_streak'] = progress['current_streak'];
        }
      } else if (now.difference(lastCompletionDate).inDays > 1) {
        // Streak broken, reset to 1
        progress['current_streak'] = 1;
      }
      // If same day, don't update streak
      
      progress['last_completion_date'] = now.toIso8601String();

      // Update total time spent
      final timeSpent = completionData['time_spent'] as int? ?? 0;
      progress['total_time_spent'] = (progress['total_time_spent'] ?? 0) + timeSpent;

      // Calculate score and determine if badge is earned
      final tutorial = _getTutorialById(tutorialId);
      final score = _calculateTutorialScore(completionData);
      final badge = tutorial?['badge'];

      // Award badge if earned
      if (badge != null && score >= 70) {
        await _awardBadge(badge);
      }

      // Update progress
      await _saveLearningProgress(progress);

      // Check for level up
      final newLevel = await _checkLevelUp();

      // Update leaderboard entry with new score
      await updateLeaderboardEntry();

      return TutorialCompletionResult(
        tutorialId: tutorialId,
        score: score,
        badgeEarned: badge != null && score >= 70 ? badge : null,
        levelUp: newLevel != null,
        newLevel: newLevel,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error completing tutorial: $e');
      }
      throw Exception('Failed to complete tutorial');
    }
  }

  // Get tutorial by ID
  static Map<String, dynamic>? _getTutorialById(String tutorialId) {
    for (var levelTutorials in _tutorials.values) {
      for (var tutorial in levelTutorials) {
        if (tutorial['id'] == tutorialId) {
          return tutorial;
        }
      }
    }
    return null;
  }

  // Calculate tutorial score
  static double _calculateTutorialScore(Map<String, dynamic> completionData) {
    // Simple scoring based on completion data
    // In a real app, this would be more sophisticated
    final quizAnswers = completionData['quiz_answers'] as List<dynamic>? ?? [];
    final timeSpent = completionData['time_spent'] as int? ?? 0;
    final sectionsCompleted = completionData['sections_completed'] as int? ?? 0;

    double score = 0;

    // Quiz score (70% weight)
    if (quizAnswers.isNotEmpty) {
      int correctAnswers = 0;
      for (var answer in quizAnswers) {
        if (answer['is_correct'] == true) {
          correctAnswers++;
        }
      }
      score += (correctAnswers / quizAnswers.length) * 70;
    }

    // Completion score (20% weight)
    score += (sectionsCompleted / 3) * 20; // Assuming 3 sections average

    // Time bonus (10% weight)
    if (timeSpent > 0) {
      score += 10; // Full bonus for spending time
    }

    return score.clamp(0, 100);
  }

  // Award badge to user
  static Future<void> _awardBadge(String badgeId) async {
    final badges = await getUserBadges();
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await FirebaseDataService.setList('user_badges', badges);
    }
  }

  // Get user's badges
  static Future<List<String>> getUserBadges() async {
    try {
      final badgesList = await FirebaseDataService.getList('user_badges');
      return badgesList?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  // Check if user should level up
  static Future<String?> _checkLevelUp() async {
    final progress = await getLearningProgress();
    final completed = progress['completed_tutorials'] as List<dynamic>;
    final currentLevel = await QuizService.getUserLevel();

    // Simple level up logic based on completed tutorials
    int completedCount = completed.length;
    String? newLevel;

    if (completedCount >= 20 && currentLevel != 'expert') {
      newLevel = 'expert';
    } else if (completedCount >= 15 && currentLevel != 'advanced') {
      newLevel = 'advanced';
    } else if (completedCount >= 10 && currentLevel != 'intermediate') {
      newLevel = 'intermediate';
    } else if (completedCount >= 5 && currentLevel != 'novice') {
      newLevel = 'novice';
    }

    if (newLevel != null) {
      await QuizService.updateUserLevel(newLevel);
    }

    return newLevel;
  }

  // Get learning progress
  static Future<Map<String, dynamic>> getLearningProgress() async {
    try {
      final progress = await FirebaseDataService.getJson('learning_progress');
      return progress ?? {
        'completed_tutorials': [],
        'in_progress_tutorials': [],
        'total_time_spent': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'last_completion_date': null,
      };
    } catch (e) {
      return {
        'completed_tutorials': [],
        'in_progress_tutorials': [],
        'total_time_spent': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'last_completion_date': null,
      };
    }
  }

  // Save learning progress
  static Future<void> _saveLearningProgress(
      Map<String, dynamic> progress) async {
    await FirebaseDataService.setJson('learning_progress', progress);
  }

  // Get learning statistics
  static Future<Map<String, dynamic>> getLearningStatistics() async {
    try {
      final progress = await getLearningProgress();
      final badges = await getUserBadges();
      final level = await QuizService.getUserLevel();

      return {
        'current_level': level,
        'completed_tutorials': (progress['completed_tutorials'] as List).length,
        'total_badges': badges.length,
        'current_streak': progress['current_streak'] ?? 0,
        'longest_streak': progress['longest_streak'] ?? 0,
        'total_time_spent': progress['total_time_spent'] ?? 0,
        'badges': badges,
      };
    } catch (e) {
      return {
        'current_level': 'novice',
        'completed_tutorials': 0,
        'total_badges': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'total_time_spent': 0,
        'badges': [],
      };
    }
  }

  // Update user's leaderboard entry
  static Future<void> updateLeaderboardEntry() async {
    try {
      final userId = FirebaseDataService.currentUserId;
      if (userId == null) return;

      // Get current user's data
      final progress = await getLearningProgress();
      final badges = await getUserBadges();
      final level = await QuizService.getUserLevel();
      
      // Calculate score
      final completedTutorials = (progress['completed_tutorials'] as List).length;
      final userScore = (completedTutorials * 100) + 
                       (badges.length * 50) + 
                       (progress['current_streak'] ?? 0) * 10;

      // Get user profile data
      final userProfile = await FirebaseDataService.getData('profile', 'info');
      final userName = userProfile?['name'] ?? userProfile?['full_name'] ?? 'Anonymous';

      // Update leaderboard entry in Firestore
      await FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(userId)
          .set({
        'user_id': userId,
        'name': userName,
        'level': level,
        'score': userScore,
        'badges': badges.length,
        'completed_tutorials': completedTutorials,
        'current_streak': progress['current_streak'] ?? 0,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Leaderboard entry updated for user: $userName (Score: $userScore)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating leaderboard entry: $e');
      }
    }
  }

  // Get leaderboard data
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final userId = FirebaseDataService.currentUserId;
      
      // Fetch top users from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(50)
          .get();

      final leaderboard = <Map<String, dynamic>>[];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        leaderboard.add({
          'user_id': data['user_id'] ?? doc.id,
          'name': data['name'] ?? 'Anonymous',
          'level': data['level'] ?? 'novice',
          'score': data['score'] ?? 0,
          'badges': data['badges'] ?? 0,
          'is_current_user': doc.id == userId,
        });
      }

      // If current user is not in top 50, fetch and add them
      if (userId != null && !leaderboard.any((user) => user['is_current_user'])) {
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('leaderboard')
            .doc(userId)
            .get();

        if (currentUserDoc.exists) {
          final data = currentUserDoc.data()!;
          leaderboard.add({
            'user_id': userId,
            'name': 'You',
            'level': data['level'] ?? 'novice',
            'score': data['score'] ?? 0,
            'badges': data['badges'] ?? 0,
            'is_current_user': true,
          });
          
          // Re-sort to put user in correct position
          leaderboard.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
        } else {
          // User doesn't have a leaderboard entry yet, create one
          await updateLeaderboardEntry();
          
          // Fetch again after creating
          final newUserDoc = await FirebaseFirestore.instance
              .collection('leaderboard')
              .doc(userId)
              .get();
          
          if (newUserDoc.exists) {
            final data = newUserDoc.data()!;
            leaderboard.add({
              'user_id': userId,
              'name': 'You',
              'level': data['level'] ?? 'novice',
              'score': data['score'] ?? 0,
              'badges': data['badges'] ?? 0,
              'is_current_user': true,
            });
            
            leaderboard.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
          }
        }
      } else {
        // Update current user's name to "You" for display
        for (var user in leaderboard) {
          if (user['is_current_user'] == true) {
            user['name'] = 'You';
            break;
          }
        }
      }

      if (kDebugMode) {
        print('📊 Loaded ${leaderboard.length} users from leaderboard');
      }

      return leaderboard;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting leaderboard: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get recommended next tutorial
  static Future<Map<String, dynamic>?> getRecommendedTutorial() async {
    final tutorials = await getPersonalizedTutorials();
    if (tutorials.isEmpty) return null;

    // Return the first available tutorial
    return tutorials.first;
  }

  // Get tutorial progress
  static Future<Map<String, dynamic>> getTutorialProgress(
      String tutorialId) async {
    final progress = await getLearningProgress();
    final inProgress = progress['in_progress_tutorials'] as List<dynamic>;

    if (inProgress.contains(tutorialId)) {
      return {
        'status': 'in_progress',
        'progress_percentage': 50, // Mock progress
        'sections_completed': 1,
        'total_sections': 3,
      };
    }

    final completed = progress['completed_tutorials'] as List<dynamic>;
    if (completed.contains(tutorialId)) {
      return {
        'status': 'completed',
        'progress_percentage': 100,
        'sections_completed': 3,
        'total_sections': 3,
      };
    }

    return {
      'status': 'not_started',
      'progress_percentage': 0,
      'sections_completed': 0,
      'total_sections': 3,
    };
  }

  // Update tutorial progress
  static Future<void> updateTutorialProgress(
      String tutorialId, Map<String, dynamic> progress) async {
    final learningProgress = await getLearningProgress();
    final tutorialProgress = learningProgress['tutorial_progress'] as Map<String, dynamic>? ?? {};

    tutorialProgress[tutorialId] = {
      ...progress,
      'last_updated': DateTime.now().toIso8601String(),
    };

    learningProgress['tutorial_progress'] = tutorialProgress;
    await _saveLearningProgress(learningProgress);
  }

  // Check and update streak on app launch
  static Future<void> checkAndUpdateStreak() async {
    try {
      final progress = await getLearningProgress();
      final lastCompletionDate = progress['last_completion_date'] != null
          ? DateTime.parse(progress['last_completion_date'])
          : null;
      
      if (lastCompletionDate != null) {
        final now = DateTime.now();
        final daysSinceLastCompletion = now.difference(lastCompletionDate).inDays;
        
        // If more than 1 day has passed, reset streak
        if (daysSinceLastCompletion > 1) {
          progress['current_streak'] = 0;
          await _saveLearningProgress(progress);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking streak: $e');
      }
    }
  }

  // Reset all learning progress
  static Future<void> resetLearningProgress() async {
    try {
      // Reset learning progress
      await FirebaseDataService.setJson('learning_progress', {
        'completed_tutorials': [],
        'in_progress_tutorials': [],
        'total_time_spent': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'last_completion_date': null,
      });

      // Reset user level to novice
      await QuizService.updateUserLevel('novice');

      // Reset user badges (as a map structure)
      await FirebaseDataService.setJson('user_badges', {'badges': []});

      // Reset learning statistics
      await FirebaseDataService.setJson('learning_statistics', {
        'completed_tutorials': 0,
        'total_time_spent': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'total_badges': 0,
        'current_level': 'novice',
        'quiz_completed': 0,
        'average_score': 0.0,
      });

      // Reset quiz history and results
      await FirebaseDataService.setJson('quiz_results', {'results': []});
      await FirebaseDataService.setJson('quiz_history', {'history': []});

      if (kDebugMode) {
        print('✅ Learning progress reset successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting learning progress: $e');
      }
      throw e;
    }
  }
}

// Tutorial completion result model
class TutorialCompletionResult {
  final String tutorialId;
  final double score;
  final String? badgeEarned;
  final bool levelUp;
  final String? newLevel;

  TutorialCompletionResult({
    required this.tutorialId,
    required this.score,
    this.badgeEarned,
    required this.levelUp,
    this.newLevel,
  });
}

