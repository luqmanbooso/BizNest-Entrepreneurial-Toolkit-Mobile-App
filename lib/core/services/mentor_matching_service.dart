import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class MentorMatchingService {
  static const String _mentorsKey = 'mentors_data';
  static const String _matchesKey = 'mentor_matches';
  static const String _messagesKey = 'mentor_messages';

  // Get available mentors
  static Future<List<Map<String, dynamic>>> getAvailableMentors() async {
    try {
      // In a real app, this would fetch from a server
      return _getMockMentors();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting mentors: $e');
      }
      return [];
    }
  }

  // Find matching mentors based on user profile
  static Future<List<Map<String, dynamic>>> findMatchingMentors({
    required String industry,
    required String businessStage,
    required List<String> goals,
    required String location,
    required String experienceLevel,
  }) async {
    try {
      final allMentors = await getAvailableMentors();
      final matches = <Map<String, dynamic>>[];

      for (var mentor in allMentors) {
        double matchScore = _calculateMatchScore(
          mentor: mentor,
          industry: industry,
          businessStage: businessStage,
          goals: goals,
          location: location,
          experienceLevel: experienceLevel,
        );

        if (matchScore >= 0.6) { // 60% match threshold
          matches.add({
            ...mentor,
            'match_score': matchScore,
            'match_reasons': _getMatchReasons(mentor, industry, businessStage, goals),
          });
        }
      }

      // Sort by match score
      matches.sort((a, b) => (b['match_score'] as double).compareTo(a['match_score'] as double));

      // Save matches
      await _saveMatches(matches);

      return matches;
    } catch (e) {
      if (kDebugMode) {
        print('Error finding matching mentors: $e');
      }
      return [];
    }
  }

  // Calculate match score between user and mentor
  static double _calculateMatchScore({
    required Map<String, dynamic> mentor,
    required String industry,
    required String businessStage,
    required List<String> goals,
    required String location,
    required String experienceLevel,
  }) {
    double score = 0.0;
    int factors = 0;

    // Industry match (30% weight)
    if (mentor['industries'].contains(industry)) {
      score += 0.3;
    }
    factors++;

    // Business stage match (25% weight)
    if (mentor['expertise_areas'].contains(businessStage)) {
      score += 0.25;
    }
    factors++;

    // Goals match (20% weight)
    final mentorGoals = mentor['specializations'] as List<dynamic>;
    int goalMatches = 0;
    for (String goal in goals) {
      if (mentorGoals.any((specialization) => 
          specialization.toString().toLowerCase().contains(goal.toLowerCase()))) {
        goalMatches++;
      }
    }
    if (goals.isNotEmpty) {
      score += (goalMatches / goals.length) * 0.2;
    }
    factors++;

    // Location match (15% weight)
    if (mentor['location'].toString().toLowerCase().contains(location.toLowerCase()) ||
        mentor['remote_available'] == true) {
      score += 0.15;
    }
    factors++;

    // Experience level match (10% weight)
    if (_isExperienceLevelCompatible(mentor['experience_level'], experienceLevel)) {
      score += 0.1;
    }
    factors++;

    return factors > 0 ? score : 0.0;
  }

  // Check if experience levels are compatible
  static bool _isExperienceLevelCompatible(String mentorLevel, String userLevel) {
    final levels = ['beginner', 'intermediate', 'advanced', 'expert'];
    final mentorIndex = levels.indexOf(mentorLevel);
    final userIndex = levels.indexOf(userLevel);
    
    // Mentor should be at least one level above user
    return mentorIndex > userIndex;
  }

  // Get match reasons
  static List<String> _getMatchReasons(
    Map<String, dynamic> mentor,
    String industry,
    String businessStage,
    List<String> goals,
  ) {
    final reasons = <String>[];

    if (mentor['industries'].contains(industry)) {
      reasons.add('Experience in $industry industry');
    }

    if (mentor['expertise_areas'].contains(businessStage)) {
      reasons.add('Expertise in $businessStage stage');
    }

    final mentorGoals = mentor['specializations'] as List<dynamic>;
    for (String goal in goals) {
      if (mentorGoals.any((specialization) => 
          specialization.toString().toLowerCase().contains(goal.toLowerCase()))) {
        reasons.add('Specializes in $goal');
      }
    }

    if (mentor['remote_available'] == true) {
      reasons.add('Available for remote mentoring');
    }

    return reasons;
  }

  // Request mentorship
  static Future<bool> requestMentorship(String mentorId, String message) async {
    try {
      // In a real app, this would send a request to the mentor
      await Future.delayed(const Duration(seconds: 1));
      
      // Save the request
      await _saveMentorshipRequest(mentorId, message);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting mentorship: $e');
      }
      return false;
    }
  }

  // Get mentorship requests
  static Future<List<Map<String, dynamic>>> getMentorshipRequests() async {
    final requestsJson = await StorageService.getString('mentorship_requests');
    if (requestsJson != null) {
      final List<dynamic> requestsList = json.decode(requestsJson);
      return requestsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Send message to mentor
  static Future<bool> sendMessage(String mentorId, String message) async {
    try {
      final messageData = {
        'mentor_id': mentorId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'sender': 'user',
      };

      await _saveMessage(messageData);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      return false;
    }
  }

  // Get messages with a mentor
  static Future<List<Map<String, dynamic>>> getMessages(String mentorId) async {
    final messagesJson = await StorageService.getString('$_messagesKey$mentorId');
    if (messagesJson != null) {
      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get all conversations
  static Future<List<Map<String, dynamic>>> getAllConversations() async {
    final conversationsJson = await StorageService.getString('mentor_conversations');
    if (conversationsJson != null) {
      final List<dynamic> conversationsList = json.decode(conversationsJson);
      return conversationsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Rate mentor
  static Future<bool> rateMentor(String mentorId, int rating, String review) async {
    try {
      final ratingData = {
        'mentor_id': mentorId,
        'rating': rating,
        'review': review,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _saveRating(ratingData);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error rating mentor: $e');
      }
      return false;
    }
  }

  // Get mentor ratings
  static Future<List<Map<String, dynamic>>> getMentorRatings(String mentorId) async {
    final ratingsJson = await StorageService.getString('mentor_ratings');
    if (ratingsJson != null) {
      final List<dynamic> ratingsList = json.decode(ratingsJson);
      return ratingsList.where((rating) => rating['mentor_id'] == mentorId).cast<Map<String, dynamic>>().toList();
    }
    return [];
  }

  // Get mentor profile
  static Future<Map<String, dynamic>?> getMentorProfile(String mentorId) async {
    final mentors = await getAvailableMentors();
    try {
      return mentors.firstWhere((mentor) => mentor['id'] == mentorId);
    } catch (e) {
      return null;
    }
  }

  // Save matches
  static Future<void> _saveMatches(List<Map<String, dynamic>> matches) async {
    await StorageService.setString(_matchesKey, json.encode(matches));
  }

  // Save mentorship request
  static Future<void> _saveMentorshipRequest(String mentorId, String message) async {
    final requests = await getMentorshipRequests();
    requests.add({
      'mentor_id': mentorId,
      'message': message,
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
    });
    await StorageService.setString('mentorship_requests', json.encode(requests));
  }

  // Save message
  static Future<void> _saveMessage(Map<String, dynamic> message) async {
    final mentorId = message['mentor_id'];
    final messages = await getMessages(mentorId);
    messages.add(message);
    await StorageService.setString('$_messagesKey$mentorId', json.encode(messages));
  }

  // Save rating
  static Future<void> _saveRating(Map<String, dynamic> rating) async {
    final ratingsJson = await StorageService.getString('mentor_ratings');
    List<dynamic> ratings = [];
    if (ratingsJson != null) {
      ratings = json.decode(ratingsJson);
    }
    ratings.add(rating);
    await StorageService.setString('mentor_ratings', json.encode(ratings));
  }

  // Get mock mentors data
  static List<Map<String, dynamic>> _getMockMentors() {
    return [
      {
        'id': 'mentor_1',
        'name': 'Sarah Johnson',
        'title': 'Serial Entrepreneur & VC Partner',
        'company': 'TechVentures Capital',
        'location': 'San Francisco, CA',
        'remote_available': true,
        'experience_level': 'expert',
        'industries': ['Technology', 'Fintech', 'Healthcare'],
        'expertise_areas': ['Early Stage', 'Growth Stage', 'Scaling'],
        'specializations': ['Fundraising', 'Product Strategy', 'Team Building', 'Market Expansion'],
        'bio': 'Sarah has founded 3 successful startups and now helps other entrepreneurs scale their businesses. She has 15+ years of experience in tech and has raised over \$50M in funding.',
        'rating': 4.9,
        'total_mentees': 45,
        'availability': 'Available',
        'response_time': 'Within 24 hours',
        'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
        'linkedin': 'sarah-johnson-tech',
        'twitter': '@sarahj_tech',
        'website': 'https://sarahjohnson.com',
        'hourly_rate': 200,
        'languages': ['English', 'Spanish'],
        'timezone': 'PST',
      },
      {
        'id': 'mentor_2',
        'name': 'Michael Chen',
        'title': 'Startup Advisor & Former CTO',
        'company': 'Innovation Labs',
        'location': 'New York, NY',
        'remote_available': true,
        'experience_level': 'expert',
        'industries': ['Technology', 'AI', 'SaaS'],
        'expertise_areas': ['Product Development', 'Technical Strategy', 'Early Stage'],
        'specializations': ['Technical Architecture', 'Product Management', 'Hiring', 'Technology Stack'],
        'bio': 'Michael is a former CTO of two unicorn startups and now advises early-stage companies on technical strategy and product development.',
        'rating': 4.8,
        'total_mentees': 32,
        'availability': 'Available',
        'response_time': 'Within 12 hours',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'linkedin': 'michael-chen-cto',
        'twitter': '@mchen_tech',
        'website': 'https://michaelchen.io',
        'hourly_rate': 180,
        'languages': ['English', 'Mandarin'],
        'timezone': 'EST',
      },
      {
        'id': 'mentor_3',
        'name': 'Dr. Emily Rodriguez',
        'title': 'Healthcare Innovation Expert',
        'company': 'MedTech Solutions',
        'location': 'Boston, MA',
        'remote_available': true,
        'experience_level': 'expert',
        'industries': ['Healthcare', 'MedTech', 'Biotech'],
        'expertise_areas': ['Regulatory Compliance', 'Clinical Trials', 'Product Development'],
        'specializations': ['FDA Approval', 'Clinical Research', 'Healthcare Regulations', 'Medical Devices'],
        'bio': 'Dr. Rodriguez has 20+ years in healthcare innovation and has helped numerous medtech startups navigate regulatory challenges and bring products to market.',
        'rating': 4.9,
        'total_mentees': 28,
        'availability': 'Available',
        'response_time': 'Within 48 hours',
        'avatar': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
        'linkedin': 'emily-rodriguez-md',
        'twitter': '@emily_medtech',
        'website': 'https://emilyrodriguez.com',
        'hourly_rate': 250,
        'languages': ['English', 'Spanish'],
        'timezone': 'EST',
      },
      {
        'id': 'mentor_4',
        'name': 'David Kim',
        'title': 'Marketing & Growth Expert',
        'company': 'Growth Partners',
        'location': 'Austin, TX',
        'remote_available': true,
        'experience_level': 'advanced',
        'industries': ['E-commerce', 'SaaS', 'Consumer Goods'],
        'expertise_areas': ['Marketing Strategy', 'Growth Hacking', 'Digital Marketing'],
        'specializations': ['SEO/SEM', 'Social Media', 'Content Marketing', 'Conversion Optimization'],
        'bio': 'David has helped 50+ startups achieve 10x growth through innovative marketing strategies and data-driven approaches.',
        'rating': 4.7,
        'total_mentees': 38,
        'availability': 'Available',
        'response_time': 'Within 24 hours',
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        'linkedin': 'david-kim-marketing',
        'twitter': '@david_growth',
        'website': 'https://davidkimgrowth.com',
        'hourly_rate': 150,
        'languages': ['English', 'Korean'],
        'timezone': 'CST',
      },
      {
        'id': 'mentor_5',
        'name': 'Lisa Thompson',
        'title': 'Financial Strategy Advisor',
        'company': 'Finance Forward',
        'location': 'Chicago, IL',
        'remote_available': true,
        'experience_level': 'expert',
        'industries': ['Finance', 'Fintech', 'Real Estate'],
        'expertise_areas': ['Financial Planning', 'Fundraising', 'M&A'],
        'specializations': ['Financial Modeling', 'Valuation', 'Investor Relations', 'Risk Management'],
        'bio': 'Lisa is a former investment banker with 18+ years of experience helping startups with financial strategy, fundraising, and M&A transactions.',
        'rating': 4.8,
        'total_mentees': 41,
        'availability': 'Available',
        'response_time': 'Within 36 hours',
        'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        'linkedin': 'lisa-thompson-finance',
        'twitter': '@lisa_finance',
        'website': 'https://lisathompson.com',
        'hourly_rate': 220,
        'languages': ['English'],
        'timezone': 'CST',
      },
    ];
  }

  // Get mentor statistics
  static Future<Map<String, dynamic>> getMentorStatistics() async {
    final mentors = await getAvailableMentors();
    final requests = await getMentorshipRequests();
    final conversations = await getAllConversations();

    return {
      'total_mentors': mentors.length,
      'available_mentors': mentors.where((m) => m['availability'] == 'Available').length,
      'total_requests': requests.length,
      'pending_requests': requests.where((r) => r['status'] == 'pending').length,
      'active_conversations': conversations.length,
      'average_rating': _calculateAverageRating(mentors),
      'top_industries': _getTopIndustries(mentors),
    };
  }

  static double _calculateAverageRating(List<Map<String, dynamic>> mentors) {
    if (mentors.isEmpty) return 0.0;
    double total = mentors.map((m) => m['rating'] as double).reduce((a, b) => a + b);
    return total / mentors.length;
  }

  static List<String> _getTopIndustries(List<Map<String, dynamic>> mentors) {
    final industryCount = <String, int>{};
    for (var mentor in mentors) {
      final industries = mentor['industries'] as List<dynamic>;
      for (var industry in industries) {
        industryCount[industry] = (industryCount[industry] ?? 0) + 1;
      }
    }
    
    final sorted = industryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).toList();
  }
}
