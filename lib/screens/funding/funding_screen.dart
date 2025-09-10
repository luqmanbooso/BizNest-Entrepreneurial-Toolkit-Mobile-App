import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';

class FundingScreen extends StatefulWidget {
  const FundingScreen({super.key});

  @override
  _FundingScreenState createState() => _FundingScreenState();
}

class _FundingScreenState extends State<FundingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Funding Resources'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Funding Types'),
            Tab(text: 'Investors'),
            Tab(text: 'Applications'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.warningColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFundingTypesTab(),
            _buildInvestorsTab(),
            _buildApplicationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingTypesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: const Text(
              'Explore Funding Options',
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
              'Find the right funding source for your business',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildFundingCard(
              'Venture Capital',
              'High-growth potential startups',
              '\$1M - \$50M+',
              'Equity-based funding for scalable businesses',
              Icons.trending_up,
              AppTheme.primaryColor,
              ['Tech startups', 'Scalable business model', 'Strong team'],
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildFundingCard(
              'Angel Investment',
              'Early-stage startups',
              '\$25K - \$1M',
              'Individual investors providing capital and mentorship',
              Icons.person,
              AppTheme.accentColor,
              ['Prototype ready', 'Market validation', 'Growth potential'],
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: _buildFundingCard(
              'Crowdfunding',
              'Consumer-focused products',
              '\$10K - \$500K',
              'Raise money from a large number of people online',
              Icons.group,
              AppTheme.successColor,
              ['Product ready', 'Strong marketing', 'Community appeal'],
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: _buildFundingCard(
              'Bank Loans',
              'Established businesses',
              '\$50K - \$5M',
              'Traditional debt financing with fixed terms',
              Icons.account_balance,
              AppTheme.warningColor,
              ['Good credit score', 'Collateral', 'Steady revenue'],
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1200),
            child: _buildFundingCard(
              'Government Grants',
              'Research & innovation',
              '\$5K - \$500K',
              'Non-repayable funding for qualifying projects',
              Icons.account_balance_wallet,
              AppTheme.secondaryColor,
              ['Research focus', 'Innovation', 'Social impact'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingCard(
    String title,
    String subtitle,
    String amount,
    String description,
    IconData icon,
    Color color,
    List<String> requirements,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
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
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 15),
          const Text(
            'Requirements:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: requirements.map((req) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  req,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showFundingDetails(title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Learn More',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FadeInDown(child: _buildInvestorMatchSection()),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildInvestorCard(
              'TechVentures Capital',
              'Series A & B Technology Investments',
              '\$1M - \$10M',
              'SaaS, AI, Fintech',
              'San Francisco, CA',
              4.8,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildInvestorCard(
              'Innovation Angels',
              'Early-stage angel investment group',
              '\$50K - \$500K',
              'Healthcare, EdTech, CleanTech',
              'New York, NY',
              4.6,
              AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 15),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildInvestorCard(
              'Growth Partners Fund',
              'Late-stage growth capital',
              '\$5M - \$50M',
              'E-commerce, Marketplace, SaaS',
              'Austin, TX',
              4.7,
              AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: _buildNetworkingEvents(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorMatchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Your Perfect Investor Match',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Answer a few questions to get matched with investors who are interested in your industry and stage.',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _startInvestorMatching();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Matching Process',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorCard(
    String name,
    String description,
    String investmentRange,
    String focus,
    String location,
    double rating,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.business, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInvestorDetailRow(
            'Investment Range',
            investmentRange,
            Icons.attach_money,
          ),
          _buildInvestorDetailRow('Focus Areas', focus, Icons.category),
          _buildInvestorDetailRow('Location', location, Icons.location_on),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View investor profile
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('View Profile', style: TextStyle(color: color)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _connectWithInvestor(name);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkingEvents() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Investor Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          _buildEventItem(
            'Tech Startup Pitch Night',
            'March 15, 2024',
            'San Francisco, CA',
            'Network with 50+ investors',
            AppTheme.primaryColor,
          ),
          _buildEventItem(
            'Angel Investor Meetup',
            'March 22, 2024',
            'New York, NY',
            'Early-stage funding opportunities',
            AppTheme.accentColor,
          ),
          _buildEventItem(
            'VC Demo Day',
            'April 5, 2024',
            'Austin, TX',
            'Present to top VCs',
            AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(
    String title,
    String date,
    String location,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.event, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$date • $location',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Register for event
            },
            child: Text(
              'Register',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FadeInDown(child: _buildApplicationsHeader()),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildApplicationCard(
              'TechVentures Capital',
              'Series A Application',
              'In Review',
              'Submitted 5 days ago',
              AppTheme.warningColor,
              0.6,
            ),
          ),
          const SizedBox(height: 15),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildApplicationCard(
              'Innovation Angels',
              'Angel Investment',
              'Interview Scheduled',
              'Next step: March 20',
              AppTheme.accentColor,
              0.8,
            ),
          ),
          const SizedBox(height: 15),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildApplicationCard(
              'Small Business Grant',
              'Government Grant',
              'Approved',
              'Funding received',
              AppTheme.successColor,
              1.0,
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: _buildNewApplicationSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor, AppTheme.successColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Applications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Track your funding applications and progress',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildApplicationStat('Active', '3'),
              const SizedBox(width: 30),
              _buildApplicationStat('Approved', '1'),
              const SizedBox(width: 30),
              _buildApplicationStat('Total Applied', '\$2.5M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(
    String investorName,
    String applicationType,
    String status,
    String lastUpdate,
    Color statusColor,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      applicationType,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            lastUpdate,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View application details
                  },
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Take action
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: statusColor),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewApplicationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start New Application',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Ready to apply for funding? Choose from our curated list of investors and grant opportunities.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _startNewApplication();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Browse Opportunities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFundingDetails(String fundingType) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$fundingType Details',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Here you would see detailed information about this funding type, including requirements, process, timeline, and tips for success.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startInvestorMatching() {
    Get.snackbar(
      'Investor Matching',
      'Starting the investor matching process...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _connectWithInvestor(String investorName) {
    Get.snackbar(
      'Connection Request',
      'Connection request sent to $investorName',
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _startNewApplication() {
    Get.snackbar(
      'New Application',
      'Opening funding opportunities...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }
}
