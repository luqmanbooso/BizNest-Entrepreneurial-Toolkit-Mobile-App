import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // Get or create a chat between two users
  static Future<String?> getOrCreateChat(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      // Create consistent chat ID
      final userIds = [currentUserId, otherUserId]..sort();
      final chatId = '${userIds[0]}_${userIds[1]}';

      // Check if chat exists
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        // Create new chat
        await chatRef.set({
          'participants': [currentUserId, otherUserId],
          'created_at': FieldValue.serverTimestamp(),
          'last_message': '',
          'last_message_time': FieldValue.serverTimestamp(),
          'last_message_sender': '',
        });
      }

      return chatId;
    } catch (e) {
      print('Error creating/getting chat: $e');
      return null;
    }
  }

  // Send a message
  static Future<bool> sendMessage({
    required String chatId,
    required String message,
    String type = 'text',
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'message': message,
        'sender_id': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
      });

      // Update chat document with last message
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({
        'last_message': message,
        'last_message_time': FieldValue.serverTimestamp(),
        'last_message_sender': currentUserId,
      });

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Get user's chats
  static Stream<QuerySnapshot> getUserChats() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('last_message_time', descending: true)
        .snapshots();
  }

  // Get messages for a specific chat
  static Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get chat participants info
  static Future<Map<String, dynamic>?> getChatParticipantInfo(
    String chatId,
    String currentUserId,
  ) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return null;

      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) return null;

      // Get other user's info
      final userDoc = await _firestore.collection('users').doc(otherUserId).get();
      if (!userDoc.exists) return null;

      return {
        'user_id': otherUserId,
        'name': userDoc.data()?['name'] ?? 'Unknown User',
        'avatar': userDoc.data()?['avatar'] ?? '',
        'business_name': userDoc.data()?['business_name'] ?? '',
        'industry': userDoc.data()?['industry'] ?? 'Not specified',
        'location': userDoc.data()?['location'] ?? 'Not specified',
      };
    } catch (e) {
      print('Error getting participant info: $e');
      return null;
    }
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Update unread messages (this would require additional fields in message documents)
      // For now, we'll implement this as a placeholder
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({
        'last_read_by_${currentUserId}': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Delete a chat
  static Future<bool> deleteChat(String chatId) async {
    try {
      // Delete all messages first
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat document
      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting chat: $e');
      return false;
    }
  }

  // Get unread message count for a chat
  static Future<int> getUnreadCount(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return 0;

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return 0;

      final lastReadTime = chatDoc.data()?['last_read_by_$currentUserId'] as Timestamp?;
      
      if (lastReadTime == null) {
        // If never read, count all messages from other users
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('sender_id', isNotEqualTo: currentUserId)
            .get();
        return messagesSnapshot.docs.length;
      }

      // Count messages after last read time from other users
      final unreadSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('sender_id', isNotEqualTo: currentUserId)
          .where('timestamp', isGreaterThan: lastReadTime)
          .get();

      return unreadSnapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}