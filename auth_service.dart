import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get user => _auth.authStateChanges();

  // SIGN UP Method
  Future<User?> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = result.user;

      if (user != null) {
        // Week 5 Task: Store user details in Cloud Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Sign Up Error: ${e.toString()}");
      return null;
    }
  }

  // SIGN IN Method
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (e) {
      print("Sign In Error: ${e.toString()}");
      return null;
    }
  }

  // SIGN OUT Method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Sign Out Error: ${e.toString()}");
    }
  }
}
