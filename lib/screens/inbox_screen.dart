import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/chat_service.dart';
import '../core/services/auth_service.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  bool _isMentor = false;

  @override
  void initState() {
    super.initState();
    _isMentor = AuthService.currentUser?['role'] == 'mentor';
    _setupAnimations();
    _loadConversations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadConversations() async {
    try {
      // Listen to real-time chat updates
      ChatService.getUserChats().listen((snapshot) async {
        final conversations = <Map<String, dynamic>>[];

        for (final doc in snapshot.docs) {
          final chatData = doc.data() as Map<String, dynamic>;
          final chatId = doc.id;
          final currentUserId = ChatService.currentUserId;

          if (currentUserId != null) {
            final participantInfo = await ChatService.getChatParticipantInfo(
              chatId,
              currentUserId,
            );

            if (participantInfo != null) {
              final unreadCount = await ChatService.getUnreadCount(chatId);

              conversations.add({
                'id': chatId,
                'participant_id': participantInfo['user_id'],
                'participant_name': participantInfo['name'],
                'participant_avatar': participantInfo['avatar'],
                'last_message': chatData['last_message'] ?? 'No messages yet',
                'last_message_time':
                    _formatLastMessageTime(chatData['last_message_time']),
                'unread_count': unreadCount,
                'industry': participantInfo['industry'],
                'location': participantInfo['location'],
                'is_online': false, // TODO: Implement online status
              });
            }
          }
        }

        if (mounted) {
          setState(() {
            _conversations = conversations;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatLastMessageTime(dynamic timestamp) {
    if (timestamp == null) return 'Now';

    try {
      final messageTime = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(messageTime);

      if (difference.inMinutes < 1) {
        return 'Now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${messageTime.day}/${messageTime.month}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: _buildBody(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child:
                _isLoading ? _buildLoadingState() : _buildConversationsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
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
          const Text(
            'Inbox',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_conversations.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: ModernTheme.electricBlue,
      ),
    );
  }

  Widget _buildConversationsList() {
    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        return _buildConversationCard(_conversations[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ModernTheme.electricBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: ModernTheme.electricBlue.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: ModernTheme.electricBlue.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Conversations Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernTheme.navy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isMentor
                  ? 'Accept mentorship requests to start conversations with mentees'
                  : 'Your accepted mentorship requests will appear here',
              style: const TextStyle(
                fontSize: 14,
                color: ModernTheme.mediumGray,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _startChat(conversation),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ModernTheme.electricBlue,
                            ModernTheme.electricBlue.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          conversation['participant_name']
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (conversation['is_online'])
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: ModernTheme.freshGreen,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation['participant_name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ModernTheme.navy,
                              ),
                            ),
                          ),
                          Text(
                            conversation['last_message_time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: ModernTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation['last_message'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: ModernTheme.mediumGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.business_outlined,
                            size: 12,
                            color: ModernTheme.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            conversation['industry'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: ModernTheme.mediumGray,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: ModernTheme.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              conversation['location'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: ModernTheme.mediumGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (conversation['unread_count'] > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ModernTheme.electricBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${conversation['unread_count']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Future<void> _refreshConversations() async {
    final conversations = <Map<String, dynamic>>[];

    try {
      final snapshot = await ChatService.getUserChats().first;

      for (final doc in snapshot.docs) {
        final chatData = doc.data() as Map<String, dynamic>;
        final chatId = doc.id;
        final currentUserId = ChatService.currentUserId;

        if (currentUserId != null) {
          final participantInfo = await ChatService.getChatParticipantInfo(
            chatId,
            currentUserId,
          );

          if (participantInfo != null) {
            final unreadCount = await ChatService.getUnreadCount(chatId);

            conversations.add({
              'id': chatId,
              'participant_id': participantInfo['user_id'],
              'participant_name': participantInfo['name'],
              'participant_avatar': participantInfo['avatar'],
              'last_message': chatData['last_message'] ?? 'No messages yet',
              'last_message_time':
                  _formatLastMessageTime(chatData['last_message_time']),
              'unread_count': unreadCount,
              'industry': participantInfo['industry'],
              'location': participantInfo['location'],
              'is_online': false,
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _conversations = conversations;
        });
      }
    } catch (e) {
      print('Error refreshing conversations: $e');
    }
  }

  Future<void> _startChat(Map<String, dynamic> conversation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: conversation['participant_id'],
          recipientName: conversation['participant_name'],
          recipientAvatar: conversation['participant_avatar'],
        ),
      ),
    );

    // Refresh conversations when returning from chat to update unread counts
    await _refreshConversations();
  }
}
