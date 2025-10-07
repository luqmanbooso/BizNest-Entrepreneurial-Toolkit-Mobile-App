import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Create a new mentorship session
  static Future<String> createSession({
    required String menteeId,
    required String menteeName,
    required String sessionTitle,
    required String sessionTopic,
    required DateTime scheduledDate,
    required String scheduledTime,
    required int durationMinutes,
    required String meetingLink,
    String? notes,
  }) async {
    try {
      final mentorId = currentUserId;
      if (mentorId == null) {
        throw Exception('No mentor logged in');
      }

      // Get mentor name from Firestore
      final mentorDoc = await _firestore.collection('users').doc(mentorId).get();
      final mentorName = mentorDoc.data()?['name'] ?? 'Unknown Mentor';

      final sessionData = {
        'mentor_id': mentorId,
        'mentor_name': mentorName,
        'mentee_id': menteeId,
        'mentee_name': menteeName,
        'session_title': sessionTitle,
        'session_topic': sessionTopic,
        'scheduled_date': Timestamp.fromDate(scheduledDate),
        'scheduled_time': scheduledTime,
        'duration_minutes': durationMinutes,
        'meeting_link': meetingLink,
        'notes': notes ?? '',
        'status': 'scheduled', // scheduled, completed, cancelled
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('sessions').add(sessionData);
      
      print('✅ Session created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating session: $e');
      rethrow;
    }
  }

  /// Get all sessions for a mentor
  static Future<List<Map<String, dynamic>>> getMentorSessions() async {
    try {
      final mentorId = currentUserId;
      if (mentorId == null) return [];

      final querySnapshot = await _firestore
          .collection('sessions')
          .where('mentor_id', isEqualTo: mentorId)
          .get();

      // Sort on client side to avoid index requirement
      final sessions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      sessions.sort((a, b) {
        final aDate = a['scheduled_date'] as Timestamp?;
        final bDate = b['scheduled_date'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

      return sessions;
    } catch (e) {
      print('❌ Error fetching mentor sessions: $e');
      return [];
    }
  }

  /// Get all sessions for a mentee (entrepreneur)
  static Future<List<Map<String, dynamic>>> getEntrpreneurSessions() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final querySnapshot = await _firestore
          .collection('sessions')
          .where('mentee_id', isEqualTo: userId)
          .get();

      // Sort on client side to avoid index requirement
      final sessions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      sessions.sort((a, b) {
        final aDate = a['scheduled_date'] as Timestamp?;
        final bDate = b['scheduled_date'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

      return sessions;
    } catch (e) {
      print('❌ Error fetching entrepreneur sessions: $e');
      return [];
    }
  }

  /// Get upcoming sessions (within next 7 days)
  static Future<List<Map<String, dynamic>>> getUpcomingSessions({bool isMentor = true}) async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final field = isMentor ? 'mentor_id' : 'mentee_id';

      // Simplified query to avoid index requirement - filter on client side
      final querySnapshot = await _firestore
          .collection('sessions')
          .where(field, isEqualTo: userId)
          .get();

      // Filter and sort on client side
      final sessions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((session) {
        final status = session['status'] as String?;
        final scheduledDate = session['scheduled_date'] as Timestamp?;
        
        if (status != 'scheduled' || scheduledDate == null) return false;
        
        final date = scheduledDate.toDate();
        return date.isAfter(now) && date.isBefore(nextWeek);
      }).toList();

      sessions.sort((a, b) {
        final aDate = a['scheduled_date'] as Timestamp;
        final bDate = b['scheduled_date'] as Timestamp;
        return aDate.compareTo(bDate);
      });

      return sessions;
    } catch (e) {
      print('❌ Error fetching upcoming sessions: $e');
      return [];
    }
  }

  /// Update session status
  static Future<void> updateSessionStatus(String sessionId, String status) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ Session status updated to: $status');
    } catch (e) {
      print('❌ Error updating session status: $e');
      rethrow;
    }
  }

  /// Delete a session
  static Future<void> deleteSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).delete();
      print('✅ Session deleted');
    } catch (e) {
      print('❌ Error deleting session: $e');
      rethrow;
    }
  }

  /// Get mentees for a mentor (from accepted mentorship requests)
  static Future<List<Map<String, dynamic>>> getMentorMentees() async {
    try {
      final mentorId = currentUserId;
      if (mentorId == null) {
        print('❌ No mentor logged in');
        return [];
      }

      print('🔍 Fetching mentees for mentor: $mentorId');

      final querySnapshot = await _firestore
          .collection('mentorship_requests')
          .where('mentor_id', isEqualTo: mentorId)
          .where('status', isEqualTo: 'accepted')
          .get();

      print('📊 Found ${querySnapshot.docs.length} accepted mentorship requests');

      final mentees = <Map<String, dynamic>>[];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // The mentee info is stored in a nested object
        final menteeInfo = data['mentee_info'] as Map<String, dynamic>?;
        
        mentees.add({
          'id': data['mentee_id'],
          'name': menteeInfo?['name'] ?? 'Unknown',
          'business_name': menteeInfo?['business_name'] ?? '',
        });
        
        print('✅ Added mentee: ${menteeInfo?['name']} (${menteeInfo?['business_name']})');
      }

      print('✅ Total mentees loaded: ${mentees.length}');
      return mentees;
    } catch (e) {
      print('❌ Error fetching mentees: $e');
      return [];
    }
  }
}
