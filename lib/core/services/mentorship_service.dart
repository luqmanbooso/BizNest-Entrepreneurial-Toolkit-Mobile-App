import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorshipService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // Get current user information
  static Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      if (currentUserId == null) return null;

      final userDoc = await _db.collection('users').doc(currentUserId).get();
      if (userDoc.exists) {
        return {
          'id': userDoc.id,
          ...userDoc.data()!,
        };
      }
      return null;
    } catch (e) {
      print('🔍 [MentorshipService] Error getting current user info: $e');
      return null;
    }
  }

  // Check if current user is a mentor
  static Future<bool> isCurrentUserMentor() async {
    try {
      final userInfo = await getCurrentUserInfo();
      return userInfo?['role'] == 'mentor';
    } catch (e) {
      print('🔍 [MentorshipService] Error checking mentor status: $e');
      return false;
    }
  }

  // Get all available mentors from database
  static Future<List<Map<String, dynamic>>> getAllMentors() async {
    try {
      print('🔍 [MentorshipService] Starting getAllMentors query...');

      // Updated query to match your database structure - removed is_active check
      final querySnapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'mentor')
          .get();

      print(
          '🔍 [MentorshipService] Query completed. Found ${querySnapshot.docs.length} documents');

      final mentors = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print(
            '🔍 [MentorshipService] Mentor found: ${data['name']} (role: ${data['role']})');
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      if (mentors.isEmpty) {
        print(
            '🔍 [MentorshipService] No mentors found in database, returning mock data');
        return _getMockMentors();
      }

      print(
          '🔍 [MentorshipService] Returning ${mentors.length} mentors from database');
      return mentors;
    } catch (e) {
      print('❌ [MentorshipService] Error getting mentors: $e');
      return _getMockMentors();
    }
  }

  // Search mentors based on query string
  static Future<List<Map<String, dynamic>>> searchMentors(String query) async {
    try {
      final mentors = await getAllMentors();

      if (query.isEmpty) {
        return mentors;
      }

      return mentors.where((mentor) {
        final name = mentor['name']?.toString().toLowerCase() ?? '';
        final expertise = mentor['expertise']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || expertise.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching mentors: $e');
      return [];
    }
  }

  // Send mentorship request (placeholder)
  static Future<bool> sendMentorshipRequest({
    required String mentorId,
    required String message,
    String? goals,
    String? timeline,
    String? requestType,
    String? industry,
    String? location,
  }) async {
    try {
      if (currentUserId == null) return false;

      // Get current user info to include in the request
      final currentUserInfo = await getCurrentUserInfo();

      await _db.collection('mentorship_requests').add({
        'mentee_id': currentUserId,
        'mentor_id': mentorId,
        'message': message,
        'goals': goals,
        'timeline': timeline,
        'request_type': requestType,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        // Include mentee info with industry and location
        'mentee_info': {
          'name': currentUserInfo?['name'] ?? 'Unknown User',
          'business_name':
              currentUserInfo?['business_name'] ?? 'Business not specified',
          'industry': industry ?? 'Not specified',
          'location': location ?? 'Not specified',
          'avatar': currentUserInfo?['avatar'] ?? '',
        },
      });

      return true;
    } catch (e) {
      print('Error sending mentorship request: $e');
      return false;
    }
  }

  // Get mentorship requests (placeholder)
  static Future<List<Map<String, dynamic>>> getMentorshipRequests(
      {String? mentorId}) async {
    try {
      final targetMentorId = mentorId ?? currentUserId;
      if (targetMentorId == null) return [];

      final querySnapshot = await _db
          .collection('mentorship_requests')
          .where('mentor_id', isEqualTo: targetMentorId)
          .get();

      print(
          '🔍 [MentorshipService] Query completed. Found ${querySnapshot.docs.length} documents');

      final requests = <Map<String, dynamic>>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        var request = {
          'id': doc.id,
          ...data,
        };

        // If mentee_info is missing or incomplete, fetch user info separately
        if (request['mentee_info'] == null ||
            request['mentee_info']['name'] == null) {
          final menteeId = request['mentee_id'];
          if (menteeId != null) {
            try {
              final userDoc = await _db.collection('users').doc(menteeId).get();
              if (userDoc.exists) {
                final userData = userDoc.data()!;
                request['mentee_info'] = {
                  'name': userData['name'] ?? 'Unknown User',
                  'business_name':
                      userData['business_name'] ?? 'Business not specified',
                  'industry': userData['industry'] ?? 'Not specified',
                  'location': userData['location'] ?? 'Not specified',
                  'avatar': userData['avatar'] ?? '',
                };
              }
            } catch (e) {
              print(
                  '⚠️ [MentorshipService] Error fetching mentee info for $menteeId: $e');
            }
          }
        }

        requests.add(request);
        print(
            '📋 [MentorshipService] Request: ${request['id']} - Status: ${request['status']} - From: ${request['mentee_info']?['name'] ?? 'Unknown'}');
      }

      // Sort by created_at timestamp (newest first) on client side to avoid Firestore index requirement
      requests.sort((a, b) {
        final aTime = a['created_at'];
        final bTime = b['created_at'];

        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        // Handle both Timestamp and String types
        try {
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime); // newest first
          }
          // Fallback to string comparison
          return bTime.toString().compareTo(aTime.toString());
        } catch (e) {
          print('⚠️ [MentorshipService] Error sorting requests: $e');
          return 0;
        }
      });

      print(
          '🔍 [MentorshipService] Returning ${requests.length} mentorship requests for mentor: $targetMentorId');
      return requests;
    } catch (e) {
      print('Error getting mentorship requests: $e');
      return [];
    }
  }

  // Accept mentorship request (placeholder)
  static Future<bool> acceptMentorshipRequest(String requestId) async {
    try {
      await _db.collection('mentorship_requests').doc(requestId).update({
        'status': 'accepted',
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error accepting request: $e');
      return false;
    }
  }

  // Reject mentorship request (placeholder)
  static Future<bool> rejectMentorshipRequest(String requestId,
      {String? reason}) async {
    try {
      await _db.collection('mentorship_requests').doc(requestId).update({
        'status': 'rejected',
        'rejection_reason': reason,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error rejecting request: $e');
      return false;
    }
  }

  // Debug method to test request system
  static Future<void> debugMentorshipRequests() async {
    try {
      print('🔧 [DEBUG] Starting mentorship request system debug...');

      // Check current user
      final userInfo = await getCurrentUserInfo();
      print(
          '🔧 [DEBUG] Current user: ${userInfo?['name']} (${userInfo?['role']})');

      // Check if user is mentor
      final isMentor = await isCurrentUserMentor();
      print('🔧 [DEBUG] Is current user a mentor: $isMentor');

      // Get requests
      final requests = await getMentorshipRequests();
      print('🔧 [DEBUG] Found ${requests.length} mentorship requests');

      for (var request in requests) {
        print(
            '🔧 [DEBUG] Request ${request['id']}: ${request['mentee_info']?['name']} -> ${request['status']}');
      }

      // Get all requests in database (for debugging) - simple query without orderBy
      final allRequests = await _db.collection('mentorship_requests').get();
      print(
          '🔧 [DEBUG] Total requests in database: ${allRequests.docs.length}');

      for (var doc in allRequests.docs) {
        final data = doc.data();
        print(
            '🔧 [DEBUG] DB Request ${doc.id}: mentee_id=${data['mentee_id']}, mentor_id=${data['mentor_id']}, status=${data['status']}');
      }

      // Try a direct query for this mentor without orderBy to test
      print('🔧 [DEBUG] Testing direct query for current mentor...');
      try {
        final directQuery = await _db
            .collection('mentorship_requests')
            .where('mentor_id', isEqualTo: currentUserId)
            .get();
        print(
            '🔧 [DEBUG] Direct query found ${directQuery.docs.length} requests for mentor');

        for (var doc in directQuery.docs) {
          final data = doc.data();
          print(
              '🔧 [DEBUG] Direct result: ${doc.id} - ${data['mentee_info']?['name'] ?? 'Unknown'} -> ${data['status']}');
        }
      } catch (e) {
        print('🔧 [DEBUG] Direct query error: $e');
      }
    } catch (e) {
      print('❌ [DEBUG] Error in debug: $e');
    }
  }

  // Mock data for testing and fallback
  static List<Map<String, dynamic>> _getMockMentors() {
    return [
      {
        'id': 'mock_1',
        'name': 'Sarah Johnson',
        'role': 'mentor',
        'expertise': ['Tech Startups'],
        'experienceLevel': '5-10 years',
        'bio': 'Serial entrepreneur with 3 successful exits.',
        'location': 'San Francisco, CA',
        'hourlyRate': '150',
        'title': 'Senior Product Manager',
        'company': 'TechVentures Inc.',
      },
    ];
  }

  // Get mentorship requests where current user is the mentee (entrepreneur)
  static Future<List<Map<String, dynamic>>> getMenteeRequests() async {
    try {
      if (currentUserId == null) return [];

      final querySnapshot = await _db
          .collection('mentorship_requests')
          .where('mentee_id', isEqualTo: currentUserId)
          .get();

      print(
          '🔍 [MentorshipService] Mentee query completed. Found ${querySnapshot.docs.length} documents');

      final requests = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final request = {
          'id': doc.id,
          ...data,
        };

        print(
            '📋 [MentorshipService] Mentee Request: ${request['id']} - Status: ${request['status']}');

        return request;
      }).toList();

      // Sort by created_at timestamp (newest first)
      requests.sort((a, b) {
        final aTime = a['created_at'];
        final bTime = b['created_at'];

        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        try {
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return bTime.toString().compareTo(aTime.toString());
        } catch (e) {
          return 0;
        }
      });

      print(
          '🔍 [MentorshipService] Returning ${requests.length} mentee requests');
      return requests;
    } catch (e) {
      print('❌ [MentorshipService] Error getting mentee requests: $e');
      return [];
    }
  }
}
