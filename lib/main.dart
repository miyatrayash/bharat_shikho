import 'package:bharat_shikho/Theme/app_theme.dart';
import 'package:bharat_shikho/screens/Login/login_screen.dart';
import 'package:bharat_shikho/screens/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    return StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(),
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Project 1',
        theme: darkModeOn ? AppTheme.dark: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Wrapper(),
      ),
    );
  }
}
