import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';


class DownloadsPage extends StatefulWidget {
  const DownloadsPage({Key? key}) : super(key: key);

  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  Map<String, String> downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    setState(() {
      downloadedFiles = {for (var key in keys) key: prefs.getString(key)!};
    });
  }

  Future<void> _shareFile(String filePath) async {
    await Share.shareFiles([filePath]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: downloadedFiles.isEmpty
          ? Center(child: Text('No downloaded files found.'))
          : ListView.builder(
              itemCount: downloadedFiles.length,
              itemBuilder: (context, index) {
                final fileId = downloadedFiles.keys.elementAt(index);
                final filePath = downloadedFiles.values.elementAt(index);
                final fileName = filePath.split('/').last;

                return ListTile(
                  title: Text(fileName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => OpenFilex.open(filePath),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => _shareFile(filePath),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
