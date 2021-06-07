import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserRepository {

  static SharedPreferences? _sharedPreferences;
  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();
  static UserRepository? _instance;
  bool get isSignedIn =>  _firebaseAuth.currentUser == null;
  String? get getUser => _firebaseAuth.currentUser!.email;


  static Future<UserRepository> instance() async {
    if(_instance == null) {
      _instance = UserRepository();

      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _instance!;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);


    return _firebaseAuth.currentUser;
  }

  Future<User?> signInWithEmail(String email, String password)  async {
    UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future<User?> signUp(String email, String password)  async {
    UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
