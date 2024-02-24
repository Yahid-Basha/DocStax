import 'package:flutter/material.dart';

// import 'pages/account/signup.dart';
// import 'pages/homePage.dart';
//TODO: from now it is Onboarding page
import 'pages/onboarding/onboardingpage.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Docstax',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // home: const HomePage(),
//       home:  SignupPage(),
      home:  OnboardingPage(),
    );
  }
}
