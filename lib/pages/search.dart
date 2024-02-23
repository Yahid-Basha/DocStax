import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, String>> tilesData = [
    {
      'title': 'Product roadmap 2023',
      'subtitle': '1.2MB Shared by Alex',
      'leadingIcon': 'assets/icons/document.svg',
      'trailingIcon': 'assets/icons/right-arrow.png',
      'pdfPath': 'assets/icons/Menstrual Health Chatbot.pdf',
    },
    {
      'title': 'User Personel 2023',
      'subtitle': '1.2MB Shared by Alex',
      'leadingIcon': 'assets/icons/document.svg',
      'trailingIcon': 'assets/icons/right-arrow.png',
      'pdfPath': 'assets/icons/Menstrual Health Chatbot.pdf',
    },
    {
      'title': 'Market Research 2023',
      'subtitle': '1.2MB Shared by Alex',
      'leadingIcon': 'assets/icons/document.svg',
      'trailingIcon': 'assets/icons/right-arrow.png',
      'pdfPath': 'assets/icons/Menstrual Health Chatbot.pdf',
    },
  ];

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
    List<Widget> tiles = tilesData
        .map((tile) => buildListTile(
              context: context,
              title: tile['title']!,
              subtitle: tile['subtitle']!,
              leadingIcon: tile['leadingIcon']!,
              trailingIcon: tile['trailingIcon']!,
              pdfPath: tile['pdfPath']!,
            ))
        .toList();

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
      appBar: AppBar(
        centerTitle: true, // Center the title
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 49, 11, 75),
          ),
        ),
      ),
      body: ListView(
        children: [
          //Input search section
          searchBar(context),

          // Shared with you section
          sectionHeading(title: 'Shared With you'),

          //Shared with you tiles
          ...tiles,

          //Yours Channels Section
          sectionHeading(title: 'Your Channels'),

          //Your Channels tiles
          ...folderTiles,
        ],
      ),
    );
  }

  Padding sectionHeading({required String title}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: defaultTargetPlatform == TargetPlatform.android ? 18.0 : 20,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 49, 11, 75),
        ),
      ),
    );
  }

  Padding searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
      child: TextField(
        style: const TextStyle(
          color: Color.fromARGB(214, 78, 27, 112),
          fontSize: 20.0,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(15.0),
          labelText: 'Search files',
          labelStyle: const TextStyle(
            fontSize: 17.0,
            color: Color.fromARGB(146, 78, 27, 112),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.0),
            borderSide: BorderSide.none,
            //underline remove
          ),
          filled: true,
          fillColor: const Color.fromARGB(182, 238, 231, 243),
          prefixIcon: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(
                color: Color.fromARGB(131, 78, 27, 112),
                size: 30, // Change to your desired size
              ),
            ),
            child: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget buildListTile(
      {required String title,
      required String subtitle,
      required String leadingIcon,
      required String trailingIcon,
      required String pdfPath,
      required BuildContext context}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      leading: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(182, 243, 231, 237),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            leadingIcon,
            height: 25.0,
            width: 25.0,
            color: Color.fromARGB(131, 78, 27, 112),
          ),
        ),
      ),
      trailing: Image.asset(trailingIcon),
      onTap: () async {
        final pdfPath =
            await preparePdf('assets/icons/Menstrual Health Chatbot.pdf');

        Navigator.push(
          // Pass the appropriate context parameter to the function or method
          context,
          MaterialPageRoute(
            builder: (context) => PDFView(
              filePath: pdfPath,
            ),
          ),
        );
      },
    );
  }

  Future<String> preparePdf(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/my_file.pdf');

    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file.path;
  }
}
