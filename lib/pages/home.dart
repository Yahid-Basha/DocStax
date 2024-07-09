import 'package:docstax/pages/account/auth_page.dart';
import 'package:docstax/pages/account/login.dart';
import 'package:docstax/pages/channels.dart';
import 'package:docstax/pages/shared_with_me_dart.dart';
import 'package:docstax/pages/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './downloads.dart';
import 'createChannel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    ChannelsPage(),
    SharedWithMePage(),
    DownloadsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(182, 238, 231, 243), // Change AppBar color
        title: const Text(
          'DocStax',
          style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(200, 78, 27,
                  112) // Change title color to contrast with AppBar color
              ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/Search.svg',
                width: 25,
                height: 25,
                color: Color.fromARGB(146, 78, 27,
                    112) // Change icon color to contrast with AppBar color
                ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SearchPage()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh, // Built-in logout icon
              size: 30, // Set the size of the icon
              color: const Color.fromARGB(146, 78, 27,
                  112), // Change icon color to contrast with AppBar color
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChannelsPage()));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout, // Built-in logout icon
              size: 25, // Set the size of the icon
              color: Color.fromARGB(146, 78, 27,
                  112), // Change icon color to contrast with AppBar color
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              // GoogleSignIn().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AuthPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Channels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Shared with Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(199, 98, 45, 134),
        onTap: _onItemTapped,
      ),
    );
  }
}