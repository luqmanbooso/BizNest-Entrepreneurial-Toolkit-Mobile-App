import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Initialize Firebase (you'll need to run this in your app context)
  await debugDatabase();
}

Future<void> debugDatabase() async {
  print('🔍 [DEBUG] Starting database investigation...');
  
  try {
    // Check all users in the users collection
    print('🔍 [DEBUG] Checking all documents in users collection...');
    final allUsersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    print('🔍 [DEBUG] Found ${allUsersSnapshot.docs.length} total documents in users collection');
    
    for (var doc in allUsersSnapshot.docs) {
      final data = doc.data();
      print('🔍 [DEBUG] User ${doc.id}: role=${data['role']}, is_active=${data['is_active']}, name=${data['name']}');
    }
    
    // Check for mentors with exact query
    print('\n🔍 [DEBUG] Checking mentors with exact query...');
    final mentorSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'mentor')
        .where('is_active', isEqualTo: true)
        .get();
    
    print('🔍 [DEBUG] Found ${mentorSnapshot.docs.length} mentors with exact query');
    
    // Check for mentors with different role values
    print('\n🔍 [DEBUG] Checking for different role values...');
    final roleVariations = ['mentor', 'Mentor', 'MENTOR', 'Mentors', 'mentors'];
    
    for (String roleValue in roleVariations) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: roleValue)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        print('🔍 [DEBUG] Found ${snapshot.docs.length} users with role="$roleValue"');
        for (var doc in snapshot.docs) {
          final data = doc.data();
          print('  - ${data['name']} (is_active: ${data['is_active']})');
        }
      }
    }
    
    // Check if there are users without is_active field
    print('\n🔍 [DEBUG] Checking users without is_active field...');
    final allUsersAgain = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    for (var doc in allUsersAgain.docs) {
      final data = doc.data();
      if (!data.containsKey('is_active')) {
        print('🔍 [DEBUG] User ${doc.id} (${data['name']}) missing is_active field');
      }
    }
    
  } catch (e) {
    print('❌ [DEBUG] Error investigating database: $e');
  }
}