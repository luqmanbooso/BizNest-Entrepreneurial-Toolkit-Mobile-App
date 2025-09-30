// Test file to validate enhanced mentorship system
// Run this with: dart run test_mentorship.dart

import 'lib/core/services/mentorship_service.dart';

void main() async {
  print('🧪 Testing Enhanced Mentorship System');
  print('=====================================');
  
  try {
    // Test 1: Get all mentors
    print('\n1. Testing mentor retrieval...');
    final mentors = await MentorshipService.getAllMentors();
    print('✅ Found ${mentors.length} mentors');
    for (var mentor in mentors) {
      print('   - ${mentor['name']} (${mentor['expertise']})');
    }
    
    // Test 2: Check current user info
    print('\n2. Testing user info retrieval...');
    final userInfo = await MentorshipService.getCurrentUserInfo();
    if (userInfo != null) {
      print('✅ Current user: ${userInfo['name']} (${userInfo['role']})');
    } else {
      print('ℹ️ No current user (not authenticated)');
    }
    
    // Test 3: Check mentor status
    print('\n3. Testing mentor status check...');
    final isMentor = await MentorshipService.isCurrentUserMentor();
    print('✅ Current user is mentor: $isMentor');
    
    // Test 4: Get mentorship requests
    print('\n4. Testing mentorship requests retrieval...');
    final requests = await MentorshipService.getMentorshipRequests();
    print('✅ Found ${requests.length} mentorship requests');
    for (var request in requests) {
      print('   - ${request['mentee_info']?['name'] ?? 'Unknown'} -> ${request['status']}');
    }
    
    // Test 5: Debug system
    print('\n5. Running debug system...');
    await MentorshipService.debugMentorshipRequests();
    
    print('\n🎉 All tests completed successfully!');
    print('=====================================');
    
  } catch (e) {
    print('❌ Test failed with error: $e');
  }
}