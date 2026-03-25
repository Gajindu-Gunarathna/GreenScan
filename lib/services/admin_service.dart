import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isAdmin(String userId) async {
    if (userId.trim().isEmpty) return false;
    // Method 1: dedicated admins collection (admins/{uid})
    final adminDoc = await _db.collection('admins').doc(userId).get();
    if (adminDoc.exists) return true;

    // Method 2: role field in users/{uid}
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;
    final role = (userDoc.data()?['role'] ?? '').toString().toLowerCase();
    return role == 'admin';
  }
}

