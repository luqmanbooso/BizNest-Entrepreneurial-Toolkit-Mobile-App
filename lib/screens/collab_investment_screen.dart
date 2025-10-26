import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/modern_theme.dart';

/// CollabInvestmentScreen provides a platform for entrepreneurs to create funding goals
/// with reward systems and for investors to contribute with Firebase Authentication integration.
///
/// Features:
/// - Firebase Auth integration for user authentication
/// - Reward system for qualifying investors
/// - Real-time goal tracking with Firestore
/// - Investment eligibility validation
/// - Modern UI with progress indicators and badges
class CollabInvestmentScreen extends StatefulWidget {
  const CollabInvestmentScreen({super.key});

  @override
  State<CollabInvestmentScreen> createState() => _CollabInvestmentScreenState();
}

class _CollabInvestmentScreenState extends State<CollabInvestmentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadGoals();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Loads all investment goals from Firestore
  /// Listens for real-time updates to keep the UI synchronized
  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    try {
      // Listen to real-time updates from Firestore
      _firestore.collection('goals').snapshots().listen((snapshot) {
        final goals = snapshot.docs.map((doc) {
          final data = doc.data();
          data['goalId'] = doc.id;
          return data;
        }).toList();

        // Sort goals by creation date (newest first)
        goals.sort((a, b) {
          final aTimestamp = a['createdAt'] as Timestamp?;
          final bTimestamp = b['createdAt'] as Timestamp?;
          if (aTimestamp == null || bTimestamp == null) return 0;
          return bTimestamp.compareTo(aTimestamp);
        });

        if (mounted) {
          setState(() {
            _goals = goals;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error loading goals: ${e.toString()}', isError: true);
      }
    }
  }

  /// Shows a snackbar with success or error styling
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade600 : ModernTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Collaborative Investment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: ModernTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'All Goals'),
            Tab(text: 'Create Goal'),
            Tab(text: 'My Goals'),
            Tab(text: 'My Investments'),
            Tab(text: 'Loans'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllGoalsTab(),
            _buildCreateGoalTab(),
            _buildMyGoalsTab(),
            _buildMyInvestmentsTab(),
            _buildLoansTab(),
          ],
        ),
      ),
    );
  }

  /// Tab 1: Display all available investment goals with rewards
  Widget _buildAllGoalsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
        ),
      );
    }

    if (_goals.isEmpty) {
      return _buildEmptyState(
        'No Investment Goals Yet',
        'Be the first to create a funding goal with rewards for investors!',
        Icons.trending_up,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGoals,
      color: ModernTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return _buildGoalCard(goal);
        },
      ),
    );
  }

  /// Builds individual goal card with reward information and progress
  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final targetAmount = (goal['targetAmount'] ?? 0).toDouble();
    final raisedAmount = (goal['raisedAmount'] ?? 0).toDouble();
    final progress = targetAmount > 0 ? raisedAmount / targetAmount : 0.0;
    final isCompleted = progress >= 1.0;

    // Deadline handling
    final deadline = goal['deadline'] as Timestamp?;
    final daysLeft = deadline?.toDate().difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with creator info and status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [
                        ModernTheme.primaryColor,
                        ModernTheme.primaryColor.withOpacity(0.8)
                      ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        goal['title'] ?? 'Untitled Goal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCompleted ? 'FUNDED' : 'ACTIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${goal['creatorName'] ?? 'Anonymous'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Goal content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  goal['description'] ?? 'No description provided',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Progress section
                _buildProgressSection(targetAmount, raisedAmount, progress),
                const SizedBox(height: 16),

                // Reward information
                _buildRewardSection(goal),
                const SizedBox(height: 16),

                // Time and action buttons
                Row(
                  children: [
                    if (daysLeft != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: daysLeft > 0
                            ? ModernTheme.primaryColor
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysLeft > 0 ? '$daysLeft days left' : 'Expired',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysLeft > 0
                              ? ModernTheme.primaryColor
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                    ],
                    if (!isCompleted && (daysLeft == null || daysLeft > 0))
                      ElevatedButton(
                        onPressed: () => _showInvestDialog(goal),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ModernTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Invest Now',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the progress section showing funding progress
  Widget _buildProgressSection(
      double targetAmount, double raisedAmount, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernTheme.primaryColor,
                    ModernTheme.primaryColor.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Amount info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${raisedAmount.toStringAsFixed(0)} raised',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
            Text(
              'of \$${targetAmount.toStringAsFixed(0)} goal',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the reward information section
  Widget _buildRewardSection(Map<String, dynamic> goal) {
    final rewardTitle = goal['rewardTitle'];
    final rewardDescription = goal['rewardDescription'];
    final rewardMinAmount = (goal['rewardMinAmount'] ?? 0).toDouble();

    if (rewardTitle == null || rewardTitle.toString().isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF64748B), size: 16),
            SizedBox(width: 8),
            Text(
              'No reward offered for this goal',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard,
                  color: Colors.orange.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rewardTitle.toString(),
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (rewardDescription != null &&
              rewardDescription.toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              rewardDescription.toString(),
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Minimum investment: \$${rewardMinAmount.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows investment dialog for contributing to a goal
  void _showInvestDialog(Map<String, dynamic> goal) {
    final user = _auth.currentUser;
    if (user == null) {
      _showSnackBar('Please log in to invest', isError: true);
      return;
    }

    final targetAmount = (goal['targetAmount'] ?? 0).toDouble();
    final raisedAmount = (goal['raisedAmount'] ?? 0).toDouble();
    final remainingAmount = targetAmount - raisedAmount;

    if (remainingAmount <= 0) {
      _showSnackBar('This goal is already fully funded', isError: true);
      return;
    }

    final amountController = TextEditingController();
    final messageController = TextEditingController();
    final rewardMinAmount = (goal['rewardMinAmount'] ?? 0).toDouble();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Invest in "${goal['title']}"',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remaining amount needed: \$${remainingAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: ModernTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Investment amount field
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Investment Amount (\$)',
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),

              // Reward eligibility info
              if (rewardMinAmount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Invest \$${rewardMinAmount.toStringAsFixed(0)}+ to qualify for the reward',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Optional message
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message (Optional)',
                  hintText: 'Leave a message for the creator',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _processInvestment(
              goal,
              amountController.text,
              messageController.text,
              remainingAmount,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Invest'),
          ),
        ],
      ),
    );
  }

  /// Processes the investment and updates Firestore
  /// Automatically calculates reward eligibility based on investment amount
  Future<void> _processInvestment(
    Map<String, dynamic> goal,
    String amountText,
    String message,
    double remainingAmount,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pop(context);
      _showSnackBar('Authentication required', isError: true);
      return;
    }

    if (amountText.isEmpty) {
      _showSnackBar('Please enter an investment amount', isError: true);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    if (amount > remainingAmount) {
      _showSnackBar(
        'Investment amount cannot exceed remaining target (\$${remainingAmount.toStringAsFixed(0)})',
        isError: true,
      );
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final goalId = goal['goalId'];
      final rewardMinAmount = (goal['rewardMinAmount'] ?? 0).toDouble();

      // Check if user qualifies for reward
      final rewardEligible = rewardMinAmount > 0 && amount >= rewardMinAmount;

      // Create investor data with Firebase Auth details
      final investorData = {
        'investorId': user.uid,
        'investorName': user.displayName ?? user.email ?? 'Anonymous',
        'amount': amount,
        'message': message.trim(),
        'rewardEligible': rewardEligible,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Update goal with new investment
      await _firestore.collection('goals').doc(goalId).update({
        'raisedAmount': FieldValue.increment(amount),
        'investors': FieldValue.arrayUnion([investorData]),
      });

      _showSnackBar(
        rewardEligible
            ? 'Investment successful! You qualify for the reward.'
            : 'Investment successful! Thank you for your support.',
      );
    } catch (e) {
      _showSnackBar('Error processing investment: ${e.toString()}',
          isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tab 2: Create new investment goal with reward system
  Widget _buildCreateGoalTab() {
    return _CreateGoalForm(
      onGoalCreated: () {
        _showSnackBar('Goal created successfully!');
        _tabController.animateTo(0); // Switch to All Goals tab
      },
      onError: (error) => _showSnackBar(error, isError: true),
    );
  }

  /// Tab 3: Show entrepreneur's own goals with management options
  Widget _buildMyGoalsTab() {
    final user = _auth.currentUser;
    if (user == null) {
      return _buildEmptyState(
        'Authentication Required',
        'Please log in to view and manage your goals.',
        Icons.login,
      );
    }

    return _MyGoalsView(
      userId: user.uid,
      onGoalDeleted: () => _showSnackBar('Goal deleted successfully!'),
      onError: (error) => _showSnackBar(error, isError: true),
    );
  }

  /// Tab 4: Show user's investments and reward status
  Widget _buildMyInvestmentsTab() {
    final user = _auth.currentUser;
    if (user == null) {
      return _buildEmptyState(
        'Authentication Required',
        'Please log in to view your investments and rewards.',
        Icons.login,
      );
    }

    return _MyInvestmentsView(userId: user.uid);
  }

  /// Tab 5: Display business loan offers
  Widget _buildLoansTab() {
    final List<_LoanOffer> loanOffers = [
      _LoanOffer(
        bankName: 'FirstBank Business',
        loanType: 'Small Business Loan',
        minAmount: 5000,
        maxAmount: 100000,
        interestRate: 6.5,
        tenure: '1-5 years',
        features: [
          'Quick approval',
          'No collateral required',
          'Flexible repayment'
        ],
        logoIcon: Icons.account_balance,
        color: ModernTheme.primaryColor,
      ),
      _LoanOffer(
        bankName: 'Capital Growth Bank',
        loanType: 'Startup Financing',
        minAmount: 10000,
        maxAmount: 250000,
        interestRate: 7.2,
        tenure: '2-7 years',
        features: ['Startup friendly', 'Business consultation', 'Grace period'],
        logoIcon: Icons.trending_up,
        color: const Color(0xFF10B981),
      ),
      _LoanOffer(
        bankName: 'Enterprise Credit Union',
        loanType: 'Equipment Financing',
        minAmount: 15000,
        maxAmount: 500000,
        interestRate: 5.8,
        tenure: '3-10 years',
        features: ['Asset-backed', 'Tax benefits', 'Low interest'],
        logoIcon: Icons.precision_manufacturing,
        color: const Color(0xFF8B5CF6),
      ),
      _LoanOffer(
        bankName: 'MicroFinance Plus',
        loanType: 'Micro Business Loan',
        minAmount: 1000,
        maxAmount: 25000,
        interestRate: 8.5,
        tenure: '6 months-3 years',
        features: [
          'Fast processing',
          'Minimal documentation',
          'For micro enterprises'
        ],
        logoIcon: Icons.payments,
        color: const Color(0xFF14B8A6),
      ),
      _LoanOffer(
        bankName: 'Commercial Trust Bank',
        loanType: 'Working Capital Loan',
        minAmount: 20000,
        maxAmount: 300000,
        interestRate: 6.9,
        tenure: '1-5 years',
        features: [
          'Cash flow management',
          'Revolving credit',
          'Seasonal support'
        ],
        logoIcon: Icons.sync_alt,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return Column(
      children: [
        // Header Info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF14B8A6),
                Color(0xFF0D9488),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B8A6).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pre-Approved Loans',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Apply directly to partner banks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Loan Offers List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: loanOffers.length,
            itemBuilder: (context, index) {
              return _buildLoanCard(loanOffers[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Builds individual loan card
  Widget _buildLoanCard(_LoanOffer loan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: loan.color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLoanApplication(loan),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: loan.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        loan.logoIcon,
                        color: loan.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.bankName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            loan.loanType,
                            style: TextStyle(
                              fontSize: 14,
                              color: loan.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: loan.color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount Range',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${loan.minAmount.toStringAsFixed(0)} - \$${loan.maxAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interest Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${loan.interestRate}% p.a.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: loan.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Tenure: ${loan.tenure}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: loan.features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: loan.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 11,
                          color: loan.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Opens loan application dialog
  void _openLoanApplication(_LoanOffer loan) {
    showDialog(
      context: context,
      builder: (context) => _LoanApplicationDialog(loan: loan),
    );
  }

  /// Builds empty state widget with icon and message
  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Form widget for creating new investment goals with rewards
class _CreateGoalForm extends StatefulWidget {
  final VoidCallback onGoalCreated;
  final Function(String) onError;

  const _CreateGoalForm({
    required this.onGoalCreated,
    required this.onError,
  });

  @override
  State<_CreateGoalForm> createState() => _CreateGoalFormState();
}

class _CreateGoalFormState extends State<_CreateGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _rewardTitleController = TextEditingController();
  final _rewardDescriptionController = TextEditingController();
  final _rewardMinAmountController = TextEditingController();
  final _rewardDeliveryController = TextEditingController();

  DateTime? _selectedDeadline;
  String _selectedCategory = 'Technology';
  bool _isLoading = false;

  final List<String> _categories = [
    'Technology',
    'Health & Wellness',
    'Education',
    'Environment',
    'Arts & Culture',
    'Social Impact',
    'Business & Finance',
    'Food & Beverage',
    'Sports & Recreation',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _rewardTitleController.dispose();
    _rewardDescriptionController.dispose();
    _rewardMinAmountController.dispose();
    _rewardDeliveryController.dispose();
    super.dispose();
  }

  /// Creates a new goal with Firebase Auth user details and reward system
  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      widget.onError('Please log in to create a goal');
      return;
    }

    if (_selectedDeadline == null) {
      widget.onError('Please select a deadline');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validate and parse amounts
      final targetAmount = double.parse(_targetAmountController.text);
      final rewardMinAmount = _rewardMinAmountController.text.isNotEmpty
          ? double.parse(_rewardMinAmountController.text)
          : 0.0;

      // Validate reward min amount doesn't exceed target
      if (rewardMinAmount > targetAmount) {
        widget.onError('Reward minimum amount cannot exceed target amount');
        setState(() => _isLoading = false);
        return;
      }

      // Create goal data with Firebase Auth integration
      final goalData = {
        'creatorId': user.uid, // Firebase Auth UID
        'creatorName':
            user.displayName ?? user.email ?? 'Anonymous', // Firebase Auth name
        'creatorEmail': user.email ?? '', // Firebase Auth email
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'targetAmount': targetAmount,
        'raisedAmount': 0.0,
        'deadline': Timestamp.fromDate(_selectedDeadline!),
        'category': _selectedCategory,
        'rewardTitle': _rewardTitleController.text.trim(),
        'rewardDescription': _rewardDescriptionController.text.trim(),
        'rewardMinAmount': rewardMinAmount,
        'rewardDelivery': _rewardDeliveryController.text.trim(),
        'investors': [], // Array to store investor data
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      await FirebaseFirestore.instance.collection('goals').add(goalData);

      // Reset form
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _targetAmountController.clear();
      _rewardTitleController.clear();
      _rewardDescriptionController.clear();
      _rewardMinAmountController.clear();
      _rewardDeliveryController.clear();
      _selectedDeadline = null;
      _selectedCategory = 'Technology';

      widget.onGoalCreated();
    } catch (e) {
      widget.onError('Error creating goal: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernTheme.primaryColor,
                    ModernTheme.primaryColor.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Investment Goal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Set up your funding goal with rewards to attract investors',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basic Goal Information
            _buildSectionHeader('Goal Information'),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _titleController,
              label: 'Goal Title',
              hint: 'Enter a compelling title for your goal',
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please enter a title';
                }
                if (value!.length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your project and why people should invest',
              maxLines: 4,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please enter a description';
                }
                if (value!.length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _targetAmountController,
                    label: 'Target Amount (\$)',
                    hint: '10000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final amount = double.tryParse(value!);
                      if (amount == null || amount <= 0) {
                        return 'Enter valid amount';
                      }
                      if (amount < 100) {
                        return 'Minimum \$100';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCategoryDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildDeadlinePicker(),
            const SizedBox(height: 32),

            // Reward System Section
            _buildSectionHeader('Reward System'),
            const SizedBox(height: 8),
            Text(
              'Define rewards to incentivize investors',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _rewardTitleController,
              label: 'Reward Title',
              hint: 'e.g., "Free product sample", "Equity share"',
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please enter a reward title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _rewardDescriptionController,
              label: 'Reward Description',
              hint: 'Describe what investors will receive',
              maxLines: 3,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please describe the reward';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _rewardMinAmountController,
                    label: 'Minimum Investment (\$)',
                    hint: '100',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final amount = double.tryParse(value!);
                      if (amount == null || amount <= 0) {
                        return 'Enter valid amount';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _rewardDeliveryController,
                    label: 'Delivery Info (Optional)',
                    hint: 'e.g., "Within 30 days"',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Goal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: ModernTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildDeadlinePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: ModernTheme.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _selectedDeadline = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: ModernTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDeadline != null
                  ? 'Deadline: ${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                  : 'Select Deadline',
              style: TextStyle(
                fontSize: 16,
                color: _selectedDeadline != null
                    ? Colors.black87
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display user's investments and reward eligibility
class _MyInvestmentsView extends StatelessWidget {
  final String userId;

  const _MyInvestmentsView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('goals')
          .where('investors', arrayContains: {
        'investorId': userId,
      }).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final goals = snapshot.data?.docs ?? [];

        if (goals.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Investments Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start investing in goals to see your portfolio here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goalData = goals[index].data() as Map<String, dynamic>;
            final investors = goalData['investors'] as List<dynamic>? ?? [];

            // Find user's investment
            final userInvestment = investors.firstWhere(
              (inv) => inv['investorId'] == userId,
              orElse: () => null,
            );

            if (userInvestment == null) return const SizedBox.shrink();

            return _buildInvestmentCard(goalData, userInvestment);
          },
        );
      },
    );
  }

  Widget _buildInvestmentCard(
      Map<String, dynamic> goal, Map<String, dynamic> investment) {
    final targetAmount = (goal['targetAmount'] ?? 0).toDouble();
    final raisedAmount = (goal['raisedAmount'] ?? 0).toDouble();
    final progress = targetAmount > 0 ? raisedAmount / targetAmount : 0.0;
    final isCompleted = progress >= 1.0;
    final rewardEligible = investment['rewardEligible'] == true;
    final investmentAmount = (investment['amount'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    goal['title'] ?? 'Untitled Goal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rewardEligible ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rewardEligible ? 'Reward Eligible' : 'No Reward',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Investment details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: ModernTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Investment: \$${investmentAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? Colors.green : ModernTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${raisedAmount.toStringAsFixed(0)} of \$${targetAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                // Reward info
                if (rewardEligible && goal['rewardTitle'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: Colors.green.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reward: ${goal['rewardTitle']}',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (goal['rewardDescription'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal['rewardDescription'],
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Claim Reward',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Message if provided
                if (investment['message'] != null &&
                    investment['message'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Message:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          investment['message'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display and manage entrepreneur's own goals
class _MyGoalsView extends StatelessWidget {
  final String userId;
  final VoidCallback onGoalDeleted;
  final Function(String) onError;

  const _MyGoalsView({
    required this.userId,
    required this.onGoalDeleted,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('goals')
          .where('creatorId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading your goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final goals = snapshot.data?.docs ?? [];

        // Sort goals by createdAt in descending order (newest first)
        goals.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;

          final aCreatedAt = aData['createdAt'] as Timestamp?;
          final bCreatedAt = bData['createdAt'] as Timestamp?;

          // Handle null values - put them at the end
          if (aCreatedAt == null && bCreatedAt == null) return 0;
          if (aCreatedAt == null) return 1;
          if (bCreatedAt == null) return -1;

          // Sort in descending order (newest first)
          return bCreatedAt.compareTo(aCreatedAt);
        });

        if (goals.isEmpty) {
          return _buildEmptyGoalsState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh is handled automatically by the StreamBuilder
          },
          color: ModernTheme.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goalData = goals[index].data() as Map<String, dynamic>;
              final goalId = goals[index].id;
              goalData['goalId'] = goalId;

              return _buildMyGoalCard(context, goalData);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyGoalsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Goals Created Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start by creating your first funding goal with rewards to attract investors.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Switch to Create Goal tab (index 1)
                DefaultTabController.of(context).animateTo(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Create Your First Goal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGoalCard(BuildContext context, Map<String, dynamic> goal) {
    final targetAmount = (goal['targetAmount'] ?? 0).toDouble();
    final raisedAmount = (goal['raisedAmount'] ?? 0).toDouble();
    final progress = targetAmount > 0 ? raisedAmount / targetAmount : 0.0;
    final isCompleted = progress >= 1.0;
    final investors = goal['investors'] as List<dynamic>? ?? [];

    // Deadline handling
    final deadline = goal['deadline'] as Timestamp?;
    final daysLeft = deadline?.toDate().difference(DateTime.now()).inDays;
    final isExpired = daysLeft != null && daysLeft <= 0 && !isCompleted;

    // Goal status
    String statusText;
    if (isCompleted) {
      statusText = 'COMPLETED';
    } else if (isExpired) {
      statusText = 'EXPIRED';
    } else {
      statusText = 'ACTIVE';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with goal info and actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : isExpired
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : [
                            ModernTheme.primaryColor,
                            ModernTheme.primaryColor.withOpacity(0.8)
                          ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal['title'] ?? 'Untitled Goal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (action) {
                        if (action == 'delete') {
                          _showDeleteConfirmation(context, goal);
                        } else if (action == 'view_investors') {
                          _showInvestorsDialog(context, goal);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view_investors',
                          child: Row(
                            children: [
                              Icon(Icons.people, size: 18),
                              SizedBox(width: 8),
                              Text('View Investors'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Goal',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Created ${_getTimeAgo(goal['createdAt'] as Timestamp?)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Goal content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  goal['description'] ?? 'No description provided',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Progress section
                _buildProgressSection(targetAmount, raisedAmount, progress),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    _buildStatItem(
                      Icons.people,
                      '${investors.length}',
                      'Investors',
                      ModernTheme.primaryColor,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      Icons.category,
                      goal['category'] ?? 'General',
                      'Category',
                      Colors.orange.shade600,
                    ),
                    const Spacer(),
                    if (daysLeft != null)
                      _buildStatItem(
                        Icons.schedule,
                        isExpired ? 'Expired' : '$daysLeft days',
                        isExpired ? '' : 'remaining',
                        isExpired ? Colors.red.shade600 : Colors.blue.shade600,
                      ),
                  ],
                ),

                // Reward info if available
                if (goal['rewardTitle'] != null &&
                    goal['rewardTitle'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildRewardInfo(goal),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
      double targetAmount, double raisedAmount, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Funding Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernTheme.primaryColor,
                    ModernTheme.primaryColor.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Amount info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${raisedAmount.toStringAsFixed(0)} raised',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
            Text(
              'of \$${targetAmount.toStringAsFixed(0)} goal',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardInfo(Map<String, dynamic> goal) {
    final rewardMinAmount = (goal['rewardMinAmount'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard,
                  color: Colors.orange.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reward: ${goal['rewardTitle']}',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (goal['rewardDescription'] != null &&
              goal['rewardDescription'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              goal['rewardDescription'].toString(),
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Minimum investment: \$${rewardMinAmount.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'recently';

    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> goal) {
    final hasInvestors = (goal['investors'] as List<dynamic>? ?? []).isNotEmpty;
    final raisedAmount = (goal['raisedAmount'] ?? 0).toDouble();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Goal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${goal['title']}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (hasInvestors) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This goal has investors and \$${raisedAmount.toStringAsFixed(0)} raised. Deleting will remove all investment records.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGoal(context, goal['goalId']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInvestorsDialog(BuildContext context, Map<String, dynamic> goal) {
    final investors = goal['investors'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Investors (${investors.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: investors.isEmpty
              ? const Center(
                  child: Text(
                    'No investors yet',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                )
              : ListView.builder(
                  itemCount: investors.length,
                  itemBuilder: (context, index) {
                    final investor = investors[index];
                    final amount = (investor['amount'] ?? 0).toDouble();
                    final isRewardEligible = investor['rewardEligible'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  investor['investorName'] ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isRewardEligible
                                      ? Colors.green
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isRewardEligible
                                      ? 'Reward Eligible'
                                      : 'No Reward',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Invested: \$${amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: ModernTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          if (investor['message'] != null &&
                              investor['message'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              investor['message'].toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(BuildContext context, String goalId) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(goalId).delete();
      onGoalDeleted();
    } catch (e) {
      onError('Error deleting goal: ${e.toString()}');
    }
  }
}

/// Loan Offer Model
class _LoanOffer {
  final String bankName;
  final String loanType;
  final double minAmount;
  final double maxAmount;
  final double interestRate;
  final String tenure;
  final List<String> features;
  final IconData logoIcon;
  final Color color;

  _LoanOffer({
    required this.bankName,
    required this.loanType,
    required this.minAmount,
    required this.maxAmount,
    required this.interestRate,
    required this.tenure,
    required this.features,
    required this.logoIcon,
    required this.color,
  });
}

/// Loan Application Dialog
class _LoanApplicationDialog extends StatefulWidget {
  final _LoanOffer loan;

  const _LoanApplicationDialog({required this.loan});

  @override
  State<_LoanApplicationDialog> createState() => _LoanApplicationDialogState();
}

class _LoanApplicationDialogState extends State<_LoanApplicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _applicantNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _purposeController = TextEditingController();

  String _selectedTenure = '1 year';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _applicantNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _loanAmountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.loan.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.loan.logoIcon,
                    color: widget.loan.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for Loan',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        widget.loan.bankName,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.loan.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter business name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _applicantNameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _loanAmountController,
                      decoration: InputDecoration(
                        labelText:
                            'Loan Amount (\$${widget.loan.minAmount.toStringAsFixed(0)} - \$${widget.loan.maxAmount.toStringAsFixed(0)})',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter loan amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Please enter valid amount';
                        }
                        if (amount < widget.loan.minAmount ||
                            amount > widget.loan.maxAmount) {
                          return 'Amount must be between \$${widget.loan.minAmount.toStringAsFixed(0)} and \$${widget.loan.maxAmount.toStringAsFixed(0)}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Loan Purpose',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter loan purpose';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.loan.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Application',
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
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Save loan application to Firestore
      await FirebaseFirestore.instance.collection('loan_applications').add({
        'userId': user.uid,
        'userEmail': user.email,
        'businessName': _businessNameController.text.trim(),
        'applicantName': _applicantNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'loanAmount': double.parse(_loanAmountController.text),
        'purpose': _purposeController.text.trim(),
        'bankName': widget.loan.bankName,
        'loanType': widget.loan.loanType,
        'interestRate': widget.loan.interestRate,
        'tenure': widget.loan.tenure,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Application Submitted!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your loan application has been successfully submitted to:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.loan.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(widget.loan.logoIcon, color: widget.loan.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.loan.bankName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.loan.loanType,
                            style: TextStyle(
                              color: widget.loan.color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pending_actions,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Status: Pending Review',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The bank will contact you within 2-3 business days.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Text('Submission Failed'),
            ],
          ),
          content: Text(
            'Failed to submit your application. Please try again.\n\nError: $e',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
