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
  @override
  Widget build(BuildContext context) {
    // add floating button to create channels
    // design channel list for homepage
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
      body: const Center(
        child: Text(
          'Hello, World!',
          style: TextStyle(fontSize: 24),
        ),
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
