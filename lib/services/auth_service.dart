import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Current logged in user
  User? get currentFirebaseUser => _auth.currentUser;

  // Auth state stream — listens for login/logout
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Register ────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required String city,
    required String district,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      // Save user profile to Firestore
      final user = UserModel(
        id: uid,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        address: address.trim(),
        city: city.trim(),
        district: district,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(uid).set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Login ───────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      // Fetch user profile from Firestore
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('User profile not found. Please register again.');
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Logout ──────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Forgot password ─────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Get current user profile from Firestore ─────────────────
  Future<UserModel?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  // ── Convert Firebase errors to readable messages ─────────────
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
