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
    } on FirebaseAuthException catch (e) {
      return _FbResult(success: false, message: _getFirebaseErrorMessage(e));
    } catch (e) {
      return _FbResult(success: false, message: 'Login failed: ${e.toString()}');
    }
  }

  static Future<_FbResult> register({
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update the display name in Firebase Auth
      await cred.user?.updateDisplayName(name);
      
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': role ?? 'entrepreneur',
        'company': '',
        'created_at': DateTime.now(),
        'avatar': '',
      });
      final token = await cred.user?.getIdToken();
      return _FbResult(success: true, token: token, refreshToken: null, user: {
        'id': cred.user!.uid,
        'name': name,
        'email': email,
        'avatar': '',
        'role': role ?? 'entrepreneur',
        'company': '',
        'is_verified': cred.user!.emailVerified,
      });
    } on FirebaseAuthException catch (e) {
      return _FbResult(success: false, message: _getFirebaseErrorMessage(e));
    } catch (e) {
      return _FbResult(success: false, message: 'Registration failed: ${e.toString()}');
    }
  }

  static Future<_FbResult> checkEmailAvailability(String email) async {
    try {
      // Try to sign in with a dummy password to check if email exists
      // This will throw an error if the email doesn't exist
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        return _FbResult(success: false, message: 'Email is already registered');
      } else {
        return _FbResult(success: true, message: 'Email is available');
      }
    } catch (e) {
      // If we get an error, assume the email is available
      return _FbResult(success: true, message: 'Email is available');
    }
  }

  static String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please try logging in instead, or use a different email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address. Please check your email format.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled. Please contact support.';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error occurred'}';
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


