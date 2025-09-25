import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/auth_service.dart';
import 'create_thread_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardAnimation;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _replyController = TextEditingController();

  String _selectedCategory = 'All';
  int _unreadNotifications = 0;
  Map<String, bool> _threadSubscriptions = {}; // Cache for subscription status

  final List<String> _categories = [
    'All',
    'General',
    'Business Ideas',
    'Funding',
    'Marketing',
    'Technology',
    'Legal',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    if (AuthService.isAuthenticated) {
      _firestore
          .collection('notifications')
          .where('userId', isEqualTo: AuthService.currentUser!['id'])
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
            if (mounted) {
              setState(() {
                _unreadNotifications = snapshot.docs.length;
              });
            }
          });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernTheme.primaryBlue,
              ModernTheme.teal,
            ],
          ),
        ),
        child: SafeArea(
          
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_slideAnimation),
                    child: Transform.translate(
                      offset: const Offset(0, -40),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AuthService.isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateThreadScreen(),
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: ModernTheme.primaryBlue,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Thread'),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 1, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Row(
                children: [
                  if (AuthService.isAuthenticated)
                    Stack(
                      children: [
                        IconButton(
                          onPressed: _showNotifications,
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        if (_unreadNotifications > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _unreadNotifications > 99 ? '99+' : _unreadNotifications.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Community Forum',
            style: ModernTheme.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discuss, share, and learn together',
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _buildThreadsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ModernTheme.primaryBlue
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? ModernTheme.primaryBlue
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    category,
                    style: ModernTheme.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildThreadsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('threads')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading threads: ${snapshot.error}',
                  style: ModernTheme.bodyMedium.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allThreads = snapshot.data?.docs ?? [];
        final threads = _selectedCategory == 'All'
            ? allThreads
            : allThreads.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['category'] == _selectedCategory;
              }).toList();

        // Load subscriptions for visible threads
        if (AuthService.isAuthenticated && threads.isNotEmpty) {
          final forumThreads = threads.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ForumThread.fromMap(data, doc.id);
          }).toList();
          _loadSubscriptionsForThreads(forumThreads);
        }

        if (threads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 64,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No threads yet',
                  style: ModernTheme.headingMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to start a discussion!',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: threads.length,
          itemBuilder: (context, index) {
            final threadData = threads[index].data() as Map<String, dynamic>;
            final thread = ForumThread.fromMap(threadData, threads[index].id);

            // Set subscription status from cache
            if (AuthService.isAuthenticated) {
              thread.isSubscribed = _threadSubscriptions[thread.id] ?? false;
            }

            return AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardAnimation.value,
                  child: _buildThreadCard(thread),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildThreadCard(ForumThread thread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: InkWell(
            onTap: () => _showThreadDetails(thread),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: thread.authorAvatar.isNotEmpty
                            ? NetworkImage(thread.authorAvatar)
                            : null,
                        child: thread.authorAvatar.isEmpty
                            ? Text(
                                thread.authorName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              thread.authorName,
                              style: ModernTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatTimestamp(thread.createdAt),
                              style: ModernTheme.bodySmall.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(thread.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          thread.category,
                          style: ModernTheme.bodySmall.copyWith(
                            color: _getCategoryColor(thread.category),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    thread.title,
                    style: ModernTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    thread.content.length > 200
                        ? '${thread.content.substring(0, 200)}...'
                        : thread.content,
                    style: ModernTheme.bodyMedium.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${thread.replyCount} replies',
                            style: ModernTheme.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (AuthService.isAuthenticated && AuthService.currentUser != null && thread.authorId == AuthService.currentUser!['id'])
                            IconButton(
                              onPressed: () => _deleteThread(thread),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              tooltip: 'Delete thread',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          else if (AuthService.isAuthenticated && AuthService.currentUser != null)
                            IconButton(
                              onPressed: () => _toggleThreadSubscription(thread),
                              icon: Icon(
                                thread.isSubscribed ? Icons.notifications : Icons.notifications_none,
                                color: thread.isSubscribed ? ModernTheme.primaryBlue : Colors.grey[600],
                                size: 20,
                              ),
                              tooltip: thread.isSubscribed ? 'Unsubscribe from thread' : 'Subscribe to thread',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          Text(
                            'View',
                            style: ModernTheme.bodySmall.copyWith(
                              color: ModernTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showThreadDetails(ForumThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadDetailScreen(thread: thread),
      ),
    );
  }

  void _deleteThread(ForumThread thread) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread'),
        content: const Text('Are you sure you want to delete this thread? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete the thread
        await _firestore.collection('threads').doc(thread.id).delete();

        // Delete all replies to this thread
        final repliesQuery = await _firestore
            .collection('replies')
            .where('threadId', isEqualTo: thread.id)
            .get();

        for (final reply in repliesQuery.docs) {
          await reply.reference.delete();
        }

        // Delete all notifications related to this thread
        final notificationsQuery = await _firestore
            .collection('notifications')
            .where('threadId', isEqualTo: thread.id)
            .get();

        for (final notification in notificationsQuery.docs) {
          await notification.reference.delete();
        }

        // Delete all subscriptions to this thread
        final subscriptionsQuery = await _firestore
            .collection('users')
            .doc(AuthService.currentUser!['id'])
            .collection('thread_subscriptions')
            .where('threadId', isEqualTo: thread.id)
            .get();

        for (final subscription in subscriptionsQuery.docs) {
          await subscription.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thread deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting thread: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleThreadSubscription(ForumThread thread) {
    if (!AuthService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to subscribe to threads'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newSubscriptionStatus = !thread.isSubscribed;
    thread.isSubscribed = newSubscriptionStatus;
    _threadSubscriptions[thread.id] = newSubscriptionStatus;

    // Store subscription in Firestore
    final subscriptionRef = _firestore
        .collection('users')
        .doc(AuthService.currentUser!['id'])
        .collection('thread_subscriptions')
        .doc(thread.id);

    if (newSubscriptionStatus) {
      subscriptionRef.set({
        'threadId': thread.id,
        'subscribedAt': FieldValue.serverTimestamp(),
      });
    } else {
      subscriptionRef.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newSubscriptionStatus
              ? 'Subscribed to thread notifications'
              : 'Unsubscribed from thread',
        ),
        backgroundColor: newSubscriptionStatus ? Colors.green : Colors.grey,
      ),
    );
  }

  Future<void> _loadThreadSubscriptionStatus(ForumThread thread) async {
    if (!AuthService.isAuthenticated) return;

    // Check cache first
    if (_threadSubscriptions.containsKey(thread.id)) {
      thread.isSubscribed = _threadSubscriptions[thread.id]!;
      return;
    }

    try {
      final subscriptionDoc = await _firestore
          .collection('users')
          .doc(AuthService.currentUser!['id'])
          .collection('thread_subscriptions')
          .doc(thread.id)
          .get();

      final isSubscribed = subscriptionDoc.exists;
      _threadSubscriptions[thread.id] = isSubscribed;
      thread.isSubscribed = isSubscribed;
    } catch (e) {
      // Ignore errors for subscription loading
      _threadSubscriptions[thread.id] = false;
      thread.isSubscribed = false;
    }
  }

  Future<void> _loadSubscriptionsForThreads(List<ForumThread> threads) async {
    if (!AuthService.isAuthenticated || threads.isEmpty) return;

    final threadIds = threads.map((t) => t.id).toList();

    try {
      final subscriptionsQuery = await _firestore
          .collection('users')
          .doc(AuthService.currentUser!['id'])
          .collection('thread_subscriptions')
          .where(FieldPath.documentId, whereIn: threadIds.take(10).toList()) // Firestore limit
          .get();

      final subscribedThreadIds = subscriptionsQuery.docs.map((doc) => doc.id).toSet();

      for (final thread in threads) {
        final isSubscribed = subscribedThreadIds.contains(thread.id);
        _threadSubscriptions[thread.id] = isSubscribed;
        thread.isSubscribed = isSubscribed;
      }
    } catch (e) {
      // If batch loading fails, fall back to individual loading
      for (final thread in threads) {
        await _loadThreadSubscriptionStatus(thread);
      }
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('notifications')
                      .where('userId', isEqualTo: AuthService.currentUser!['id'])
                      .orderBy('createdAt', descending: true)
                      .limit(50)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading notifications'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final notifications = snapshot.data?.docs ?? [];

                    if (notifications.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index].data() as Map<String, dynamic>;
                        final isRead = notification['isRead'] ?? false;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isRead ? Colors.grey[200] : ModernTheme.primaryBlue.withOpacity(0.1),
                            child: Icon(
                              notification['type'] == 'thread_reply' ? Icons.chat : Icons.notifications,
                              color: isRead ? Colors.grey : ModernTheme.primaryBlue,
                            ),
                          ),
                          title: Text(
                            notification['title'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['message'] ?? ''),
                              Text(
                                _formatTimestamp((notification['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: !isRead
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () async {
                            // Mark as read
                            await notifications[index].reference.update({'isRead': true});

                            // Navigate to thread if it's a reply notification
                            if (notification['threadId'] != null) {
                              Navigator.pop(context);
                              // Navigate to thread detail
                              final threadDoc = await _firestore.collection('threads').doc(notification['threadId']).get();
                              if (threadDoc.exists) {
                                final threadData = threadDoc.data()!;
                                final thread = ForumThread.fromMap(threadData, threadDoc.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ThreadDetailScreen(thread: thread),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'General':
        return ModernTheme.primaryBlue;
      case 'Business Ideas':
        return ModernTheme.accentGreen;
      case 'Funding':
        return ModernTheme.secondaryPurple;
      case 'Marketing':
        return ModernTheme.warningOrange;
      case 'Technology':
        return Colors.blue;
      case 'Legal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ForumThread {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int replyCount;
  final DateTime lastReplyAt;
  bool isSubscribed;

  ForumThread({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.replyCount,
    required this.lastReplyAt,
    this.isSubscribed = false,
  });

  factory ForumThread.fromMap(Map<String, dynamic> data, String id) {
    return ForumThread(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorAvatar: data['authorAvatar'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replyCount: data['replyCount'] ?? 0,
      lastReplyAt: (data['lastReplyAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSubscribed: false, // Will be set based on user subscriptions
    );
  }
}

class ThreadDetailScreen extends StatefulWidget {
  final ForumThread thread;

  const ThreadDetailScreen({super.key, required this.thread});

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _replyController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernTheme.primaryBlue,
              ModernTheme.teal,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildThreadAndReplies(),
                      ),
                      if (AuthService.isAuthenticated) _buildReplyInput(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.thread.title,
                  style: ModernTheme.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.thread.category,
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadAndReplies() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('threads')
          .doc(widget.thread.id)
          .collection('replies')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading replies',
              style: ModernTheme.bodyMedium.copyWith(color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildOriginalThread(),
            const SizedBox(height: 24),
            Text(
              'Replies',
              style: ModernTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.data!.docs.isEmpty)
              Center(
                child: Text(
                  'No replies yet. Be the first to reply!',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...snapshot.data!.docs.map((doc) {
                final replyData = doc.data() as Map<String, dynamic>;
                final reply = ForumReply.fromMap(replyData, doc.id);
                return _buildReplyCard(reply);
              }),
          ],
        );
      },
    );
  }

  Widget _buildOriginalThread() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.thread.authorAvatar.isNotEmpty
                      ? NetworkImage(widget.thread.authorAvatar)
                      : null,
                  child: widget.thread.authorAvatar.isEmpty
                      ? Text(widget.thread.authorName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.thread.authorName,
                        style: ModernTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimestamp(widget.thread.createdAt),
                        style: ModernTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.thread.content,
              style: ModernTheme.bodyMedium.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(ForumReply reply) {
    final bool isCurrentUserReply = AuthService.isAuthenticated &&
        AuthService.currentUser!['id'] == reply.authorId;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: reply.authorAvatar.isNotEmpty
                      ? NetworkImage(reply.authorAvatar)
                      : null,
                  child: reply.authorAvatar.isEmpty
                      ? Text(
                          reply.authorName[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primaryBlue,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reply.authorName,
                            style: ModernTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrentUserReply) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ModernTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'You',
                                style: ModernTheme.bodySmall.copyWith(
                                  color: ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatTimestamp(reply.createdAt),
                        style: ModernTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentUserReply)
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleReplyAction(reply, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reply.content,
              style: ModernTheme.bodyMedium.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildReplyActionButton(
                  icon: Icons.thumb_up_outlined,
                  label: 'Like',
                  onPressed: () => _toggleReplyLike(reply),
                  isActive: reply.likes?.contains(AuthService.currentUser?['id']) ?? false,
                ),
                const SizedBox(width: 16),
                _buildReplyActionButton(
                  icon: Icons.reply,
                  label: 'Reply',
                  onPressed: () => _showNestedReplyInput(reply),
                ),
                const Spacer(),
                if (reply.likes != null && reply.likes!.isNotEmpty)
                  Text(
                    '${reply.likes!.length} ${reply.likes!.length == 1 ? 'like' : 'likes'}',
                    style: ModernTheme.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            // Show nested replies if any
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('threads')
                  .doc(widget.thread.id)
                  .collection('replies')
                  .doc(reply.id)
                  .collection('nestedReplies')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, nestedSnapshot) {
                if (nestedSnapshot.hasError || !nestedSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final nestedReplies = nestedSnapshot.data!.docs
                    .map((doc) => ForumReply.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                if (nestedReplies.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: nestedReplies
                        .map((nestedReply) => Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: _buildNestedReplyCard(nestedReply, reply),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isLoading ? null : _submitReply,
            mini: true,
            backgroundColor: ModernTheme.primaryBlue,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReply() async {
    if (!AuthService.isAuthenticated) return;

    final content = _replyController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Add reply to subcollection
      await _firestore
          .collection('threads')
          .doc(widget.thread.id)
          .collection('replies')
          .add({
        'content': content,
        'authorId': AuthService.currentUser!['id'],
        'authorName': AuthService.currentUser!['name'],
        'authorAvatar': AuthService.currentUser!['avatar'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update thread reply count and last reply time
      await _firestore.collection('threads').doc(widget.thread.id).update({
        'replyCount': FieldValue.increment(1),
        'lastReplyAt': FieldValue.serverTimestamp(),
      });

      // Send notifications to subscribers
      await _sendReplyNotifications(widget.thread, content);

      _replyController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildReplyActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? ModernTheme.primaryBlue : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: ModernTheme.bodySmall.copyWith(
                color: isActive ? ModernTheme.primaryBlue : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReplyAction(ForumReply reply, String action) {
    switch (action) {
      case 'edit':
        _showEditReplyDialog(reply);
        break;
      case 'delete':
        _showDeleteReplyDialog(reply);
        break;
    }
  }

  Future<void> _toggleReplyLike(ForumReply reply) async {
    if (!AuthService.isAuthenticated) return;

    final currentUserId = AuthService.currentUser!['id'];
    final replyRef = _firestore
        .collection('threads')
        .doc(widget.thread.id)
        .collection('replies')
        .doc(reply.id);

    try {
      final doc = await replyRef.get();
      final currentLikes = List<String>.from(doc.data()?['likes'] ?? []);

      if (currentLikes.contains(currentUserId)) {
        // Remove like
        currentLikes.remove(currentUserId);
      } else {
        // Add like
        currentLikes.add(currentUserId);
      }

      await replyRef.update({'likes': currentLikes});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating like: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNestedReplyInput(ForumReply parentReply) {
    final nestedReplyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
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
            children: [
              Row(
                children: [
                  Text(
                    'Reply to ${parentReply.authorName}',
                    style: ModernTheme.headingMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nestedReplyController,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Write your reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submitNestedReply(parentReply, nestedReplyController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Post Reply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitNestedReply(ForumReply parentReply, String content) async {
    if (!AuthService.isAuthenticated || content.isEmpty) return;

    try {
      await _firestore
          .collection('threads')
          .doc(widget.thread.id)
          .collection('replies')
          .doc(parentReply.id)
          .collection('nestedReplies')
          .add({
        'content': content,
        'authorId': AuthService.currentUser!['id'],
        'authorName': AuthService.currentUser!['name'],
        'authorAvatar': AuthService.currentUser!['avatar'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNestedReplyCard(ForumReply nestedReply, ForumReply parentReply) {
    final bool isCurrentUserReply = AuthService.isAuthenticated &&
        AuthService.currentUser!['id'] == nestedReply.authorId;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: nestedReply.authorAvatar.isNotEmpty
                      ? NetworkImage(nestedReply.authorAvatar)
                      : null,
                  child: nestedReply.authorAvatar.isEmpty
                      ? Text(
                          nestedReply.authorName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primaryBlue,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            nestedReply.authorName,
                            style: ModernTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrentUserReply) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: ModernTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'You',
                                style: ModernTheme.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatTimestamp(nestedReply.createdAt),
                        style: ModernTheme.bodySmall.copyWith(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              nestedReply.content,
              style: ModernTheme.bodySmall.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleNestedReplyLike(nestedReply, parentReply),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up,
                          size: 12,
                          color: (nestedReply.likes?.contains(AuthService.currentUser?['id']) ?? false)
                              ? ModernTheme.primaryBlue
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Like',
                          style: ModernTheme.bodySmall.copyWith(
                            fontSize: 10,
                            color: (nestedReply.likes?.contains(AuthService.currentUser?['id']) ?? false)
                                ? ModernTheme.primaryBlue
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (nestedReply.likes != null && nestedReply.likes!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${nestedReply.likes!.length}',
                    style: ModernTheme.bodySmall.copyWith(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNestedReplyLike(ForumReply nestedReply, ForumReply parentReply) async {
    if (!AuthService.isAuthenticated) return;

    final currentUserId = AuthService.currentUser!['id'];
    final nestedReplyRef = _firestore
        .collection('threads')
        .doc(widget.thread.id)
        .collection('replies')
        .doc(parentReply.id)
        .collection('nestedReplies')
        .doc(nestedReply.id);

    try {
      final doc = await nestedReplyRef.get();
      final currentLikes = List<String>.from(doc.data()?['likes'] ?? []);

      if (currentLikes.contains(currentUserId)) {
        currentLikes.remove(currentUserId);
      } else {
        currentLikes.add(currentUserId);
      }

      await nestedReplyRef.update({'likes': currentLikes});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating like: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditReplyDialog(ForumReply reply) {
    final editController = TextEditingController(text: reply.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Edit your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateReply(reply, editController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryBlue,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateReply(ForumReply reply, String newContent) async {
    if (newContent.isEmpty) return;

    try {
      await _firestore
          .collection('threads')
          .doc(widget.thread.id)
          .collection('replies')
          .doc(reply.id)
          .update({'content': newContent});

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteReplyDialog(ForumReply reply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteReply(reply),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReply(ForumReply reply) async {
    try {
      await _firestore
          .collection('threads')
          .doc(widget.thread.id)
          .collection('replies')
          .doc(reply.id)
          .delete();

      // Update thread reply count
      await _firestore.collection('threads').doc(widget.thread.id).update({
        'replyCount': FieldValue.increment(-1),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendReplyNotifications(ForumThread thread, String replyContent) async {
    try {
      // Get all subscribers to this thread
      final subscriptionsSnapshot = await _firestore
          .collection('users')
          .doc(thread.authorId)
          .collection('thread_subscriptions')
          .doc(thread.id)
          .get();

      if (!subscriptionsSnapshot.exists) return;

      // Get thread subscribers (excluding the reply author)
      final subscribersQuery = await _firestore
          .collectionGroup('thread_subscriptions')
          .where('threadId', isEqualTo: thread.id)
          .get();

      final currentUserId = AuthService.currentUser!['id'];

      for (final doc in subscribersQuery.docs) {
        final subscriberId = doc.reference.parent.parent!.id;

        // Don't notify the person who made the reply
        if (subscriberId == currentUserId) continue;

        // Create in-app notification
        await _firestore.collection('notifications').add({
          'userId': subscriberId,
          'type': 'thread_reply',
          'title': 'New reply in "${thread.title}"',
          'message': '${AuthService.currentUser!['name']} replied: ${replyContent.length > 50 ? '${replyContent.substring(0, 50)}...' : replyContent}',
          'threadId': thread.id,
          'threadTitle': thread.title,
          'replyAuthorId': currentUserId,
          'replyAuthorName': AuthService.currentUser!['name'],
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      // Don't show error for notification failures
      print('Error sending notifications: $e');
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ForumReply {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final List<String>? likes;
  final List<ForumReply>? nestedReplies;

  ForumReply({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    this.likes,
    this.nestedReplies,
  });

  factory ForumReply.fromMap(Map<String, dynamic> data, String id) {
    return ForumReply(
      id: id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorAvatar: data['authorAvatar'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: List<String>.from(data['likes'] ?? []),
      nestedReplies: null, // Will be populated separately for nested replies
    );
  }
}