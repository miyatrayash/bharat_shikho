import 'package:audio_service/audio_service.dart';
import 'package:bharat_shikho/audio/audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

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
      _googleSignIn.disconnect(),
    ]);
  }
}

void audioTaskEntryPoint() async {
  print("here");

  await AudioServiceBackground.run(() => AudioPlayerTask());
}


/// Transforms string into a mm:ss format
String transformString(int seconds) {
  String minuteString =
      '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
  String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
  return '$minuteString:$secondString'; // Returns a string with the format mm:ss
}

Stream<AudioState> get audioStateStream {
  return Rx.combineLatest3<List<MediaItem>?, MediaItem?, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) => AudioState(
        queue: queue, mediaItem: mediaItem, playbackState: playbackState),
  );
}


AudioPlayer _audioPlayer = AudioPlayer();

AudioPlayer get audioPlayer => _audioPlayer;