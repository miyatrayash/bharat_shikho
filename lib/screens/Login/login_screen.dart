import 'package:bharat_shikho/screens/Login/SignIn/signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bharat_shikho/screens/Home/home_screen.dart';
import 'package:bharat_shikho/user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: size.height * 0.14,
              bottom: size.height * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hello, \nWelcome Back",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final userRep = await UserRepository.instance();
                          await userRep.signInWithGoogle();
                        },
                        icon: Icon(FontAwesomeIcons.google),
                      ),
                      SizedBox(width: 60),
                      SizedBox(
                        width: 60,
                      ),
                      IconButton(
                        onPressed: () {},
                        color: Colors.transparent,
                        icon: Icon(
                          Icons.alternate_email_rounded,
                          size: 40,
                          color: brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) =>
                            value!.isEmpty ? "Email can't be null" : null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      validator: (value) =>
                          value!.length < 3 ? "invalid password length" : null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off_rounded,
                            color: brightness == Brightness.light
                                ? Colors.black45
                                : Colors.white54,
                          ),
                          onPressed: _togglePasswordStatus,
                        ),
                      ),
                      obscureText: _obscureText,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Forgot Password?",
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
              Column(
                children: [
                  // ignore: deprecated_member_use
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(EdgeInsets.all(18)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final userRep = await UserRepository.instance();

                        await userRep.signInWithEmail(
                            emailController.text, passwordController.text);
                      }
                    },
                    child: Center(
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: Text("Sign up"),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
