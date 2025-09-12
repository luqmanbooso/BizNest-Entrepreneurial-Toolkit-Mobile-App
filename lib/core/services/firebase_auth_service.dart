import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<_FbResult> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await cred.user?.getIdToken();
      final userDoc = await _db.collection('users').doc(cred.user!.uid).get();
      final userMap = {
        'id': cred.user!.uid,
        'name': userDoc.data()?['name'] ?? cred.user!.displayName ?? 'User',
        'email': cred.user!.email,
        'avatar': userDoc.data()?['avatar'] ?? '',
        'role': userDoc.data()?['role'] ?? 'entrepreneur',
        'company': userDoc.data()?['company'] ?? '',
        'is_verified': cred.user!.emailVerified,
      };
      return _FbResult(success: true, token: token, refreshToken: null, user: userMap);
    } catch (e) {
      return _FbResult(success: false, message: e.toString());
    }
  }

  static Future<_FbResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'entrepreneur',
        'company': '',
        'created_at': DateTime.now(),
        'avatar': '',
      });
      final token = await cred.user?.getIdToken();
      return _FbResult(success: true, token: token, refreshToken: null, user: {
        'id': cred.user!.uid,
        'name': name,
        'email': email,
      });
    } catch (e) {
      return _FbResult(success: false, message: e.toString());
    }
  }
}

class _FbResult {
  final bool success;
  final String? message;
  final String? token;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  _FbResult({
    required this.success,
    this.message,
    this.token,
    this.refreshToken,
    this.user,
  });
}


