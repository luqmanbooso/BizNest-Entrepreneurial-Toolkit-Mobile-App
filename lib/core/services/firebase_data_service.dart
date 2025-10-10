import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class FirebaseDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // Initialize Firebase Data Service
  static Future<void> init() async {
    // Firebase is already initialized in main.dart
    print('FirebaseDataService initialized');
  }

  // Generic data operations with user-specific collections
  static Future<void> setData(
      String collection, String key, dynamic value) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _db
          .collection('users')
          .doc(currentUserId!)
          .collection(collection)
          .doc(key)
          .set({
        'data': value,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error setting data: $e');
      rethrow;
    }
  }

  static Future<dynamic> getData(String collection, String key) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final doc = await _db
          .collection('users')
          .doc(currentUserId!)
          .collection(collection)
          .doc(key)
          .get();

      if (doc.exists) {
        return doc.data()?['data'];
      }
      return null;
    } catch (e) {
      print('Error getting data: $e');
      return null;
    }
  }

  static Future<void> removeData(String collection, String key) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _db
          .collection('users')
          .doc(currentUserId!)
          .collection(collection)
          .doc(key)
          .delete();
    } catch (e) {
      print('Error removing data: $e');
      rethrow;
    }
  }

  // String operations
  static Future<void> setString(String key, String value) async {
    await setData('strings', key, value);
  }

  static Future<String?> getString(String key) async {
    return await getData('strings', key) as String?;
  }

  // JSON operations
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    await setData('json', key, json.encode(value));
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    final data = await getData('json', key);
    if (data != null && data is String) {
      try {
        return json.decode(data) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding JSON: $e');
        return null;
      }
    }
    return null;
  }

  // List operations
  static Future<void> setList(String key, List<dynamic> value) async {
    await setData('lists', key, json.encode(value));
  }

  static Future<List<dynamic>?> getList(String key) async {
    final data = await getData('lists', key);
    if (data != null && data is String) {
      try {
        return json.decode(data) as List<dynamic>;
      } catch (e) {
        print('Error decoding list: $e');
        return null;
      }
    }
    return null;
  }

  // Remove operations
  static Future<void> remove(String key) async {
    // Try to remove from all collections
    await removeData('strings', key);
    await removeData('json', key);
    await removeData('lists', key);
  }

  // Batch operations for better performance
  static Future<void> setMultipleData(Map<String, dynamic> data) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final batch = _db.batch();

    data.forEach((key, value) {
      final docRef = _db
          .collection('users')
          .doc(currentUserId!)
          .collection('data')
          .doc(key);

      batch.set(docRef, {
        'data': value,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
  }

  // Get all user data for a collection
  static Future<Map<String, dynamic>> getAllData(String collection) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(currentUserId!)
          .collection(collection)
          .get();

      final data = <String, dynamic>{};
      for (final doc in querySnapshot.docs) {
        data[doc.id] = doc.data()['data'];
      }

      return data;
    } catch (e) {
      print('Error getting all data: $e');
      return {};
    }
  }

  // Clear all user data (useful for logout)
  static Future<void> clearAllUserData() async {
    if (currentUserId == null) return;

    try {
      final collections = ['strings', 'json', 'lists', 'data'];

      for (final collection in collections) {
        final querySnapshot = await _db
            .collection('users')
            .doc(currentUserId!)
            .collection(collection)
            .get();

        final batch = _db.batch();
        for (final doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }
}
