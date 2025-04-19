import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
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

  // Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (currentUser == null) return null;
    
    final docSnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    
    if (docSnapshot.exists) {
      return docSnapshot.data();
    }
    
    return null;
  }
  
  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) throw Exception("No authenticated user found");
    
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update(data);
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}