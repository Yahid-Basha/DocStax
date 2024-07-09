// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../pages/homePage.dart';
// import '../../pages/account/signup.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   void _login() async {
//     setState(() {
//       _isLoading = true;
//     });

//     String email = _emailController.text;
//     String password = _passwordController.text;

//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       print('Logging in');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomePage()),
//       );
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       // Handle login error
//       print('Login error: $e');
//     }
//   }

//   void _loginWithGoogle() {
//     // Implement your login with Google logic here
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SignupPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 204, 188, 233),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('LOGIN'),
//         backgroundColor: const Color.fromARGB(255, 204, 188, 233),
//       ),
//       body: Center(
//         child: _isLoading
//             ? CircularProgressIndicator() // Loading indicator
//             : Card(
//                 margin: const EdgeInsets.all(16.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextField(
//                         controller: _emailController,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                         ),
//                       ),
//                       const SizedBox(height: 16.0),
//                       TextField(
//                         controller: _passwordController,
//                         decoration: const InputDecoration(
//                           labelText: 'Password',
//                         ),
//                         obscureText: true,
//                       ),
//                       ElevatedButton(
//                         onPressed: _login,
//                         child: const Text('Login'),
//                       ),
//                       const SizedBox(height: 16.0),
//                       ElevatedButton(
//                         onPressed: _loginWithGoogle,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               const Color.fromARGB(255, 47, 33, 243),
//                         ),
//                         child: const Text(
//                           'Sign in with Google',
//                           style: TextStyle(color: Colors.amber),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../pages/home.dart';
import 'package:google_sign_in/google_sign_in.dart';


// import 'register.dart';
import '../../pages/account/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode? _focusNode;
  bool _loggingIn = false;
  TextEditingController? _passwordController;
  TextEditingController? _usernameController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _passwordController = TextEditingController(text: 'Qawsed1-');
    _usernameController = TextEditingController(text: '');
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loggingIn = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController!.text,
        password: _passwordController!.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _loggingIn = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text('Error'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _passwordController?.dispose();
    _usernameController?.dispose();
    super.dispose();
  }
  Future<void> _loginWithGoogle() async {
    // Implement your login with Google logic here

    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);

    if (UserCredential != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
            child: Column(
              children: [
                TextField(
                  autocorrect: false,
                  autofillHints: _loggingIn ? null : [AutofillHints.email],
                  autofocus: true,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    labelText: 'Email',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _usernameController?.clear(),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onEditingComplete: () {
                    _focusNode?.requestFocus();
                  },
                  readOnly: _loggingIn,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    autocorrect: false,
                    autofillHints: _loggingIn ? null : [AutofillHints.password],
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _passwordController?.clear(),
                      ),
                    ),
                    focusNode: _focusNode,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: true,
                    onEditingComplete: _login,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                TextButton(
                  onPressed: _loggingIn ? null : _login,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: _loggingIn
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignupPage(),
                            ),
                          );
                        },
                  child: const Text('Register'),
                ),

                TextButton(onPressed: _loginWithGoogle , child: const Text('Login with Google'))
              ],
            ),
          ),
        ),
      );
}
