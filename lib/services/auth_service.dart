import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password with improved error handling
  Future signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('SignIn error details: $e');
      throw e;
    }
  }

  // Register with email and password
  Future registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String dob,
    required String bloodGroup,
  }) async {
    // Create user with email and password
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Add user data to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  // Get current user data from Firestore with improved handling for List type
  Future<Map<String, dynamic>?> getCurrentUserData() async {
  try {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = docSnapshot.data();

    if (data == null) {
      print("No data found for current user.");
      return null;
    }

    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is List && data.isNotEmpty) {
      final firstItem = data[0];
      if (firstItem is Map<String, dynamic>) {
        return firstItem;
      } else {
        print("First item is not a Map: ${firstItem.runtimeType}");
        return <String, dynamic>{};
      }
    } else {
      print("Unexpected data format: ${data.runtimeType}");
      return <String, dynamic>{};
    }
  } catch (e, stacktrace) {
    print("Error retrieving user data: $e\n$stacktrace");
    return null;
  }
}

  // Update user profile data
  Future updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) throw Exception("No authenticated user found");

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update(data);
  }

  // Password reset
  Future resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future signOut() async {
    await _auth.signOut();
  }
}