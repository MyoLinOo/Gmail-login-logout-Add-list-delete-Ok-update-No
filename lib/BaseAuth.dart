import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BaseAuth {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final googlesingn = GoogleSignIn();

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
