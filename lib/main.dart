import 'package:flutter/material.dart';
import 'pages/account/signup.dart';
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
      home:  SignupPage(),
    );
  }
}
