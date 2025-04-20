// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Sign in with email and password with improved error handling
  Future<UserCredential> signInWithEmailAndPassword({
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
  
  // Check if user is admin
  Future<bool> isUserAdmin(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists && (userDoc.data() as Map<String, dynamic>)['isAdmin'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
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
      'isAdmin': false, // Default user is not an admin
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return userCredential;
  }
  
  // Create admin user
  Future<UserCredential> createAdminUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Create user with email and password
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Add admin data to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'isAdmin': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return userCredential;
  }
  
  // Get current user data from Firestore with improved handling
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (!docSnapshot.exists) {
        print("No data found for current user.");
        return null;
      }
      
      return docSnapshot.data();
    } catch (e, stacktrace) {
      print("Error retrieving user data: $e\n$stacktrace");
      return null;
    }
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