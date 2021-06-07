import 'package:bharat_shikho/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscureText = true;

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.amber,
            ),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.google,
              size: 30,
            ),
            onPressed: () async {
              final userRep = await UserRepository.instance();

              await userRep.signInWithGoogle();
            },
          ),
        ],
      ),
    );
  }
}
