import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class UserManagementService {
  static final _db = FirebaseFirestore.instance;

  /// Fetch all users from Firestore
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((doc) => {'uid': doc.id, ...doc.data()}).toList();
  }

  /// Update user role in Firestore
  static Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
  }

  /// Delete user Firestore data only
  static Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// Create a new user using a secondary FirebaseApp instance
  /// so the current admin session is not affected
  static Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // Initialize secondary app to avoid signing out current admin
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );
    } catch (_) {
      // Already initialized — reuse it
      secondaryApp = Firebase.app('SecondaryApp');
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    // Create the account
    final credential = await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // Sign out from secondary app immediately
    await secondaryAuth.signOut();

    // Save user data to Firestore
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'createdAt': Timestamp.now(),
    });
  }

  /// Get user counts by role for stats
  static Future<Map<String, int>> getUserCounts() async {
    final snap = await _db.collection('users').get();
    int admins = 0;
    int students = 0;
    for (final doc in snap.docs) {
      final role = doc.data()['role'] as String? ?? 'student';
      if (role == 'admin') {
        admins++;
      } else {
        students++;
      }
    }
    return {'admins': admins, 'students': students};
  }

  /// Stream user counts for real-time stats
  static Stream<Map<String, int>> watchUserCounts() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((snap) {
      int admins = 0;
      int students = 0;
      for (final doc in snap.docs) {
        final role = doc.data()['role'] as String? ?? 'student';
        if (role == 'admin') {
          admins++;
        } else {
          students++;
        }
      }
      return {'admins': admins, 'students': students};
    });
  }

  static Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'email': email,
      'role': role,
    });
  }
}