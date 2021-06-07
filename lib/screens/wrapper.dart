import 'package:bharat_shikho/screens/Home/home_screen.dart';
import 'package:bharat_shikho/screens/Login/login_screen.dart';
// import 'package:bharat_shikho/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  @override
  Widget build(BuildContext context) {

    User? user = Provider.of<User?>(context);

    if(user == null)
      return LoginScreen();

    return HomeScreen();
  }
}
