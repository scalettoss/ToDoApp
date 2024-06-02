import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  static String? _userName;
  static String? _userUrl;

  static String? _userId;

  static Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _userName = googleUser.displayName;
      _userUrl = googleUser.photoUrl;
      _userId = googleUser.id;
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    _userName = null;
    _userUrl = null;
    _userId = null;
  }

  static String? get userName => _userName;
  static String? get userUrl => _userUrl;
  static String? get userId => _userId;
}