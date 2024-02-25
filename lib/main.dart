import 'package:flutter/material.dart';
import 'pages/account/signup.dart';
import 'pages/homePage.dart';
// import 'pages/createChannel.dart';

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
        primaryColor: const Color(0xffEE5366),
        colorScheme:
            ColorScheme.fromSwatch(accentColor: const Color(0xffEE5366)),
      ),
      // home: const CreateChannel(),
      // home: const HomePage(),
      home:  SignupPage(),
    );
  }
}
