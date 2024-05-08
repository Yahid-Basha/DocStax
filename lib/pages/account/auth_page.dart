import 'package:docstax/pages/account/login.dart';
import 'package:docstax/pages/account/signup.dart';
import 'package:docstax/pages/homePage.dart';
import 'package:docstax/pages/onboarding/onboardingpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // User is signed in
            if (snapshot.hasData) {
              return SignupPage();
            } 
            // User is not signed in
            else {
              return LoginPage();
            }
          },
        ),
    );
  }
}