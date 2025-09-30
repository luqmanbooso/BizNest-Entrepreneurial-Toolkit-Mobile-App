import 'package:cloud_firestore/cloud_firestore.dart';

// This is a one-time script to add sample mentors to your database
// Run this ONCE to populate your database with mentor data

Future<void> addSampleMentors() async {
  final db = FirebaseFirestore.instance;
  
  print('Adding sample mentors to database...');
  
  final mentors = [
    {
      'role': 'mentor',
      'is_active': true,
      'name': 'Sarah Johnson',
      'expertise': 'Tech Startups',
      'experience_years': 8,
      'bio': 'Serial entrepreneur with 3 successful exits. Expert in SaaS and mobile app development.',
      'location': 'San Francisco, CA',
      'is_remote': true,
      'specializations': ['SaaS', 'Mobile Apps', 'Fundraising', 'Product Development'],
      'hourly_rate': 150,
      'availability': 'evenings',
      'profile_image': 'https://randomuser.me/api/portraits/women/1.jpg',
      'company': 'TechVentures Inc.',
      'linkedin': 'https://linkedin.com/in/sarahjohnson',
      'rating': 4.9,
      'total_mentees': 24,
      'languages': ['English', 'Spanish'],
      'email': 'sarah.johnson@email.com',
      'created_at': FieldValue.serverTimestamp(),
    },
    {
      'role': 'mentor',
      'is_active': true,
      'name': 'Michael Chen',
      'expertise': 'E-commerce',
      'experience_years': 12,
      'bio': 'Built and scaled multiple e-commerce brands from zero to 8-figures.',
      'location': 'New York, NY',
      'is_remote': true,
      'specializations': ['E-commerce', 'Digital Marketing', 'Operations'],
      'hourly_rate': 200,
      'availability': 'flexible',
      'profile_image': 'https://randomuser.me/api/portraits/men/2.jpg',
      'company': 'CommerceScale',
      'linkedin': 'https://linkedin.com/in/michaelchen',
      'rating': 4.8,
      'total_mentees': 18,
      'languages': ['English', 'Mandarin'],
      'email': 'michael.chen@email.com',
      'created_at': FieldValue.serverTimestamp(),
    },
    {
      'role': 'mentor',
      'is_active': true,
      'name': 'Emily Rodriguez',
      'expertise': 'Food & Beverage',
      'experience_years': 6,
      'bio': 'Restaurant owner and food industry consultant.',
      'location': 'Austin, TX',
      'is_remote': false,
      'specializations': ['Restaurant Operations', 'Franchising'],
      'hourly_rate': 120,
      'availability': 'weekends',
      'profile_image': 'https://randomuser.me/api/portraits/women/3.jpg',
      'company': 'Taste Ventures',
      'linkedin': 'https://linkedin.com/in/emilyrodriguez',
      'rating': 4.7,
      'total_mentees': 15,
      'languages': ['English', 'Spanish'],
      'email': 'emily.rodriguez@email.com',
      'created_at': FieldValue.serverTimestamp(),
    },
  ];
  
  try {
    for (var mentor in mentors) {
      await db.collection('users').add(mentor);
      print('✅ Added mentor: ${mentor['name']}');
    }
    print('🎉 Successfully added ${mentors.length} mentors to database!');
  } catch (e) {
    print('❌ Error adding mentors: $e');
  }
}

// Call this function once from your app to populate the database
// You can add this to a button press or call it from initState() once