import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../pages/homePage.dart';

Client client = Client();
Account account = Account(client);

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _signup() {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: 'John Doe',
      );
      print('User created');
    } on AppwriteException catch (e) {
      print(e.message);
    } 
  }

  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;
    Account account = Account(client);
    try{
      account.createEmailSession(
        email: email,
        password: password,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  void _loginWithGoogle() {
    // Implement your login with Google logic here
  }

  @override
  Widget build(BuildContext context) {
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('65d85fad5e0e749080b7')
        .setSelfSigned(
            status:
                true); // For self signed certificates, only use for development

    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 179, 144, 240), // Set the background color to lavender
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _signup,
                  child: const Text('Signup'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _loginWithGoogle,
                  child: const Text('Signup with Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

