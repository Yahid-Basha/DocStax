import 'package:docstax/pages/search.dart';
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
                  radius: 26.0,
                  backgroundImage: AssetImage(folder['imagePath']!),
                ),
                onTap: () {
                  // Navigate to folder screen
                },
              ),
            ))
        .toList();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Adjust the value as needed
          child: AppBar(
            title: const Text(
              'DocStax',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 49, 11, 75),
              ),
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Search.svg', // Replace with your SVG file path
                  width: 30,
                  height: 30,
                  color: Color.fromARGB(131, 78, 27, 112),
                ),
                onPressed: () {
                  // showSearch(context: context, delegate: DataSearch());
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context)=> const SearchPage()));
                },
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          //Your Channels tiles
          ...folderTiles,
          ...folderTiles,
          ...folderTiles,
          ...folderTiles,
        ],
      ),
 
      floatingActionButton:  FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateChannel()));
            })
    );
  }
}
