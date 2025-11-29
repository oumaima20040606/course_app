import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTER
  Future<String> register(String email, String password, String name, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection("users").doc(credential.user!.uid).set({
        "uid": credential.user!.uid,
        "name": name,
        "email": email,
        "role": role,
        "createdAt": DateTime.now(),
      });

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN
  Future<String> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid;   // FIX
    } catch (e) {
      return "error";
    }
  }

  // GET USER ROLE BY UID
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc['role'] ?? 'student';
      }
      return 'student';
    } catch (e) {
      return 'student';
    }
  }
}
