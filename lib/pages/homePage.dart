import 'package:docstax/pages/account/auth_page.dart';
import 'package:docstax/pages/account/login.dart';
import 'package:docstax/pages/chatPage.dart';
import 'package:docstax/pages/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'createChannel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override

  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> folderData = [
    {
      'name': 'Product roadmap',
      'imagePath': 'assets/icons/profile_img.png',
      'latest': 'The roadmap.pdf'
    },
    {
      'name': 'Marketing',
      'imagePath': 'assets/icons/profile_img.png',
      'latest': 'mr.pdf'
    },
    {
      'name': 'Engineering',
      'imagePath': 'assets/icons/profile_img.png',
      'latest': 'Operating Systems.pdf'
    },
    // ... other folders
  ];
  @override
  Widget build(BuildContext context) {
    // design channel list for homepage

    List<Widget> folderTiles = folderData
        .map((folder) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ListTile(
                title: Text(
                  folder['name']!,
                ),
                subtitle: Text(
                  folder['latest']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                leading: CircleAvatar(
                  radius: 28.0,
                  backgroundImage: AssetImage(folder['imagePath']!),
                  backgroundColor: Colors.transparent,
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen()));
                },
              ),
            ))
        .toList();
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
                width: 30,
                height: 30,
                color: Color.fromARGB(146, 78, 27,
                    112) // Change icon color to contrast with AppBar color
                ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SearchPage()));
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/account.svg',
              width: 30,
              height: 30,
              // Change icon color to contrast with AppBar color
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut();
               Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AuthPage()));
            },
          ),
        ],
      ),
      body: Padding(
        // Add padding to ListView
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ...folderTiles,
            ...folderTiles,
            ...folderTiles,
            ...folderTiles,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(
            199, 98, 45, 134), // Change FloatingActionButton color

        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateChannel()));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
