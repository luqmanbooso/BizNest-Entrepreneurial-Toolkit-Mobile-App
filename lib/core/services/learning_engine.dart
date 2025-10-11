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
        'description':
            'Master the fundamentals of starting and running a successful business',
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
                  'explanation':
                      'Entrepreneurship is fundamentally about creating value for customers while solving real problems, though profit is often a natural outcome.'
                },
                {
                  'question':
                      'Which trait is NOT typically associated with successful entrepreneurs?',
                  'options': [
                    'Risk-taking',
                    'Creativity',
                    'Fear of failure',
                    'Resilience'
                  ],
                  'correct': 2,
                  'explanation':
                      'Successful entrepreneurs embrace calculated risks and learn from failures rather than fearing them.'
                },
                {
                  'question':
                      'What type of entrepreneur focuses on solving social problems?',
                  'options': [
                    'Opportunity entrepreneur',
                    'Necessity entrepreneur',
                    'Social entrepreneur',
                    'Lifestyle entrepreneur'
                  ],
                  'correct': 2,
                  'explanation':
                      'Social entrepreneurs prioritize social impact alongside or above financial returns.'
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
        'description':
            'Master market research and customer discovery to build products people want',
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
                  'explanation':
                      'Market research helps you understand what customers actually need and want, reducing the risk of building unwanted products.'
                },
                {
                  'question':
                      'Which of these is an example of primary research?',
                  'options': [
                    'Reading industry reports',
                    'Conducting customer interviews',
                    'Analyzing competitor websites',
                    'Studying government statistics'
                  ],
                  'correct': 1,
                  'explanation':
                      'Primary research involves collecting data directly from customers through interviews, surveys, or observations.'
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
                  'explanation':
                      'TAM (Total Addressable Market) represents the total market demand for a product or service type.'
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
                  'explanation':
                      'Competitive analysis helps you understand what works, what doesn\'t, and how to differentiate your business.'
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
        'description':
            'Learn to design and validate your business model using the Business Model Canvas framework',
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
                  'question':
                      'What is the Business Model Canvas primarily used for?',
                  'options': [
                    'Creating financial projections',
                    'Designing and documenting business models',
                    'Writing marketing copy',
                    'Managing employee performance'
                  ],
                  'correct': 1,
                  'explanation':
                      'The BMC is a strategic tool for developing and communicating business models visually.'
                },
                {
                  'question':
                      'Which building block comes first when creating a BMC?',
                  'options': [
                    'Revenue Streams',
                    'Customer Segments',
                    'Key Resources',
                    'Cost Structure'
                  ],
                  'correct': 1,
                  'explanation':
                      'Start with Customer Segments to understand who you\'re creating value for.'
                },
                {
                  'question':
                      'What type of value proposition focuses on making things easier to use?',
                  'options': [
                    'Performance',
                    'Design',
                    'Convenience/Usability',
                    'Cost Reduction'
                  ],
                  'correct': 2,
                  'explanation':
                      'Convenience/Usability value propositions make products easier or more pleasant to use.'
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
                  'explanation':
                      'Variable costs change with production volume, like raw materials needed for manufacturing.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['novice_1', 'novice_2'],
        'badge': 'business_modeler'
      },
      {
        'id': 'novice_4',
        'title': 'Lean Startup Methodology',
        'description':
            'Learn to build successful startups using lean principles and validated learning',
        'duration': 40,
        'category': 'startup_methodology',
        'difficulty': 'novice',
        'content': {
          'sections': [
            {
              'title': 'Introduction to Lean Startup',
              'content':
                  'The Lean Startup methodology, pioneered by Eric Ries, revolutionizes how companies are built and new products are launched. It\'s designed to help startups:\n\n- **Reduce waste**: Avoid building products nobody wants\n- **Learn faster**: Get customer feedback as quickly as possible\n- **Pivot when needed**: Change direction based on learning\n- **Scale efficiently**: Grow sustainable businesses\n\n**Core Principles:**\n1. **Validated Learning**: Test your assumptions with real customers\n2. **Build-Measure-Learn**: Create feedback loops to drive decision-making\n3. **Innovation Accounting**: Measure progress in uncertain environments\n4. **Minimum Viable Product (MVP)**: Start with the smallest possible version\n5. **Pivot or Persevere**: Make data-driven decisions about your direction\n\n**Why Lean Startup Works:**\nTraditional business planning assumes you can predict customer behavior and market dynamics. Lean Startup acknowledges uncertainty and provides tools to navigate it systematically.',
              'type': 'text'
            },
            {
              'title': 'The Build-Measure-Learn Loop',
              'content':
                  'The Build-Measure-Learn loop is the core engine of the Lean Startup methodology. It\'s designed to turn ideas into products, measure customer responses, and learn whether to pivot or persevere.\n\n**BUILD: Minimum Viable Product**\n- Create the smallest version of your product that provides value\n- Focus on core functionality, not polish\n- Use prototypes, landing pages, or concierge services\n- Goal: Test your riskiest assumptions first\n\n**MEASURE: Validated Learning**\n- Define actionable metrics (not vanity metrics)\n- Collect quantitative and qualitative data\n- Track user behavior, not just opinions\n- Use cohort analysis to understand trends\n\n**LEARN: Make Informed Decisions**\n- Analyze results objectively\n- Identify which assumptions were correct/incorrect\n- Decide whether to pivot or persevere\n- Apply learnings to the next iteration\n\n**Accelerating the Loop:**\nThe faster you complete Build-Measure-Learn cycles, the more you learn and the better your product becomes. Speed is crucial in startup environments.',
              'type': 'text'
            },
            {
              'title': 'Validated Learning & Metrics',
              'content':
                  'Validated learning is the process of demonstrating empirically that a team has discovered valuable truths about a startup\'s present and future business prospects.\n\n**Types of Metrics:**\n\n**Vanity Metrics (Avoid These):**\n- Total users registered\n- Total page views\n- Total downloads\n- Raw social media followers\n\n**Actionable Metrics (Focus on These):**\n- Customer Acquisition Cost (CAC)\n- Monthly Recurring Revenue (MRR)\n- Customer Lifetime Value (LTV)\n- Retention/Churn rates\n- Daily/Monthly Active Users\n- Conversion rates through your funnel\n\n**Innovation Accounting Framework:**\n1. **Establish Baseline**: Where are you now?\n2. **Tune the Engine**: Make small improvements\n3. **Pivot or Persevere**: Based on learning\n\n**Key Performance Indicators (KPIs):**\n- Choose 2-3 KPIs that matter most\n- Make them specific and measurable\n- Ensure they drive behavior\n- Review regularly and adjust as needed\n\n**Learning Milestones:**\nSet learning goals, not just feature goals. What do you need to learn to reduce uncertainty?',
              'type': 'text'
            },
            {
              'title': 'Pivot Strategies',
              'content':
                  'A pivot is a structured course correction designed to test a new fundamental hypothesis about the product, strategy, and engine of growth.\n\n**Types of Pivots:**\n\n**1. Zoom-in Pivot**\nA single feature becomes the whole product\nExample: Twitter started as a podcasting platform, pivoted to focus on status updates\n\n**2. Zoom-out Pivot**\nThe whole product becomes a single feature of a larger product\nExample: Instagram started as Burbn (location check-in app), pivoted to photo-sharing\n\n**3. Customer Segment Pivot**\nSame product, different customer segment\nExample: Facebook started for college students, expanded to everyone\n\n**4. Customer Need Pivot**\nSame customers, different problem\nExample: Slack started as a gaming company, pivoted to team communication\n\n**5. Solution Pivot**\nSame problem, different solution\nExample: Dropbox considered various sync solutions before settling on file-sharing\n\n**6. Revenue Model Pivot**\nChange how you make money\nExample: Netflix pivoted from DVD rental to subscription streaming\n\n**When to Pivot:**\n- Customer feedback indicates limited demand\n- Growth metrics plateau despite optimization\n- Team morale is consistently low\n- Vision doesn\'t align with market reality\n\n**How to Pivot Successfully:**\n- Use data, not just intuition\n- Preserve what\'s working\n- Communicate clearly with stakeholders\n- Move quickly once decision is made',
              'type': 'text'
            },
            {
              'title': 'Hypothesis-Driven Development',
              'content': '''Lean startups treat their business plans as a series of untested hypotheses that need validation.

**Business Model Hypotheses:**
- **Value Hypothesis**: Do customers find value in your solution?
- **Growth Hypothesis**: How will your business grow?
- **Channel Hypothesis**: How will you reach customers?
- **Revenue Hypothesis**: Will customers pay for your solution?

**Creating Good Hypotheses:**
1. **Be Specific**: "We believe that [customer segment] will [behavior] because [reason]"
2. **Make it Testable**: Define what success/failure looks like
3. **Prioritize by Risk**: Test the riskiest assumptions first
4. **Time-Bound**: Set deadlines for validation

**Hypothesis Testing Methods:**
- **Customer Interviews**: Qualitative insights
- **Surveys**: Quantitative validation
- **Landing Page Tests**: Measure interest
- **Prototype Testing**: Test usability and value
- **Pre-sales**: Ultimate validation

**Example Hypothesis:**
"We believe that busy working mothers aged 25-40 will pay \$20/month for meal planning service because they value time savings and healthy family meals. We will test this by creating a landing page and measuring conversion rates from Facebook ads."

**Validation Criteria:**
Define clear success metrics before testing. What would convince you the hypothesis is true or false?''',
              'type': 'text'
            },
            {
              'title': 'Lean Analytics & Growth',
              'content': '''Analytics in lean startups focus on learning and growth, not just reporting.

**Analytics Stages:**

**1. Empathy Stage**
- Understand the problem
- Metrics: Problem interviews, customer pain scores
- Goal: Prove there's a problem worth solving

**2. Stickiness Stage**
- Build engagement
- Metrics: DAU/MAU ratio, session length, feature usage
- Goal: Prove people want to use your product repeatedly

**3. Virality Stage**
- Achieve organic growth
- Metrics: Viral coefficient, referral rates, organic traffic
- Goal: Prove people recommend your product

**4. Revenue Stage**
- Monetize effectively
- Metrics: ARPU, LTV, conversion rates
- Goal: Prove people will pay for your product

**5. Scale Stage**
- Grow efficiently
- Metrics: Unit economics, CAC payback period
- Goal: Prove you can grow profitably

**Growth Engines:**
- **Sticky Engine**: Focus on customer retention
- **Viral Engine**: Customers bring other customers
- **Paid Engine**: Pay for customer acquisition

**Choose One Engine:** Focus on mastering one growth engine before moving to others.''',
              'type': 'text'
            },
            {
              'title': 'Quiz: Lean Startup Mastery',
              'content': 'Test your understanding of lean startup principles',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the core principle of the Lean Startup methodology?',
                  'options': [
                    'Build perfect products from the start',
                    'Validated learning through experimentation',
                    'Raise as much funding as possible',
                    'Focus only on technology development'
                  ],
                  'correct': 1,
                  'explanation': 'Lean Startup emphasizes validated learning - testing assumptions with real customers to reduce uncertainty and waste.'
                },
                {
                  'question': 'What does the Build-Measure-Learn loop help startups do?',
                  'options': [
                    'Create detailed business plans',
                    'Turn ideas into products and learn from customer feedback',
                    'Hire more employees',
                    'Increase marketing spend'
                  ],
                  'correct': 1,
                  'explanation': 'The Build-Measure-Learn loop creates feedback cycles to test ideas, measure results, and learn what works.'
                },
                {
                  'question': 'Which of these is a vanity metric?',
                  'options': [
                    'Customer Acquisition Cost',
                    'Monthly Recurring Revenue',
                    'Total number of app downloads',
                    'Customer retention rate'
                  ],
                  'correct': 2,
                  'explanation': 'Total downloads is a vanity metric because it doesn\'t indicate customer engagement or business value.'
                },
                {
                  'question': 'When should a startup consider pivoting?',
                  'options': [
                    'After the first week of operations',
                    'When customer feedback indicates limited demand despite optimization efforts',
                    'When competitors enter the market',
                    'Never, persistence is always key'
                  ],
                  'correct': 1,
                  'explanation': 'Pivoting should be considered when data shows the current approach isn\'t working despite genuine efforts to optimize.'
                },
                {
                  'question': 'What makes a good hypothesis in lean startup?',
                  'options': [
                    'It should be vague and general',
                    'It should be specific, testable, and time-bound',
                    'It should focus only on technology features',
                    'It should avoid customer input'
                  ],
                  'correct': 1,
                  'explanation': 'Good hypotheses are specific, testable, and time-bound so you can validate or invalidate them with real data.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['novice_1'],
        'badge': 'lean_practitioner'
      },
      {
        'id': 'novice_5',
        'title': 'MVP Development & Testing',
        'description':
            'Master the art of building and testing Minimum Viable Products to validate your ideas',
        'duration': 35,
        'category': 'product_development',
        'difficulty': 'novice',
        'content': {
          'sections': [
            {
              'title': 'Understanding MVP Fundamentals',
              'content':
                  'A Minimum Viable Product (MVP) is the simplest version of your product that provides value to customers and generates validated learning about your business assumptions.\n\n**What MVP is NOT:**\n- A beta version with fewer features\n- A low-quality or broken product\n- The first version of your final product\n- An excuse to ship incomplete work\n\n**What MVP IS:**\n- The fastest way to test core assumptions\n- A learning vehicle for customer discovery\n- The foundation for iterative improvement\n- A risk reduction strategy\n\n**MVP Characteristics:**\n- **Minimum**: Has only essential features\n- **Viable**: Delivers real value to users\n- **Product**: Users can actually use it\n\n**MVP Goals:**\n1. **Test Core Value Proposition**: Do customers find value?\n2. **Validate Customer Segments**: Are you targeting the right people?\n3. **Confirm Problem-Solution Fit**: Does your solution address real problems?\n4. **Learn About User Behavior**: How do customers actually use your product?\n5. **Generate Revenue Signals**: Will customers pay?\n\n**Remember**: Your MVP should be embarrassing enough that you\'re worried about showing it, but valuable enough that customers use it.',
              'type': 'text'
            },
            {
              'title': 'Types of MVPs',
              'content':
                  'Different types of MVPs serve different validation purposes. Choose based on what you need to learn.\n\n**1. Landing Page MVP**\n- Single page describing your product\n- Measures interest through sign-ups or pre-orders\n- Best for: Testing demand before building\n- Example: Dropbox\'s demo video\n\n**2. Wizard of Oz MVP**\n- Appears automated but is manually operated\n- Tests user experience without full automation\n- Best for: Complex backend processes\n- Example: Zappos started by buying shoes from stores\n\n**3. Concierge MVP**\n- Manually deliver your service to a few customers\n- Learn by doing the work yourself\n- Best for: Service businesses\n- Example: Delivering meal plans personally\n\n**4. Prototype MVP**\n- Functional but limited version\n- Focuses on core user journey\n- Best for: Testing usability and core features\n- Example: First iPhone had limited apps\n\n**5. Pre-order MVP**\n- Sell before you build\n- Ultimate validation of demand\n- Best for: Physical products\n- Example: Pebble smartwatch Kickstarter\n\n**6. Feature MVP**\n- Single feature that solves one problem\n- Focus on doing one thing extremely well\n- Best for: Platform or complex products\n- Example: Twitter\'s 140-character messages\n\n**Choosing the Right MVP:**\nConsider your resources, timeline, and what you need to learn most urgently.',
              'type': 'text'
            },
            {
              'title': 'MVP Planning & Prioritization',
              'content':
                  'Building the right MVP requires careful planning and ruthless prioritization.\n\n**Step 1: Define Your Riskiest Assumptions**\n- Will customers use this?\n- Will they pay for it?\n- Can we build it?\n- Can we reach customers?\n- Is the market big enough?\n\n**Step 2: User Story Mapping**\n- Map the complete user journey\n- Identify core activities\n- Break down into specific tasks\n- Prioritize by importance and risk\n\n**Step 3: Feature Prioritization Framework**\n\n**MoSCoW Method:**\n- **Must Have**: Core functionality\n- **Should Have**: Important but not critical\n- **Could Have**: Nice to have features\n- **Won\'t Have**: Future considerations\n\n**RICE Scoring:**\n- **Reach**: How many users affected?\n- **Impact**: How much will it improve their experience?\n- **Confidence**: How sure are you about reach/impact?\n- **Effort**: How much work is required?\n\nScore = (Reach × Impact × Confidence) / Effort\n\n**Step 4: MVP Feature Set**\n- Include only "Must Have" features\n- Focus on one primary user flow\n- Remove everything that doesn\'t support core value proposition\n- Plan for measurement and learning\n\n**Step 5: Success Metrics**\n- Define what success looks like\n- Choose 2-3 key metrics\n- Set realistic targets\n- Plan how you\'ll collect data',
              'type': 'text'
            },
            {
              'title': 'Building Your MVP',
              'content':
                  'Building an MVP requires different approaches depending on your product type and constraints.\n\n**No-Code/Low-Code MVPs:**\n- **Websites**: WordPress, Webflow, Squarespace\n- **Apps**: Bubble, Adalo, Glide\n- **E-commerce**: Shopify, WooCommerce\n- **Automation**: Zapier, IFTTT\n- **Forms/Surveys**: Typeform, Google Forms\n\n**Technical MVPs:**\n- Focus on core functionality first\n- Use existing frameworks and libraries\n- Prioritize speed over perfection\n- Make it work, then make it beautiful\n- Plan for scalability but don\'t over-engineer\n\n**Service MVPs:**\n- Start with manual processes\n- Use existing tools and platforms\n- Focus on customer experience\n- Document everything for future automation\n\n**MVP Development Principles:**\n\n**1. Start Simple**\n- Solve one problem really well\n- Avoid feature creep\n- Focus on core user journey\n\n**2. Fail Fast**\n- Build quickly and test early\n- Don\'t be precious about your first version\n- Embrace feedback and iteration\n\n**3. Measure Everything**\n- Build analytics from day one\n- Track user behavior, not just opinions\n- Set up feedback collection systems\n\n**4. Stay Flexible**\n- Build for learning, not perfection\n- Keep architecture simple for easy changes\n- Prepare to pivot based on learning',
              'type': 'text'
            },
            {
              'title': 'Testing & Validation Strategies',
              'content':
                  'Testing your MVP effectively is crucial for learning and iteration.\n\n**Pre-Launch Testing:**\n\n**1. Internal Testing**\n- Team members use the product\n- Identify obvious bugs and usability issues\n- Ensure core functionality works\n\n**2. Friends & Family Testing**\n- Get feedback from trusted circle\n- Focus on honest, constructive criticism\n- Test with people who represent your target market\n\n**3. Beta Testing**\n- Recruit 10-50 early adopters\n- Provide incentives for participation\n- Focus on power users who give detailed feedback\n\n**Launch Testing:**\n\n**1. Soft Launch**\n- Limited geographic or demographic rollout\n- Monitor performance and gather feedback\n- Fix issues before full launch\n\n**2. A/B Testing**\n- Test different versions simultaneously\n- Compare conversion rates and user behavior\n- Make data-driven decisions\n\n**Post-Launch Validation:**\n\n**1. User Analytics**\n- Track user flows and drop-off points\n- Identify most/least used features\n- Monitor engagement metrics\n\n**2. Customer Interviews**\n- Conduct regular user interviews\n- Ask about problems, not just opinions\n- Understand the "why" behind user behavior\n\n**3. Feedback Collection**\n- In-app feedback tools\n- Customer support interactions\n- Social media monitoring\n- Review site analysis\n\n**Validation Questions:**\n- Are users engaging with your core features?\n- Do users return after first use?\n- Are users recommending your product?\n- Are users willing to pay?\n- What\'s the biggest complaint/request?',
              'type': 'text'
            },
            {
              'title': 'Iteration & Growth Planning',
              'content':
                  'Your MVP is just the beginning. Success comes from continuous iteration and improvement.\n\n**Iteration Framework:**\n\n**1. Analyze Results**\n- Review quantitative data (analytics, metrics)\n- Synthesize qualitative feedback (interviews, support)\n- Identify patterns and trends\n- Prioritize insights by impact and confidence\n\n**2. Generate Hypotheses**\n- What changes might improve key metrics?\n- What new features would provide value?\n- What obstacles prevent user success?\n- How can you better serve your target market?\n\n**3. Plan Experiments**\n- Design tests for your top hypotheses\n- Define success criteria\n- Estimate effort and timeline\n- Consider risks and mitigation strategies\n\n**4. Execute and Measure**\n- Implement changes systematically\n- Monitor impact on key metrics\n- Collect user feedback\n- Document learnings\n\n**Growth Planning:**\n\n**Phase 1: Problem-Solution Fit**\n- Validate core problem\n- Confirm your solution addresses the problem\n- Refine target customer segment\n\n**Phase 2: Product-Market Fit**\n- Achieve strong user engagement\n- Generate positive word-of-mouth\n- Establish repeatable growth model\n\n**Phase 3: Scale Preparation**\n- Optimize unit economics\n- Build scalable systems\n- Prepare for increased demand\n\n**Signs You\'re Ready to Scale:**\n- Consistent user growth\n- Strong retention rates\n- Positive unit economics\n- Repeatable customer acquisition\n- Team and systems can handle growth\n\n**Remember:** Most successful products look very different from their first MVP. Embrace change as a sign of learning and progress.',
              'type': 'text'
            },
            {
              'title': 'Quiz: MVP Development Mastery',
              'content': 'Test your understanding of MVP development and testing',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the primary purpose of an MVP?',
                  'options': [
                    'To create a perfect product from the start',
                    'To test core assumptions and generate validated learning',
                    'To compete directly with established competitors',
                    'To impress investors with advanced features'
                  ],
                  'correct': 1,
                  'explanation': 'An MVP is designed to test your riskiest assumptions and learn from real customers with minimal investment.'
                },
                {
                  'question': 'Which MVP type involves manually delivering services that appear automated?',
                  'options': [
                    'Landing Page MVP',
                    'Prototype MVP',
                    'Wizard of Oz MVP',
                    'Feature MVP'
                  ],
                  'correct': 2,
                  'explanation': 'Wizard of Oz MVP appears automated to users but is actually operated manually behind the scenes.'
                },
                {
                  'question': 'In the MoSCoW prioritization method, what does the "M" stand for?',
                  'options': [
                    'Maybe Have',
                    'Must Have',
                    'Might Have',
                    'More Features'
                  ],
                  'correct': 1,
                  'explanation': 'Must Have features are absolutely essential for your MVP to deliver core value.'
                },
                {
                  'question': 'What should you focus on when building your first MVP?',
                  'options': [
                    'Including as many features as possible',
                    'Making it perfect before launch',
                    'Solving one problem really well',
                    'Competing on price alone'
                  ],
                  'correct': 2,
                  'explanation': 'Focus on solving one core problem exceptionally well rather than trying to do everything.'
                },
                {
                  'question': 'What indicates you might be ready to scale beyond your MVP?',
                  'options': [
                    'You have raised funding',
                    'Consistent user growth and strong retention rates',
                    'You have hired more employees',
                    'Competitors have entered the market'
                  ],
                  'correct': 1,
                  'explanation': 'Consistent growth and retention show you have achieved product-market fit and can scale sustainably.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['novice_1', 'novice_4'],
        'badge': 'mvp_master'
      }
    ],
    'intermediate': [
      {
        'id': 'intermediate_1',
        'title': 'Advanced Financial Modeling',
        'description': 'Master financial modeling, forecasting, and startup valuation techniques',
        'duration': 45,
        'category': 'financial_management',
        'difficulty': 'intermediate',
        'content': {
          'sections': [
            {
              'title': 'Financial Modeling Fundamentals',
              'content': '''Financial modeling is the process of creating a mathematical representation of your business's financial performance. For startups, this involves projecting future revenues, costs, and cash flows based on assumptions about market dynamics and business operations.

**Why Financial Models Matter:**
- **Investor Communication**: Demonstrate your understanding of the business
- **Strategic Planning**: Make data-driven decisions about resource allocation
- **Risk Management**: Identify potential financial challenges early
- **Fundraising**: Support valuation and funding requirements
- **Performance Tracking**: Compare actual results to projections

**Key Components of Startup Financial Models:**

**1. Revenue Model**
- Unit economics and pricing strategy
- Customer acquisition and retention rates
- Market size and penetration assumptions
- Seasonal and cyclical patterns

**2. Cost Structure**
- Fixed costs (rent, salaries, software)
- Variable costs (materials, commissions, shipping)
- Semi-variable costs (utilities, phone bills)
- One-time costs (equipment, legal fees)

**3. Working Capital**
- Accounts receivable and payment terms
- Inventory requirements and turnover
- Accounts payable and supplier terms
- Cash conversion cycle

**4. Capital Requirements**
- Initial investment needs
- Growth capital requirements
- Equipment and infrastructure costs
- Technology and development expenses

**Model Types:**
- **Bottom-Up**: Start with unit economics and scale up
- **Top-Down**: Start with market size and work down
- **Hybrid**: Combine both approaches for validation''',
              'type': 'text'
            },
            {
              'title': 'Building Revenue Projections',
              'content': '''Accurate revenue projections are the foundation of your financial model. They require deep understanding of your business model and market dynamics.

**Revenue Forecasting Methods:**

**1. Unit Economics Approach**
- Calculate revenue per customer/transaction
- Project customer acquisition rates
- Factor in customer lifetime value
- Account for churn and expansion revenue

**2. Market-Based Approach**
- Estimate total addressable market (TAM)
- Determine serviceable addressable market (SAM)
- Project market share capture over time
- Validate with bottom-up calculations

**3. Cohort Analysis**
- Track customer behavior by acquisition period
- Analyze retention and expansion patterns
- Project future cohort performance
- Build cumulative revenue projections

**Revenue Drivers to Model:**

**SaaS/Subscription Businesses:**
- Monthly Recurring Revenue (MRR)
- Annual Recurring Revenue (ARR)
- Customer Acquisition Rate
- Churn Rate (monthly/annual)
- Average Revenue Per User (ARPU)
- Expansion Revenue Rate

**E-commerce/Marketplace:**
- Gross Merchandise Value (GMV)
- Take Rate/Commission Percentage
- Order Frequency
- Average Order Value
- Customer Lifetime Value

**Professional Services:**
- Billable Hours/Utilization Rate
- Hourly/Daily Rates
- Project-Based Revenue
- Retainer Agreements

**Best Practices:**
- Use conservative assumptions
- Build multiple scenarios (optimistic, realistic, pessimistic)
- Validate assumptions with market data
- Update projections regularly based on actual performance''',
              'type': 'text'
            },
            {
              'title': 'Cost Structure & Expense Planning',
              'content': '''Understanding and projecting costs accurately is crucial for financial planning and pricing decisions.

**Cost Categories:**

**1. Cost of Goods Sold (COGS)**
- Direct materials and labor
- Manufacturing and production costs
- Third-party services directly tied to revenue
- Payment processing fees

**2. Operating Expenses (OpEx)**
- Salaries and benefits
- Rent and utilities
- Marketing and sales expenses
- General and administrative costs

**3. Capital Expenditures (CapEx)**
- Equipment and machinery
- Technology infrastructure
- Leasehold improvements
- Intangible assets (patents, software licenses)

**Expense Forecasting Strategies:**

**Fixed Costs:**
- Rent, insurance, base salaries
- Software subscriptions
- Professional services (legal, accounting)
- Loan payments and interest

**Variable Costs:**
- Commission-based compensation
- Usage-based services (AWS, shipping)
- Materials tied to production volume
- Performance marketing spend

**Step Costs:**
- Additional office space
- New employee hirings
- Equipment purchases for growth
- System upgrades and scalability

**Cost Management Principles:**
- **Lean Operations**: Minimize non-essential expenses
- **Scalable Infrastructure**: Use variable cost structures when possible
- **Benchmarking**: Compare costs to industry standards
- **Unit Economics**: Understand cost per customer/transaction
- **Break-Even Analysis**: Know when you'll become profitable

**Financial Ratios to Track:**
- Gross Margin: (Revenue - COGS) / Revenue
- Operating Margin: Operating Income / Revenue
- Burn Rate: Monthly cash consumption
- Runway: Cash available / Monthly burn rate''',
              'type': 'text'
            },
            {
              'title': 'Cash Flow Management',
              'content': '''Cash flow is the lifeblood of any startup. Even profitable companies can fail due to poor cash flow management.

**Three Types of Cash Flow:**

**1. Operating Cash Flow**
- Cash from core business operations
- Revenue collection minus operating expenses
- Working capital changes
- Non-cash expenses (depreciation, stock compensation)

**2. Investing Cash Flow**
- Capital expenditures
- Asset purchases and sales
- Investments in other companies
- Technology and equipment purchases

**3. Financing Cash Flow**
- Equity investments and fundraising
- Debt issuance and repayment
- Dividend payments
- Share repurchases

**Cash Flow Forecasting:**

**Weekly Cash Flow (Early Stage):**
- Track actual cash receipts and payments
- Monitor accounts receivable collection
- Plan for seasonal variations
- Maintain minimum cash reserves

**Monthly Cash Flow (Growth Stage):**
- Project revenue collection timing
- Plan major expense categories
- Schedule capital expenditures
- Plan for fundraising needs

**Cash Flow Management Strategies:**

**Improve Collection:**
- Offer early payment discounts
- Implement automatic payment systems
- Follow up on overdue accounts
- Require deposits for large orders

**Optimize Payments:**
- Negotiate extended payment terms with suppliers
- Use credit cards for 30-day float
- Time discretionary expenses strategically
- Implement approval processes for large expenses

**Working Capital Optimization:**
- Minimize inventory levels
- Negotiate consignment arrangements
- Use just-in-time delivery
- Implement efficient invoicing processes

**Cash Flow Ratios:**
- Operating Cash Flow Ratio: Operating Cash Flow / Current Liabilities
- Cash Flow Coverage Ratio: Operating Cash Flow / Total Debt Service
- Cash Conversion Cycle: Days Sales Outstanding + Days Inventory Outstanding - Days Payable Outstanding''',
              'type': 'text'
            },
            {
              'title': 'Startup Valuation Methods',
              'content': '''Valuation is both an art and a science, especially for early-stage startups with limited financial history.

**Pre-Revenue Valuation Methods:**

**1. Berkus Method**
- Assigns value to qualitative factors
- Sound idea: \$0-\$500K
- Prototype: \$0-\$500K
- Quality management team: \$0-\$500K
- Strategic relationships: \$0-\$500K
- Product rollout or sales: \$0-\$500K
- Maximum pre-money valuation: \$2.5M

**2. Scorecard Valuation Method**
- Compare to funded companies in region/sector
- Adjust for factors: management (0-30%), size of opportunity (0-25%), product/technology (0-15%), competitive environment (0-10%), marketing/sales channels (0-10%), need for additional investment (0-5%), other factors (0-5%)

**3. Risk Factor Summation Method**
- Start with average pre-money valuation in region/sector
- Adjust for 12 risk factors (+\$250K to -\$500K each)
- Management, stage of business, legislation/political risk, manufacturing risk, sales and marketing risk, funding/capital raising risk, competition risk, technology risk, litigation risk, international risk, reputation risk, potential lucrative exit

**Revenue-Stage Valuation Methods:**

**4. Discounted Cash Flow (DCF)**
- Project future cash flows (5-10 years)
- Determine terminal value
- Discount to present value using appropriate rate
- Best for stable, predictable businesses

**5. Comparable Company Analysis (Comps)**
- Find similar public companies
- Calculate valuation multiples (P/E, EV/Revenue, EV/EBITDA)
- Apply multiples to your financial metrics
- Adjust for size, growth, and risk differences

**6. Precedent Transaction Analysis**
- Analyze recent M&A transactions in your sector
- Calculate transaction multiples
- Apply to your metrics
- Consider control premiums and synergies

**Growth-Stage Valuation Methods:**

**7. Revenue Multiple Method**
- Industry-specific revenue multiples
- SaaS: 5-15x ARR
- E-commerce: 2-6x revenue
- Marketplace: 10-20x revenue
- Adjust for growth rate, margins, and market position

**Valuation Considerations:**
- Stage of development
- Market size and opportunity
- Competitive advantages
- Management team quality
- Financial performance and projections
- Market conditions and investor appetite''',
              'type': 'text'
            },
            {
              'title': 'Financial Planning & Analysis',
              'content': '''Financial Planning & Analysis (FP&A) involves ongoing monitoring, analysis, and strategic planning based on financial data.

**Key FP&A Activities:**

**1. Budgeting and Forecasting**
- Annual budget creation
- Quarterly forecast updates
- Rolling forecasts (12-18 months)
- Scenario planning and sensitivity analysis

**2. Performance Analysis**
- Actual vs. budget variance analysis
- Key Performance Indicator (KPI) tracking
- Cohort analysis and unit economics
- Benchmarking against industry standards

**3. Strategic Planning**
- Long-term financial planning (3-5 years)
- Capital allocation decisions
- Investment prioritization
- Growth strategy evaluation

**Financial Dashboards and KPIs:**

**Revenue Metrics:**
- Monthly Recurring Revenue (MRR) growth
- Customer Acquisition Cost (CAC)
- Customer Lifetime Value (LTV)
- LTV/CAC ratio
- Churn rate and retention

**Profitability Metrics:**
- Gross margin trends
- Contribution margin by product/customer
- EBITDA and operating margin
- Unit economics and payback periods

**Cash and Liquidity Metrics:**
- Cash burn rate
- Monthly runway remaining
- Working capital requirements
- Cash conversion cycle

**Efficiency Metrics:**
- Revenue per employee
- Sales efficiency (magic number for SaaS)
- Marketing ROI and payback periods
- Operational leverage ratios

**Financial Planning Tools:**
- Spreadsheet-based models (Excel/Google Sheets)
- Financial planning software (Planful, Adaptive Insights)
- Business intelligence tools (Tableau, Power BI)
- ERP and accounting integration

**Best Practices:**
- Update forecasts monthly
- Use rolling forecasts for agility
- Focus on leading indicators
- Automate data collection where possible
- Communicate insights clearly to stakeholders
- Align financial plans with business strategy''',
              'type': 'text'
            },
            {
              'title': 'Quiz: Financial Modeling Mastery',
              'content': 'Test your understanding of advanced financial modeling concepts',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the primary purpose of financial modeling for startups?',
                  'options': [
                    'To impress investors with complex calculations',
                    'To create mathematical representations for strategic planning and decision-making',
                    'To comply with accounting regulations',
                    'To determine exact future profits'
                  ],
                  'correct': 1,
                  'explanation': 'Financial models help startups make data-driven decisions, communicate with investors, and plan strategically based on projected performance.'
                },
                {
                  'question': 'Which valuation method is most appropriate for pre-revenue startups?',
                  'options': [
                    'Discounted Cash Flow (DCF)',
                    'Revenue Multiple Method',
                    'Berkus Method or Scorecard Valuation',
                    'Comparable Company Analysis'
                  ],
                  'correct': 2,
                  'explanation': 'Pre-revenue startups lack financial history, so qualitative methods like Berkus or Scorecard that evaluate factors like team quality and market opportunity are most appropriate.'
                },
                {
                  'question': 'What does the Cash Conversion Cycle measure?',
                  'options': [
                    'How quickly cash flows through working capital',
                    'Monthly burn rate',
                    'Customer acquisition cost',
                    'Revenue growth rate'
                  ],
                  'correct': 0,
                  'explanation': 'Cash Conversion Cycle measures how long it takes to convert investments in inventory and receivables back into cash, indicating working capital efficiency.'
                },
                {
                  'question': 'For SaaS businesses, what is typically the most important revenue metric to track?',
                  'options': [
                    'Total revenue',
                    'Monthly Recurring Revenue (MRR)',
                    'One-time sales',
                    'Gross merchandise value'
                  ],
                  'correct': 1,
                  'explanation': 'MRR is crucial for SaaS businesses as it represents predictable, recurring income and helps track subscription business health and growth trends.'
                },
                {
                  'question': 'What is the LTV/CAC ratio and why is it important?',
                  'options': [
                    'Revenue divided by costs, shows profitability',
                    'Customer Lifetime Value divided by Customer Acquisition Cost, indicates unit economics health',
                    'Lead conversion rate, shows sales efficiency',
                    'Monthly growth rate, shows scalability'
                  ],
                  'correct': 1,
                  'explanation': 'LTV/CAC ratio compares the value of a customer over their lifetime to the cost of acquiring them. A ratio above 3:1 generally indicates healthy unit economics.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['novice_1', 'novice_2', 'novice_3'],
        'badge': 'financial_expert'
      },
      {
        'id': 'intermediate_2',
        'title': 'Digital Marketing & Growth Hacking',
        'description': 'Master modern digital marketing strategies and growth hacking techniques',
        'duration': 50,
        'category': 'marketing',
        'difficulty': 'intermediate',
        'content': {
          'sections': [
            {
              'title': 'Digital Marketing Fundamentals',
              'content': '''Digital marketing encompasses all marketing efforts that use digital channels to reach and engage customers. For startups, it offers cost-effective ways to build brand awareness, generate leads, and drive sales.

**Digital Marketing vs Traditional Marketing:**
- **Measurable**: Track every click, view, and conversion
- **Targeted**: Reach specific audiences with precision
- **Interactive**: Two-way communication with customers
- **Cost-Effective**: Lower barriers to entry than traditional media
- **Agile**: Quickly adjust campaigns based on performance

**Core Digital Marketing Channels:**

**1. Search Engine Optimization (SEO)**
- Organic visibility in search results
- Long-term, sustainable traffic growth
- Builds authority and credibility
- High-intent traffic from people actively searching

**2. Search Engine Marketing (SEM/PPC)**
- Paid search advertising (Google Ads, Bing Ads)
- Immediate visibility and traffic
- Highly targeted and measurable
- Control over budget and bidding

**3. Social Media Marketing**
- Organic social media presence
- Paid social advertising
- Community building and engagement
- Brand awareness and customer service

**4. Content Marketing**
- Blog posts, videos, podcasts, infographics
- Educational and valuable content
- SEO benefits and thought leadership
- Lead generation and nurturing

**5. Email Marketing**
- Direct communication with subscribers
- High ROI potential
- Automation and personalization
- Customer retention and loyalty

**6. Influencer Marketing**
- Partnerships with industry influencers
- Authentic endorsements and reviews
- Access to established audiences
- Social proof and credibility

**Digital Marketing Funnel:**
- **Awareness**: Attract potential customers
- **Interest**: Engage and educate prospects
- **Consideration**: Nurture leads with valuable content
- **Conversion**: Turn prospects into customers
- **Retention**: Keep customers engaged and loyal
- **Advocacy**: Turn customers into brand ambassadors''',
              'type': 'text'
            },
            {
              'title': 'Growth Hacking Methodology',
              'content': '''Growth hacking is a data-driven approach to rapid growth that combines marketing, product development, and analytics to find scalable ways to grow a business.

**Growth Hacking Principles:**

**1. Product-Market Fit First**
- Growth hacking only works with a product people want
- Focus on retention and engagement before acquisition
- Measure product-market fit through user behavior

**2. Data-Driven Decision Making**
- Use analytics to guide every decision
- Test hypotheses with experiments
- Focus on actionable metrics, not vanity metrics

**3. Rapid Experimentation**
- Run multiple small experiments quickly
- Fail fast and learn faster
- Scale what works, kill what doesn't

**4. Cross-Functional Approach**
- Combine marketing, product, and engineering
- Growth team with diverse skills
- Break down traditional department silos

**The AARRR Framework (Pirate Metrics):**

**1. Acquisition**
- How do users find you?
- Channels: SEO, SEM, social, referrals, PR
- Metrics: Traffic, cost per acquisition, conversion rates

**2. Activation**
- Do users have a great first experience?
- Onboarding optimization
- Metrics: Sign-up completion, first action taken, time to value

**3. Retention**
- Do users come back and use your product?
- Product stickiness and engagement
- Metrics: DAU/MAU, cohort retention, churn rate

**4. Revenue**
- Do users pay for your product?
- Monetization and pricing optimization
- Metrics: ARPU, LTV, conversion to paid

**5. Referral**
- Do users refer others to your product?
- Viral loops and word-of-mouth
- Metrics: Viral coefficient, referral rate, NPS

**Growth Hacking Tactics:**

**Viral Loops:**
- Built-in sharing mechanisms
- Incentivized referrals
- Social proof and network effects

**Content Marketing:**
- SEO-optimized blog content
- Viral content and storytelling
- Guest posting and PR

**Product-Led Growth:**
- Freemium models
- Free trials and demos
- In-product upgrade prompts

**Partnership Marketing:**
- Integration partnerships
- Co-marketing campaigns
- Affiliate programs''',
              'type': 'text'
            },
            {
              'title': 'Customer Acquisition Strategies',
              'content': '''Effective customer acquisition requires understanding your target audience and choosing the right channels to reach them cost-effectively.

**Customer Acquisition Channel Analysis:**

**Paid Channels:**
- Search Engine Marketing (Google Ads, Bing)
- Social Media Advertising (Facebook, LinkedIn, Twitter)
- Display Advertising and Retargeting
- Influencer Partnerships and Sponsorships

**Organic Channels:**
- Search Engine Optimization (SEO)
- Content Marketing and Blogging
- Social Media Organic Reach
- Public Relations and Media Coverage

**Direct Channels:**
- Sales Outreach and Cold Calling
- Email Marketing to Owned Lists
- Referral Programs
- Events and Networking

**Channel Selection Criteria:**

**1. Target Audience Fit**
- Where does your audience spend time?
- What channels do they trust?
- How do they prefer to discover new products?

**2. Cost Effectiveness**
- Customer Acquisition Cost (CAC)
- Lifetime Value to CAC ratio (LTV:CAC)
- Payback period for acquisition spend

**3. Scalability**
- Can the channel grow with your business?
- What are the limits of the channel?
- How competitive is the channel?

**4. Control and Ownership**
- Do you own the relationship with customers?
- Are you dependent on third-party platforms?
- Can you build sustainable competitive advantages?

**Customer Acquisition Optimization:**

**A/B Testing:**
- Test different ad creatives and copy
- Experiment with landing page designs
- Optimize conversion funnels
- Test pricing and offers

**Conversion Rate Optimization (CRO):**
- Improve website user experience
- Optimize forms and checkout processes
- Reduce friction in the buying journey
- Use social proof and testimonials

**Attribution Modeling:**
- Understand multi-touch customer journeys
- Assign credit to different touchpoints
- Optimize budget allocation across channels
- Measure true impact of each channel

**Customer Acquisition Metrics:**
- Customer Acquisition Cost (CAC) by channel
- Conversion rates at each funnel stage
- Time to conversion and sales cycle length
- Quality scores and customer fit metrics''',
              'type': 'text'
            },
            {
              'title': 'Retention & Engagement Strategies',
              'content': '''Customer retention is often more cost-effective than acquisition and drives long-term business value through increased lifetime value and referrals.

**Understanding Customer Lifecycle:**

**1. Onboarding Phase**
- First impression and setup experience
- Time to first value realization
- Initial engagement and feature adoption
- Support and guidance during setup

**2. Adoption Phase**
- Feature discovery and usage patterns
- Habit formation and routine integration
- Value realization and success metrics
- Expansion to additional features

**3. Expansion Phase**
- Increased usage and engagement
- Upgrade to higher plans or features
- Additional product purchases
- Integration with other systems

**4. Advocacy Phase**
- High satisfaction and loyalty
- Referrals and word-of-mouth marketing
- Case studies and testimonials
- Community participation and leadership

**Retention Strategies:**

**Product Experience:**
- Intuitive user interface and design
- Regular feature updates and improvements
- Performance optimization and reliability
- Mobile and cross-platform accessibility

**Customer Success:**
- Proactive customer support
- Educational content and resources
- Regular check-ins and health scoring
- Success metrics tracking and reporting

**Engagement Programs:**
- Email marketing and newsletters
- In-app notifications and prompts
- Webinars and educational events
- User communities and forums

**Personalization:**
- Customized product experiences
- Personalized content recommendations
- Targeted messaging and offers
- Behavioral trigger campaigns

**Churn Prevention:**

**Early Warning Signs:**
- Decreased usage patterns
- Feature abandonment
- Support ticket patterns
- Billing and payment issues

**Intervention Strategies:**
- Proactive outreach to at-risk customers
- Win-back campaigns and offers
- Product education and training
- Alternative solutions and workarounds

**Retention Metrics:**
- Customer Churn Rate (monthly/annual)
- Revenue Churn Rate
- Cohort Retention Analysis
- Net Promoter Score (NPS)
- Customer Satisfaction (CSAT)
- Customer Effort Score (CES)''',
              'type': 'text'
            },
            {
              'title': 'Analytics & Performance Measurement',
              'content': '''Effective measurement and analytics are crucial for optimizing digital marketing performance and making data-driven growth decisions.

**Marketing Analytics Stack:**

**1. Web Analytics**
- Google Analytics 4 (GA4)
- Adobe Analytics
- Mixpanel for product analytics
- Hotjar for user behavior analysis

**2. Attribution and Tracking**
- Google Tag Manager for tag deployment
- Facebook Pixel for social media tracking
- UTM parameters for campaign tracking
- Cross-device and cross-platform tracking

**3. Marketing Automation**
- HubSpot, Marketo, or Pardot
- Email marketing platforms (Mailchimp, SendGrid)
- CRM integration and lead scoring
- Behavioral trigger automation

**4. Business Intelligence**
- Data warehousing (Snowflake, BigQuery)
- Visualization tools (Tableau, Looker)
- Custom dashboards and reporting
- Predictive analytics and forecasting

**Key Performance Indicators (KPIs):**

**Acquisition Metrics:**
- Traffic volume and sources
- Cost Per Click (CPC) and Cost Per Acquisition (CPA)
- Conversion rates by channel
- Lead quality and scoring

**Engagement Metrics:**
- Time on site and pages per session
- Email open and click-through rates
- Social media engagement rates
- Content consumption patterns

**Conversion Metrics:**
- Landing page conversion rates
- Sales conversion rates and velocity
- Average order value and frequency
- Lifetime value progression

**Retention Metrics:**
- Repeat purchase rates
- Product usage and feature adoption
- Customer satisfaction scores
- Churn and retention cohort analysis

**Analytics Best Practices:**

**Data Quality:**
- Implement proper tracking setup
- Regular data validation and auditing
- Clean and consistent data collection
- Privacy compliance (GDPR, CCPA)

**Actionable Insights:**
- Focus on metrics that drive decisions
- Segment data for deeper insights
- Trend analysis and pattern recognition
- Predictive modeling for future planning

**Reporting and Communication:**
- Executive dashboards for high-level metrics
- Operational reports for day-to-day management
- Campaign-specific performance reports
- Regular review cycles and optimization planning''',
              'type': 'text'
            },
            {
              'title': 'Quiz: Digital Marketing & Growth Hacking',
              'content': 'Test your knowledge of digital marketing and growth hacking strategies',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What does the AARRR framework in growth hacking represent?',
                  'options': [
                    'Acquisition, Activation, Retention, Revenue, Referral',
                    'Advertising, Analytics, Results, ROI, Reach',
                    'Awareness, Attention, Response, Relationship, Reward',
                    'Audience, Acquisition, Revenue, Retention, Reviews'
                  ],
                  'correct': 0,
                  'explanation': 'AARRR (Pirate Metrics) stands for Acquisition, Activation, Retention, Revenue, and Referral - the key stages of the customer journey that growth hackers optimize.'
                },
                {
                  'question': 'Which is the most important prerequisite for successful growth hacking?',
                  'options': [
                    'Large marketing budget',
                    'Product-market fit',
                    'Viral social media presence',
                    'Celebrity endorsements'
                  ],
                  'correct': 1,
                  'explanation': 'Product-market fit is essential before growth hacking. You need a product people actually want before you can effectively scale acquisition and retention.'
                },
                {
                  'question': 'What is Customer Acquisition Cost (CAC)?',
                  'options': [
                    'The total revenue from a customer',
                    'The cost to serve an existing customer',
                    'The cost to acquire one new customer',
                    'The lifetime value of a customer'
                  ],
                  'correct': 2,
                  'explanation': 'CAC measures how much it costs to acquire one new customer, including all marketing and sales expenses divided by the number of customers acquired.'
                },
                {
                  'question': 'Which metric is most important for measuring customer retention?',
                  'options': [
                    'Total number of customers',
                    'Churn rate and cohort retention analysis',
                    'Customer acquisition rate',
                    'Social media followers'
                  ],
                  'correct': 1,
                  'explanation': 'Churn rate and cohort retention analysis show how well you\'re keeping customers over time, which is crucial for sustainable growth and profitability.'
                },
                {
                  'question': 'What characterizes a good LTV:CAC ratio?',
                  'options': [
                    '1:1 ratio',
                    '2:1 ratio',
                    '3:1 or higher ratio',
                    '10:1 ratio'
                  ],
                  'correct': 2,
                  'explanation': 'A 3:1 LTV:CAC ratio is generally considered healthy, meaning customers generate at least 3x more value than it costs to acquire them.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['novice_2', 'novice_4', 'novice_5'],
        'badge': 'growth_hacker'
      }
    ],
    'advanced': [
      {
        'id': 'advanced_1',
        'title': 'Scaling Operations & Team Building',
        'description': 'Master the art of scaling your startup operations and building high-performing teams',
        'duration': 60,
        'category': 'operations',
        'difficulty': 'advanced',
        'content': {
          'sections': [
            {
              'title': 'Scaling Fundamentals',
              'content': '''Scaling a startup requires transitioning from a scrappy, do-everything approach to building systematic, repeatable processes that can handle exponential growth.

**The Scaling Challenge:**
Most startups fail not because they can't get customers, but because they can't scale their operations to serve those customers effectively. Scaling requires:
- **Process Standardization**: Moving from ad-hoc to systematic approaches
- **Team Expansion**: Hiring and developing the right people
- **Technology Infrastructure**: Systems that can handle increased load
- **Cultural Preservation**: Maintaining startup culture while growing
- **Financial Management**: Managing cash flow during rapid expansion

**Signs You're Ready to Scale:**
- Product-market fit achieved and validated
- Repeatable sales and marketing processes
- Positive unit economics and clear path to profitability
- Strong founding team with complementary skills
- Sufficient capital to fund growth
- Market demand exceeding current capacity

**Scaling Phases:**

**Phase 1: Foundation (0-10 employees)**
- Establish core processes and workflows
- Define company culture and values
- Build MVP and achieve initial product-market fit
- Develop basic financial and operational systems

**Phase 2: Growth (10-50 employees)**
- Formalize organizational structure
- Implement scalable technology infrastructure
- Establish key performance metrics and reporting
- Build middle management layer

**Phase 3: Expansion (50-200 employees)**
- Develop specialized departments and functions
- Implement advanced systems and automation
- Focus on efficiency and optimization
- Prepare for potential exit opportunities

**Scaling Metrics to Track:**
- Revenue per employee
- Customer acquisition efficiency
- Operational leverage ratios
- Time to productivity for new hires
- System uptime and performance
- Customer satisfaction during growth periods''',
              'type': 'text'
            },
            {
              'title': 'Building High-Performance Teams',
              'content': '''Your team is your most valuable asset when scaling. Building the right team with the right culture is crucial for sustainable growth.

**Team Building Strategy:**

**1. Define Roles and Responsibilities**
- Create clear job descriptions and expectations
- Establish reporting structures and accountability
- Define decision-making authority and processes
- Document key workflows and procedures

**2. Hiring Best Practices**
- Hire for cultural fit and growth potential
- Use structured interview processes
- Check references and validate skills
- Consider diverse perspectives and backgrounds

**3. Onboarding and Training**
- Create comprehensive onboarding programs
- Provide role-specific training and resources
- Assign mentors and buddy systems
- Set clear 30-60-90 day goals

**4. Performance Management**
- Establish regular performance review cycles
- Set individual and team OKRs (Objectives and Key Results)
- Provide continuous feedback and coaching
- Create career development paths

**Key Roles for Scaling Startups:**

**Executive Team:**
- CEO: Vision, strategy, fundraising, culture
- CTO: Technology strategy, product development
- CFO: Financial planning, operations, investor relations
- VP Sales: Revenue generation, customer acquisition
- VP Marketing: Brand building, demand generation

**Management Layer:**
- Engineering Managers: Team leadership, technical delivery
- Product Managers: Feature prioritization, user experience
- Operations Managers: Process optimization, efficiency
- Customer Success Managers: Retention, expansion

**Cultural Considerations:**

**Preserving Startup Culture:**
- Maintain open communication and transparency
- Encourage innovation and risk-taking
- Celebrate successes and learn from failures
- Keep bureaucracy minimal and decisions fast

**Scaling Culture:**
- Document and communicate core values
- Hire people who embody company values
- Create systems that reinforce desired behaviors
- Regular culture assessments and adjustments

**Team Effectiveness Metrics:**
- Employee Net Promoter Score (eNPS)
- Time to productivity for new hires
- Employee retention and turnover rates
- Internal promotion rates
- 360-degree feedback scores''',
              'type': 'text'
            },
            {
              'title': 'Operational Excellence',
              'content': '''Operational excellence involves creating efficient, repeatable processes that can scale with your business growth.

**Process Optimization Framework:**

**1. Process Mapping**
- Document current workflows and procedures
- Identify bottlenecks and inefficiencies
- Map customer journey touchpoints
- Analyze handoffs between departments

**2. Standardization**
- Create standard operating procedures (SOPs)
- Implement quality control checkpoints
- Establish performance benchmarks
- Document best practices and lessons learned

**3. Automation**
- Identify repetitive, rule-based tasks
- Implement workflow automation tools
- Use AI and machine learning where appropriate
- Maintain human oversight for quality

**4. Continuous Improvement**
- Regular process reviews and updates
- Employee feedback and suggestions
- Performance monitoring and optimization
- Lean Six Sigma methodologies

**Key Operational Areas:**

**Customer Operations:**
- Support ticket management and resolution
- Customer onboarding and success processes
- Quality assurance and satisfaction monitoring
- Escalation procedures and crisis management

**Sales Operations:**
- Lead qualification and scoring
- Sales process standardization
- CRM management and data hygiene
- Sales forecasting and pipeline management

**Marketing Operations:**
- Campaign planning and execution
- Lead generation and nurturing
- Content creation and distribution
- Marketing automation and analytics

**Product Operations:**
- Development workflow and release management
- Quality assurance and testing procedures
- Feature flag management and A/B testing
- User feedback collection and analysis

**Financial Operations:**
- Accounting and bookkeeping automation
- Expense management and approval workflows
- Revenue recognition and reporting
- Budget planning and variance analysis

**Technology Infrastructure:**

**Scalable Systems:**
- Cloud-based infrastructure (AWS, Azure, GCP)
- Microservices architecture
- API-first development approach
- Database scaling and optimization

**Security and Compliance:**
- Data protection and privacy measures
- Access control and authentication
- Compliance with industry regulations
- Regular security audits and updates

**Monitoring and Analytics:**
- Application performance monitoring
- Business intelligence and dashboards
- Predictive analytics and forecasting
- Real-time alerting and incident response''',
              'type': 'text'
            },
            {
              'title': 'Technology & Infrastructure Scaling',
              'content': '''Technology infrastructure must evolve to support increased user load, data volume, and feature complexity as your startup scales.

**Infrastructure Scaling Strategies:**

**1. Horizontal vs Vertical Scaling**
- **Horizontal (Scale Out)**: Add more servers/instances
- **Vertical (Scale Up)**: Increase server capacity
- **Hybrid Approach**: Combine both strategies
- **Auto-scaling**: Automatic resource adjustment

**2. Architecture Patterns**
- **Monolithic**: Single deployable unit (good for early stage)
- **Microservices**: Distributed services (better for scale)
- **Serverless**: Function-as-a-Service (cost-effective scaling)
- **Event-Driven**: Asynchronous communication patterns

**3. Database Scaling**
- **Read Replicas**: Distribute read operations
- **Sharding**: Partition data across databases
- **Caching**: Redis, Memcached for performance
- **NoSQL**: Document/graph databases for flexibility

**Technology Stack Considerations:**

**Frontend Technologies:**
- Progressive Web Apps (PWAs)
- Content Delivery Networks (CDNs)
- Mobile-first responsive design
- Performance optimization and lazy loading

**Backend Technologies:**
- API-first architecture
- Message queues and event streaming
- Background job processing
- Search and analytics engines

**DevOps and Deployment:**
- Containerization (Docker, Kubernetes)
- Continuous Integration/Continuous Deployment (CI/CD)
- Infrastructure as Code (Terraform, CloudFormation)
- Monitoring and logging (DataDog, New Relic)

**Security Scaling:**
- Identity and Access Management (IAM)
- Encryption at rest and in transit
- Web Application Firewalls (WAF)
- Regular security assessments and penetration testing

**Performance Optimization:**

**Application Performance:**
- Code optimization and refactoring
- Database query optimization
- Caching strategies at multiple layers
- Content compression and minification

**Monitoring and Alerting:**
- Application Performance Monitoring (APM)
- Infrastructure monitoring
- Business metrics tracking
- Incident response procedures

**Capacity Planning:**
- Traffic forecasting and growth modeling
- Resource utilization analysis
- Cost optimization strategies
- Disaster recovery and backup procedures

**Technology Decision Framework:**
- Build vs Buy vs Partner decisions
- Open source vs commercial solutions
- Short-term needs vs long-term scalability
- Total cost of ownership analysis''',
              'type': 'text'
            },
            {
              'title': 'Strategic Partnerships & Alliances',
              'content': '''Strategic partnerships can accelerate growth, provide access to new markets, and create competitive advantages during scaling.

**Types of Strategic Partnerships:**

**1. Technology Partnerships**
- Integration partnerships with complementary products
- Platform partnerships (app stores, marketplaces)
- API partnerships and developer ecosystems
- White-label and OEM relationships

**2. Go-to-Market Partnerships**
- Channel partnerships and reseller networks
- Referral and affiliate programs
- Co-marketing and joint campaigns
- Distribution partnerships

**3. Strategic Alliances**
- Joint ventures for new market entry
- Research and development collaborations
- Supply chain and procurement partnerships
- Customer success partnerships

**Partnership Evaluation Framework:**

**Strategic Fit:**
- Alignment with business objectives
- Complementary capabilities and resources
- Cultural compatibility and values
- Long-term vision and roadmap alignment

**Market Impact:**
- Access to new customer segments
- Geographic expansion opportunities
- Competitive positioning benefits
- Market validation and credibility

**Financial Benefits:**
- Revenue generation potential
- Cost reduction opportunities
- Risk sharing and mitigation
- Investment and funding possibilities

**Partnership Development Process:**

**1. Partner Identification**
- Market research and competitive analysis
- Partner ecosystem mapping
- Due diligence and evaluation
- Initial outreach and qualification

**2. Partnership Negotiation**
- Define mutual value propositions
- Establish clear roles and responsibilities
- Negotiate terms and conditions
- Create governance structures

**3. Partnership Execution**
- Joint planning and goal setting
- Regular communication and reporting
- Performance monitoring and optimization
- Relationship management and renewal

**Partnership Success Factors:**
- Clear communication and expectations
- Mutual value creation and benefit
- Strong relationship management
- Flexibility and adaptability
- Regular performance review and optimization

**Common Partnership Challenges:**
- Misaligned incentives and goals
- Competition for resources and attention
- Cultural and operational differences
- Intellectual property and confidentiality concerns
- Performance measurement and accountability''',
              'type': 'text'
            },
            {
              'title': 'Quiz: Scaling Operations Mastery',
              'content': 'Test your understanding of scaling operations and team building',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the most critical factor for successful startup scaling?',
                  'options': [
                    'Having unlimited funding',
                    'Achieving product-market fit before scaling',
                    'Hiring as many people as possible',
                    'Building the most advanced technology'
                  ],
                  'correct': 1,
                  'explanation': 'Product-market fit is essential before scaling. Without it, you\'ll scale problems rather than solutions, leading to inefficient resource use.'
                },
                {
                  'question': 'Which scaling approach adds more servers rather than upgrading existing ones?',
                  'options': [
                    'Vertical scaling',
                    'Horizontal scaling',
                    'Database scaling',
                    'Network scaling'
                  ],
                  'correct': 1,
                  'explanation': 'Horizontal scaling (scale out) involves adding more servers or instances to handle increased load, while vertical scaling increases the capacity of existing servers.'
                },
                {
                  'question': 'What should be prioritized when hiring for a scaling startup?',
                  'options': [
                    'Experience over potential',
                    'Technical skills over soft skills',
                    'Cultural fit and growth potential',
                    'Lowest salary requirements'
                  ],
                  'correct': 2,
                  'explanation': 'Cultural fit and growth potential are crucial for scaling startups, as employees need to adapt quickly and maintain company culture during rapid growth.'
                },
                {
                  'question': 'Which operational metric is most important for scaling efficiency?',
                  'options': [
                    'Total number of employees',
                    'Revenue per employee',
                    'Office square footage',
                    'Number of meetings per day'
                  ],
                  'correct': 1,
                  'explanation': 'Revenue per employee measures how efficiently the organization generates revenue relative to its workforce, indicating scaling effectiveness.'
                },
                {
                  'question': 'What is the primary benefit of strategic partnerships during scaling?',
                  'options': [
                    'Reducing competition',
                    'Accelerating growth and accessing new markets',
                    'Eliminating the need for hiring',
                    'Guaranteeing profitability'
                  ],
                  'correct': 1,
                  'explanation': 'Strategic partnerships can accelerate growth by providing access to new markets, customers, technologies, and capabilities without building everything internally.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['intermediate_1', 'intermediate_2'],
        'badge': 'scale_master'
      },
      {
        'id': 'advanced_2',
        'title': 'Fundraising & Investor Relations',
        'description': 'Master the art of fundraising, investor relations, and equity management',
        'duration': 55,
        'category': 'fundraising',
        'difficulty': 'advanced',
        'content': {
          'sections': [
            {
              'title': 'Fundraising Fundamentals',
              'content': '''Fundraising is a critical skill for scaling startups, involving raising capital from investors to fuel growth while maintaining strategic control of your business.

**Types of Funding:**

**1. Bootstrap/Self-Funding**
- Personal savings and revenue reinvestment
- Maintains full control and ownership
- Limited by personal resources and cash flow
- Slower growth but sustainable development

**2. Friends & Family Round**
- Initial capital from personal network
- Typically \$10K-\$250K range
- Less formal due diligence process
- Important to maintain personal relationships

**3. Angel Investment**
- Individual investors (\$25K-\$500K typical)
- Often former entrepreneurs or executives
- Provide mentorship and network access
- Convertible notes or equity investment

**4. Venture Capital**
- Professional investment firms
- Series A: \$2M-\$15M, Series B: \$10M-\$50M+
- Rigorous due diligence process
- Board seats and governance rights

**5. Alternative Funding**
- Revenue-based financing
- Crowdfunding (Kickstarter, equity crowdfunding)
- Government grants and programs
- Strategic corporate investment

**When to Raise Capital:**

**Right Reasons:**
- Accelerate proven growth model
- Expand to new markets or products
- Scale team and operations
- Achieve competitive advantages

**Wrong Reasons:**
- Fix fundamental business problems
- Extend runway without clear progress
- Keep up with competitors
- Impress stakeholders

**Fundraising Timing Indicators:**
- Strong product-market fit evidence
- Repeatable sales and marketing model
- Clear path to next milestone
- Competitive market opportunity
- Strong team and execution capability''',
              'type': 'text'
            },
            {
              'title': 'Preparing for Fundraising',
              'content': '''Successful fundraising requires thorough preparation, compelling storytelling, and robust business fundamentals.

**The Fundraising Preparation Checklist:**

**Business Fundamentals:**
- Clear value proposition and market positioning
- Proven business model with positive unit economics
- Strong financial projections and assumptions
- Competitive analysis and differentiation
- Intellectual property protection

**Financial Documentation:**
- Historical financial statements (3+ years if available)
- Monthly financial projections (3-5 years)
- Key metrics and KPI tracking
- Cap table and existing investor details
- Legal and corporate structure documentation

**Team and Operations:**
- Experienced management team with relevant expertise
- Advisory board with industry credentials
- Operational processes and systems
- Key partnerships and customer relationships
- Risk assessment and mitigation strategies

**The Pitch Deck Structure:**

**1. Problem (1-2 slides)**
- Clear, relatable problem statement
- Market size and urgency
- Personal connection to problem

**2. Solution (1-2 slides)**
- Unique value proposition
- Product demonstration or screenshots
- How it solves the problem better than alternatives

**3. Market Opportunity (1-2 slides)**
- Total Addressable Market (TAM)
- Serviceable Addressable Market (SAM)
- Market trends and growth drivers

**4. Business Model (1 slide)**
- Revenue streams and pricing
- Unit economics and profitability path
- Go-to-market strategy

**5. Traction (2-3 slides)**
- Key metrics and growth trends
- Customer testimonials and case studies
- Partnerships and achievements

**6. Competition (1 slide)**
- Competitive landscape analysis
- Differentiation and competitive advantages
- Barriers to entry and moats

**7. Team (1 slide)**
- Founder and key team backgrounds
- Relevant experience and expertise
- Advisory board and key hires planned

**8. Financial Projections (1-2 slides)**
- Revenue and growth projections
- Key assumptions and drivers
- Path to profitability

**9. Funding (1 slide)**
- Amount raising and use of funds
- Milestones to be achieved
- Timeline and next round strategy

**10. Appendix**
- Additional metrics and details
- Technical specifications
- Market research and validation
- Reference customers and partnerships''',
              'type': 'text'
            },
            {
              'title': 'Investor Relations & Communication',
              'content': '''Building strong relationships with investors requires ongoing communication, transparency, and strategic alignment beyond just raising capital.

**Types of Investors:**

**Angel Investors:**
- High-net-worth individuals
- Often former entrepreneurs or executives
- Provide mentorship and network access
- Smaller check sizes (\$25K-\$500K)
- More flexible terms and faster decisions

**Venture Capital Firms:**
- Professional investment partnerships
- Larger check sizes (\$1M-\$50M+)
- Institutional due diligence process
- Board representation and governance
- Portfolio support and resources

**Strategic Investors:**
- Corporate venture arms
- Industry-specific expertise and partnerships
- Potential acquisition opportunities
- Strategic value beyond capital
- Longer decision-making processes

**Investor Evaluation Criteria:**

**Investor Fit Assessment:**
- Investment stage and check size alignment
- Industry expertise and network
- Portfolio companies and potential synergies
- Investment timeline and exit expectations
- Value-add beyond capital

**Due Diligence Process:**
- Financial and legal review
- Market and competitive analysis
- Team and reference checks
- Technical and product evaluation
- Customer and partnership validation

**Ongoing Investor Relations:**

**Regular Communication:**
- Monthly investor updates (email)
- Quarterly board meetings and reports
- Annual shareholder meetings
- Ad-hoc updates for significant events

**Investor Update Content:**
- Key metrics and performance highlights
- Progress on goals and milestones
- Challenges and areas where help is needed
- Financial performance and burn rate
- Team updates and hiring needs
- Market developments and competitive landscape

**Building Investor Value:**
- Leverage investor expertise and networks
- Make strategic introductions and partnerships
- Seek advice on key business decisions
- Invite investors to customer and team events
- Provide early access to new products or features

**Managing Investor Expectations:**
- Set realistic goals and timelines
- Communicate challenges early and often
- Provide context for changes in strategy
- Celebrate wins but acknowledge areas for improvement
- Maintain transparency and trust''',
              'type': 'text'
            },
            {
              'title': 'Equity Management & Cap Table',
              'content': '''Understanding equity distribution, cap table management, and employee compensation is crucial for long-term success and fundraising.

**Cap Table Fundamentals:**

**Key Components:**
- Founder equity and vesting schedules
- Employee stock option pool (typically 10-20%)
- Investor equity and liquidation preferences
- Board composition and voting rights
- Anti-dilution and pro-rata rights

**Equity Distribution Guidelines:**

**Founder Equity:**
- Single founder: 100% initially
- Co-founders: Split based on contribution, risk, and commitment
- Typical splits: 60/40, 50/30/20, or equal if similar contributions
- Vesting schedules: 4 years with 1-year cliff

**Employee Equity:**
- Early employees: 0.1%-5% depending on role and timing
- Key executives: 1%-10% for VPs and C-level
- Option pool: 10-20% of total shares
- Vesting: 4 years with 1-year cliff, monthly vesting thereafter

**Investor Equity:**
- Seed round: 10-25% dilution
- Series A: 20-30% dilution
- Series B+: 15-25% dilution per round
- Total founder dilution: 50-80% through successful exit

**Equity Compensation Strategies:**

**Stock Options:**
- Right to purchase shares at exercise price
- Vesting schedule motivates retention
- Tax implications on exercise and sale
- ISOs vs NSOs for tax treatment

**Restricted Stock:**
- Actual shares with vesting restrictions
- Early exercise options available
- 83(b) election for tax optimization
- Full voting and dividend rights

**Stock Appreciation Rights (SARs):**
- Cash or stock payment based on appreciation
- No upfront purchase required
- Phantom equity alternative
- Simpler administration and tax treatment

**Cap Table Management Best Practices:**

**Documentation and Compliance:**
- Maintain accurate cap table records
- Proper legal documentation for all transactions
- Regular updates and reconciliation
- Board approval for equity issuances

**Scenario Planning:**
- Model dilution through future rounds
- Plan for key hire equity needs
- Exit scenario modeling and distribution
- Liquidation preference impact analysis

**Common Cap Table Mistakes:**
- Inadequate founder vesting schedules
- Insufficient option pool for growth
- Complex liquidation preferences
- Poor documentation and record keeping
- Not planning for future rounds and dilution''',
              'type': 'text'
            },
            {
              'title': 'Exit Strategies & Liquidity',
              'content': '''Understanding exit strategies helps guide long-term strategic decisions and ensures alignment between founders, employees, and investors.

**Types of Exit Strategies:**

**1. Acquisition (M&A)**
- Strategic acquisition by larger company
- Financial acquisition by private equity
- Most common exit for startups (90%+)
- Timeline: 5-10 years typically

**2. Initial Public Offering (IPO)**
- Public stock exchange listing
- Requires significant scale (\$100M+ revenue)
- Regulatory compliance and reporting requirements
- Continued growth pressure from public markets

**3. Secondary Sales**
- Partial liquidity for founders and employees
- Private market transactions
- Growth capital while maintaining control
- Intermediate step before full exit

**4. Management Buyout**
- Internal team purchases company
- Investor exit while maintaining operations
- Less common for venture-backed companies
- Requires significant financing capability

**Factors Affecting Exit Valuation:**

**Financial Performance:**
- Revenue growth rate and predictability
- Profitability and cash flow generation
- Unit economics and scalability
- Market position and competitive advantages

**Strategic Value:**
- Synergies with potential acquirers
- Technology and intellectual property
- Customer base and market access
- Team talent and capabilities

**Market Conditions:**
- Industry consolidation trends
- Public market valuations
- Economic environment and credit availability
- Competitive dynamics and timing

**Preparing for Exit:**

**Operational Excellence:**
- Scalable systems and processes
- Strong management team and succession planning
- Diversified customer base and revenue streams
- Clean financial records and compliance

**Strategic Positioning:**
- Clear value proposition and differentiation
- Market leadership or strong niche position
- Growth trajectory and expansion opportunities
- Strong brand and customer relationships

**Due Diligence Preparation:**
- Organized data room with key documents
- Clean legal structure and IP protection
- Financial audits and tax compliance
- Customer and employee contracts review

**Exit Process Management:**

**Investment Banking:**
- Selecting the right investment bank
- Managing the auction process
- Negotiating deal terms and structure
- Coordinating due diligence and closing

**Legal and Tax Considerations:**
- Deal structure optimization
- Tax implications and planning
- Regulatory approvals and compliance
- Employment and retention agreements

**Post-Exit Considerations:**
- Earnout provisions and milestones
- Integration planning and execution
- Team retention and cultural fit
- Personal financial planning and diversification''',
              'type': 'text'
            },
            {
              'title': 'Quiz: Fundraising & Investor Relations',
              'content': 'Test your knowledge of fundraising and investor relations',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the most important factor investors consider when evaluating startups?',
                  'options': [
                    'Size of the market opportunity',
                    'Quality and experience of the team',
                    'Uniqueness of the technology',
                    'Amount of funding requested'
                  ],
                  'correct': 1,
                  'explanation': 'While all factors matter, investors consistently rank team quality as the most important factor, as great teams can adapt and execute even when other elements change.'
                },
                {
                  'question': 'What is typically the appropriate employee stock option pool size for a growing startup?',
                  'options': [
                    '5-8%',
                    '10-20%',
                    '25-30%',
                    '35-40%'
                  ],
                  'correct': 1,
                  'explanation': 'Most startups allocate 10-20% of shares for employee stock options to attract and retain talent while preserving equity for founders and investors.'
                },
                {
                  'question': 'Which fundraising timing indicator is most critical?',
                  'options': [
                    'Competitor fundraising activity',
                    'Strong product-market fit evidence',
                    'Favorable market conditions',
                    'Low current valuation'
                  ],
                  'correct': 1,
                  'explanation': 'Strong product-market fit evidence shows investors that the business model works and additional capital can accelerate proven growth rather than fund experiments.'
                },
                {
                  'question': 'What should be included in regular investor updates?',
                  'options': [
                    'Only positive news and achievements',
                    'Detailed technical product specifications',
                    'Key metrics, progress, challenges, and areas where help is needed',
                    'Personal updates about founder activities'
                  ],
                  'correct': 2,
                  'explanation': 'Effective investor updates are transparent about both progress and challenges, helping investors understand how they can provide value beyond capital.'
                },
                {
                  'question': 'What is the most common exit strategy for venture-backed startups?',
                  'options': [
                    'Initial Public Offering (IPO)',
                    'Management buyout',
                    'Acquisition by another company',
                    'Liquidation and shutdown'
                  ],
                  'correct': 2,
                  'explanation': 'Over 90% of successful startup exits are through acquisition by larger companies, as IPOs require significant scale that most startups don\'t achieve.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['intermediate_1'],
        'badge': 'fundraising_expert'
      }
    ],
    'expert': [
      {
        'id': 'expert_1',
        'title': 'Strategic Leadership & Vision',
        'description': 'Master strategic thinking, visionary leadership, and long-term business planning',
        'duration': 50,
        'category': 'leadership',
        'difficulty': 'expert',
        'content': {
          'sections': [
            {
              'title': 'Strategic Thinking Fundamentals',
              'content': '''Strategic thinking is the ability to analyze complex situations, anticipate future trends, and make decisions that position your organization for long-term success.

**Core Elements of Strategic Thinking:**

**1. Systems Thinking**
- Understanding interconnected relationships
- Recognizing patterns and feedback loops
- Anticipating unintended consequences
- Viewing business as part of larger ecosystem

**2. Long-term Perspective**
- Balancing short-term results with long-term vision
- Anticipating market evolution and disruption
- Building sustainable competitive advantages
- Creating options for future growth

**3. Outside-In Thinking**
- Customer-centric decision making
- Market-driven strategy development
- Competitive intelligence and positioning
- External stakeholder consideration

**4. Hypothesis-Driven Analysis**
- Forming testable strategic hypotheses
- Gathering evidence to validate assumptions
- Iterating strategy based on learning
- Making decisions with incomplete information

**Strategic Frameworks:**

**Porter's Five Forces:**
- Threat of new entrants
- Bargaining power of suppliers
- Bargaining power of buyers
- Threat of substitute products
- Competitive rivalry intensity

**SWOT Analysis (Enhanced):**
- Strengths: Internal capabilities and advantages
- Weaknesses: Internal limitations and disadvantages
- Opportunities: External factors that could benefit the business
- Threats: External factors that could harm the business

**Blue Ocean Strategy:**
- Create uncontested market space
- Make competition irrelevant
- Create and capture new demand
- Break value-cost trade-off

**Platform Strategy:**
- Network effects and ecosystem thinking
- Multi-sided market dynamics
- Winner-take-all competitive dynamics
- Platform vs. product business models

**Strategic Decision-Making Process:**
1. **Define the Strategic Question**: What decision needs to be made?
2. **Gather Intelligence**: Market research, competitive analysis, internal assessment
3. **Generate Options**: Brainstorm multiple strategic alternatives
4. **Evaluate Options**: Assess feasibility, impact, and alignment
5. **Make Decision**: Choose based on evidence and strategic fit
6. **Execute and Monitor**: Implement with clear metrics and feedback loops''',
              'type': 'text'
            },
            {
              'title': 'Visionary Leadership',
              'content': '''Visionary leadership involves creating compelling futures, inspiring others to achieve extraordinary results, and navigating uncertainty with confidence.

**Components of Visionary Leadership:**

**1. Vision Creation**
- Paint a compelling picture of the future
- Connect vision to deeper purpose and meaning
- Make vision tangible and achievable
- Ensure vision inspires and motivates

**2. Vision Communication**
- Tell stories that resonate emotionally
- Use multiple channels and repeated messaging
- Adapt communication to different audiences
- Demonstrate personal commitment to vision

**3. Vision Execution**
- Translate vision into actionable strategies
- Align organizational resources and capabilities
- Create systems and processes that support vision
- Monitor progress and adjust course as needed

**Leadership Styles for Different Situations:**

**Transformational Leadership:**
- Inspire and motivate through shared vision
- Encourage innovation and creative thinking
- Develop individual capabilities and potential
- Build strong emotional connections

**Servant Leadership:**
- Focus on serving others and their development
- Emphasize humility and empathy
- Build trust through authentic relationships
- Create supportive and empowering environments

**Adaptive Leadership:**
- Navigate complex and uncertain environments
- Experiment with new approaches and solutions
- Learn from failures and adjust quickly
- Balance stability with necessary change

**Authentic Leadership:**
- Lead with integrity and consistent values
- Demonstrate self-awareness and vulnerability
- Build genuine relationships and trust
- Make decisions based on core principles

**Building High-Performance Culture:**

**Cultural Elements:**
- Shared values and beliefs
- Common language and communication norms
- Rituals and traditions that reinforce culture
- Stories and symbols that embody values

**Culture Development Strategies:**
- Model desired behaviors consistently
- Hire and promote people who embody values
- Create systems that reward desired behaviors
- Celebrate successes that demonstrate values
- Address behaviors that contradict culture

**Leading Through Change:**
- Communicate the need for change clearly
- Create urgency while maintaining stability
- Involve others in change planning and execution
- Provide support and resources for adaptation
- Celebrate milestones and progress

**Developing Future Leaders:**
- Identify high-potential individuals
- Provide stretch assignments and challenges
- Offer mentoring and coaching support
- Create leadership development programs
- Delegate meaningful authority and responsibility''',
              'type': 'text'
            },
            {
              'title': 'Innovation & Disruption',
              'content': '''Innovation leadership requires creating environments where breakthrough ideas emerge and managing the tension between current operations and future possibilities.

**Types of Innovation:**

**1. Incremental Innovation**
- Continuous improvement of existing products/services
- Process optimization and efficiency gains
- Customer experience enhancements
- Lower risk, predictable returns

**2. Radical Innovation**
- Breakthrough technologies or business models
- Significant departures from current approaches
- Higher risk, potentially transformative returns
- Longer development timelines

**3. Disruptive Innovation**
- Creates new markets or value networks
- Eventually displaces established products/companies
- Often starts with "inferior" products for new segments
- Gradually moves upmarket and disrupts incumbents

**Innovation Management Framework:**

**Innovation Strategy:**
- Define innovation goals and priorities
- Allocate resources and investment levels
- Choose innovation focus areas and domains
- Balance portfolio across innovation types

**Idea Generation:**
- Create diverse sources of ideas
- Encourage experimentation and risk-taking
- Use customer insights and market research
- Leverage external partnerships and ecosystems

**Idea Evaluation:**
- Establish clear criteria for evaluation
- Use stage-gate processes for development
- Balance quantitative and qualitative assessment
- Consider strategic fit and resource requirements

**Innovation Execution:**
- Create dedicated innovation teams or processes
- Provide adequate resources and support
- Protect innovations from operational pressures
- Measure and learn from both successes and failures

**Building Innovation Culture:**

**Psychological Safety:**
- Encourage experimentation and intelligent failure
- Reward learning and adaptation
- Avoid punishing honest mistakes
- Create space for creative thinking

**Diversity and Inclusion:**
- Diverse perspectives drive better innovation
- Include different backgrounds, experiences, and thinking styles
- Create inclusive decision-making processes
- Challenge groupthink and conventional wisdom

**Continuous Learning:**
- Invest in employee development and skill building
- Encourage cross-functional collaboration
- Provide time and resources for learning
- Share knowledge and best practices across organization

**Managing Disruption:**

**Disruption Response Strategies:**
- Monitor weak signals and emerging trends
- Experiment with new business models
- Create separate innovation units or labs
- Partner with or acquire disruptive startups
- Cannibalize own products before others do

**Innovation Metrics:**
- R&D investment as percentage of revenue
- Time to market for new products/features
- Percentage of revenue from new products
- Number of patents and IP created
- Employee innovation engagement scores''',
              'type': 'text'
            },
            {
              'title': 'Global Market Expansion',
              'content': '''Expanding into global markets requires strategic planning, cultural sensitivity, and operational excellence across diverse environments.

**Global Expansion Strategy:**

**Market Selection Criteria:**
- Market size and growth potential
- Competitive landscape and barriers to entry
- Regulatory environment and compliance requirements
- Cultural fit and localization needs
- Economic and political stability

**Entry Strategy Options:**

**1. Export Strategy**
- Sell products/services from home market
- Low investment and risk
- Limited local presence and control
- Good for testing market demand

**2. Licensing/Franchising**
- Partner with local operators
- Leverage local knowledge and relationships
- Share risks and investments
- Maintain brand and quality control

**3. Joint Ventures**
- Partnership with local companies
- Shared ownership and control
- Access to local expertise and networks
- Shared risks and rewards

**4. Direct Investment**
- Establish local operations and presence
- Full control over strategy and execution
- Higher investment and risk
- Better long-term market position

**Cultural Intelligence and Adaptation:**

**Cultural Dimensions:**
- Power distance and hierarchy
- Individualism vs. collectivism
- Uncertainty avoidance
- Long-term vs. short-term orientation
- Masculinity vs. femininity

**Localization Strategies:**
- Product/service adaptation for local needs
- Marketing and communication localization
- Pricing strategies for local markets
- Distribution channel optimization
- Local talent acquisition and development

**Global Operations Management:**

**Organizational Structure:**
- Centralized vs. decentralized decision-making
- Regional vs. global functional organization
- Matrix structures for dual reporting
- Communication and coordination mechanisms

**Technology and Systems:**
- Global platforms with local customization
- Data privacy and security compliance
- Integration across multiple systems
- Scalable infrastructure and operations

**Financial Management:**
- Multi-currency operations and hedging
- Transfer pricing and tax optimization
- Local financing and banking relationships
- Regulatory compliance and reporting

**Risk Management:**
- Political and economic risk assessment
- Currency and interest rate risk
- Operational and supply chain risks
- Compliance and legal risks

**Global Talent Management:**
- International recruitment and retention
- Cross-cultural training and development
- Expatriate and local talent integration
- Global mobility and career development

**Success Factors for Global Expansion:**
- Patient capital and long-term commitment
- Strong local partnerships and relationships
- Adaptable business model and operations
- Cultural sensitivity and local responsiveness
- Global brand with local relevance''',
              'type': 'text'
            },
            {
              'title': 'Mentoring & Knowledge Transfer',
              'content': '''Expert-level leaders have a responsibility to develop others and transfer knowledge to ensure sustainable success beyond their individual contributions.

**Mentoring Excellence:**

**Types of Mentoring:**

**1. Traditional Mentoring**
- One-on-one relationship with junior professional
- Long-term development focus
- Career guidance and support
- Knowledge and network sharing

**2. Reverse Mentoring**
- Learning from younger or less experienced individuals
- Technology and trend insights
- Fresh perspectives and ideas
- Mutual learning and development

**3. Group Mentoring**
- Mentoring multiple individuals simultaneously
- Peer learning and networking
- Efficient knowledge transfer
- Diverse perspectives and experiences

**4. Virtual Mentoring**
- Remote mentoring relationships
- Technology-enabled communication
- Global reach and accessibility
- Flexible scheduling and interaction

**Effective Mentoring Practices:**

**Relationship Development:**
- Establish clear expectations and boundaries
- Build trust and psychological safety
- Create regular communication rhythms
- Maintain confidentiality and professionalism

**Development Planning:**
- Assess mentee needs and goals
- Create development plans and milestones
- Provide stretch assignments and challenges
- Monitor progress and adjust plans

**Knowledge Transfer Methods:**
- Storytelling and case study sharing
- Job shadowing and observation
- Collaborative problem-solving
- Reflective questioning and coaching

**Network Expansion:**
- Introduce mentees to key contacts
- Facilitate networking opportunities
- Provide access to industry events
- Create peer learning groups

**Organizational Knowledge Management:**

**Knowledge Capture:**
- Document processes and best practices
- Create training materials and resources
- Record lessons learned and case studies
- Build searchable knowledge bases

**Knowledge Sharing:**
- Regular knowledge sharing sessions
- Communities of practice
- Cross-functional project teams
- Succession planning and transition

**Culture of Learning:**
- Reward knowledge sharing behaviors
- Create time and space for learning
- Encourage experimentation and reflection
- Celebrate learning from failures

**Legacy Building:**

**Institutional Knowledge:**
- Create systems and processes that outlast individuals
- Document strategic thinking and decision-making
- Build organizational capabilities and competencies
- Develop next generation of leaders

**Industry Contribution:**
- Thought leadership and content creation
- Speaking and conference participation
- Industry association involvement
- Academic and research collaboration

**Social Impact:**
- Entrepreneurship education and support
- Community economic development
- Social enterprise and impact investing
- Philanthropy and giving strategies

**Measuring Mentoring Impact:**
- Mentee career progression and success
- Knowledge retention and application
- Organizational capability development
- Network growth and relationship quality
- Long-term business performance improvements''',
              'type': 'text'
            },
            {
              'title': 'Quiz: Strategic Leadership Excellence',
              'content': 'Test your mastery of strategic leadership and vision',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the key characteristic of strategic thinking?',
                  'options': [
                    'Making quick tactical decisions',
                    'Focusing only on short-term results',
                    'Analyzing complex situations with long-term perspective',
                    'Following industry best practices'
                  ],
                  'correct': 2,
                  'explanation': 'Strategic thinking involves analyzing complex situations, understanding interconnections, and making decisions with a long-term perspective that positions the organization for sustained success.'
                },
                {
                  'question': 'Which innovation type creates new markets and eventually displaces established companies?',
                  'options': [
                    'Incremental innovation',
                    'Process innovation',
                    'Disruptive innovation',
                    'Sustaining innovation'
                  ],
                  'correct': 2,
                  'explanation': 'Disruptive innovation creates new markets or value networks and eventually displaces established market leaders, often starting with "inferior" products for new customer segments.'
                },
                {
                  'question': 'What is the most important factor for successful global market expansion?',
                  'options': [
                    'Having the lowest prices',
                    'Cultural intelligence and local adaptation',
                    'Using the same strategy everywhere',
                    'Entering all markets simultaneously'
                  ],
                  'correct': 1,
                  'explanation': 'Cultural intelligence and the ability to adapt to local needs, preferences, and business practices is crucial for successful global expansion.'
                },
                {
                  'question': 'Which leadership style is most effective for navigating uncertainty and driving innovation?',
                  'options': [
                    'Authoritarian leadership',
                    'Micromanagement',
                    'Adaptive leadership',
                    'Laissez-faire leadership'
                  ],
                  'correct': 2,
                  'explanation': 'Adaptive leadership is most effective in uncertain environments as it emphasizes experimentation, learning from failures, and adjusting approaches based on new information.'
                },
                {
                  'question': 'What is the primary benefit of effective mentoring programs?',
                  'options': [
                    'Reducing employee salaries',
                    'Knowledge transfer and leadership development',
                    'Eliminating the need for formal training',
                    'Increasing work hours'
                  ],
                  'correct': 1,
                  'explanation': 'Effective mentoring programs facilitate knowledge transfer, develop future leaders, and create sustainable organizational capabilities that extend beyond individual contributions.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['advanced_1', 'advanced_2'],
        'badge': 'strategic_leader'
      },
      {
        'id': 'expert_2',
        'title': 'Ecosystem Building & Industry Impact',
        'description': 'Master ecosystem development, industry transformation, and creating lasting impact',
        'duration': 45,
        'category': 'ecosystem',
        'difficulty': 'expert',
        'content': {
          'sections': [
            {
              'title': 'Ecosystem Thinking',
              'content': '''Ecosystem thinking involves understanding and influencing the complex web of relationships, resources, and interactions that create value in modern business environments.

**Ecosystem Fundamentals:**

**Definition and Characteristics:**
- Interconnected network of organizations, people, and resources
- Shared value creation and mutual dependence
- Emergent properties that arise from interactions
- Dynamic and evolving relationships
- Platform-mediated or naturally occurring

**Types of Business Ecosystems:**

**1. Platform Ecosystems**
- Technology platforms with third-party developers
- Marketplace platforms connecting buyers and sellers
- Content platforms with creators and consumers
- Examples: iOS/Android, Amazon, YouTube

**2. Innovation Ecosystems**
- Clusters of companies, universities, and support organizations
- Knowledge sharing and collaborative R&D
- Talent mobility and entrepreneurship
- Examples: Silicon Valley, Boston, Tel Aviv

**3. Industry Ecosystems**
- Value chains and supply networks
- Industry associations and standards bodies
- Regulatory and policy environment
- Examples: Automotive, healthcare, energy

**4. Startup Ecosystems**
- Entrepreneurs, investors, and support organizations
- Accelerators, incubators, and mentorship networks
- Government policies and infrastructure
- Culture of risk-taking and innovation

**Ecosystem Design Principles:**

**Network Effects:**
- Direct network effects: Value increases with more users
- Indirect network effects: Complementary products/services
- Data network effects: Better products through usage data
- Social network effects: Status and belonging

**Platform Strategy:**
- Core platform with modular components
- APIs and developer tools
- Governance and curation mechanisms
- Revenue sharing and incentive alignment

**Ecosystem Orchestration:**
- Define vision and value proposition
- Attract and onboard key participants
- Facilitate connections and interactions
- Govern and evolve ecosystem rules
- Measure and optimize ecosystem health''',
              'type': 'text'
            },
            {
              'title': 'Industry Transformation Leadership',
              'content': '''Industry transformation leaders drive systemic change, challenge established norms, and create new paradigms for how industries operate.

**Transformation Leadership Strategies:**

**1. Thought Leadership**
- Articulate compelling vision for industry future
- Challenge conventional wisdom and assumptions
- Influence public policy and regulation
- Shape industry standards and best practices

**2. Ecosystem Building**
- Convene diverse stakeholders around shared goals
- Create platforms for collaboration and innovation
- Facilitate knowledge sharing and learning
- Build coalitions for systemic change

**3. Innovation Catalysis**
- Invest in breakthrough technologies and solutions
- Support entrepreneurship and startup development
- Create innovation labs and research partnerships
- Demonstrate new business models and approaches

**4. Market Making**
- Create new market categories and segments
- Educate customers and build demand
- Establish new value chains and ecosystems
- Set industry standards and benchmarks

**Change Management at Scale:**

**Systems Thinking:**
- Map current industry structure and dynamics
- Identify leverage points for maximum impact
- Understand feedback loops and unintended consequences
- Design interventions at multiple system levels

**Stakeholder Engagement:**
- Identify key stakeholders and influencers
- Understand different perspectives and interests
- Build coalitions and alliances for change
- Manage resistance and navigate politics

**Communication and Narrative:**
- Craft compelling story for change
- Use multiple channels and messengers
- Adapt message for different audiences
- Create urgency while maintaining hope

**Implementation Strategy:**
- Start with pilot projects and proof points
- Scale successful interventions gradually
- Learn and adapt based on feedback
- Institutionalize changes through policy and structure

**Industry Impact Metrics:**

**Market Creation:**
- New market size and growth rate
- Number of new companies and solutions
- Job creation and economic impact
- Investment attraction and capital formation

**Innovation Acceleration:**
- R&D investment and patent activity
- Startup formation and success rates
- Technology adoption and diffusion
- Time to market for new solutions

**Ecosystem Health:**
- Participant diversity and engagement
- Collaboration frequency and depth
- Knowledge sharing and learning
- Network resilience and adaptability

**Social Impact:**
- Environmental sustainability improvements
- Social equity and inclusion progress
- Community development and prosperity
- Quality of life enhancements''',
              'type': 'text'
            },
            {
              'title': 'Sustainable Impact Creation',
              'content': '''Creating sustainable impact requires balancing economic success with environmental stewardship and social responsibility, building businesses that generate long-term value for all stakeholders.

**Triple Bottom Line Framework:**

**People (Social Impact):**
- Employee well-being and development
- Community engagement and development
- Diversity, equity, and inclusion
- Human rights and labor practices
- Product safety and consumer protection

**Planet (Environmental Impact):**
- Carbon footprint and climate action
- Resource efficiency and circular economy
- Biodiversity protection and restoration
- Pollution prevention and remediation
- Sustainable supply chain practices

**Profit (Economic Impact):**
- Financial performance and sustainability
- Stakeholder value creation
- Innovation and competitiveness
- Economic development and job creation
- Ethical business practices

**Sustainable Business Models:**

**Circular Economy:**
- Design out waste and pollution
- Keep products and materials in use
- Regenerate natural systems
- Sharing economy and product-as-a-service
- Closed-loop supply chains

**Social Enterprise:**
- Mission-driven business models
- Blended value creation (social + financial)
- Impact measurement and reporting
- Stakeholder governance models
- Reinvestment of profits for social good

**B Corporation Movement:**
- Legal accountability to stakeholders
- Verified social and environmental performance
- Public transparency and disclosure
- Community of purpose-driven businesses
- Movement toward stakeholder capitalism

**Impact Measurement:**

**Theory of Change:**
- Define intended outcomes and impact
- Map causal pathways and assumptions
- Identify key activities and outputs
- Measure inputs, outputs, outcomes, and impact
- Learn and adapt based on evidence

**Impact Metrics:**
- Social Return on Investment (SROI)
- United Nations Sustainable Development Goals (SDGs)
- Global Reporting Initiative (GRI) standards
- Benefit Corporation accountability standards
- Industry-specific impact frameworks

**Stakeholder Engagement:**
- Materiality assessment and priority setting
- Regular stakeholder consultation and feedback
- Transparent reporting and communication
- Grievance mechanisms and response
- Collaborative problem-solving and innovation

**Long-term Value Creation:**

**Stakeholder Capitalism:**
- Consider all stakeholder interests in decision-making
- Balance short-term pressures with long-term value
- Transparent governance and accountability
- Sustainable compensation and incentive structures
- Purpose-driven culture and leadership

**Future-Proofing Strategies:**
- Scenario planning and risk assessment
- Climate resilience and adaptation
- Technology foresight and preparation
- Workforce development and reskilling
- Regulatory anticipation and compliance

**Legacy Considerations:**
- Institutional knowledge preservation
- Leadership development and succession
- Community investment and capacity building
- Industry standard setting and best practices
- Inspiration and replication by others''',
              'type': 'text'
            },
            {
              'title': 'Global Influence & Policy Impact',
              'content': '''Expert leaders often have opportunities to influence policy, shape regulation, and contribute to global conversations about business, technology, and society.

**Policy Engagement Strategies:**

**1. Public-Private Partnerships**
- Collaborate with government agencies
- Provide expertise and industry insights
- Co-invest in public goods and infrastructure
- Shape policy design and implementation

**2. Regulatory Advocacy**
- Engage in regulatory comment processes
- Participate in industry working groups
- Provide testimony and expert witness services
- Build relationships with regulators and policymakers

**3. International Forums**
- World Economic Forum and similar convenings
- United Nations and international organizations
- Industry associations and trade groups
- Academic and think tank partnerships

**4. Standards Development**
- Technical standards organizations
- Industry best practice development
- Certification and accreditation programs
- Open source and collaborative initiatives

**Global Leadership Platforms:**

**Thought Leadership:**
- Research publication and whitepapers
- Speaking at major conferences and events
- Media commentary and opinion pieces
- Podcast and digital content creation

**Board Service:**
- Corporate board of directors
- Nonprofit and foundation boards
- Government advisory committees
- University and research institution boards

**Philanthropic Leadership:**
- Strategic philanthropy and giving
- Social impact investing and financing
- Foundation creation and management
- Volunteer leadership and service

**Academic Engagement:**
- Teaching and guest lecturing
- Research collaboration and funding
- Case study development and sharing
- Executive education and programs

**Digital Influence:**

**Content Strategy:**
- Consistent thought leadership publishing
- Multi-channel content distribution
- Community building and engagement
- Measurement and optimization

**Social Media Leadership:**
- Professional platform presence (LinkedIn, Twitter)
- Authentic voice and perspective sharing
- Engagement with industry conversations
- Influence measurement and growth

**Digital Platform Creation:**
- Blogs and personal websites
- Podcasts and video series
- Online courses and education
- Digital community building

**Measuring Global Impact:**

**Influence Metrics:**
- Media mentions and coverage
- Social media reach and engagement
- Speaking invitations and audience size
- Policy citations and references

**Network Growth:**
- Professional relationship expansion
- Cross-sector collaboration increases
- Mentorship and development impact
- Alumni and successor achievements

**Systemic Change:**
- Industry practice evolution
- Policy and regulation improvements
- Social norm and culture shifts
- Economic and social outcome improvements

**Reputation Management:**
- Consistent values-based decision making
- Transparent communication and disclosure
- Crisis management and response
- Long-term relationship building''',
              'type': 'text'
            },
            {
              'title': 'Quiz: Ecosystem Building & Industry Impact',
              'content': 'Test your understanding of ecosystem development and industry transformation',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the key characteristic of successful business ecosystems?',
                  'options': [
                    'Complete control by a single company',
                    'Shared value creation and mutual dependence',
                    'Limited number of participants',
                    'Focus only on financial returns'
                  ],
                  'correct': 1,
                  'explanation': 'Successful ecosystems are characterized by shared value creation where all participants benefit and develop mutual dependence that strengthens the overall network.'
                },
                {
                  'question': 'Which framework helps evaluate sustainable business impact?',
                  'options': [
                    'Single bottom line (profit only)',
                    'Double bottom line (profit + people)',
                    'Triple bottom line (people, planet, profit)',
                    'Quadruple bottom line (adding purpose)'
                  ],
                  'correct': 2,
                  'explanation': 'The triple bottom line framework evaluates business success based on three dimensions: people (social impact), planet (environmental impact), and profit (economic impact).'
                },
                {
                  'question': 'What is the most effective approach for driving industry transformation?',
                  'options': [
                    'Working alone to maintain competitive advantage',
                    'Building coalitions and facilitating collaboration',
                    'Focusing only on internal operations',
                    'Avoiding engagement with competitors'
                  ],
                  'correct': 1,
                  'explanation': 'Industry transformation requires building coalitions, facilitating collaboration among diverse stakeholders, and creating shared vision for systemic change.'
                },
                {
                  'question': 'How should expert leaders measure their global impact?',
                  'options': [
                    'Only through financial metrics',
                    'Through influence metrics, network growth, and systemic change',
                    'By counting social media followers',
                    'Through media mentions alone'
                  ],
                  'correct': 1,
                  'explanation': 'Global impact should be measured through influence metrics, network growth, and evidence of systemic change in industries, policies, and social outcomes.'
                },
                {
                  'question': 'What is the primary goal of ecosystem orchestration?',
                  'options': [
                    'Controlling all ecosystem participants',
                    'Maximizing personal profits',
                    'Facilitating value creation for all participants',
                    'Eliminating competition'
                  ],
                  'correct': 2,
                  'explanation': 'Ecosystem orchestration aims to facilitate value creation for all participants by creating platforms, governance mechanisms, and incentive structures that benefit the entire network.'
                }
              ]
            }
          ]
        },
        'prerequisites': ['advanced_1'],
        'badge': 'ecosystem_builder'
      }
    ]
  };

  // Check if all tutorials for current level are completed
  static Future<bool> areCurrentLevelTutorialsCompleted() async {
    try {
      final userLevel = await QuizService.getUserLevel();
      final progress = await getLearningProgress();
      final completedTutorials = progress['completed_tutorials'] as List<dynamic>;
      
      // Get all tutorials for current level only
      final currentLevelTutorials = _tutorials[userLevel] ?? [];
      
      if (kDebugMode) {
        print('🔍 Checking tutorial completion for level: $userLevel');
        print('🔍 Total tutorials for $userLevel: ${currentLevelTutorials.length}');
        print('🔍 Completed tutorials: ${completedTutorials.length}');
      }
      
      // Check if all current level tutorials are completed
      for (var tutorial in currentLevelTutorials) {
        if (!completedTutorials.contains(tutorial['id'])) {
          if (kDebugMode) {
            print('❌ Tutorial "${tutorial['title']}" (${tutorial['id']}) not completed');
          }
          return false;
        }
      }
      
      if (kDebugMode) {
        print('✅ All $userLevel level tutorials completed!');
      }
      
      return currentLevelTutorials.isNotEmpty; // Must have at least one tutorial completed
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking tutorial completion: $e');
      }
      return false;
    }
  }

  // Get remaining tutorials for current level
  static Future<List<Map<String, dynamic>>> getRemainingCurrentLevelTutorials() async {
    try {
      final userLevel = await QuizService.getUserLevel();
      final progress = await getLearningProgress();
      final completedTutorials = progress['completed_tutorials'] as List<dynamic>;
      
      final currentLevelTutorials = _tutorials[userLevel] ?? [];
      final remainingTutorials = <Map<String, dynamic>>[];
      
      for (var tutorial in currentLevelTutorials) {
        if (!completedTutorials.contains(tutorial['id'])) {
          remainingTutorials.add(tutorial);
        }
      }
      
      if (kDebugMode) {
        print('📚 Remaining tutorials for $userLevel: ${remainingTutorials.length}');
        for (var tutorial in remainingTutorials) {
          print('  - ${tutorial['title']}');
        }
      }
      
      return remainingTutorials;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting remaining tutorials: $e');
      }
      return [];
    }
  }

  // Get personalized tutorials for user
  static Future<List<Map<String, dynamic>>> getPersonalizedTutorials() async {
    try {
      final userLevel = await QuizService.getUserLevel();
      final progress = await getLearningProgress();
      final completedTutorials =
          progress['completed_tutorials'] as List<dynamic>;

      if (kDebugMode) {
        print('🎯 Getting tutorials for user level: $userLevel');
        print('🎯 Completed tutorials: ${completedTutorials.length}');
      }

      List<Map<String, dynamic>> availableTutorials = [];

      // Get tutorials for current level and below
      for (String level in ['novice', 'intermediate', 'advanced', 'expert']) {
        if (_isLevelAccessible(level, userLevel)) {
          final levelTutorials = _tutorials[level] ?? [];
          if (kDebugMode) {
            print('✅ Level $level accessible: ${levelTutorials.length} tutorials available');
          }
          for (var tutorial in levelTutorials) {
            if (!completedTutorials.contains(tutorial['id']) &&
                _arePrerequisitesMet(
                    tutorial['prerequisites'], completedTutorials)) {
              availableTutorials.add(tutorial);
              if (kDebugMode) {
                print('  ➕ Added tutorial: ${tutorial['title']} (Level: ${tutorial['difficulty']})');
              }
            }
          }
        } else {
          if (kDebugMode) {
            print('❌ Level $level NOT accessible for user level $userLevel');
          }
        }
      }

      if (kDebugMode) {
        print('🎯 Total available tutorials: ${availableTutorials.length}');
      }

      return availableTutorials;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting tutorials: $e');
      }
      // Return default novice tutorials if Firebase fails
      return _tutorials['novice'] ?? [];
    }
  }

  // Check if level is accessible based on user's current level
  static bool _isLevelAccessible(String level, String userLevel) {
    final levelOrder = ['novice', 'intermediate', 'advanced', 'expert'];
    final userIndex = levelOrder.indexOf(userLevel);
    final levelIndex = levelOrder.indexOf(level);
    
    if (kDebugMode) {
      print('  🔍 Checking level access: $level (index $levelIndex) for user $userLevel (index $userIndex)');
    }
    
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
      progress['total_time_spent'] =
          (progress['total_time_spent'] ?? 0) + timeSpent;

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

      // NOTE: Level advancement should only happen through quiz completion, not tutorial completion
      // Removed automatic level up check to prevent conflicts with quiz-based progression

      // Update leaderboard entry with new score
      await updateLeaderboardEntry();

      return TutorialCompletionResult(
        tutorialId: tutorialId,
        score: score,
        badgeEarned: badge != null && score >= 70 ? badge : null,
        levelUp: false, // Level advancement only through quiz completion
        newLevel: null,
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


  // Get learning progress
  static Future<Map<String, dynamic>> getLearningProgress() async {
    try {
      final progress = await FirebaseDataService.getJson('learning_progress');
      return progress ??
          {
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
      final completedTutorials =
          (progress['completed_tutorials'] as List).length;
      final userScore = (completedTutorials * 100) +
          (badges.length * 50) +
          (progress['current_streak'] ?? 0) * 10;

      // Get user profile data
      final userProfile = await FirebaseDataService.getData('profile', 'info');
      final userName =
          userProfile?['name'] ?? userProfile?['full_name'] ?? 'Anonymous';

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
        print(
            '✅ Leaderboard entry updated for user: $userName (Score: $userScore)');
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
      if (userId != null &&
          !leaderboard.any((user) => user['is_current_user'])) {
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
          leaderboard
              .sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
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

            leaderboard.sort(
                (a, b) => (b['score'] as int).compareTo(a['score'] as int));
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
    final tutorialProgress =
        learningProgress['tutorial_progress'] as Map<String, dynamic>? ?? {};

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
        final daysSinceLastCompletion =
            now.difference(lastCompletionDate).inDays;

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
