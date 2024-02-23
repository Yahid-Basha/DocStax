import 'package:flutter/material.dart';
import 'pages/homePage.dart';
import 'package:appwrite/appwrite.dart';

void main() {
  Client client = Client();
  client
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('65d85fad5e0e749080b7')
    .setSelfSigned(status: true); // For self signed certificates, only use for development
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
      home: const HomePage(),
    );
  }
}
