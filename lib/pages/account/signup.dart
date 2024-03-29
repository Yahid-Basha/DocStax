import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/widgets.dart';
import '../../pages/homePage.dart';
import 'package:flutter/gestures.dart';
import 'login.dart';

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
      final user = account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: 'John Doe',
      );
      user.then((value) => print(value.toMap()));
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;
    Account account = Account(client);
    try {
      final session = account.createEmailSession(
        email: email,
        password: password,
      );

      session.then((value) {
        print(value.toMap());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
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
      backgroundColor: const Color.fromARGB(255, 204, 188, 233), // Set the background color to lavender
      appBar: AppBar(
        title: const Text('Signup'),
        backgroundColor: Color.fromARGB(255, 204, 188, 233),
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
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _signup,
                  child: const Text('Signup'),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 47, 33, 243),
                  ),
                  child: const Text(
                    'Signup with Google',
                    style: TextStyle(color: Colors.amber),
                  ),
                ),
                const SizedBox(height: 10.0),
                RichText(
                  text: TextSpan(
                    text: 'Have an account? ',
                    style: const TextStyle(color: Colors.black, fontSize: 14.0),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Login',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
