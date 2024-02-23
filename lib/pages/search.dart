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
      'pdfPath': 'assets/pdf/Menstrual Health Chatbot.pdf',
    },
    {
      'title': 'User Personel 2023',
      'subtitle': '1.2MB Shared by Alex',
      'leadingIcon': 'assets/icons/document.svg',
      'trailingIcon': 'assets/icons/right-arrow.png',
      'pdfPath': 'assets/pdf/Menstrual Health Chatbot.pdf',
    },
    {
      'title': 'Market Research 2023',
      'subtitle': '1.2MB Shared by Alex',
      'leadingIcon': 'assets/icons/document.svg',
      'trailingIcon': 'assets/icons/right-arrow.png',
      'pdfPath': 'assets/pdf/Menstrual Health Chatbot.pdf',
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
          searchBar(context, tilesData, folderData),

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

  Padding searchBar(BuildContext context, List<Map<String, String>> tilesData,
      List<Map<String, String>> folderData) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
      child: GestureDetector(
        onTap: () {
          showSearch(
            context: context,
            delegate: DataSearch(tilesData: tilesData, folderData: folderData),
          );
        },
        child: AbsorbPointer(
          child: TextField(
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
              ),
              filled: true,
              fillColor: const Color.fromARGB(182, 238, 231, 243),
              prefixIcon: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: const IconThemeData(
                    color: Color.fromARGB(131, 78, 27, 112),
                    size: 30,
                  ),
                ),
                child: const Icon(Icons.search),
              ),
            ),
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
            await preparePdf('assets/pdf/Menstrual Health Chatbot.pdf');

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

class DataSearch extends SearchDelegate<String> {
  final List<Map<String, String>> tilesData;
  final List<Map<String, String>> folderData;

  DataSearch({required this.tilesData, required this.folderData});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = tilesData
        .where((tile) =>
            tile['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..addAll(folderData
          .where((folder) =>
              folder['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList());

    return results.isEmpty
        ? Center(child: Text('No results found'))
        : ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(results[index]['title'] ?? results[index]['name']!),
                subtitle: Text(results[index]['subtitle'] ?? ''),
                onTap: () {
                  // Handle tap
                },
              );
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = tilesData
        .where((tile) =>
            tile['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..addAll(folderData
          .where((folder) =>
              folder['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList());

    return suggestions.isEmpty
        ? Center(child: Text('No results found'))
        : ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              var suggestion =
                  suggestions[index]['title'] ?? suggestions[index]['name']!;
              var queryIndex =
                  suggestion.toLowerCase().indexOf(query.toLowerCase());
              return ListTile(
                title: RichText(
                  text: TextSpan(
                    text: suggestion.substring(0, queryIndex),
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: suggestion.substring(
                            queryIndex, queryIndex + query.length),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: suggestion.substring(queryIndex + query.length),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(suggestions[index]['subtitle'] ?? ''),
                onTap: () {
                  query = suggestion;
                  showResults(context);
                },
              );
            },
          );
  }
}
